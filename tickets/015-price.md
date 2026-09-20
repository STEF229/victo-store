TICKET 015 — composant Price

Crée `src/components/ui/Price.tsx`, export nommé `Price`. C'est la pièce
centrale du positionnement « grandes marques au bon prix ».

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
{ amount: number; compareAt?: number; className?: string }
```
`amount` et `compareAt` sont des **entiers en cents**.

## Dépendance imposée
Le formatage passe **obligatoirement** par `formatPrice` de
`src/lib/formatPrice.ts`. Ne réécris pas de logique de formatage.

## Contrat
Élément racine : `<div data-ui="price" data-testid="prix">` portant
`data-promo="true"` ou `"false"`.

Il y a promotion si et seulement si `compareAt` est fourni **et**
strictement supérieur à `amount`.

Toujours présent :
- `<span data-testid="prix-courant">` contenant `formatPrice(amount)`.

Seulement en promotion :
- `<s data-testid="prix-compare">` contenant `formatPrice(compareAt)`.
- `<span data-testid="prix-remise">` contenant le pourcentage de remise, au
  format `−30 %` : le signe **moins mathématique U+2212** (`'\u2212'`),
  le nombre, une **espace insécable U+00A0**, puis `%`.
  Calcul : `Math.round((1 - amount / compareAt) * 100)`.

Hors promotion, ces deux éléments doivent être **absents du DOM**, pas cachés.

## Style
Prix courant en `var(--vs-promo)` et graisse lourde quand il y a promotion,
en `var(--vs-noir)` sinon. Prix barré en `var(--vs-gris)`, plus petit.
Pourcentage de remise en `var(--vs-promo)`.
N'utilise **jamais** `var(--vs-accent)` ici : le cobalt est la couleur des
actions, le rouge celle des promotions.

## Critère de fin
`npm run typecheck` et `npm test` passent.
