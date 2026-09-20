TICKET 031 — filtrage, tri et pagination

Crée `src/lib/filtres.ts` : toute la logique du catalogue, sans aucun React.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée aucun autre fichier.
- Couleurs uniquement via les tokens `var(--vs-*)`. Jamais de valeur en dur.
- Le cobalt `--vs-accent` est la couleur des actions ; `--vs-promo` (rouge) est
  réservé aux remises.
- **Aucun fichier baril nexiste.** Chaque composant a son module. Nimporte
  jamais depuis un dossier (`@/components/ui`, `../../components/ui`…).
- Les attributs `data-testid` décrits sont un contrat testé. Les classes
  Tailwind sont libres.

## Bloc d'imports exact
```ts
import type { Produit } from '@/lib/catalogue';
import { estEnPromotion, remisePourcent, stockTotal } from '@/lib/catalogue';
```

## Types à exporter
```ts
export interface Criteres {
  marques?: string[];        // slugs de marque
  tailles?: string[];        // valeurs de taille
  promotionSeulement?: boolean;
  enStockSeulement?: boolean;
}

export type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';

export interface Page<T> {
  items: T[];
  page: number;
  pages: number;
  total: number;
}
```

## `filtrerProduits(produits: Produit[], criteres: Criteres): Produit[]`
- Un critère absent ou à tableau vide **ne filtre rien**.
- `marques` : garde les produits dont `marque.slug` est dans la liste.
- `tailles` : garde les produits ayant **au moins une variante** dont la
  `taille` est dans la liste, **quel que soit son stock**.
- `promotionSeulement: true` : garde ceux pour lesquels `estEnPromotion` est vrai.
- `enStockSeulement: true` : garde ceux dont `stockTotal` est strictement positif.
- Les critères se **cumulent** (ET logique).
- Retourne un **nouveau tableau**, sans muter l'entrée ni son ordre d'origine.

## `trierProduits(produits: Produit[], tri: Tri): Produit[]`
Retourne un **nouveau tableau** trié, sans muter l'entrée.
- `nouveautes` : conserve l'ordre reçu, à l'identique.
- `prix-croissant` : `prixCents` croissant.
- `prix-decroissant` : `prixCents` décroissant.
- `remise` : pourcentage de remise décroissant ; un produit sans promotion
  compte pour `0` et se retrouve donc à la fin.
- À valeur égale, l'ordre relatif d'origine est conservé (tri stable).

## `paginer<T>(items: T[], page: number, parPage: number): Page<T>`
- `page` commence à **1**. Une page hors bornes est ramenée dans `[1, pages]`.
- `pages` vaut `Math.max(1, Math.ceil(total / parPage))`.
- Une liste vide donne `{ items: [], page: 1, pages: 1, total: 0 }`.
- `parPage` inférieur à 1 lève `new RangeError('paginer: parPage doit être >= 1')`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
