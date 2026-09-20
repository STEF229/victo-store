TICKET 014 — composant Badge

Crée `src/components/ui/Badge.tsx`, export nommé `Badge`.

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
{ children: ReactNode; variant?: 'promo' | 'neutre' | 'marque' | 'nouveau'; className?: string }
```

## Contrat
- Rend un `<span>` portant `data-ui="badge"`, `data-testid="badge"` et
  `data-variant` (défaut `"neutre"`).
- `className` est ajoutée aux classes internes.

## Style
`promo` : fond `var(--vs-promo)`, texte blanc, graisse lourde — c'est le badge
de remise, le plus voyant.
`nouveau` : fond `var(--vs-noir)`, texte blanc.
`marque` : fond transparent, bordure `var(--vs-ligne)`, texte `var(--vs-gris)`,
petites capitales espacées — c'est la puce de marque des cartes produit.
`neutre` : fond `var(--vs-surface)`, texte `var(--vs-noir)`.
Dans tous les cas : petit, arrondi, compact.

## Critère de fin
`npm run typecheck` et `npm test` passent.
