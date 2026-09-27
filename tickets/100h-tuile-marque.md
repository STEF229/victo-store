TICKET 100h — tuile d'une marque

Crée `src/components/marques/TuileMarque.tsx`, export nommé `TuileMarque`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ; la
  teinte de fond se choisit par l'expression conditionnelle donnée plus bas, jamais
  dans un tableau.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icône `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
import { ArrowUpRight } from 'lucide-react';
import Link from 'next/link';
import { hrefMarque } from '@/lib/catalogue';
import { libelleProduits, type ResumeMarque } from '@/lib/marques';
```

## Props et rendu
Taille attendue : ~40 lignes.

`export function TuileMarque({ resume, rang }: { resume: ResumeMarque; rang: number })`, avec :
```tsx
const fond =
  rang % 3 === 0 ? 'bg-[#EEF1F8]' : rang % 3 === 1 ? 'bg-[#E9E4DA]' : 'bg-[var(--vs-surface)]';
```
rend :
```tsx
<Link
  href={hrefMarque(resume.marque)}
  data-testid={`tuile-marque-${resume.marque.slug}`}
  className={`flex h-[150px] flex-col justify-between rounded-[20px] p-4 text-[var(--vs-noir)] sm:h-[240px] sm:rounded-[28px] sm:p-7 ${fond}`}
>
  {resume.enSoldes > 0 ? (
    <span data-testid="tuile-soldes" className="self-start rounded-full bg-[var(--vs-promo)] px-[11px] py-[5px] text-xs font-extrabold text-[var(--vs-blanc)]">
      {`${resume.enSoldes} en soldes`}
    </span>
  ) : (
    <span />
  )}
  <div className="flex items-end justify-between gap-2">
    <div className="flex flex-col gap-1">
      <span className="text-lg font-black uppercase leading-none tracking-[0.04em] sm:text-[34px]">{resume.marque.nom}</span>
      <span data-testid="tuile-produits" className="text-xs text-[var(--vs-gris)] sm:text-sm">{libelleProduits(resume.nombre)}</span>
    </div>
    <span className="hidden h-11 w-11 shrink-0 items-center justify-center rounded-full bg-[var(--vs-blanc)] sm:flex">
      <ArrowUpRight aria-hidden size={18} />
    </span>
  </div>
</Link>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
