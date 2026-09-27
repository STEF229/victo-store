#!/usr/bin/env bash
# VICTO STORE — rattrapage du lot 102 (102l mes commandes, 102m lien « Mon compte »).
# Deux erreurs de TESTS, pas de code :
#   102l : le test comptait tous les titres de niveau 3, pied de page compris ; il lit
#          maintenant les titres DANS chaque carte de commande ;
#   102m : un ancien test, hors de tests/ ou sous une autre forme, cherchait encore
#          « Mon compte » comme un bouton ; l'assouplissement parcourt maintenant TOUS
#          les fichiers de test suivis par git.
# Le code du modèle est repris de sa branche sans modification et passe la porte
# complète (tsc, tests, build) avec tout main : vert → fusionné ; rouge → relance préparée.
# Usage :  cd ~/victo-store && bash rattrapage-102.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git checkout -q -f main; git reset -q --hard "$DEPART"; git clean -fdq -- tests tickets src
           git branch -q -D verif/102l verif/102m 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
for c in src/app/compte/commandes/page.tsx; do
  if [ -f "$c" ] && ! git ls-files --error-unmatch "$c" >/dev/null 2>&1; then
    [ -s "$c" ] && mort "$c existe hors suivi git et n'est pas vide : je n'y touche pas"; rm -f "$c"; fi
done
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
DEPART="$(git rev-parse HEAD)"
ok "main à jour ($(git rev-parse --short HEAD))"

fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 102a 102b 102c 102d 102e 102f 102g 102h 102i 102j 102k; do fusionne "$d" || mort "$d n'est pas fusionné : ce rattrapage suppose le run du 27 septembre"; done
declare -A CIBLE=( [102l]=src/app/compte/commandes/page.tsx [102m]=src/components/ui/SiteHeader.tsx )
declare -A TEST=( [102l]=tests/page-commandes.test.tsx [102m]=tests/entete-compte.test.tsx )
A_FAIRE=()
for t in 102l 102m; do
  if fusionne "$t"; then ok "$t déjà fusionné"; continue; fi
  git rev-parse -q --verify "auto/$t" >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin "auto/$t:auto/$t" \
    || mort "branche auto/$t introuvable, ni en local ni sur GitHub"
  touches="$(git diff --name-only "main...auto/$t" | sort | tr '\n' ' ')"
  attendu="$(printf '%s\n%s\n' "${CIBLE[$t]}" "${TEST[$t]}" | sort | tr '\n' ' ')"
  [ "$touches" = "$attendu" ] || mort "auto/$t ne contient pas ce que le journal décrivait : $touches"
  git show "auto/$t:${TEST[$t]}" | cmp -s - "tickets/${TEST[$t]}" || mort "le test de auto/$t diffère du test en attente : branche suspecte"
  A_FAIRE+=("$t")
done
[ "${#A_FAIRE[@]}" -gt 0 ] || { ok "rien à rattraper : 102l et 102m sont fusionnés"; exit 0; }
ok "branches à reprendre : ${A_FAIRE[*]} (code du modèle et test intacts)"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
cat > tickets/tests/page-commandes.test.tsx <<'__VICTO_FIN_0__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageCommandes from '../src/app/compte/commandes/page';
import { PILULE_ON } from '../src/components/catalogue/filtres-affichage';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const connecter = (client: object) => window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
const poser = () => render(<SessionProvider><PageCommandes /></SessionProvider>);
const filtre = (nom: string) => screen.getByRole('button', { name: nom });
// Titres lus DANS chaque carte : le pied de page a aussi des titres de niveau 3.
const numeros = () =>
  screen.queryAllByTestId('carte-commande').map((c: HTMLElement) => within(c).getByRole('heading', { level: 3 }).textContent);

beforeEach(() => window.localStorage.clear());

