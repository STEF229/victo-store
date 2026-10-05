TICKET 114k — le gabarit du site charge le catalogue

Modifie `src/app/layout.tsx`. Le serveur charge le catalogue une fois par page et le transmet aux
composants du navigateur.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ne change ni les métadonnées, ni `<html>`, ni `<body>`, ni l'ordre des fournisseurs existants.

## Les quatre changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { CatalogueProvider } from '@/components/catalogue/CatalogueProvider';
   import { chargerCatalogue } from '@/lib/catalogue-source';
   ```
2. La fonction `RootLayout` devient asynchrone : `export default function RootLayout(` devient
   `export default async function RootLayout(` (ses paramètres ne changent pas).
3. Première ligne de son corps, avant le `return` : `const catalogue = await chargerCatalogue();`
4. Entoure **tout** l'élément `<FavorisProvider>…</FavorisProvider>` (avec ce qu'il contient) par
   `<CatalogueProvider valeur={catalogue}>` et `</CatalogueProvider>`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests `layout-*`.
