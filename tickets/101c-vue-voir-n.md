TICKET 101c — la page de liste donne le nombre de résultats au tiroir

Modifie `src/components/catalogue/VueCatalogue.tsx`. Un seul changement.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune autre ligne ne change.

## Le changement
Le composant calcule déjà `const n = resultats.length;` (c'est le nombre affiché par
le compteur). Sur l'élément `<FiltresBarre …>`, ajoute, après
`onTriChange={changerTri}`, l'attribut `nombreResultats={n}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/VueCatalogue-v2.test.tsx` (comportement existant).
