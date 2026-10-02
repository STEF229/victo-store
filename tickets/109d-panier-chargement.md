TICKET 109d — sur téléphone, le chargement du panier ne laisse plus un grand vide

Modifie `src/components/panier/VuePanier.tsx`. Une seule valeur de classe change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Sur l'élément `data-testid="panier-chargement"`, remplace exactement
`className="min-h-[320px]"` par `className="min-h-[320px] max-sm:min-h-[96px]"`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests du panier.
