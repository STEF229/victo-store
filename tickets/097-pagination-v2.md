TICKET 097 — pagination conforme au style de la liste

Écris `src/components/catalogue/Pagination.tsx` en entier, export nommé
`Pagination`, à partir de zéro.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Icônes `lucide-react` uniquement, avec `aria-hidden`.
- Chaque `className` est écrit **exactement** comme ci-dessous, sans rien ajouter :
  ni `hover:`, ni `focus:`, ni `rounded-md`, ni autre couleur.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';
```

## Props (inchangées)
```ts
interface PaginationProps {
  page: number;
  pages: number;
  onChange: (page: number) => void;
  className?: string;
}
```
Paramètre par défaut : `className = ''`.

## Comportement
- `pages <= 1` : le composant renvoie `null`.
- Page précédente : désactivée si `page <= 1` ; sinon, au clic, `onChange(page - 1)`.
- Page suivante : désactivée si `page >= pages` ; sinon, au clic, `onChange(page + 1)`.
- Numéros de page : affichés **seulement si `pages <= 7`**, un bouton par page de 1 à
  `pages`. Au clic sur un numéro différent de `page` : `onChange(numéro)`. Au clic
  sur le numéro de la page courante : rien.

## Rendu
Taille attendue : ~70 lignes.

```tsx
<nav
  aria-label="Pagination"
  data-testid="pagination"
  className={`mt-12 flex flex-col items-center gap-3.5 ${className}`}
>
  <div className="flex items-center gap-2">
    {/* bouton précédent */}
    {/* numéros, seulement si pages <= 7 */}
    {/* bouton suivant */}
  </div>
  <span data-testid="pagination-etat" className="text-sm text-[var(--vs-gris)]">
    Page {page} sur {pages}
  </span>
</nav>
```

**Bouton précédent**, avec exactement ces attributs, et pour seul contenu
`<ChevronLeft aria-hidden size={18} />` :
```tsx
type="button"
aria-label="Page précédente"
disabled={page <= 1}
className={page <= 1
  ? 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]'
  : 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] text-[var(--vs-noir)]'}
```

**Bouton suivant** : identique, avec `aria-label="Page suivante"`,
`disabled={page >= pages}`, la même alternative de `className` avec la condition
`page >= pages`, et pour seul contenu `<ChevronRight aria-hidden size={18} />`.

**Chaque numéro** `n`, dans l'ordre croissant, avec une `key` égale à `n`, pour
contenu le nombre `{n}` et exactement ces attributs :
```tsx
type="button"
aria-label={`Page ${n}`}
aria-current={n === page ? 'page' : undefined}
className={n === page
  ? 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
  : 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
```
La liste des numéros se construit sans accès par index, par exemple avec
`Array.from({ length: pages }, (_, i) => i + 1).map((n) => (...))`.

Les trois commentaires `{/* … */}` du bloc de rendu indiquent seulement où placer
les éléments : ne les recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/Pagination.test.tsx` (comportement existant, à conserver).
