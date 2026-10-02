TICKET 109a — la page ne déborde plus jamais sur le côté

Modifie `src/app/layout.tsx`. Deux balises reçoivent des attributs, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Les fournisseurs (favoris, panier, session), les métadonnées et `<head>` ne bougent pas.

## Les deux remplacements
1. Remplace exactement `<html lang="fr" suppressHydrationWarning>` par
   `<html lang="fr" suppressHydrationWarning className="overflow-x-clip">`
2. Remplace exactement `<body>` par
   `<body className="overflow-x-clip" suppressHydrationWarning>`

(`suppressHydrationWarning` sur `<body>` fait taire l'avertissement causé par les
extensions de navigateur, comme Grammarly, qui ajoutent leurs attributs au `<body>`.)

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests `layout-*`.
