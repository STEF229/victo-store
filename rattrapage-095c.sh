#!/usr/bin/env bash
# VICTO STORE — rattrapage 095c sans rappeler le modèle.
# Le test du 095c plantait sur la croix des pastilles : el.className.split sur un
# SVG, dont className n'est pas une chaîne. Le code du modèle n'a jamais été jugé
# sur ce point. Ce script :
#   1. corrige le test (getAttribute('class')) et ajoute la règle au contrôle ;
#   2. vérifie que la branche auto/095c ne touche que sa cible et son test, intact ;
#   3. passe la porte complète (tsc, tests, build) sur le code du modèle, test corrigé ;
#   4. vert  → fusion comme le ferait le harnais ;
#      rouge → rien n'est fusionné, le ticket est prêt à être relancé par le harnais.
# Usage :  cd ~/victo-store && bash rattrapage-095c.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git checkout -q -f main; git reset -q --hard "$DEPART"; git clean -fdq -- tests tickets outils
           git branch -q -D verif/095c 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }
T=tests/FiltresBarre-v3.test.tsx
TT=tickets/tests/FiltresBarre-v3.test.tsx
CIBLE=src/components/catalogue/FiltresBarre.tsx

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
DEPART="$(git rev-parse HEAD)"
ok "main à jour ($(git rev-parse --short HEAD))"

if git log main -1 --format=%h --fixed-strings --grep="feat(095c): fusionné" | grep -q .; then
  ok "095c est déjà fusionné dans main — rien à faire"; exit 0
fi
for d in 095a 095b; do
  git log main -1 --format=%h --fixed-strings --grep="feat($d): fusionné" | grep -q . || mort "$d n'est pas fusionné dans main"
done
git rev-parse -q --verify auto/095c >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin auto/095c:auto/095c \
  || mort "branche auto/095c introuvable, ni en local ni sur GitHub"

# ------------------------------------------------------------ la branche est-elle saine ?
touches="$(git diff --name-only main...auto/095c -- tests tickets outils run.sh)"
[ "$touches" = "$T" ] || mort "auto/095c touche d'autres fichiers protégés que son test : $(echo $touches)"
git show "auto/095c:$T" | cmp -s - "$TT" || mort "le test de la branche diffère du test en attente : branche suspecte"
git show "auto/095c:$CIBLE" | grep -q . || mort "la cible est vide sur auto/095c"
autres="$(git diff --name-only main...auto/095c | grep -vxF -e "$T" -e "$CIBLE" || true)"
[ -z "$autres" ] || printf '  \033[33m!\033[0m auto/095c modifie aussi : %s\n' "$(echo $autres)"
ok "auto/095c : code du modèle présent, test intact"

# ------------------------------------------------------------ correctifs sur main
cat > tickets/tests/FiltresBarre-v3.test.tsx <<'__VICTO_FIN_0__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, PANNEAU, PANNEAU_MARQUES, PANNEAU_TAILLES,
  PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '../src/components/catalogue/filtres-affichage';
