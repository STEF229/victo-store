TICKET 105c — le cœur de la carte produit reste dans sa carte

Modifie `src/components/ui/ProductCard.tsx`. Le bouton « Ajouter aux favoris » est en
`absolute top-2 right-2`, mais aucun de ses ancêtres dans la carte n'est positionné :
sur une page, tous les cœurs remontent au coin de l'écran, par-dessus l'en-tête.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le bouton garde exactement ses classes et son comportement. Aucune autre ligne ne change.

## Le changement
L'élément qui enveloppe **à la fois** le lien `<a>` de la carte et le bouton
« Ajouter aux favoris » (le `<div>` juste au-dessus du bouton) reçoit la classe
`relative` : ajoute `relative` au début de son `className` (s'il n'en a pas, donne-lui
`className="relative"`).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
