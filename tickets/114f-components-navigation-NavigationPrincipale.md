TICKET 114f — le méga-menu lit le catalogue du site

Modifie `src/components/navigation/NavigationPrincipale.tsx`. Les marques et le nombre de produits viennent de `useCatalogue()` (Medusa ou démonstration), plus des données écrites dans le code.

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
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
function PanneauMega({ panneau }: { panneau: Panneau }) {
  if (panneau === 'marques') {
```
Après :
```tsx
function PanneauMega({ panneau }: { panneau: Panneau }) {
  const catalogue = useCatalogue();
  if (panneau === 'marques') {
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
produitsDe(listerProduits(), panneau, [])
```
Après :
```tsx
produitsDe(catalogue.produits, panneau, [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
