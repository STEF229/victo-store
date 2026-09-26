TICKET 099b — fil d'Ariane

Crée `src/components/produit/FilAriane.tsx`, export nommé `FilAriane`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  pour savoir si un élément est le dernier, compare son rang `i` (donné par `.map`)
  à `items.length - 1`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import Link from 'next/link';
import type { ElementFil } from '@/lib/fiche-produit';
```

## Rendu
Taille attendue : ~30 lignes.

`export function FilAriane({ items }: { items: ElementFil[] })` rend :
```tsx
<nav aria-label="Fil d'Ariane" data-testid="fil-ariane" className="flex flex-wrap items-center gap-2.5 py-4 text-sm text-[var(--vs-gris)]">
  <ol className="flex flex-wrap items-center gap-2.5">
    {/* un <li> par élément */}
  </ol>
</nav>
```
Pour chaque élément `e` de rang `i`, un `<li className="flex items-center gap-2.5">`
qui contient, dans l'ordre :
- si `i > 0` : `<span aria-hidden="true">/</span>` ;
- si `i === items.length - 1` (le dernier) :
  `<span aria-current="page" className="font-semibold text-[var(--vs-noir)]">{e.label}</span>` ;
- sinon, si `e.href` est défini : `<Link href={e.href}>{e.label}</Link>` ;
- sinon : `<span>{e.label}</span>`.

Le commentaire du bloc de rendu indique seulement où placer les `<li>` : ne le
recopie pas. `aria-current` n'apparaît que sur le dernier élément ; ne l'écris
jamais avec une valeur `false` (pour les autres, n'écris pas l'attribut, ou donne
`undefined`).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
