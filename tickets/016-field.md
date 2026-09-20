TICKET 016 — composant Field

Crée `src/components/ui/Field.tsx`, export nommé `Field`. Champ de formulaire
complet et accessible, utilisé par la connexion, l'inscription et le paiement.

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
interface FieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id'> {
  id: string;
  label: string;
  hint?: string;
  error?: string;
}
```
Les props HTML restantes (`value`, `onChange`, `placeholder`, `required`,
`autoComplete`…) sont transmises à l'`<input>`.

## Contrat d'accessibilité
- `<label htmlFor={id}>` contenant `label`, et `<input id={id}>`.
- `type` vaut `"text"` par défaut, remplaçable.
- Si `hint` : `<p id={\`${id}-hint\`}>` contenant le texte.
- Si `error` : `<p id={\`${id}-error\`} role="alert">` contenant le texte,
  et l'input porte `aria-invalid="true"`.
- `aria-describedby` de l'input liste les identifiants présents, séparés par une
  espace : aide seule, erreur seule, ou les deux.
- **Sans aide ni erreur**, l'attribut `aria-describedby` doit être **absent**,
  et `aria-invalid` ne doit pas valoir `"true"`.

## Style
Input : fond `var(--vs-blanc)`, bordure `var(--vs-ligne)`, bordure
`var(--vs-noir)` au focus. En erreur, bordure `var(--vs-accent)` et message
en `var(--vs-accent)`. Aide en `var(--vs-gris)`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
