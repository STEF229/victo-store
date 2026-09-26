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
