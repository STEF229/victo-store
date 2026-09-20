TICKET 018 — composant QuantityStepper

Crée `src/components/ui/QuantityStepper.tsx`, export nommé `QuantityStepper`.
Contrôle de quantité du panier et de la fiche produit.

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
{ value: number; onChange: (value: number) => void; min?: number; max?: number; className?: string }
```
Défauts : `min = 1`, `max = 99`.

## Dépendance imposée
Les bornes passent **obligatoirement** par `clampQuantity` de
`src/lib/clampQuantity.ts`. Ne réécris pas de logique de bornage.

## Contrat
- Racine `<div data-ui="quantity">`.
- Bouton de retrait : `<button type="button" aria-label="Diminuer la quantité">`,
  `disabled` quand `value <= min`.
- Affichage : `<span data-testid="quantite-valeur">` contenant la valeur.
- Bouton d'ajout : `<button type="button" aria-label="Augmenter la quantité">`,
  `disabled` quand `value >= max`.
- Clic sur retrait : `onChange(clampQuantity(value - 1, min, max))`.
- Clic sur ajout : `onChange(clampQuantity(value + 1, min, max))`.
- Un bouton désactivé ne déclenche jamais `onChange`.

Le composant est **contrôlé** : il ne garde aucun état interne.

## Critère de fin
`npm run typecheck` et `npm test` passent.
