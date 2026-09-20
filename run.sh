#!/usr/bin/env bash
# =============================================================================
# VICTO STORE — harnais autonome
# Aucune action humaine entre les tickets.
#
# Par ticket :
#   1. branche auto/<id> partant de main
#   2. appel Aider non interactif (timeout dur)
#   3. porte de qualité : tsc --noEmit ET npm test
#   4. rouge -> on renvoie la sortie brute au modèle (max 3 tentatives)
#   5. vert  -> merge --no-ff dans main.  calé -> la branche reste isolée.
#
# Sortie : VERT / CALÉ / TIMEOUT / TRICHE  par ticket.
# =============================================================================
set -uo pipefail

# ------------------------------------------------------------------- réglages
REPO="${REPO:-$PWD}"
MODEL="${MODEL:-ollama_chat/qwen3-coder-ctx}"
MANIFEST="${MANIFEST:-tickets/manifest.tsv}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # plafond de réflexions, en dur
AIDER_TIMEOUT="${AIDER_TIMEOUT:-2400}" # 40 min par appel (CPU : ~14 tok/s)
GIT_REMOTE="${GIT_REMOTE:-origin}"    # vide ("") = aucun push
RUN_BUILD="${RUN_BUILD:-1}"           # 0 = sauter npm run build dans la porte


export OLLAMA_API_BASE="${OLLAMA_API_BASE:-http://192.168.40.30:11434}"
export AIDER_NO_ANALYTICS=1

cd "$REPO" || { echo "Dépôt introuvable : $REPO"; exit 2; }
RUN_ID="$(date +%Y%m%d-%H%M%S)"
LOGDIR=".logs/$RUN_ID"
mkdir -p "$LOGDIR"

log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOGDIR/run.log"; }
fail() { log "FATAL: $*"; exit 2; }

# ------------------------------------------------------------ pré-vérifications
command -v aider >/dev/null || fail "aider absent du PATH (pipx ensurepath + ~/.bashrc)"
command -v git   >/dev/null || fail "git absent"
[ -f "$MANIFEST" ] || fail "manifeste introuvable : $MANIFEST"
[ -f ".aider.model.settings.yml" ] || fail ".aider.model.settings.yml manquant (num_ctx → reload à froid)"

if ! git diff --quiet || ! git diff --cached --quiet; then
  fail "arbre de travail sale — commit ou stash avant de lancer le harnais"
fi

if ! curl -sf --max-time 5 "$OLLAMA_API_BASE/api/tags" >/dev/null; then
  fail "Ollama injoignable sur $OLLAMA_API_BASE"
fi
log "Ollama OK sur $OLLAMA_API_BASE — modèle : $MODEL"

# Le push doit être non interactif (clé SSH sans passphrase ou credential store),
# sinon le harnais resterait bloqué sur une demande de mot de passe.
if [ -n "$GIT_REMOTE" ]; then
  if ! git remote get-url "$GIT_REMOTE" >/dev/null 2>&1; then
    log "AVERTISSEMENT : remote '$GIT_REMOTE' inexistant — push désactivé"
    GIT_REMOTE=""
  elif ! GIT_TERMINAL_PROMPT=0 git ls-remote --exit-code "$GIT_REMOTE" >/dev/null 2>&1; then
    fail "remote '$GIT_REMOTE' injoignable ou demande une authentification interactive"
  else
    log "Remote OK : $(git remote get-url "$GIT_REMOTE")"
  fi
else
  log "Push distant désactivé (GIT_REMOTE vide)"
fi

git checkout -q main || fail "branche main introuvable"

# ------------------------------------------------------ porte de qualité
# 0 = vert. Toute la sortie va dans le log passé en $1.
run_gate() {
  local log="$1"
  : > "$log"
  echo "===== tsc --noEmit =====" >> "$log"
  if ! npm run --silent typecheck >> "$log" 2>&1; then return 1; fi
  printf '\n===== vitest run =====\n' >> "$log"
  if ! npm run --silent test >> "$log" 2>&1; then return 1; fi
  # Troisième barreau : l'application doit CONSTRUIRE. Sans lui, un projet peut
  # être vert partout et ne rien afficher (config PostCSS absente, import mort,
  # composant serveur invalide). C'est le seul contrôle qui voit la vraie appli.
  if [ "$RUN_BUILD" = "1" ] && grep -q '"build"' package.json; then
    printf '\n===== npm run build =====\n' >> "$log"
    if ! npm run --silent build >> "$log" 2>&1; then return 1; fi
  fi
  return 0
}

