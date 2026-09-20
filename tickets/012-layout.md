TICKET 012 — primitives de mise en page et de typographie

Crée `src/components/ui/layout.tsx` avec quatre composants React.

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

## `Container`
```ts
{ children: ReactNode; size?: 'default' | 'narrow'; className?: string }
```
Rend un `<div>` portant `data-ui="container"` et `data-size` (valeur par défaut
`"default"`). Largeur maximale `var(--vs-maxw)`, centré, avec du padding latéral.
La `className` reçue est **ajoutée** aux classes internes, jamais remplacée.

## `Section`
```ts
{ children: ReactNode; className?: string }
```
Rend un `<section>` portant `data-ui="section"`, avec un espacement vertical.

## `Heading`
```ts
{ children: ReactNode; level?: 1 | 2 | 3 | 4; className?: string }
```
Rend `<h1>`…`<h4>` selon `level` (défaut `2`), avec `data-ui="heading"`.
Graisse lourde, interlettrage légèrement négatif, police `var(--vs-font-display)`.

## `Text`
```ts
{ children: ReactNode; tone?: 'default' | 'muted'; className?: string }
```
Rend un `<p>` portant `data-ui="text"` et `data-tone` (défaut `"default"`).
Le ton `muted` utilise `var(--vs-gris)`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
