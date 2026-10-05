TICKET 114i — les favoris retrouvent leurs produits dans le catalogue du site

Modifie `src/app/compte/favoris/page.tsx`. Chaque favori retrouve son produit dans `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { trouverProduit } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const favoris = useFavoris();
  const produits = favoris.favoris.flatMap((slug) => {
    const p = trouverProduit(slug);
```
Après :
```tsx
  const favoris = useFavoris();
  const catalogue = useCatalogue();
  const produits = favoris.favoris.flatMap((slug) => {
    const p = catalogue.produits.find((x) => x.slug === slug);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
