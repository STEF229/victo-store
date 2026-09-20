TICKET 030 — jeu de données du catalogue

Crée `src/lib/donnees.ts` : le catalogue fictif qui alimentera la boutique
jusqu'au branchement sur Medusa.

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
import type { Marque, Produit } from '@/lib/catalogue';
```

## À exporter
- `MARQUES: Marque[]` — exactement **6** marques réelles du prêt-à-porter et de
  la chaussure (Nike, Adidas, Converse, Lacoste, Levi's, New Balance par exemple),
  chacune avec `id`, `nom` et `slug` en minuscules sans accent.
- `PRODUITS: Produit[]` — exactement **12** produits.
- `listerProduits(): Produit[]` — une **copie** du tableau.
- `listerMarques(): Marque[]` — une **copie** du tableau.
- `trouverProduit(slug: string): Produit | undefined`.
- `taillesCatalogue(): string[]` — toutes les tailles distinctes de tous les
  produits, **triées par ordre croissant** : les tailles numériques en premier
  dans l'ordre numérique, puis les tailles alphabétiques dans l'ordre
  `S, M, L, XL`.

## Contraintes sur les données
- `id` et `slug` uniques sur les 12 produits.
- Chaque `produit.marque` est **un des objets de `MARQUES`**, pas une copie.
- Chaque produit a **au moins 2 variantes**, chacune avec un `sku` unique.
- `prixCents` strictement positif.
- **Au moins 4** produits en promotion (`prixCompareCents` > `prixCents`).
- **Au moins 1** produit dont toutes les variantes ont `stock: 0`.
- `imageUrl` vaut obligatoirement `/img/pegasus.svg`, `/img/chuck70.svg` ou
  `/img/polo.svg` — ce sont les seuls visuels présents.
- Les fonctions sont **pures** : aucune mutation des tableaux exportés.

## Critère de fin
`npm run typecheck` et `npm test` passent.
