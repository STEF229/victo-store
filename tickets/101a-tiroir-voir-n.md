TICKET 101a — le tiroir mobile annonce « Voir N produits »

Modifie `src/components/catalogue/TiroirsFiltres.tsx`. Le fichier actuel est
correct et testé : tu ajoutes une prop facultative, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune classe ne change.

## Les trois changements
1. Dans `interface TiroirsFiltresProps`, ajoute, après `onFermer`, exactement :
   `nombreResultats?: number | undefined;`
2. Lis cette prop avec les autres, puis, avant le `return`, ajoute exactement :
   ```tsx
   const libelleValider =
     nombreResultats === undefined
       ? 'Appliquer les filtres'
       : `Voir ${nombreResultats} ${nombreResultats > 1 ? 'produits' : 'produit'}`;
   ```
3. Le bouton de classe `VALIDER` affiche `{libelleValider}` au lieu du texte fixe
   `Appliquer les filtres`. Ses autres attributs ne changent pas.

Sans la prop, le bouton garde donc son texte actuel.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/TiroirsFiltres.test.tsx` (comportement existant).
