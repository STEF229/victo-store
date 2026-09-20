TICKET 017 — composant SizeSelector

Crée `src/components/ui/SizeSelector.tsx`, export nommé `SizeSelector`.
Sélecteur de taille ou de pointure de la fiche produit.

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
interface SizeOption { value: string; available: boolean }
interface SizeSelectorProps {
  sizes: SizeOption[];
  value?: string | null;
  onChange: (value: string) => void;
  label?: string;
  className?: string;
}
```

## Contrat
- Racine : `<div data-ui="size-selector" role="group">` avec
  `aria-label={label}`, valeur par défaut `"Taille"`.
- Un `<button type="button">` par entrée, dont le texte visible est `value`.
- `aria-pressed` vaut `"true"` sur la taille sélectionnée, `"false"` sur toutes
  les autres. Si `value` est absent ou `null`, aucune n'est à `"true"`.
- Une taille dont `available` est faux rend un bouton `disabled`, qui ne
  déclenche jamais `onChange`.
- Un clic sur une taille disponible appelle `onChange(value)`.

## Style
Bouton carré, bordure `var(--vs-ligne)`. Sélectionné : fond `var(--vs-noir)`,
texte `var(--vs-blanc)`. Indisponible : texte barré, contraste réduit,
`cursor-not-allowed`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
