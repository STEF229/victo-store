TICKET 114t — la fiche produit lit le catalogue du site

Modifie `src/app/produits/[slug]/page.tsx`. Le produit et les produits similaires viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits, trouverProduit } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const produit = trouverProduit(slug);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const produit = catalogue.produits.find((p) => p.slug === slug);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produitsSimilaires(produit, listerProduits())
```
Après :
```tsx
produitsSimilaires(produit, catalogue.produits)
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
