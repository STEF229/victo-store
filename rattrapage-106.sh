#!/usr/bin/env bash
# VICTO STORE — rattrapage du lot 106 : gabarit « Aide » (106a), puis les pages d'aide.
# Cause : le test cherchait l'en-tête du site par getByRole('banner') ; le <header> du titre,
# placé dans l'article comme le demandait la spec, compte aussi comme « banner » pour
# Testing Library. Le test repère maintenant l'en-tête par sa navigation nommée ; le contrôle
# refuse désormais getByRole('banner'). Le code du modèle, resté sur auto/106a, passe la porte
# complète avec ce test : vert → fusionné ; rouge → relancé avec les pages.
# Usage :  cd ~/victo-store && bash rattrapage-106.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ git checkout -q -f main; git reset -q --hard "$DEPART"; git clean -fdq -- tests tickets outils
           git branch -q -D verif/106a 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }
CIBLE=src/components/aide/GabaritAide.tsx; T=tests/GabaritAide.test.tsx; TT=tickets/tests/GabaritAide.test.tsx

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
if [ -f "$CIBLE" ] && ! git ls-files --error-unmatch "$CIBLE" >/dev/null 2>&1; then
  [ -s "$CIBLE" ] && mort "$CIBLE existe hors suivi git et n'est pas vide : je n'y touche pas"
  rm -f "$CIBLE"; ok "cible vide laissée par le run retirée du disque"
fi
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
DEPART="$(git rev-parse HEAD)"
ok "main à jour ($(git rev-parse --short HEAD))"

fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
[ -f tickets/manifest-106.tsv ] || mort "tickets/manifest-106.tsv absent : lot 106 non installé"
for d in 106b 106e; do fusionne "$d" || info "$d n'est pas fusionné : il sera relancé aussi"; done
SAUVETAGE=0
if fusionne 106a; then
  ok "106a déjà fusionné"
else
  git rev-parse -q --verify auto/106a >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin auto/106a:auto/106a 2>/dev/null || true
  if git rev-parse -q --verify auto/106a >/dev/null \
     && [ "$(git diff --name-only main...auto/106a | sort | tr '\n' ' ')" = "$CIBLE $T " ] \
     && git show "auto/106a:$T" | cmp -s - "$TT"; then
    SAUVETAGE=1; ok "auto/106a : gabarit du modèle à sa place, test d'origine intact"
  else
    info "auto/106a absente ou inattendue : le 106a sera relancé"
  fi
