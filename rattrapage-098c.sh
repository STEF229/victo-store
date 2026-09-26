#!/usr/bin/env bash
# VICTO STORE — rattrapage du 098c (compteur de l'en-tête) et des tickets qui en dépendent.
#
# Cause : la spec disait « cartCount sans valeur par défaut » ; le modèle a rendu la
# prop obligatoire (cartCount: number). Tout le reste de son travail était juste.
#   • spec 098c : « cartCount?: number; » reste tel quel, seul « = 0 » disparaît ;
#     le test le vérifie explicitement.
#   • run.sh : TEST_SUSPECT seulement si tsc n'accuse que le test du ticket. Des tests
#     déjà verts cassés par la cible déclenchent une relance, en le disant au modèle.
#   • /design garde son compteur de démonstration : ticket 098e2 retiré.
#   • tickets 098e : le test vérifie l'absence de « cartCount={ », pas du mot entier.
# Usage :  cd ~/victo-store && bash rattrapage-098c.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
SHA_RUN_V4=21e2e220ce41ccfa295f31ad3013a4f6c8b381fb774e6901b6f3dc88bfd545de
SHA_RUN_V3=0b703208bbc93e9c1474fa5b6f767da5fbf3142012b1880b1731ca1d45fac328
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ état attendu
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 098a 098b 098d; do fusionne "$d" || mort "$d n'est pas fusionné : ce rattrapage suppose le run du 26 septembre"; done
fusionne 098c && mort "098c est déjà fusionné : rien à rattraper"
[ -f tickets/manifest-098.tsv ] || mort "tickets/manifest-098.tsv absent"
case "$(sha256sum run.sh | cut -d' ' -f1)" in
  "$SHA_RUN_V3"|"$SHA_RUN_V4") ;;
  *) mort "run.sh diffère des versions connues (lot v3, ce rattrapage) : je ne l'écrase pas sans savoir ce qui a changé" ;;
esac
grep -q 'cartCount?: number' src/components/ui/SiteHeader.tsx || mort "SiteHeader.tsx sur main n'a pas « cartCount?: number » : la spec corrigée ne s'appliquerait pas"
ok "098a, 098b, 098d fusionnés ; run.sh et en-tête conformes"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
cat > tickets/098c-entete-compteur.md <<'__VICTO_FIN_0__'
TICKET 098c — compteur de l'en-tête branché sur le panier

Modifie `src/components/ui/SiteHeader.tsx`. Le fichier actuel est correct et
testé : tu ne changes que ce qui est décrit ici.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ne change aucune classe, aucun texte, aucun `data-testid`, aucun `aria-*`, aucun
  autre import, aucune autre prop.

## Les cinq changements
1. **Première ligne** du fichier : `'use client';`. Si elle y est déjà, ne la
   double pas.
2. **Ajoute** cet import, à la suite des imports existants :
   ```tsx
   import { usePanier } from '@/components/panier/PanierProvider';
   ```
3. **Type des props : ne le touche pas.** La ligne `cartCount?: number;` reste
   **exactement** ainsi, point d'interrogation compris : la prop reste
   **facultative**. Beaucoup de pages et de tests affichent l'en-tête sans elle ;
   la rendre obligatoire casserait tout le projet.
   **Paramètres de la fonction** : si la déstructuration donne une valeur par
   défaut à `cartCount` (par exemple `cartCount = 0`), écris seulement `cartCount`,
   sans `= 0`. Rien d'autre ne change dans la signature.
4. **Au début du corps** de `SiteHeader`, avant tout autre code, ajoute exactement :
   ```tsx
   const { nombre } = usePanier();
   const compte = cartCount ?? nombre;
   ```
   puis, **dans tout le reste du composant**, remplace chaque utilisation de
   `cartCount` par `compte`. Après ce changement, `cartCount` n'apparaît plus que
   dans la signature et dans la ligne `const compte = cartCount ?? nombre;`.
5. L'élément `data-testid="entete-panier-compte"` n'est rendu **que si
   `compte > 0`** : `{compte > 0 && ( … )}` autour de lui. Un panier vide
   n'affiche pas de pastille « 0 ».

