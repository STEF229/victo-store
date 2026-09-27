TICKET 101b — la barre de filtres transmet le nombre de résultats au tiroir

Modifie `src/components/catalogue/FiltresBarre.tsx`. Le fichier actuel est correct
et testé : tu ajoutes une prop facultative et tu la transmets, rien d'autre.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune classe, aucun texte, aucun
  `data-testid` ne change.

## Les deux changements
1. Dans `interface FiltresBarreProps`, ajoute, après `onTriChange`, exactement :
   `nombreResultats?: number | undefined;`
   et lis cette prop avec les autres.
2. Sur l'élément `<TiroirsFiltres …>`, ajoute l'attribut
   `nombreResultats={nombreResultats}`. Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/FiltresBarre.test.tsx` et `tests/FiltresBarre-v3.test.tsx` (comportement existant).
