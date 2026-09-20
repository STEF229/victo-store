TICKET 013 — composant Button

Crée `src/components/ui/Button.tsx`, export nommé `Button`.

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
interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'ghost' | 'accent';
  size?: 'sm' | 'md' | 'lg';
  block?: boolean;
  loading?: boolean;
}
```
Les props HTML non listées (`onClick`, `type`, `disabled`, `aria-*`…) sont
transmises telles quelles au `<button>`.

## Contrat
- `type` vaut `"button"` par défaut, mais un `type` explicite le remplace.
- Attributs constants : `data-ui="button"`, `data-variant`, `data-size`.
- Défauts : `variant="primary"`, `size="md"`.
- `block` ajoute `data-block="true"`. Quand `block` est faux, l'attribut
  `data-block` doit être **absent** (pas `"false"`).
- `loading` rend le bouton `disabled` **et** ajoute `aria-busy="true"`.
  Hors chargement, `aria-busy` ne vaut pas `"true"`.
- `disabled` seul désactive aussi le bouton.
- `className` est ajoutée aux classes internes.

## Style
`primary` : fond `var(--vs-noir)`, texte `var(--vs-blanc)`.
`accent` : fond `var(--vs-accent)`, texte blanc, survol `var(--vs-accent-fonce)`.
En mode `block`, l'aplat couvre toute la largeur : garde des angles doux
(`var(--vs-radius)`) et une hauteur mesurée, un aplat plein écran trop haut
devient agressif.
`ghost` : fond transparent, bordure et texte `var(--vs-noir)`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