Ainsi une valeur passée explicitement l'emporte (les tests existants passent
`cartCount={2}`), et sans elle l'en-tête affiche le nombre d'articles du panier.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/entete-v3.test.tsx` (comportement existant) et `tests/entete-compteur.test.tsx`.
__VICTO_FIN_0__
cat > tickets/tests/entete-compteur.test.tsx <<'__VICTO_FIN_1__'
import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';
import { CLE_PANIER } from '../src/lib/panier';

const NAV: NavItem[] = [{ label: 'Femme', href: '/femme' }];
const remplir = (quantites: number[]) =>
  window.localStorage.setItem(
    CLE_PANIER,
    JSON.stringify(quantites.map((q, i) => ({ slug: `p${i}`, sku: `p${i}-41`, quantite: q }))),
  );

beforeEach(() => window.localStorage.clear());

describe('en-tête — compteur du panier', () => {
  it('affiche le nombre d’articles du panier', () => {
    remplir([2, 1]);
    render(<PanierProvider><SiteHeader navItems={NAV} /></PanierProvider>);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('3');
  });

  it('n’affiche aucune pastille pour un panier vide', () => {
    render(<PanierProvider><SiteHeader navItems={NAV} /></PanierProvider>);
    expect(screen.queryByTestId('entete-panier-compte')).toBeNull();
    expect(screen.getByTestId('entete-panier')).toBeInTheDocument();
  });

  it('laisse une valeur explicite l’emporter', () => {
    remplir([2, 1]);
    render(<PanierProvider><SiteHeader navItems={NAV} cartCount={5} /></PanierProvider>);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('5');
  });
});

describe('en-tête — source', () => {
  const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');

  it('est un composant client branché sur usePanier', () => {
    expect(source.trimStart().startsWith("'use client'")).toBe(true);
    expect(source).toContain("import { usePanier } from '@/components/panier/PanierProvider';");
    expect(source).toContain('const compte = cartCount ?? nombre;');
  });

  it('garde cartCount facultatif, sans valeur par défaut', () => {
    expect(source).toMatch(/cartCount\?:\s*number/);
    expect(source).not.toMatch(/cartCount\s*=\s*[^=]/);
  });
});
__VICTO_FIN_1__
cat > run.sh <<'__VICTO_FIN_2__'
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
# Manifeste TSV : id  cible  tests  spec  [contexte]  [dépend_de]  [mode]
#   contexte  : fichiers en lecture seule, séparés par des virgules
#   dépend_de : ids de tickets, séparés par des virgules. Si l'un d'eux n'a pas
#               été fusionné dans main par le harnais, le ticket est BLOQUÉ sans
#               appel au modèle — et, n'étant pas fusionné, bloque à son tour
#               ceux qui dépendent de lui (cascade).
#   mode      : « neuf » = la cible est vidée sur la branche avant le premier
#               appel. Le modèle l'écrit d'après la spec seule, sans relire
#               l'ancienne version : sur CPU, lire un jeton coûte autant
#               qu'en écrire un.
#
# Budget : avant d'appeler le modèle, le harnais estime entrée + sortie en
# jetons. Au-delà de 90 % de num_ctx, le ticket est TROP_GROS, en quelques
# secondes au lieu de 40 minutes de TIMEOUT (ticket 095 : 14 062 jetons en
# entrée, fenêtre saturée, moitié du prompt jetée).
#
# Sortie : VERT / CALÉ / TIMEOUT / TRICHE / BLOQUÉ / TEST_SUSPECT / TROP_GROS.
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

# Aider coupe par défaut un appel au modèle après 600 s puis le relance depuis
# zéro : un gros fichier généré sur CPU n'aboutit alors jamais. On aligne son
# délai sur celui du harnais, seulement si cette version d'Aider connaît l'option.
AIDER_DELAI=()
if aider --help 2>/dev/null | grep -q -- '--timeout'; then
  AIDER_DELAI=(--timeout "$((AIDER_TIMEOUT - 120))")
fi
# Le lint automatique d'Aider relance le modèle avec tout le contexte dès qu'un
# fichier ne se lit pas : un deuxième prompt complet, à ~12 jetons/s. La porte du
# harnais fait déjà ce travail, avec la spec. On le coupe si l'option existe.
if aider --help 2>/dev/null | grep -q -- '--auto-lint'; then
  AIDER_DELAI+=(--no-auto-lint)
fi

# Budget de contexte. CAR_PAR_JETON et SURCOUT_AIDER sont calibrés sur le 095 :
# 36 000 caractères de fichiers → 14 062 jetons observés dans le journal d'Ollama.
NUM_CTX="$(grep -oE 'num_ctx["]?:[[:space:]]*[0-9]+' .aider.model.settings.yml 2>/dev/null | grep -oE '[0-9]+$' | head -1)"
NUM_CTX="${NUM_CTX:-16384}"
CAR_PAR_JETON=3
SURCOUT_AIDER=2000
BUDGET_MAX=$((NUM_CTX * 90 / 100))

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
# Imports du fichier cible qui ne pointent vers aucun fichier réel.
# Le modèle n'a le droit de créer que sa cible : un module qu'il importe sans
# qu'il existe n'existera jamais. C'est la cause des échecs d'assemblage 021 et 061.
imports_inventes() {
  local f="$1" spec base ext
  [ -f "$f" ] || return 0
  grep -oE "from ['\"][^'\"]+['\"]" "$f" | sed -E "s/^from ['\"]//; s/['\"]$//" | sort -u |
  while read -r spec; do
    case "$spec" in
      @/*)       base="src/${spec#@/}" ;;
      ./*|../*)  base="$(dirname "$f")/$spec" ;;
      *)         continue ;;
    esac
    for ext in "" .ts .tsx /index.ts /index.tsx; do
      [ -f "$base$ext" ] && continue 2
    done
    echo "$spec"
  done
}

modules_existants() {
  find src -type f \( -name '*.ts' -o -name '*.tsx' \) ! -name '*.d.ts' ! -path 'src/app/*' |
    sed -E 's#^src/#@/#; s#\.(tsx|ts)$##' | sort
}

# Déclarations de types de tout le projet : un résumé exact des exports et des
# props, sans le code. Compact et toujours conforme à ce que le modèle a écrit.
DECL=".logs/decl"
generer_declarations() {
  rm -rf "$DECL"
  npx --no-install tsc -p tsconfig.json --noEmit false --declaration \
    --emitDeclarationOnly --outDir "$DECL" >/dev/null 2>&1 || true
}

# Ne renvoie au modèle que ce qui échoue : les erreurs TypeScript, sinon les
# assertions vitest en échec, sinon la fin du journal (erreur de build).
erreurs_utiles() {
  local log="$1" r
  r="$(grep -E 'error TS[0-9]+' "$log" | head -40)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  r="$(grep -E '×|FAIL |AssertionError|Expected|Received|^[[:space:]]*[-+] |→ ' "$log" | grep -v '✓' | head -60)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  tail -n 60 "$log"
}

# TEST_SUSPECT seulement si tsc n'accuse QUE le test propre au ticket. Si des tests
# déjà verts sur main ne compilent plus, c'est la cible qui les a cassés (098c :
# une prop devenue obligatoire) : c'est au modèle de corriger, on relance.
gate_accuse_les_tests() {
  local log="$1" cible="$2" propre="$3"
  grep -qE '^tests/[^ ]+\([0-9]+,[0-9]+\): error' "$log" || return 1
  grep -q "$cible" "$log" && return 1
  grep -oE '^tests/[^(]+' "$log" | sort -u | grep -vxF "$propre" | grep -q . && return 1
  return 0
}

# Vrai si tsc n'accuse que des fichiers de tests : la cible compile, mais casse
# des tests existants. Le message de relance doit alors le dire au modèle.
erreurs_dans_tests_seulement() {
  local log="$1"
  grep -qE '^tests/[^ ]+\([0-9]+,[0-9]+\): error' "$log" || return 1
  grep -E 'error TS[0-9]+' "$log" | grep -qvE '^tests/' && return 1
  return 0
}

# Première dépendance déclarée (6ᵉ colonne) qui n'a pas été fusionnée dans main.
# Critère unique : le commit de fusion que le harnais écrit au vert. Il vaut
# d'un run à l'autre, sans état à conserver.
dependance_absente() {
  local deps="$1" d IFS=','
  [ -n "$deps" ] || return 1
  for d in $deps; do
    d="${d//[[:space:]]/}"
    [ -n "$d" ] || continue
    if [ -z "$(git log main -1 --format=%h --fixed-strings --grep="feat($d): fusionné")" ]; then
      echo "$d"; return 0
    fi
  done
  return 1
}

# Estimation « entree sortie » en jetons. Entrée : spec + fichiers en lecture
# seule + cible actuelle. Sortie : « Taille attendue : ~N lignes » si la spec le
# dit (40 caractères par ligne), sinon la taille actuelle de la cible + 10 %.
budget_ticket() {
  local spec="$1" cible="$2"; shift 2
  local car=0 f n sortie=0
  for f in "$spec" "$@" "$cible"; do
    [ -f "$f" ] && car=$((car + $(wc -m < "$f")))
  done
  n="$(grep -oE 'Taille attendue : ~?[0-9]+ lignes' "$spec" | grep -oE '[0-9]+' | head -1)"
  if [ -n "$n" ]; then sortie=$((n * 40 / CAR_PAR_JETON))
  elif [ -f "$cible" ]; then sortie=$(( $(wc -m < "$cible") * 11 / 10 / CAR_PAR_JETON ))
  fi
  echo "$((car / CAR_PAR_JETON + SURCOUT_AIDER)) $sortie"
}

# Empreinte d'un échec : les lignes renvoyées au modèle, sans couleurs ni durées.
# Deux empreintes égales d'affilée = la tentative suivante n'y changera rien.
empreinte_echec() {
  local esc=$'\x1b'
  erreurs_utiles "$1" |
    sed -E -e "s/${esc}\[[0-9;]*m//g" -e 's/[0-9]+([.,][0-9]+)? ?ms\b//g' -e 's/[[:space:]]+$//' |
    sort -u | md5sum | cut -d' ' -f1
}

# Un ticket dont les tests importent un module absent de main et différent de sa
# propre cible dépend d'un ticket qui a calé : il échouera à coup sûr.
ticket_bloque() {
  local test_src="$1" cible="$2" imp chemin
  [ -f "$test_src" ] || return 1
  while read -r imp; do
    [ -n "$imp" ] || continue   # test sans import relatif : rien à vérifier
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

while IFS= read -r LIGNE || [ -n "${LIGNE:-}" ]; do
  # Découpage sur un séparateur non blanc : avec IFS=tabulation, bash fusionne
  # deux tabulations consécutives et une colonne vide décalerait les suivantes.
  LIGNE="${LIGNE%$'\r'}"
  ID="" TARGET="" TESTFILE="" SPEC="" EXTRA="" DEPS="" MODE=""
  IFS=$'\x1f' read -r ID TARGET TESTFILE SPEC EXTRA DEPS MODE <<< "${LIGNE//$'\t'/$'\x1f'}"
  MODE="${MODE//[[:space:]]/}"
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

  # Dépendance déclarée non fusionnée : on saute avant même de créer la branche.
  if manque="$(dependance_absente "$DEPS")"; then
    log "  BLOQUÉ : dépend du ticket $manque, qui n'est pas fusionné dans main"
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi
  [ -n "$DEPS" ] && log "  dépendances fusionnées : $DEPS"

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
  # Mode « neuf » : la cible est vidée sur la branche, main n'est pas touché.
  if [ "$MODE" = "neuf" ]; then
    mkdir -p "$(dirname "$TARGET")"
    : > "$TARGET"
    git add "$TARGET"
    git diff --cached --quiet || git commit -q -m "chore($ID): cible vidée pour une réécriture complète"
    log "  mode neuf : $TARGET vidé sur la branche"
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
    generer_declarations
    OLDIFS="$IFS"; IFS=','
    for ctx in $EXTRA; do
      decl="$DECL/${ctx%.*}.d.ts"
      if [ -f "$decl" ]; then READS+=(--read "$decl")
      elif [ -f "$ctx" ]; then READS+=(--read "$ctx")
      fi
    done
    IFS="$OLDIFS"
    log "  contexte (déclarations de types) : $EXTRA"
  fi

  # Budget : la cible (vidée en mode neuf) et tout ce qu'Aider lira.
  LUS=()
  for ((k = 1; k < ${#READS[@]}; k += 2)); do LUS+=("${READS[$k]}"); done
  read -r B_ENTREE B_SORTIE <<< "$(budget_ticket "$SPEC" "$TARGET" "${LUS[@]}")"
  log "  budget : ≈ $B_ENTREE jetons lus + $B_SORTIE écrits = $((B_ENTREE + B_SORTIE)) / $NUM_CTX (plafond $BUDGET_MAX)"
  if [ $((B_ENTREE + B_SORTIE)) -gt "$BUDGET_MAX" ]; then
    log "  TROP_GROS : le ticket saturerait la fenêtre du modèle — découper la spec ou passer en mode neuf"
    git checkout -q --force main
    IDS+=("$ID"); STATUSES+=("TROP_GROS"); ATTEMPTS+=(0)
    continue
  fi

  MSG="$(cat "$SPEC")"
  STATUS="CALÉ"
  attempt=1
  used=0
  EMPREINTE_PREC=""

  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    # Une relance relit la spec, les échecs ET la cible déjà écrite : on refait le compte.
    if [ "$attempt" -gt 1 ]; then
      printf '%s\n' "$MSG" > "$LOGDIR/$ID.message.$attempt.txt"
      read -r B_ENTREE B_SORTIE <<< "$(budget_ticket "$LOGDIR/$ID.message.$attempt.txt" "$TARGET" "${LUS[@]}")"
      log "  budget de la relance : ≈ $((B_ENTREE + B_SORTIE)) / $NUM_CTX"
      if [ $((B_ENTREE + B_SORTIE)) -gt "$BUDGET_MAX" ]; then
        log "  TROP_GROS : la relance saturerait la fenêtre — arrêt"
        STATUS="TROP_GROS"; break
      fi
    fi
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
        "${AIDER_DELAI[@]}" \
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

    INVENTES="$(imports_inventes "$TARGET")"
    if [ -n "$INVENTES" ]; then
      log "  IMPORTS INVENTÉS : $(printf '%s ' $INVENTES)"
      MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : IMPORTS INVENTÉS
Ton fichier $TARGET importe des modules qui N'EXISTENT PAS :
$INVENTES

Tu n'as le droit de créer AUCUN autre fichier que $TARGET : ces modules
n'existeront donc jamais. Retire ces imports. Tout ce qui n'est pas importé d'un
module réel doit être écrit dans $TARGET lui-même.

Voici la liste COMPLÈTE des modules qui existent. N'importe que parmi eux :
$(modules_existants)

Réécris $TARGET en entier."
      attempt=$((attempt + 1))
      continue
    fi

    GATELOG="$LOGDIR/$ID.gate.$attempt.log"
    if run_gate "$GATELOG"; then
      log "  porte VERTE"
      STATUS="VERT"; break
    fi

    if gate_accuse_les_tests "$GATELOG" "$TARGET" "$TESTFILE"; then
      log "  TEST_SUSPECT : tsc n'accuse que des fichiers de tests, le modèle ne peut rien corriger"
      STATUS="TEST_SUSPECT"; break
    fi

    # Diagnostic d'un coup d'œil dans run.log : premières lignes utiles de l'échec.
    grep -E 'error TS|×|→' "$GATELOG" | sed -E "s/$(printf '\033')\[[0-9;]*m//g" | head -3 |
      while IFS= read -r l; do log "    | $l"; done

    EMPREINTE="$(empreinte_echec "$GATELOG")"
    if [ "$EMPREINTE" = "$EMPREINTE_PREC" ]; then
      log "  MÊME ÉCHEC qu'à la tentative précédente — arrêt, une relance n'y changera rien"
      STATUS="CALÉ"; break
    fi
    EMPREINTE_PREC="$EMPREINTE"

    [ "$attempt" -lt "$MAX_ATTEMPTS" ] && log "  porte ROUGE — relance avec la spec et les seuls échecs"
    CAUSE=""
    if erreurs_dans_tests_seulement "$GATELOG"; then
      CAUSE="Ces erreurs sont dans des tests que tu n'as PAS le droit de modifier. Ils
compilaient avant ta modification : c'est ta version de $TARGET qui les casse
(une prop, un type ou un export a changé). Corrige $TARGET, pas les tests.
"
      log "  erreurs dans des tests existants : la cible les casse, relance"
    fi
    MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : ROUGE
$TARGET contient ta dernière version. Garde tout ce qui fonctionne et corrige
UNIQUEMENT les échecs ci-dessous. Respecte à la lettre les imports et les exports
imposés par la spécification ci-dessus. Ne modifie aucun test.
${CAUSE}
Échecs :
$(erreurs_utiles "$GATELOG")"
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
__VICTO_FIN_2__
chmod +x run.sh
ok "spec 098c, test du compteur et harnais mis à jour"

# ------------------------------------------------------------ la pastille « 0 » (même règle que rattrapage-098)
T=tests/SiteHeader.test.tsx
if [ -f "$T" ] && grep -E "entete-panier-compte" "$T" | grep -qE "['\"]0['\"]"; then
  python3 - <<'PYC'
def rep(p, a, b):
    s = open(p).read(); assert s.count(a) == 1, (p, a[:40]); open(p, 'w').write(s.replace(a, b))
rep('tickets/098c-entete-compteur.md', '## Les cinq changements', '## Les quatre changements')
s = open('tickets/098c-entete-compteur.md').read()
debut = s.index('5. L\'élément `data-testid="entete-panier-compte"`'); fin = s.index('\n\n', debut)
open('tickets/098c-entete-compteur.md', 'w').write(s[:debut].rstrip('\n') + s[fin:])
t = 'tickets/tests/entete-compteur.test.tsx'; s = open(t).read()
debut = s.index("  it('n’affiche aucune pastille pour un panier vide'"); fin = s.index("  it('laisse une valeur explicite", debut)
open(t, 'w').write(s[:debut] + s[fin:])
PYC
  info "$T attend une pastille « 0 » : règle « pas de pastille à zéro » retirée du 098c"
else
  ok "$T n'attend pas de pastille « 0 » : règle conservée"
fi

# ------------------------------------------------------------ tickets 098e : /design exclu, tests resserrés
DESIGN=src/app/design/page.tsx
python3 - <<'PYM'
lignes = open('tickets/manifest-098.tsv').read().splitlines(keepends=True)
garde = [l for l in lignes if l.split('\t')[1:2] != ['src/app/design/page.tsx']]
open('tickets/manifest-098.tsv', 'w').write(''.join(garde))
open('tickets/manifest-rattrapage-098c.tsv', 'w').write(
    ''.join(l for l in garde if l.split('\t')[0] == '098c' or l.split('\t')[0].startswith('098e')))
PYM
for f in $(grep -lF "$DESIGN" tickets/098e*-sans-cartcount.md 2>/dev/null); do
  n="${f#tickets/}"; n="${n%%-*}"; t="tickets/tests/sans-cartcount-${n#098e}.test.ts"
  git rm -q -- "$f" "$t" 2>/dev/null || rm -f -- "$f" "$t"
  ok "ticket $n retiré : /design garde son compteur de démonstration"
done
TESTS=(entete-compteur.test.tsx)
while IFS=$'\t' read -r id cible test _; do
  case "$id" in 098e*) ;; *) continue ;; esac
  t="$(basename "$test")"; TESTS+=("$t")
  cat > "tickets/tests/$t" <<__GEN__
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('$id — compteur laissé au panier', () => {
  it('ne passe plus l’attribut cartCount à l’en-tête', () => {
    expect(readFileSync('$cible', 'utf8')).not.toMatch(/cartCount=\{/);
  });
});
__GEN__
  n_attr="$(grep -o 'cartCount={' "$cible" | wc -l || true)"; n_entete="$(grep -o '<SiteHeader' "$cible" | wc -l || true)"
  [ "$n_attr" -le "$n_entete" ] || info "$cible : $n_attr « cartCount={ » pour $n_entete en-tête(s) — un usage hors de <SiteHeader> ferait caler $id"
done < tickets/manifest-rattrapage-098c.tsv
ok "manifeste de rattrapage : $(cut -f1 tickets/manifest-rattrapage-098c.tsv | tr '\n' ' ')"

# ------------------------------------------------------------ contrôle, budget, pré-vol
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cut -f4 tickets/manifest-rattrapage-098c.tsv | while read -r s; do cp "$s" "$CTL/"; done
for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-rattrapage-098c.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    if os.path.isfile(cible): car += len(open(cible).read())
    sortie = len(open(cible).read()) * 11 // 30 if os.path.isfile(cible) else 0
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB
MAUVAIS='TypeError|ReferenceError|SyntaxError|Transform failed|is not a function|Cannot read propert|is not defined'
for t in "${TESTS[@]}"; do
  p="tests/zz-prevol-$t"; cp "tickets/tests/$t" "$p"
  npx --no-install vitest run "$p" > /tmp/victo-prevol.log 2>&1 || true
  rm -f "$p"; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
  if grep -qE "$MAUVAIS" /tmp/victo-prevol.log; then
    grep -nE "$MAUVAIS" /tmp/victo-prevol.log | head -4; annuler "pré-vol de $t : le test PLANTE — c'est le test qui est faux"
  elif grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log; then
    ok "pré-vol $t : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' '), sans plantage"
  else
    tail -12 /tmp/victo-prevol.log; annuler "pré-vol de $t : le test ne s'est pas exécuté"
  fi
done

# ------------------------------------------------------------ base verte, commit
bash -n run.sh
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests run.sh
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "fix(tickets): 098c — cartCount reste facultatif ; harnais : TEST_SUSPECT resserré ; /design exclu"
  ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
git branch -q -D auto/098c 2>/dev/null || true
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-rattrapage-098c.tsv ./run.sh\n\n%s tickets : 098c, puis les pages qui fixaient le compteur. Compte 30 à 45 minutes.\n' "$(wc -l < tickets/manifest-rattrapage-098c.tsv)"
