TICKET 100i — page des marques

Crée `src/app/marques/page.tsx`. Ticket d'assemblage : le fichier est donné en
entier, recopie-le. (La page `src/app/marques/[slug]/page.tsx` existe déjà et ne
change pas.)

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageMarques`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~45 lignes.
```tsx
import { TuileMarque } from '@/components/marques/TuileMarque';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { MARQUES, PRODUITS } from '@/lib/donnees';
import { libelleMarques, resumerMarques } from '@/lib/marques';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PageMarques() {
  const resumes = resumerMarques(MARQUES, PRODUITS);

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Marques' }]} />
        <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
          <div className="flex flex-col gap-3">
            <h1 className="text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[64px]">Marques</h1>
            <p className="text-base text-[var(--vs-gris)] lg:text-[17px]">Les grandes marques de la sélection, au bon prix.</p>
          </div>
          <span data-testid="marques-nombre" className="text-[15px] text-[var(--vs-gris)]">
            {libelleMarques(resumes.length)}
          </span>
        </div>
        <div data-testid="grille-marques" className="grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3">
          {resumes.map((r, i) => (
            <TuileMarque key={r.marque.slug} resume={r} rang={i} />
          ))}
        </div>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
