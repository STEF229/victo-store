TICKET 109g — le fournisseur de favoris signale sa présence

Modifie `src/components/favoris/FavorisProvider.tsx`. Le contexte gagne un champ
`present` : `false` hors du fournisseur (valeur par défaut), `true` dedans. Les cartes
produit s'en serviront (ticket 109h). Rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Les trois changements
1. Dans `interface ContexteFavoris`, ajoute `present: boolean;`.
2. Dans la **valeur par défaut** du contexte, ajoute `present: false`.
3. Dans la valeur passée au fournisseur par `FavorisProvider`, ajoute `present: true`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/FavorisProvider.test.tsx`.
