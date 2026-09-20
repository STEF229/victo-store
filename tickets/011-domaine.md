TICKET 011 — modèle de domaine catalogue

Crée `src/lib/catalogue.ts`. C'est le contrat de données partagé par toute la
boutique et par l'admin. Les marques sont une **entité à part entière**, gérées
depuis l'admin : aucun composant ne doit jamais manipuler une marque sous forme
de simple chaîne.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` activé.
- **Exports nommés** uniquement, jamais `export default`.
- Aucune dépendance : ce fichier n'importe rien.
- **Ne modifie aucun fichier de test.**
- Fonctions **pures** : aucun effet de bord, aucune mutation des entrées.

## Types à exporter
```ts
export interface Marque {
  id: string;
  nom: string;
  slug: string;
}

export interface Variante {
  id: string;
  taille: string;      // « 40 », « M », « 32/34 »
  sku: string;
  stock: number;       // entier >= 0
}

export interface Produit {
  id: string;
  slug: string;
  nom: string;
  marque: Marque;
  imageUrl: string;
  prixCents: number;
  prixCompareCents?: number;
  variantes: Variante[];
  badge?: string;
}
```

## Fonctions à exporter

### `hrefProduit(produit: Produit): string`
Retourne `/produits/<slug>`.

### `hrefMarque(marque: Marque): string`
Retourne `/marques/<slug>`.

### `estEnPromotion(produit: Produit): boolean`
Vrai si et seulement si `prixCompareCents` est défini **et** strictement
supérieur à `prixCents`.

### `remisePourcent(produit: Produit): number | null`
`null` hors promotion. Sinon `Math.round((1 - prixCents / prixCompareCents) * 100)`.

### `optionsDeTaille(produit: Produit): Array<{ value: string; available: boolean }>`
Convertit les variantes en options pour `SizeSelector`, **dans l'ordre des
variantes**. `value` vaut `taille`, `available` vaut `stock > 0`.

### `stockTotal(produit: Produit): number`
Somme des stocks des variantes. `0` si aucune variante.

### `estEnRupture(produit: Produit): boolean`
Vrai si `stockTotal` vaut `0`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
