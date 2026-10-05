TICKET 114h — le panier retrouve ses produits dans le catalogue du site

Modifie `src/components/panier/VuePanier.tsx`. Chaque ligne du panier retrouve son produit dans `useCatalogue()`.

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
  const panier = usePanier();
```
Après :
```tsx
  const panier = usePanier();
  const catalogue = useCatalogue();
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
detaillerPanier(panier.lignes, trouverProduit)
```
Après :
```tsx
detaillerPanier(panier.lignes, (slug) => catalogue.produits.find((p) => p.slug === slug))
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