fi
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
cat > tickets/tests/GabaritAide.test.tsx <<'__VICTO_FIN_0__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GabaritAide, RUBRIQUES_AIDE } from '../src/components/aide/GabaritAide';
import { MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('GabaritAide', () => {
  it('liste les cinq rubriques, dans l’ordre, avec leurs adresses', () => {
    expect(RUBRIQUES_AIDE.map((r) => [r.libelle, r.href])).toEqual([
      ['Livraison', '/livraison'], ['Retours et échanges', '/retours'], ['Contact', '/contact'],
      ['Conditions de vente', '/conditions-de-vente'], ['Confidentialité', '/confidentialite'],
    ]);
  });

  it('assemble en-tête, fil, menu marqué, titre, contenu, date et pied', () => {
    render(<GabaritAide actif="retours" titre="Retours et échanges" intro="Pas la bonne pointure ?" miseAJour="27 septembre 2026"><p>contenu</p></GabaritAide>);
    // L'en-tête du site se repère par sa navigation : le <header> du titre, dans l'article, compte aussi comme « banner ».
    expect(screen.getByRole('navigation', { name: 'Navigation principale' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Retours et échanges' })).toBeInTheDocument();
    expect(screen.getByText('Pas la bonne pointure ?')).toBeInTheDocument();
    const menu = screen.getByRole('navigation', { name: 'Aide' });
    const actif = within(menu).getByRole('link', { name: 'Retours et échanges' });
    expect(actif).toHaveAttribute('aria-current', 'page');
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif)).toContain(k);
    expect(within(menu).getByRole('link', { name: 'Contact' })).not.toHaveAttribute('aria-current');
    expect(screen.getByText('contenu')).toBeInTheDocument();
    expect(screen.getByText('Dernière mise à jour : 27 septembre 2026')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('se passe de date quand il n’y en a pas', () => {
    render(<GabaritAide actif="contact" titre="Contact" intro="Une question ?"><p>x</p></GabaritAide>);
    expect(screen.queryByText(/Dernière mise à jour/)).toBeNull();
  });
});
__VICTO_FIN_0__
cat > outils/controle-lot.py <<'__VICTO_FIN_1__'
import re
#!/usr/bin/env python3
"""Usage : python3 outils/controle-lot.py <dossier_de_tickets> [src/styles/tokens.css]

Contrôle d'un lot avant livraison : chaque piège déjà rencontré dans le projet
devient une règle vérifiée automatiquement sur les specs et les tests."""
import os, re, sys

racine = sys.argv[1]
specs = {f: open(os.path.join(racine, f)).read() for f in os.listdir(racine) if f.endswith('.md')}
dtests = os.path.join(racine, 'tests')
tests = {f: open(os.path.join(dtests, f)).read() for f in os.listdir(dtests)} if os.path.isdir(dtests) else {}
alertes = []
NAV_DOM = re.compile(r'\.(parentElement|parentNode|firstElementChild|lastElementChild|firstChild|lastChild|nextElementSibling|previousElementSibling|nextSibling|previousSibling)\b|\.(children|childNodes)\[')
def alerte(fichier, piege, detail): alertes.append((fichier, piege, detail))

for f, s in tests.items():
    for n, l in enumerate(s.splitlines(), 1):
        if l.strip().startswith(('//', 'it(', 'it.each', 'describe(')): continue
        # piège : toHaveTextContent normalise l'espace insécable (tickets 015, 019)
        if 'toHaveTextContent' in l and ('NB' in l or '\u00a0' in l):
            alerte(f, 'insécable', f'ligne {n} : toHaveTextContent avec une espace insécable')
        # piège : élément désigné par sa position dans le DOM, cassé par toute enveloppe
        # (parentElement : 090, 094 ; firstElementChild : réintroduit par le correctif du 090)
        nav = NAV_DOM.search(l)
        if nav:
            alerte(f, 'navigation DOM', f'ligne {n} : {nav.group(0)} — viser un data-testid ou closest()')
        # piège : className lu dans un test — sur un SVG ce n'est pas une chaîne (ticket 095c)
        if '.className' in l:
            alerte(f, 'className', f"ligne {n} : lire getAttribute('class'), className d'un SVG n'est pas une chaîne")
        # piège : getByRole('banner') — un <header> dans un article compte aussi comme « banner » (lot 106a)
        if re.search(r"getByRole\(\s*['\"]banner['\"]\s*\)", l):
            alerte(f, 'banner', f"ligne {n} : getByRole('banner') peut trouver plusieurs en-têtes ; chercher la navigation nommée « Navigation principale »")
        # piège : prix cherché par texte — formatPrice met une espace insécable que
        # getByText normalise dans la page mais pas dans le motif (ticket 100c)
        if 'ByText(' in l and 'formatPrice' in l:
            alerte(f, 'insécable', f'ligne {n} : prix cherché par ByText ; lire .textContent et comparer à formatPrice')
        # piège : apostrophe courbe dans un texte comparé exactement
        if '’' in l and ('.toBe(' in l or 'name:' in l):
            alerte(f, 'apostrophe', f'ligne {n} : apostrophe courbe dans une comparaison exacte')

# piège : accord en nombre décrit en prose — zéro au singulier (tickets 037, 083)
singuliers_zero = set()
for f, s in tests.items():
    for m in re.findall(r"['`]0 ([a-zéèàù]+)['`]", s): singuliers_zero.add(m)
for f, s in specs.items():
    for mot in singuliers_zero:
        produit_un_compteur = 'compteur' in s and (mot + 's') in s
        if produit_un_compteur and '> 1 ?' not in s:
            alerte(f, 'pluriel', f"les tests attendent « 0 {mot} » mais la spec ne donne pas le code exact `n > 1 ? …`")

for f, s in specs.items():
    cible_page = re.search(r"page\.tsx", s.split('\n', 3)[2] if s.count('\n') > 2 else s)
    # piège : une page Next avec un export nommé en plus du défaut (ticket 061)
    if cible_page and re.search(r'[Ee]xport nommé [`\w]', s) and 'Aucun export nommé' not in s:
        alerte(f, 'export de page', 'une page demande un export nommé : un seul export par défaut')
    # piège : exigence visuelle en prose, sans classe imposée (ticket 058)
    for mot in ['grand espacement', 'espacement intérieur', 'marges généreuses', 'bien espacé']:
        if mot in s:
            alerte(f, 'prose visuelle', f'« {mot} » sans classe imposée')
    # piège : icône dessinée à la main demandée au modèle (tickets 053, 059)
    if re.search(r'\bun camion\b|\bune flèche circulaire\b|tracé', s) and 'lucide' not in s:
        alerte(f, 'icône dessinée', 'icône décrite en mots : utiliser lucide-react')
    # piège : aria-current booléen rendu "false" par React (ticket 054)
    if 'aria-current' in s and "undefined" not in s:
        alerte(f, 'aria-current', "donner `aria-current={actif ? 'true' : undefined}`")
    # piège : fichier baril (tickets 021, 061)
    if re.search(r"from '@/components/(ui|accueil|catalogue)'", s):
        alerte(f, 'baril', 'import depuis un dossier')
    # piège : cible CSS confiée au modèle (ticket 010)
    if re.search(r"Crée `src/[^`]+\.css`", s):
        alerte(f, 'cible css', 'un livrable CSS : passer par un module TypeScript')

# piège : jetons de couleur laissés au modèle (ticket 093 : --vs-principal et
# --vs-fond inventés, pastilles blanc sur blanc, invisibles pour jsdom)
for f, s in specs.items():
    if 'var(--vs-*)' in s:
        alerte(f, 'jetons non listés', 'donner la liste fermée des jetons autorisés, pas « var(--vs-*) »')
chemin_jetons = sys.argv[2] if len(sys.argv) > 2 else os.path.join(racine, '..', 'src', 'styles', 'tokens.css')
if os.path.isfile(chemin_jetons):
    definis = set(re.findall(r'(--vs-[a-z0-9-]+)\s*:', open(chemin_jetons).read()))
    for f, s in list(specs.items()) + list(tests.items()):
        for j in sorted(set(re.findall(r'var\((--vs-[a-z0-9-]+)\)', s)) - definis):
            alerte(f, 'jeton inconnu', f'{j} absent de {os.path.basename(chemin_jetons)}')
else:
    print(f'  (jetons non vérifiés : {chemin_jetons} introuvable)')

for f, s in specs.items():
    # piège : noUncheckedIndexedAccess cité sans dire comment accéder aux tableaux (ticket 098a)
    if 'noUncheckedIndexedAccess' in s and 'accès par index' not in s:
        alerte(f, 'accès par index', "dire comment lire un tableau : .find, .map, .filter, jamais t[i]")

for f, s in specs.items():
    # piège : code à trous « … » laissé au modèle (ticket 083)
    for bloc in re.findall(r"```[a-z]*\n(.*?)```", s, re.S):
        if '…' in bloc:
            alerte(f, 'code à trous', 'un bloc de code contient « … » : le modèle doit deviner')
            break

for f, piege, detail in sorted(alertes):
    print(f'  ✗ {f:34} [{piege}] {detail}')
print(f'  {len(alertes)} alerte(s) sur {len(specs)} specs et {len(tests)} tests')
sys.exit(1 if alertes else 0)
__VICTO_FIN_1__
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"; cp tickets/106a-gabarit-aide.md "$CTL/"; cp "$TT" "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge sur main"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges sur main"; }
git add -- "$TT" outils/controle-lot.py
git diff --cached --quiet && ok "test et contrôle déjà à jour" || {
  git commit -q -m "fix(tests): 106a — en-tête repéré par sa navigation ; le contrôle refuse getByRole('banner')"
  ok "test corrigé et règle ajoutée au contrôle"; }

# ------------------------------------------------------------ porte sur le gabarit du modèle
RELANCE=()
if [ "$SAUVETAGE" = 1 ]; then
  git checkout -q -b verif/106a main
  git checkout auto/106a -- "$CIBLE"
  git show "main:$TT" > "$T"
  git add -- "$CIBLE" "$T"; git commit -q -m "chore(106a): gabarit du modèle repris de auto/106a, test corrigé"
  PORTE=/tmp/victo-porte-106a.log; : > "$PORTE"; vert=1
  npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
  [ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
  [ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }
  git checkout -q main
  if [ "$vert" = 1 ]; then
    git merge --no-ff -q verif/106a -m "feat(106a): fusionné au vert par le harnais" || annuler "fusion impossible"
    { npm run --silent typecheck && npm run --silent test && { ! grep -q '"build"' package.json || npm run --silent build; }; } >/tmp/victo-apres.log 2>&1 \
      || { grep -E "error TS|FAIL|×|→" /tmp/victo-apres.log | head; annuler "main rouge après la fusion du gabarit"; }
    git branch -q -D verif/106a auto/106a
    GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/106a 2>/dev/null || true
    ok "gabarit du modèle : porte verte (tsc, tests, build), fusionné"
  else
    info "gabarit du modèle : porte ROUGE, rien n'est fusionné. Échecs :"
    grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | sort -u | head -6 | sed 's/^/      /'
    git branch -q -D verif/106a auto/106a; RELANCE+=(106a)
    GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/106a 2>/dev/null || true   # le harnais repartira d'une branche neuve
  fi
elif ! fusionne 106a; then
  RELANCE+=(106a)
fi

# ------------------------------------------------------------ relance : ce qui n'est pas fusionné
: > tickets/manifest-rattrapage-106.tsv
while IFS=$'\t' read -r id reste; do
  [ -n "$id" ] || continue
  if [ "$id" = 106a ]; then [ "${#RELANCE[@]}" -gt 0 ] || continue; else fusionne "$id" && continue; fi
  printf '%s\t%s\n' "$id" "$reste" >> tickets/manifest-rattrapage-106.tsv
done < tickets/manifest-106.tsv
trap - ERR
if [ -s tickets/manifest-rattrapage-106.tsv ]; then
  git add tickets/manifest-rattrapage-106.tsv
  git diff --cached --quiet || git commit -q -m "chore(tickets): relance du lot 106 ($(cut -f1 tickets/manifest-rattrapage-106.tsv | tr '\n' ' '))"
fi
[ -z "$(git status --porcelain)" ] || mort "arbre sale en fin de script : $(git status --porcelain | head -3)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log && ok "poussé sur GitHub" || info "push refusé (voir /tmp/victo-push.log)"
if [ -s tickets/manifest-rattrapage-106.tsv ]; then
  printf '\nÀ relancer :\n\n    MANIFEST=tickets/manifest-rattrapage-106.tsv ./run.sh\n\nTickets : %s\n' "$(cut -f1 tickets/manifest-rattrapage-106.tsv | tr '\n' ' ')"
else
  printf '\nLe lot 106 est terminé : rien à relancer.\n'
fi
