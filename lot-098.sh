#!/usr/bin/env bash
# VICTO STORE — lot 098 : le panier.
#   098a  src/lib/panier.ts                       logique pure (ajout, stock, lecture sûre)
#   098b  src/components/panier/PanierProvider    contexte React + localStorage
#   098c  SiteHeader                              compteur branché sur le panier
#   098d  layout.tsx                              fournisseur autour de tout le site
#   098e* générés ici : un ticket par fichier qui passe cartCount en dur à l'en-tête
# Chaque test passe un pré-vol sur le dépôt réel avant livraison.
# Usage :  cd ~/victo-store && bash lot-098.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ ce que les specs supposent
grep -q 'data-testid="entete-panier-compte"' src/components/ui/SiteHeader.tsx || mort "SiteHeader : entete-panier-compte introuvable"
grep -q 'cartCount' src/components/ui/SiteHeader.tsx || mort "SiteHeader : prop cartCount introuvable"
grep -qF '<body>{children}</body>' src/app/layout.tsx || mort "layout.tsx : <body>{children}</body> introuvable, la spec 098d ne s'appliquerait pas"
grep -q "suppressHydrationWarning" src/app/layout.tsx || mort "layout.tsx : suppressHydrationWarning introuvable"
[ ! -e src/lib/panier.ts ] && [ ! -e src/components/panier/PanierProvider.tsx ] || mort "un fichier du panier existe déjà : lot déjà passé ?"
ok "en-tête, layout et emplacements du panier conformes aux specs"
# À partir d'ici, toute erreur imprévue remet le dépôt dans son état de départ.
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
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
- TypeScript strict, `noUncheckedIndexedAccess` actif. Première ligne : `'use client';`.
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
- TypeScript strict, `noUncheckedIndexedAccess` actif.
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
cat > tickets/098d-layout-panier.md <<'__VICTO_FIN_3__'
TICKET 098d — fournisseur du panier autour de tout le site

Modifie `src/app/layout.tsx`. Deux changements, rien d'autre : ni les métadonnées,
ni la balise `<head>`, ni les attributs de `<html>` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ce fichier reste un composant serveur : **pas** de `'use client'`.
- Un seul export par défaut, `RootLayout`, et l'export `metadata` existant.

## Les deux changements
1. Ajoute cet import, à la suite des imports existants :
   ```tsx
   import { PanierProvider } from '@/components/panier/PanierProvider';
   ```
