TICKET 114v — la page de sous-catégorie reçoit les produits de sa route

Modifie `src/components/catalogue/PageSousCategorie.tsx`. Une prop facultative `produits` (passée par les routes) ; sans elle, les données de démonstration, comme avant.

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
import type { Produit } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function PageSousCategorie({ rubrique, chemin }: { rubrique: Rubrique; chemin: string[] }) {
```
Après :
```tsx
export function PageSousCategorie({ rubrique, chemin, produits }: { rubrique: Rubrique; chemin: string[]; produits?: Produit[] | undefined }) {
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
  const tous = listerProduits();
```
Après :
```tsx
  const tous = produits ?? listerProduits();
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