# Une erreur tsc qui pointe un fichier de tests/ SANS jamais nommer le fichier
# cible est impossible à corriger par le modèle : il n'a pas le droit d'y toucher.
# Inutile de brûler trois tentatives, on nomme le coupable tout de suite.
gate_accuse_les_tests() {
  local log="$1" cible="$2"
  grep -qE '^tests/[^ ]+\([0-9]+,[0-9]+\): error' "$log" || return 1
  grep -q "$cible" "$log" && return 1
  return 0
}

# Un ticket dont les tests importent un module absent de main et différent de sa
# propre cible dépend d'un ticket qui a calé : il échouera à coup sûr.
ticket_bloque() {
  local test_src="$1" cible="$2" imp chemin
  [ -f "$test_src" ] || return 1
  while read -r imp; do
    chemin="$(printf '%s' "$imp" | sed -E "s|.*from '\.\./||; s|'.*||")"
    case "$chemin" in
      "${cible%.*}"|"$cible") continue ;;
    esac
    if [ ! -e "$chemin.ts" ] && [ ! -e "$chemin.tsx" ] && [ ! -e "$chemin" ]; then
      echo "$chemin"; return 0
    fi
  done <<EOF
$(grep -oE "from '\.\./[^']+'" "$test_src" | sort -u)
EOF
  return 1
}

# ------------------------------------------------------------------ exécution
declare -a IDS=() STATUSES=() ATTEMPTS=()

while IFS=$'\t' read -r ID TARGET TESTFILE SPEC EXTRA || [ -n "${ID:-}" ]; do
  EXTRA="${EXTRA:-}"
  [ -z "${ID:-}" ] && continue
  case "$ID" in \#*) continue ;; esac

  BRANCH="auto/$ID"
  log "──────────────────────────────────────────────────────────────"
  log "TICKET $ID  →  $TARGET   (tests : $TESTFILE)"

  PENDING="tickets/tests/$(basename "$TESTFILE")"

  [ -f "$SPEC" ] || { log "spec introuvable : $SPEC"; IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue; }
  if [ ! -f "$PENDING" ] && [ ! -f "$TESTFILE" ]; then
    log "tests introuvables : ni $PENDING ni $TESTFILE"
    IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue
  fi

  git checkout -q main
  git branch -q -D "$BRANCH" 2>/dev/null
  git checkout -q -b "$BRANCH"

  # Activation des tests du ticket : ils quittent la zone d'attente pour entrer
  # dans le périmètre de la porte. Un ticket ne voit donc que ses propres tests
  # et ceux des tickets déjà fusionnés — jamais ceux des tickets à venir.
  if [ -f "$PENDING" ]; then
    mkdir -p "$(dirname "$TESTFILE")"
    cp "$PENDING" "$TESTFILE"
    git add "$TESTFILE"
    git diff --cached --quiet || git commit -q -m "test($ID): activation des tests par le harnais"
    log "  tests activés : $PENDING → $TESTFILE"
  fi
  TEST_BASE="$(git rev-parse HEAD)"   # référence anti-triche

  # Dépendance manquante : on saute sans appeler le modèle.
  if manque="$(ticket_bloque "$PENDING" "$TARGET")"; then
    log "  BLOQUÉ : $manque est absent de main (ticket amont calé)"
    git checkout -q --force main
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi

  # Contexte en lecture seule : les types et composants que le ticket consomme.
  # Sans ça le modèle devine les noms de champs — c'est l'origine des deux seules
  # erreurs réelles du modèle lors du premier build (image/imageUrl, badge en prop).
  READS=(--read "$TESTFILE")
  if [ -n "$EXTRA" ]; then
    OLDIFS="$IFS"; IFS=','
    for ctx in $EXTRA; do
      [ -f "$ctx" ] && READS+=(--read "$ctx")
    done
    IFS="$OLDIFS"
    log "  contexte : $EXTRA"
  fi

  MSG="$(cat "$SPEC")"
  STATUS="CALÉ"
  attempt=1
  used=0

  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    log "  tentative $attempt/$MAX_ATTEMPTS — appel du modèle…"
    timeout --signal=TERM --kill-after=60 "$AIDER_TIMEOUT" \
      aider \
        --model "$MODEL" \
        --edit-format whole \
        --yes-always \
        --no-auto-test \
        --no-stream \
        --no-check-update \
        --no-show-model-warnings \
        "${READS[@]}" \
        --file "$TARGET" \
        --message "$MSG" \
        >> "$LOGDIR/$ID.aider.log" 2>&1 < /dev/null
    rc=$?
    used="$attempt"

    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
      log "  TIMEOUT après ${AIDER_TIMEOUT}s"
      STATUS="TIMEOUT"; break
    fi

    # Garde-fou anti-triche : les tests sont passés en --read. On compare au
    # commit d'activation, pas à main, puisque c'est le harnais qui les a posés.
    if ! git diff --quiet "$TEST_BASE" HEAD -- "$TESTFILE"; then
      log "  TRICHE : le fichier de test a été modifié sur la branche"
      STATUS="TRICHE"; break
    fi

    GATELOG="$LOGDIR/$ID.gate.$attempt.log"
    if run_gate "$GATELOG"; then
      log "  porte VERTE"
      STATUS="VERT"; break
    fi

    if gate_accuse_les_tests "$GATELOG" "$TARGET"; then
      log "  TEST_SUSPECT : tsc n'accuse que des fichiers de tests, le modèle ne peut rien corriger"
      STATUS="TEST_SUSPECT"; break
    fi

    log "  porte ROUGE — renvoi de la sortie brute au modèle"
    MSG="La porte de qualité a échoué (tsc --noEmit puis vitest run).
