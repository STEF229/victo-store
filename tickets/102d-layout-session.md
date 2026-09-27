TICKET 102d — session autour de tout le site

Modifie `src/app/layout.tsx`. Deux changements, rien d'autre : ni les métadonnées,
ni `<head>`, ni les attributs de `<html>` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le fichier reste un composant serveur : **pas** de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SessionProvider } from '@/components/compte/SessionProvider';
   ```
2. Remplace exactement `<PanierProvider>{children}</PanierProvider>` par
   ```tsx
   <PanierProvider>
     <SessionProvider>{children}</SessionProvider>
   </PanierProvider>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/layout-panier.test.ts`.
