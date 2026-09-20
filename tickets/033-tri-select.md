TICKET 033 — sélecteur de tri

Crée `src/components/catalogue/TriSelect.tsx`, export `TriSelect`.

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

import type { Tri } from '@/lib/filtres';
```

## Props
```ts
{ value: Tri; onChange: (tri: Tri) => void; className?: string }
```

## Contrat
- `<label htmlFor="tri">Trier par</label>` et `<select id="tri" data-testid="tri">`.
- Quatre options, dans cet ordre, avec ces `value` et ces libellés exacts :

  | value | libellé |
  |---|---|
  | `nouveautes` | Nouveautés |
  | `prix-croissant` | Prix croissant |
  | `prix-decroissant` | Prix décroissant |
  | `remise` | Meilleures remises |

- Le `select` reflète `value`. Un changement appelle `onChange` avec la
  nouvelle valeur. Composant **contrôlé**, aucun état interne.

## Critère de fin
`npm run typecheck` et `npm test` passent.
