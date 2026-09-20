TICKET 035 — pagination

Crée `src/components/catalogue/Pagination.tsx`, export `Pagination`.

## Règles absolues
- TypeScript strict. Exports **nommés**. Ne modifie aucun test, ne crée aucun
  autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- Les `data-testid` sont un contrat testé ; les classes Tailwind sont libres.

## Bloc d'imports exact
```tsx
'use client';
```

## Props
```ts
{ page: number; pages: number; onChange: (page: number) => void; className?: string }
```

## Contrat
- Racine `<nav aria-label="Pagination" data-testid="pagination">`.
- `<button type="button" aria-label="Page précédente">`, `disabled` quand
  `page <= 1`, appelle `onChange(page - 1)`.
- `<span data-testid="pagination-etat">` au format exact `Page 2 sur 5`.
- `<button type="button" aria-label="Page suivante">`, `disabled` quand
  `page >= pages`, appelle `onChange(page + 1)`.
- Si `pages <= 1`, le composant retourne `null` : rien dans le DOM.
- Un bouton désactivé n'appelle jamais `onChange`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