Corrige UNIQUEMENT le code applicatif dans $TARGET.
N'écris pas, ne modifie pas, ne contourne pas les tests : ils font foi.
Sortie brute :

$(tail -n 120 "$GATELOG")"
    attempt=$((attempt + 1))
  done

  if [ "$STATUS" = "VERT" ]; then
    npm run --silent lint:fix >/dev/null 2>&1   # optionnel, après le vert
    git add -A
    git diff --cached --quiet || git commit -q -m "chore($ID): formatage post-porte"
    git checkout -q main
    git merge --no-ff -q "$BRANCH" -m "feat($ID): fusionné au vert par le harnais"
    log "  fusionné dans main"
    if [ -n "$GIT_REMOTE" ]; then
      if GIT_TERMINAL_PROMPT=0 git push -q "$GIT_REMOTE" main 2>>"$LOGDIR/$ID.git.log"; then
        log "  poussé sur $GIT_REMOTE/main"
      else
        log "  AVERTISSEMENT : push de main échoué (voir $LOGDIR/$ID.git.log)"
      fi
    fi
  else
    git checkout -q --force main
    log "  laissé isolé sur $BRANCH — main est intact"
    # On pousse quand même la branche calée : elle est relisible depuis le laptop.
    if [ -n "$GIT_REMOTE" ]; then
      GIT_TERMINAL_PROMPT=0 git push -q --force "$GIT_REMOTE" "$BRANCH" \
        2>>"$LOGDIR/$ID.git.log" && log "  branche calée poussée sur $GIT_REMOTE/$BRANCH"
    fi
  fi

  IDS+=("$ID"); STATUSES+=("$STATUS"); ATTEMPTS+=("$used")
done < "$MANIFEST"

# -------------------------------------------------------------------- rapport
echo | tee -a "$LOGDIR/run.log"
log "═══════════════ RAPPORT  ($RUN_ID) ═══════════════"
exit_code=0
i=0
while [ "$i" -lt "${#IDS[@]}" ]; do
  printf '  %-12s %-8s (tentatives : %s)\n' "${IDS[$i]}" "${STATUSES[$i]}" "${ATTEMPTS[$i]}" \
    | tee -a "$LOGDIR/run.log"
  [ "${STATUSES[$i]}" = "VERT" ] || exit_code=1
  i=$((i + 1))
done
log "logs : $LOGDIR"
log "main : $(git rev-parse --short HEAD) — $(git log -1 --pretty=%s)"

# Porte finale : l'état fusionné de main doit tenir debout dans son ensemble.
git checkout -q main
if run_gate "$LOGDIR/final.gate.log"; then
  log "PORTE FINALE VERTE sur main"
else
  log "PORTE FINALE ROUGE sur main — voir $LOGDIR/final.gate.log"
  exit_code=1
fi
exit "$exit_code"
