TICKET 104f — favoris autour de tout le site

Modifie `src/app/layout.tsx`. Trois changements, rien d'autre : ni les métadonnées,
ni `<head>`, ni les attributs de `<html>`, ni `SessionProvider` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le fichier reste un composant serveur : **pas** de `'use client'`.

## Les trois changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { FavorisProvider } from '@/components/favoris/FavorisProvider';
   ```
2. Remplace la balise ouvrante `<PanierProvider>` par `<FavorisProvider><PanierProvider>`.
3. Remplace la balise fermante `</PanierProvider>` par `</PanierProvider></FavorisProvider>`.

`FavorisProvider` enveloppe donc `PanierProvider`, qui enveloppe toujours
`SessionProvider` exactement comme aujourd'hui.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/layout-panier.test.ts`
et `tests/layout-session.test.ts`.
