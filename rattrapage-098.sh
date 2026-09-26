#!/usr/bin/env bash
# VICTO STORE — rattrapage du lot 098 (panier).
# 098a a calé sur noUncheckedIndexedAccess : la spec ne disait pas comment lire un
# tableau. Elle impose maintenant les formes .find / .map / garde de type, vérifiées
# avec tsc strict. 098b et 098c reçoivent la même consigne ; le contrôle refuse
# désormais toute spec qui cite noUncheckedIndexedAccess sans elle.
# Le script lit aussi tests/SiteHeader.test.tsx : s'il attend une pastille « 0 »
# visible, la règle « pas de pastille à zéro » est retirée du 098c avant le run.
# Usage :  cd ~/victo-store && bash rattrapage-098.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git reset -q --hard HEAD; git clean -fdq -- tests tickets outils; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"
[ -f tickets/manifest-098.tsv ] || mort "tickets/manifest-098.tsv absent : lancer d'abord lot-098.sh"
git log main -1 --format=%h --fixed-strings --grep="feat(098a): fusionné" | grep -q . && mort "098a est déjà fusionné : rien à rattraper"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
cat > tickets/098a-panier.md <<'__VICTO_FIN_0__'
TICKET 098a — logique du panier

Crée `src/lib/panier.ts`. Fonctions **pures** : aucune ne modifie ses arguments,
aucune ne lit ni n'écrit `localStorage` (le ticket suivant s'en charge).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Aucun import.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Jamais de `.push`, `.splice` ni d'affectation sur un élément reçu : chaque
  changement renvoie un **nouveau** tableau et de **nouveaux** objets pour les
  lignes modifiées. Les lignes non concernées gardent leur ordre.

## Exports exacts
Taille attendue : ~60 lignes.
```ts
export interface LignePanier {
  slug: string;
  sku: string;
  quantite: number;
}
export type Panier = LignePanier[];
export const CLE_PANIER = 'victo-panier';

export function ajouterAuPanier(
  panier: Panier,
  article: { slug: string; sku: string },
  quantite: number,
  stock: number,
): Panier;
export function changerQuantite(panier: Panier, sku: string, quantite: number, stock: number): Panier;
export function retirerDuPanier(panier: Panier, sku: string): Panier;
export function nombreArticles(panier: Panier): number;
export function lirePanier(texte: string | null): Panier;
export function ecrirePanier(panier: Panier): string;
```

## Accès aux tableaux — formes imposées
`noUncheckedIndexedAccess` rend `panier[i]` « peut-être `undefined` ». Donc
**aucun accès par index** (`panier[i]`), **aucun `findIndex`**, et jamais de
`{ ...x }` sur une valeur qui peut être `undefined`. Utilise exactement ces formes :

```ts
// chercher une ligne
const existante = panier.find((l) => l.sku === sku);
if (existante) {
  // existante.quantite est un number
}

// remplacer une ligne, en gardant l'ordre et les autres lignes intactes
panier.map((l) => (l.sku === sku ? { slug: l.slug, sku: l.sku, quantite: nouvelle } : l));

// valider un élément lu dans localStorage
function estLigne(x: unknown): x is LignePanier {
  return (
    typeof x === 'object' && x !== null &&
    'slug' in x && typeof x.slug === 'string' && x.slug !== '' &&
    'sku' in x && typeof x.sku === 'string' && x.sku !== '' &&
    'quantite' in x && typeof x.quantite === 'number' && Number.isInteger(x.quantite) && x.quantite > 0
  );
}
// puis, si le JSON lu est un tableau :
donnees.filter(estLigne).map((l) => ({ slug: l.slug, sku: l.sku, quantite: l.quantite }));
```
`estLigne` n'est pas exportée.

## Règles de calcul
Une ligne est identifiée par son `sku`. Toute quantité reçue est d'abord
arrondie vers le bas avec `Math.floor`.

- **`ajouterAuPanier`** : si la quantité arrondie est `<= 0` ou si `stock <= 0`,
  renvoie `panier` **lui-même**, inchangé. Sinon, si une ligne a déjà ce `sku`,
  sa quantité devient `Math.min(ancienne + quantité, stock)`. Sinon, ajoute à la
  fin `{ slug, sku, quantite: Math.min(quantité, stock) }`.
- **`changerQuantite`** : si aucune ligne n'a ce `sku`, renvoie `panier`
  lui-même. Sinon la nouvelle quantité vaut `Math.min(quantité, stock)` ; si elle
  est `<= 0`, la ligne est retirée ; sinon la ligne prend cette quantité.
- **`retirerDuPanier`** : renvoie un nouveau tableau sans la ligne de ce `sku`.
- **`nombreArticles`** : somme des quantités (0 pour un panier vide).
- **`lirePanier`** : `null` → `[]`. Sinon `JSON.parse` dans un `try` ; en cas
  d'erreur, ou si le résultat n'est pas un tableau → `[]`. Garde seulement les
  éléments qui sont des objets non nuls avec `slug` et `sku` chaînes non vides et
  `quantite` entier (`Number.isInteger`) strictement positif, et renvoie pour
  chacun un objet neuf `{ slug, sku, quantite }` sans aucun autre champ.
- **`ecrirePanier`** : `JSON.stringify(panier)`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > tickets/098b-panier-provider.md <<'__VICTO_FIN_1__'
TICKET 098b — contexte du panier, gardé dans localStorage

Crée `src/components/panier/PanierProvider.tsx`, avec deux exports nommés :
`PanierProvider` (le fournisseur) et `usePanier` (le crochet de lecture).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`. Première ligne : `'use client';`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Tout le calcul passe par les fonctions de `@/lib/panier` (leurs déclarations te
  sont fournies en lecture seule) : ce fichier ne recalcule rien lui-même.
- Tout accès à `localStorage` est dans un `try { … } catch { }` : navigation
  privée ou stockage plein ne doivent jamais faire planter la page.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import {
  ajouterAuPanier, changerQuantite, CLE_PANIER, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '@/lib/panier';
```