describe('mes commandes', () => {
  it('liste toutes les commandes du client de démonstration', () => {
    connecter(CLIENT_DEMO);
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Mes commandes' })).toBeInTheDocument();
    expect(numeros()).toEqual(['Commande VS-10482', 'Commande VS-10417', 'Commande VS-10360', 'Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('4 commandes');
    expect(filtre('Toutes')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('aria-current', 'page');
  });

  it('filtre par statut', () => {
    connecter(CLIENT_DEMO);
    poser();
    fireEvent.click(filtre('Livrées'));
    expect(numeros()).toEqual(['Commande VS-10417', 'Commande VS-10360']);
    expect(filtre('Livrées')).toHaveAttribute('aria-pressed', 'true');
    for (const k of PILULE_ON.split(' ')) expect(classes(filtre('Livrées'))).toContain(k);
    fireEvent.click(filtre('Annulées'));
    expect(numeros()).toEqual(['Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('1 commande');
  });

  it('dit qu’il n’y a rien pour un nouveau client', () => {
    connecter({ ...CLIENT_DEMO, courriel: 'lea@exemple.ca' });
    poser();
    expect(screen.getByTestId('commandes-vides')).toBeInTheDocument();
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('0 commande');
  });
});
__VICTO_FIN_0__
ok "test de la page des commandes corrigé (titres lus dans chaque carte)"

# ------------------------------------------------------------ « Mon compte » : tous les fichiers de test suivis
python3 - <<'PYT' > /tmp/victo-assouplis.txt
import re, subprocess
fichiers = subprocess.run(['git', 'ls-files', '*.test.ts', '*.test.tsx'], capture_output=True, text=True).stdout.split()
motif = re.compile(r"""\b(get|query|find)(All)?ByRole\((['"])button\3,\s*\{\s*name:\s*(['"])Mon compte\4[^}]*\}\)""")
for f in fichiers:
    s = open(f, encoding='utf-8').read()
    t = motif.sub(lambda m: f"{m.group(1)}{m.group(2) or ''}ByLabelText('Mon compte')", s)
    if t != s:
        open(f, 'w', encoding='utf-8').write(t); print(f)
PYT
[ -s /tmp/victo-assouplis.txt ] && ok "« Mon compte » trouvé par son étiquette dans : $(tr '\n' ' ' < /tmp/victo-assouplis.txt)" \
  || info "aucun test à assouplir trouvé sous la forme attendue"
# Ce qui cherche encore un bouton dans un fichier qui parle de « Mon compte » : montré, puis jugé par la porte.
suspects="$(git ls-files '*.test.ts' '*.test.tsx' | xargs grep -l "Mon compte" 2>/dev/null | xargs grep -nE "ByRole\(['\"]button['\"]" 2>/dev/null | grep -v "Créer mon compte\|Se connecter\|Envoyer le lien\|Renvoyer\|Retirer\|mot de passe\|Ouvrir le menu" || true)"
[ -z "$suspects" ] || { info "boutons cherchés dans des tests qui parlent de « Mon compte » (la porte dira s'ils bloquent) :"; echo "$suspects" | head -8 | sed 's/^/      /'; }

CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"; cp tickets/102l-page-commandes.md "$CTL/"; cp tickets/tests/page-commandes.test.tsx "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge sur main"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges sur main après assouplissement"; }
git add -A -- tests tickets src
git diff --cached --quiet || git commit -q -m "fix(tests): 102l titres lus dans les cartes ; « Mon compte » trouvé par son étiquette partout"
ok "corrections commitées, base verte"

# ------------------------------------------------------------ porte sur le code du modèle, ticket par ticket
RELANCE=()
for t in "${A_FAIRE[@]}"; do
  git checkout -q -b "verif/$t" main
  git checkout "auto/$t" -- "${CIBLE[$t]}"
  git show "main:tickets/${TEST[$t]}" > "${TEST[$t]}"
  git add -- "${CIBLE[$t]}" "${TEST[$t]}"
  git commit -q -m "chore($t): code du modèle repris de auto/$t, test en vigueur"
  PORTE="/tmp/victo-porte-$t.log"; : > "$PORTE"; vert=1
  npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
  [ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
  [ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }
  git checkout -q main
  if [ "$vert" = 1 ]; then
    git merge --no-ff -q "verif/$t" -m "feat($t): fusionné au vert par le harnais" || annuler "fusion de $t impossible"
    git branch -q -D "verif/$t" "auto/$t"
    GIT_TERMINAL_PROMPT=0 git push -q origin --delete "auto/$t" 2>/dev/null || true
    ok "$t : code du modèle vert (tsc, tests, build), fusionné"
  else
    info "$t : porte ROUGE, rien n'est fusionné. Échecs :"
    grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | sort -u | head -6 | sed 's/^/      /'
    git branch -q -D "verif/$t"
    RELANCE+=("$t")
  fi
done
if [ "${#RELANCE[@]}" -lt "${#A_FAIRE[@]}" ]; then
  { npm run --silent typecheck && npm run --silent test && { ! grep -q '"build"' package.json || npm run --silent build; }; } >/tmp/victo-apres.log 2>&1 \
    || { grep -E "error TS|FAIL|×|→" /tmp/victo-apres.log | head; annuler "main rouge après les fusions"; }
  ok "main vert après les fusions (tsc, tests, build)"
fi
if [ "${#RELANCE[@]}" -gt 0 ]; then
  : > tickets/manifest-rattrapage-102.tsv
  for t in "${RELANCE[@]}"; do grep -P "^$t\t" tickets/manifest-102.tsv >> tickets/manifest-rattrapage-102.tsv; done
  git add tickets/manifest-rattrapage-102.tsv; git commit -q -m "chore(tickets): relance du lot 102 (${RELANCE[*]})"
fi
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale en fin de script : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log)"; fi
if [ "${#RELANCE[@]}" -eq 0 ]; then
  printf '\nLe lot 102 est terminé : rien à lancer.\nÀ vérifier : http://192.168.40.32:3000/connexion — camille.tremblay@exemple.ca / victo2026\n'
else
  printf '\nÀ relancer :\n\n    MANIFEST=tickets/manifest-rattrapage-102.tsv ./run.sh\n\nTicket(s) : %s. Si la porte a cité un ancien test ci-dessus, envoie-moi ces lignes.\n' "${RELANCE[*]}"
fi
