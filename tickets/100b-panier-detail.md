TICKET 100b — détail et récapitulatif du panier

Crée `src/lib/panier-detail.ts`. Fonctions **pures** : aucune ne modifie ses arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.flatMap`, `.reduce`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Bloc d'imports exact
```ts
import type { Produit, Variante } from '@/lib/catalogue';
import type { Panier } from '@/lib/panier';
```

## Exports exacts
Taille attendue : ~55 lignes.
```ts
export interface LigneDetaillee {
  slug: string;
  sku: string;
  quantite: number;
  produit: Produit;
  variante: Variante;
  totalCents: number;
  economieCents: number;
}
export interface RecapPanier {
  articles: number;
  sousTotalCents: number;
  economiesCents: number;
  totalCents: number;
}
export function detaillerPanier(lignes: Panier, trouver: (slug: string) => Produit | undefined): LigneDetaillee[];
export function recapitulerPanier(lignes: LigneDetaillee[]): RecapPanier;
export function libelleArticles(n: number): string;
```

## Règles
**`detaillerPanier`** : `lignes.flatMap((ligne) => { … })`, où pour chaque ligne :
- `const produit = trouver(ligne.slug);` — s'il est indéfini, renvoie `[]` ;
- `const variante = produit.variantes.find((v) => v.sku === ligne.sku);` — si elle
  est indéfinie, renvoie `[]` ;
- remise unitaire : `produit.prixCompareCents !== undefined && produit.prixCompareCents > produit.prixCents`
  ? `produit.prixCompareCents - produit.prixCents` : `0` ;
- renvoie `[{ slug: ligne.slug, sku: ligne.sku, quantite: ligne.quantite, produit, variante,
  totalCents: produit.prixCents * ligne.quantite, economieCents: remise * ligne.quantite }]`.

**`recapitulerPanier`** : `articles` = somme des `quantite` ; `sousTotalCents` = somme
des `totalCents` ; `economiesCents` = somme des `economieCents` ;
`totalCents` = `sousTotalCents` (livraison offerte, taxes calculées au paiement).
Un panier vide donne quatre zéros.

**`libelleArticles`** renvoie exactement
```ts
`${n} ${n > 1 ? 'articles' : 'article'}`
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
