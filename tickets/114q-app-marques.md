TICKET 114q — la page Marques lit le catalogue du site

Modifie `src/app/marques/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { MARQUES, PRODUITS } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageMarques() {
  const resumes = resumerMarques(MARQUES, PRODUITS);
```
Après :
```tsx
export default async function PageMarques() {
  const { produits, marques } = await chargerCatalogue();
  const resumes = resumerMarques(marques, produits);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
