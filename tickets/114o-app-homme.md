TICKET 114o — la page Homme lit le catalogue du site

Modifie `src/app/homme/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageHomme() {
  return (
```
Après :
```tsx
export default async function PageHomme() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().filter(
```
Après :
```tsx
produits={produits.filter(
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
sousCategories(listerProduits(), 'homme', [])
```
Après :
```tsx
sousCategories(produits, 'homme', [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
