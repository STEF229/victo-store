TICKET 114r — la page d’une marque lit le catalogue du site

Modifie `src/app/marques/[slug]/page.tsx`. La marque et ses produits viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { produitsDeMarque, trouverMarque } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const marque = trouverMarque(slug);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const marque = catalogue.marques.find((m) => m.slug === slug);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={produitsDeMarque(slug)}
```
Après :
```tsx
produits={catalogue.produits.filter((p) => p.marque.slug === slug)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
