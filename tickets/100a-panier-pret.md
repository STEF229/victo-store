TICKET 100a — le contexte du panier dit quand il est prêt

Modifie `src/components/panier/PanierProvider.tsx`. Le fichier actuel est correct et
testé : tu n'ajoutes qu'un champ `pret`, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Ne change aucune autre ligne.

## Les trois changements
1. Dans `interface ContextePanier`, juste après la ligne `nombre: number;`, ajoute
   exactement `pret: boolean;`.
2. Dans la **valeur par défaut** du contexte (celle passée à `createContext`),
   ajoute `pret: true`. Hors du fournisseur, un composant voit donc un panier vide
   et prêt.
3. Dans l'objet passé au fournisseur, ajoute `pret` : c'est l'état `pret` qui existe
   déjà dans le composant (faux au premier rendu, vrai une fois le panier relu).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/PanierProvider.test.tsx` (comportement existant).