## Contrat exporté
Taille attendue : ~70 lignes.
```ts
export interface ContextePanier {
  lignes: Panier;
  nombre: number;
  ajouter: (article: { slug: string; sku: string }, quantite: number, stock: number) => void;
  changerQuantite: (sku: string, quantite: number, stock: number) => void;
  retirer: (sku: string) => void;
  vider: () => void;
}
```
Le contexte est créé avec `createContext<ContextePanier>(…)` et une **valeur par
défaut** : `lignes` vaut `[]`, `nombre` vaut `0`, et les quatre fonctions ne font
rien. Ainsi un composant qui appelle `usePanier()` hors du fournisseur (dans un
test par exemple) voit un panier vide, sans erreur.

`export function usePanier(): ContextePanier` renvoie `useContext(...)` de ce contexte.

`export function PanierProvider({ children }: { children: ReactNode })` :
1. état `lignes` (type `Panier`), initialement `[]` ; état `pret` (booléen),
   initialement `false` ;
2. **au montage** (effet sans dépendance, tableau `[]`) : lit
   `window.localStorage.getItem(CLE_PANIER)`, passe le texte à `lirePanier`, met
   le résultat dans `lignes`, puis met `pret` à `true` ;
3. **à chaque changement de `lignes`**, seulement quand `pret` est vrai (effet
   dépendant de `[lignes, pret]`) : écrit `ecrirePanier(lignes)` sous `CLE_PANIER`.
   Tant que `pret` est faux, rien n'est écrit : sinon le panier vide du premier
   rendu écraserait le panier enregistré ;
4. les fonctions mettent à jour `lignes` **par la forme fonctionnelle**
   `setLignes((precedent) => …)` :
   `ajouter` → `ajouterAuPanier(precedent, article, quantite, stock)`,
   `changerQuantite` → `changerQuantite(precedent, sku, quantite, stock)`,
   `retirer` → `retirerDuPanier(precedent, sku)`, `vider` → `[]` ;
5. `nombre` vaut `nombreArticles(lignes)` ;
6. rend le fournisseur du contexte autour de `children`.

La fonction `changerQuantite` du contexte porte le même nom que celle importée :
à l'intérieur du composant, appelle l'importée en la qualifiant clairement, par
exemple en déclarant la fonction du contexte sous un autre nom local
(`const modifierQuantite = …`) et en la plaçant dans l'objet de contexte sous la
clé `changerQuantite`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > tickets/098c-entete-compteur.md <<'__VICTO_FIN_2__'
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
3. **Signature** : la prop `cartCount` reste dans les props, mais **sans valeur par
   défaut**. Si la signature contient `cartCount = 0` (ou toute autre valeur par
   défaut), remplace-la par `cartCount` seul.
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
__VICTO_FIN_2__
cat > tickets/tests/entete-compteur.test.tsx <<'__VICTO_FIN_3__'
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

  it('ne donne plus de valeur par défaut à cartCount', () => {
    expect(source).not.toMatch(/cartCount\s*=\s*[^=]/);
  });
});
__VICTO_FIN_3__
cat > outils/controle-lot.py <<'__VICTO_FIN_4__'
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
__VICTO_FIN_4__
ok "specs 098a, 098b, 098c et contrôle mis à jour"

# ------------------------------------------------------------ le test existant de l'en-tête
T=tests/SiteHeader.test.tsx
if [ -f "$T" ]; then
  echo "    lignes de $T sur le compteur :"
  grep -nE "cartCount|entete-panier-compte" "$T" | sed 's/^/      /' || echo "      (aucune)"
  if grep -E "entete-panier-compte" "$T" | grep -qE "['\"]0['\"]"; then
    python3 - <<'PYC'
def rep(p, a, b):
    s = open(p).read(); assert s.count(a) == 1, (p, a[:40]); open(p, 'w').write(s.replace(a, b))
rep('tickets/098c-entete-compteur.md', '## Les cinq changements', '## Les quatre changements')
s = open('tickets/098c-entete-compteur.md').read()
debut = s.index('5. L\'élément `data-testid="entete-panier-compte"`')
fin = s.index('\n\n', debut)
open('tickets/098c-entete-compteur.md', 'w').write(s[:debut].rstrip('\n') + s[fin:])
t = 'tickets/tests/entete-compteur.test.tsx'; s = open(t).read()
debut = s.index("  it('n’affiche aucune pastille pour un panier vide'")
fin = s.index("  it('laisse une valeur explicite", debut)
open(t, 'w').write(s[:debut] + s[fin:])
PYC
    info "$T attend une pastille « 0 » : règle « pas de pastille à zéro » retirée du 098c et de son test"
  else
    ok "$T n'attend pas de pastille « 0 » : la règle du 098c est compatible"
  fi
else
  ok "pas de $T : rien à concilier"
fi

# ------------------------------------------------------------ contrôle du lot entier
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/098*.md "$CTL/"
cut -f3 tickets/manifest-098.tsv | while read -r t; do cp "tickets/tests/$(basename "$t")" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
ok "contrôle du lot 098 : 0 alerte"

npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests outils
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "fix(tickets): 098 — formes d'accès aux tableaux imposées, règle ajoutée au contrôle"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
git branch -q -D auto/098a 2>/dev/null || true
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-098.tsv ./run.sh\n\nLes %s tickets du lot, dans le même ordre. Compte une heure à une heure et demie.\n' "$(wc -l < tickets/manifest-098.tsv)"
