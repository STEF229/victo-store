TICKET 114u — la recherche lit le catalogue du site

Modifie `src/app/recherche/page.tsx`. Les résultats, les marques et les suggestions viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const resultats = rechercherProduits(listerProduits(), terme);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const resultats = rechercherProduits(catalogue.produits, terme);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
{listerMarques().map((m) => (
```
Après :
```tsx
{catalogue.marques.map((m) => (
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().slice(0, 4)}
```
Après :
```tsx
produits={catalogue.produits.slice(0, 4)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
