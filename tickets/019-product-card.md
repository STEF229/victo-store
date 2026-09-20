TICKET 019 — composant ProductCard

Crée `src/components/ui/ProductCard.tsx`, export nommé `ProductCard`.
C'est la brique du catalogue : elle doit rendre la bonne affaire lisible d'un
coup d'œil.

## Règles absolues (valables pour tous les tickets)
- TypeScript strict, `noUncheckedIndexedAccess` activé.
- **Exports nommés** uniquement, jamais `export default`.
- Aucune dépendance nouvelle : seulement React et ce qui existe déjà dans `src/`.
- **Ne modifie aucun fichier de test.** Les tests font foi.
- Ne crée et ne modifie aucun autre fichier que celui indiqué.
- Styles en classes Tailwind. Les couleurs passent **toujours** par les tokens
  (`text-[var(--vs-noir)]`, `bg-[var(--vs-accent)]`…), jamais de valeur en dur.
- Les attributs `data-*` et `data-testid` décrits sont un **contrat** : ils sont
  testés. Les classes Tailwind, elles, sont libres.

## Props
```ts
{ produit: Produit; className?: string }
```
`Produit` vient de `src/lib/catalogue.ts` : ne le redéfinis pas, importe-le.

## Dépendances imposées
Réutilise `Price` (`./Price`), `Badge` (`./Badge`) et `hrefProduit` de
`../../lib/catalogue`. N'écris ni formatage de prix, ni construction d'URL, ni
pastille à la main.

## Contrat
- Racine : `<article data-ui="product-card" data-testid="carte-produit">`
  portant `data-produit-id={produit.id}`.
- **Un seul** `<a>` dans la carte, dont le `href` vient de
  `hrefProduit(produit)`, et qui enveloppe l'image et le contenu textuel.
- `<img src={produit.imageUrl}>` dont le `alt` contient le nom de la marque
  **et** le nom du produit.
- `<span data-testid="carte-marque">` contenant `produit.marque.nom`. C'est un simple
  élément stylé, **pas** le composant `Badge` : le test vérifie qu'aucun
  `data-testid="badge"` n'existe tant que `produit.badge` n'est pas fourni.
- `<span data-testid="carte-nom">` contenant le nom.
- `<Price amount={produit.prixCents} compareAt={produit.prixCompareCents} />`.
- Si et seulement si `produit.badge` est fourni : `<Badge variant="promo">`
  contenant ce texte, positionné en superposition sur l'image.

## Style
Image en ratio 4/5, coins arrondis, fond `var(--vs-surface)`. Marque en petites
capitales `var(--vs-gris)`, nom en `var(--vs-noir)`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