2. Remplace le contenu de `<body>` : `{children}` devient exactement
   ```tsx
   <PanierProvider>{children}</PanierProvider>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > tickets/tests/panier.test.ts <<'__VICTO_FIN_4__'
import { describe, expect, it } from 'vitest';
import {
  CLE_PANIER, ajouterAuPanier, changerQuantite, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '../src/lib/panier';

const A = { slug: 'pegasus', sku: 'peg-41' };
const B = { slug: 'polo', sku: 'polo-m' };

describe('panier — ajout', () => {
  it('ajoute une ligne à la fin', () => {
    const p = ajouterAuPanier([{ ...A, quantite: 1 }], B, 2, 5);
    expect(p).toEqual([{ ...A, quantite: 1 }, { ...B, quantite: 2 }]);
  });

  it('cumule sur le même sku, plafonné au stock', () => {
    let p: Panier = [];
    p = ajouterAuPanier(p, A, 2, 3);
    p = ajouterAuPanier(p, A, 2, 3);
    expect(p).toEqual([{ ...A, quantite: 3 }]);
  });

  it('plafonne une première ligne au stock et arrondit vers le bas', () => {
    expect(ajouterAuPanier([], A, 9, 4)).toEqual([{ ...A, quantite: 4 }]);
    expect(ajouterAuPanier([], A, 2.9, 5)).toEqual([{ ...A, quantite: 2 }]);
  });

  it('renvoie le même panier pour une quantité nulle ou un stock épuisé', () => {
    const p: Panier = [{ ...A, quantite: 1 }];
    expect(ajouterAuPanier(p, B, 0, 5)).toBe(p);
    expect(ajouterAuPanier(p, B, 0.5, 5)).toBe(p);
    expect(ajouterAuPanier(p, B, 1, 0)).toBe(p);
  });

  it('ne modifie jamais le panier reçu', () => {
    const ligne = { ...A, quantite: 1 };
    const p: Panier = [ligne];
    const suivant = ajouterAuPanier(p, A, 1, 5);
    expect(p).toEqual([{ ...A, quantite: 1 }]);
    expect(ligne.quantite).toBe(1);
    expect(suivant).not.toBe(p);
    expect(suivant[0]).not.toBe(ligne);
  });
});

describe('panier — quantités', () => {
  const p: Panier = [{ ...A, quantite: 2 }, { ...B, quantite: 1 }];

  it('change la quantité en gardant l’ordre, plafonnée au stock', () => {
    expect(changerQuantite(p, 'peg-41', 3, 10)).toEqual([{ ...A, quantite: 3 }, { ...B, quantite: 1 }]);
    expect(changerQuantite(p, 'peg-41', 30, 4)).toEqual([{ ...A, quantite: 4 }, { ...B, quantite: 1 }]);
  });

  it('retire la ligne à zéro', () => {
    expect(changerQuantite(p, 'peg-41', 0, 10)).toEqual([{ ...B, quantite: 1 }]);
  });

  it('renvoie le même panier pour un sku absent', () => {
    expect(changerQuantite(p, 'inconnu', 2, 10)).toBe(p);
  });

  it('retire une ligne', () => {
    expect(retirerDuPanier(p, 'polo-m')).toEqual([{ ...A, quantite: 2 }]);
    expect(p).toHaveLength(2);
  });

  it('compte les articles', () => {
    expect(nombreArticles(p)).toBe(3);
    expect(nombreArticles([])).toBe(0);
  });
});

describe('panier — lecture et écriture', () => {
  it('utilise la clé prévue', () => {
    expect(CLE_PANIER).toBe('victo-panier');
  });

  it('relit ce qu’il a écrit', () => {
    const p: Panier = [{ ...A, quantite: 2 }];
    expect(lirePanier(ecrirePanier(p))).toEqual(p);
    expect(ecrirePanier(p)).toBe(JSON.stringify(p));
  });

  it('rend un panier vide pour une entrée absente ou illisible', () => {
    expect(lirePanier(null)).toEqual([]);
    expect(lirePanier('{pas du json')).toEqual([]);
    expect(lirePanier('{"slug":"a"}')).toEqual([]);
  });

  it('écarte les lignes invalides et les champs inconnus', () => {
    const texte = JSON.stringify([
      { slug: 'a', sku: 'a-1', quantite: 2, prix: 99 },
      { slug: '', sku: 'b-1', quantite: 1 },
      { slug: 'c', sku: 'c-1', quantite: 0 },
      { slug: 'd', sku: 'd-1', quantite: 1.5 },
      null,
      'texte',
    ]);
    expect(lirePanier(texte)).toEqual([{ slug: 'a', sku: 'a-1', quantite: 2 }]);
  });
});
__VICTO_FIN_4__
cat > tickets/tests/PanierProvider.test.tsx <<'__VICTO_FIN_5__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider, usePanier } from '../src/components/panier/PanierProvider';
import { CLE_PANIER } from '../src/lib/panier';

function Temoin() {
  const p = usePanier();
  return (
    <div>
      <span data-testid="nombre">{p.nombre}</span>
      <span data-testid="lignes">{JSON.stringify(p.lignes)}</span>
      <button type="button" onClick={() => p.ajouter({ slug: 'pegasus', sku: 'peg-41' }, 2, 5)}>ajouter</button>
      <button type="button" onClick={() => p.changerQuantite('peg-41', 1, 5)}>une</button>
      <button type="button" onClick={() => p.retirer('peg-41')}>retirer</button>
      <button type="button" onClick={() => p.vider()}>vider</button>
    </div>
  );
}
const cliquer = (nom: string) => fireEvent.click(screen.getByRole('button', { name: nom }));
const nombre = () => screen.getByTestId('nombre').textContent;
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_PANIER) ?? 'null') as unknown;

beforeEach(() => window.localStorage.clear());

describe('usePanier — hors du fournisseur', () => {
  it('voit un panier vide et ne plante pas', () => {
    render(<Temoin />);
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    cliquer('vider');
    expect(nombre()).toBe('0');
  });
});

describe('PanierProvider — actions', () => {
  it('ajoute, cumule et plafonne au stock', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    expect(nombre()).toBe('2');
    cliquer('ajouter');
    cliquer('ajouter');
    expect(nombre()).toBe('5');
  });

  it('change la quantité, retire et vide', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    cliquer('une');
    expect(nombre()).toBe('1');
    cliquer('retirer');
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    cliquer('vider');
    expect(screen.getByTestId('lignes').textContent).toBe('[]');
  });
});

describe('PanierProvider — localStorage', () => {
  it('enregistre chaque changement', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    expect(enregistre()).toEqual([{ slug: 'pegasus', sku: 'peg-41', quantite: 2 }]);
  });

  it('relit le panier enregistré au montage, sans l’écraser', () => {
    const stocke = [{ slug: 'polo', sku: 'polo-m', quantite: 3 }];
    window.localStorage.setItem(CLE_PANIER, JSON.stringify(stocke));
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(nombre()).toBe('3');
    expect(enregistre()).toEqual(stocke);
  });

  it('ignore un enregistrement illisible', () => {
    window.localStorage.setItem(CLE_PANIER, '{pas du json');
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    expect(nombre()).toBe('2');
  });
});
__VICTO_FIN_5__
cat > tickets/tests/entete-compteur.test.tsx <<'__VICTO_FIN_6__'
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
__VICTO_FIN_6__
cat > tickets/tests/layout-panier.test.ts <<'__VICTO_FIN_7__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — fournisseur du panier', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe tout le site dans PanierProvider', () => {
    expect(source).toContain("import { PanierProvider } from '@/components/panier/PanierProvider';");
    expect(source).toContain('<PanierProvider>{children}</PanierProvider>');
  });

  it('reste un composant serveur, avec ses métadonnées', () => {
    expect(source).not.toContain('use client');
    expect(source).toContain('export const metadata');
    expect(source).toContain('suppressHydrationWarning');
    expect(source).toContain("import './globals.css';");
  });
});
__VICTO_FIN_7__
cat > tickets/manifest-098.tsv <<'__VICTO_FIN_8__'
098a	src/lib/panier.ts	tests/panier.test.ts	tickets/098a-panier.md			
098b	src/components/panier/PanierProvider.tsx	tests/PanierProvider.test.tsx	tickets/098b-panier-provider.md	src/lib/panier.ts	098a	
098c	src/components/ui/SiteHeader.tsx	tests/entete-compteur.test.tsx	tickets/098c-entete-compteur.md	src/components/panier/PanierProvider.tsx	098b	
098d	src/app/layout.tsx	tests/layout-panier.test.ts	tickets/098d-layout-panier.md		098b	
__VICTO_FIN_8__
TESTS=(panier.test.ts PanierProvider.test.tsx entete-compteur.test.tsx layout-panier.test.ts)

# ------------------------------------------------------------ cartCount en dur : un ticket par fichier
i=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  i=$((i + 1)); id="098e$i"; spec="tickets/$id-sans-cartcount.md"; t="sans-cartcount-$i.test.ts"
  {
    printf 'TICKET %s — laisser le panier fixer le compteur\n\n' "$id"
    printf 'Modifie `%s`. Un seul changement : sur chaque élément `<SiteHeader`\n' "$f"
    printf 'de ce fichier, retire l'"'"'attribut `cartCount`, avec sa valeur. Rien d'"'"'autre ne\n'
    printf 'change : ni les autres attributs, ni les imports, ni les exports.\n\n'
    printf "L'en-tête lit désormais le nombre d'articles du panier ; une valeur passée ici\n"
    printf "l'écraserait et figerait le compteur.\n\n"
    printf '## Règles absolues\n- **Ne modifie aucun test.** Ne modifie aucun autre fichier.\n'
    printf -- '- Garde le fichier identique à la lettre, en dehors de cet attribut.\n\n'
    printf '## Critère de fin\n`npm run typecheck`, `npm test` et `npm run build` passent.\n'
  } > "$spec"
  cat > "tickets/tests/$t" <<__GEN__
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('$id — compteur laissé au panier', () => {
  it('ne passe plus cartCount à l’en-tête', () => {
    expect(readFileSync('$f', 'utf8')).not.toContain('cartCount');
  });
});
__GEN__
  printf '%s\t%s\ttests/%s\t%s\t\t098c\t\n' "$id" "$f" "$t" "$spec" >> tickets/manifest-098.tsv
  TESTS+=("$t")
  info "$f fixe cartCount : ticket $id généré"
done <<< "$(grep -rlE 'cartCount=' src --include='*.tsx' | grep -vxF src/components/ui/SiteHeader.tsx | sort || true)"
[ "$i" -gt 0 ] || ok "aucune page ne fixe cartCount"
autres="$(grep -rl 'entete-panier-compte' tests | grep -vE 'entete-v3|entete-compteur' || true)"
[ -z "$autres" ] || info "ces tests lisent le compteur de l'en-tête et pourraient attendre une valeur fixe : $(echo $autres)"
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "$(( 4 + i )) tickets écrits, manifeste tickets/manifest-098.tsv"

# ------------------------------------------------------------ contrôle et budget
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/098*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-098.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    if not c[0]: continue
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    existe = os.path.isfile(cible)
    if mode != 'neuf' and existe: car += len(open(cible).read())
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    sortie = int(n.group(1)) * 40 // 3 if n else (len(open(cible).read()) * 11 // 30 if existe else 0)
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB
ok "contrôle : 0 alerte ; budgets dans le plafond"

# ------------------------------------------------------------ pré-vol de chaque test
MAUVAIS='TypeError|ReferenceError|SyntaxError|Transform failed|is not a function|Cannot read propert|is not defined'
for t in "${TESTS[@]}"; do
  p="tests/zz-prevol-$t"; cp "tickets/tests/$t" "$p"
  npx --no-install vitest run "$p" > /tmp/victo-prevol.log 2>&1 || true
  rm -f "$p"; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
  if grep -qE "$MAUVAIS" /tmp/victo-prevol.log; then
    grep -nE "$MAUVAIS" /tmp/victo-prevol.log | head -4
    annuler "pré-vol de $t : le test PLANTE — c'est le test qui est faux"
  elif grep -qE "Failed to resolve import|Cannot find module|Does the file exist" /tmp/victo-prevol.log; then
    ok "pré-vol $t : module à créer, pas encore exécutable (normal)"
  elif grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log; then
    ok "pré-vol $t : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' '), sans plantage"
  else
    tail -12 /tmp/victo-prevol.log; annuler "pré-vol de $t : résultat illisible"
  fi
done

# ------------------------------------------------------------ base verte, commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 098 — panier (logique, contexte, compteur, layout)"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-098.tsv ./run.sh\n\n%s tickets enchaînés : 098b attend 098a ; 098c et 098d attendent 098b.\nCompte une heure à une heure et demie.\n' "$(( 4 + i ))"
