TICKET 098d — fournisseur du panier autour de tout le site

Modifie `src/app/layout.tsx`. Deux changements, rien d'autre : ni les métadonnées,
ni la balise `<head>`, ni les attributs de `<html>` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ce fichier reste un composant serveur : **pas** de `'use client'`.
- Un seul export par défaut, `RootLayout`, et l'export `metadata` existant.

## Les deux changements
1. Ajoute cet import, à la suite des imports existants :
   ```tsx
   import { PanierProvider } from '@/components/panier/PanierProvider';
   ```
2. Remplace le contenu de `<body>` : `{children}` devient exactement
   ```tsx
   <PanierProvider>{children}</PanierProvider>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