// Dépendance déclarée pour le harnais : sans les tiroirs, ce ticket est BLOQUÉ.
import { TiroirsFiltres as _dependance } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nom = (el: Element) =>
  el.getAttribute('data-testid') ?? el.getAttribute('aria-label') ?? el.textContent ?? el.tagName;
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
  }
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(criteres: Criteres = {}) {
  const onChange = vi.fn();
  const onTriChange = vi.fn();
  render(
    <FiltresBarre marques={MARQUES} tailles={['40', '41']} criteres={criteres}
      onChange={onChange} tri="nouveautes" onTriChange={onTriChange} />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre v3 — pilules', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_OFF);
    }
  });

  it('noircit chaque pilule active', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_ON);
    }
    expect(screen.getByTestId('filtre-promo')).toHaveAttribute('aria-pressed', 'true');
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v3 — panneaux et tri', () => {
  it('habille le panneau des marques', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et le tri', () => {
    poser({ tailles: ['41'] });
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    expect(screen.getByTestId('filtre-taille-41')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByTestId('filtre-taille-40')).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v3 — pastilles', () => {
  it('rend des pastilles visibles avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    const noms = within(zone).getAllByRole('button').map((b: HTMLElement) => b.getAttribute('aria-label') ?? b.textContent);
    expect(noms).toEqual([
      'Retirer le filtre Nike', 'Retirer le filtre Taille 41', 'Retirer le filtre Promotions',
      'Retirer le filtre En stock', 'Tout effacer',
    ]);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      porte(croix as Element, PASTILLE_CROIX);
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });

  it('remet un interrupteur à false depuis sa pastille', () => {
    const { onChange } = poser({ promotionSeulement: true, marques: ['nike'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Promotions' }));
    expect(onChange).toHaveBeenCalledWith({ promotionSeulement: false, marques: ['nike'] });
  });
});

describe('FiltresBarre v3 — téléphone', () => {
  it('délègue les tiroirs à TiroirsFiltres et relaie ses actions', () => {
    const { onChange, onTriChange } = poser({ marques: ['lacoste'] });
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-nike'));
    expect(onChange).toHaveBeenCalledWith({ marques: ['lacoste', 'nike'] });
    fireEvent.click(within(tiroir).getByTestId('filtre-stock'));
    expect(onChange).toHaveBeenLastCalledWith({ marques: ['lacoste'], enStockSeulement: true });
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    fireEvent.click(within(screen.getByTestId('tiroir-tri')).getByRole('button', { name: 'Prix croissant' }));
    expect(onTriChange).toHaveBeenCalledWith('prix-croissant');
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });
});

describe('FiltresBarre v3 — source', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');

  it('ne code aucune couleur à la main', () => {
    expect(source).not.toContain('var(--vs-');
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });

  it('ne réimplémente pas les tiroirs', () => {
    expect(source).toContain('<TiroirsFiltres');
    expect(source).not.toContain('tiroir-filtres');
    expect(source).not.toContain('tiroir-tri');
  });
});
__VICTO_FIN_0__
cat > outils/controle-lot.py <<'__VICTO_FIN_1__'
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
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"; cp tickets/095c-filtres-barre-v3.md "$CTL/"; cp "$TT" "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge sur main"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges sur main"; }
git add -- "$TT" outils/controle-lot.py
git commit -q -m "fix(tests): 095c — classes lues par getAttribute (className d'un SVG), règle ajoutée au contrôle"
ok "test corrigé et règle du contrôle ajoutée (commit $(git rev-parse --short HEAD))"

# ------------------------------------------------------------ porte sur le code du modèle
git checkout -q -b verif/095c auto/095c
git show "main:$TT" > "$T"
PORTE=/tmp/victo-porte-095c.log; : > "$PORTE"
vert=1
npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
[ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
[ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }

if [ "$vert" = 1 ]; then
  ok "porte VERTE sur le code du modèle (tsc, tests, build)"
  git add -- "$T"; git commit -q -m "test(095c): test corrigé par le superviseur (className SVG)"
  git checkout -q main
  git merge --no-ff -q verif/095c -m "feat(095c): fusionné au vert par le harnais" || annuler "fusion impossible"
  npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 && npm run --silent test >/tmp/victo-test.log 2>&1 \
    || { grep -hE "error TS|FAIL|×|→" /tmp/victo-tsc.log /tmp/victo-test.log | head; annuler "main rouge après fusion"; }
  ok "095c fusionné dans main ($(git rev-parse --short HEAD)), main vert"
  git branch -q -D verif/095c auto/095c
  GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/095c 2>/dev/null || true
  SUITE="Rien à lancer : le lot des filtres est terminé. Vérifie la page /soldes sur http://192.168.40.32:3000"
else
  printf '  \033[33m!\033[0m porte ROUGE sur le code du modèle — rien n'"'"'est fusionné. Échecs :\n'
  grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | head -8 | sed 's/^/      /'
  git checkout -q -f main; git branch -q -D verif/095c
  grep -P '^095c\t' tickets/manifest-liste-v3.tsv > tickets/manifest-rattrapage-095c.tsv
  git add tickets/manifest-rattrapage-095c.tsv; git commit -q -m "chore(tickets): manifeste de relance du 095c"
  ok "relance du 095c préparée : le modèle recevra ces échecs, avec le test corrigé"
  SUITE="MANIFEST=tickets/manifest-rattrapage-095c.tsv ./run.sh      (un ticket, 30 à 60 minutes)"
fi

if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else printf '  \033[33m!\033[0m push refusé (voir /tmp/victo-push.log)\n'; fi
[ -z "$(git status --porcelain)" ] || mort "arbre sale en fin de script : $(git status --porcelain | head -3)"
printf '\nSuite :\n\n    %s\n\n' "$SUITE"
