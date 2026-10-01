TICKET 108c — la vue des listes accepte un bandeau sous son titre

Modifie `src/components/catalogue/VueCatalogue.tsx`. Le fichier actuel est correct et
testé : tu ajoutes une prop facultative, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre ligne ne change : titre, compteur, barre de filtres, grille et pagination
  restent identiques.

## Les trois changements
1. Si `ReactNode` n'est pas déjà importé, ajoute `import type { ReactNode } from 'react';`
   à la suite des imports existants.
2. Dans les props de `VueCatalogue`, ajoute `entete?: ReactNode | undefined;` et lis-la
   avec les autres.
3. Rends `{entete}` **juste avant** l'élément `<FiltresBarre …>` : entre le bloc du titre
   (titre, description, compteur) et la barre de filtres.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/VueCatalogue-v2.test.tsx`.
