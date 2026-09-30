TICKET 107b — page de recherche

Crée `src/app/recherche/page.tsx`, export par défaut `PageRecherche`. Composant
**serveur** asynchrone : pas de `'use client'`. Le terme vient de l'adresse
(`/recherche?q=nike`).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Chaque `className` est écrit exactement.
- Recopie tous les textes exactement, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier complet
Taille attendue : ~65 lignes.
```tsx
import { Search } from 'lucide-react';
import Link from 'next/link';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { listerMarques, listerProduits } from '@/lib/donnees';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { rechercherProduits } from '@/lib/recherche';

export default async function PageRecherche({ searchParams }: { searchParams: Promise<{ q?: string | string[] }> }) {
  const { q } = await searchParams;
  const terme = (Array.isArray(q) ? q.join(' ') : q ?? '').trim();
  const resultats = rechercherProduits(listerProduits(), terme);

  if (resultats.length > 0) {
    return (
      <VueCatalogue
        titre={`Résultats pour « ${terme} »`}
        description="Recherche dans les noms, les marques et les descriptions."
        produits={resultats}
      />
    );
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Recherche' }]} />
        <section data-testid="recherche-vide" className="flex flex-col items-center gap-4 rounded-[28px] bg-[var(--vs-surface)] px-6 py-14 text-center">
          <span className="flex h-16 w-16 items-center justify-center rounded-full bg-[var(--vs-blanc)]">
            <Search aria-hidden size={28} />
          </span>
          <h1 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[40px]">
            {terme === '' ? 'Que cherchez-vous ?' : `Aucun résultat pour « ${terme} »`}
          </h1>
          <p className="max-w-[560px] text-base leading-relaxed text-[var(--vs-gris)]">
            Vérifiez l'orthographe, essayez un terme plus court ou cherchez par marque. Les pointures se choisissent sur la fiche du produit.
          </p>
          <p className="text-[13px] font-extrabold uppercase tracking-[0.14em] text-[var(--vs-gris)]">Nos marques</p>
          <div className="flex max-w-[760px] flex-wrap justify-center gap-2.5">
            {listerMarques().map((m) => (
              <Link key={m.slug} href={`/recherche?q=${encodeURIComponent(m.nom)}`}
                className="rounded-full bg-[var(--vs-blanc)] px-4 py-2 text-[15px] font-semibold text-[var(--vs-noir)]">
                {m.nom}
              </Link>
            ))}
          </div>
        </section>
        <section className="mt-10 flex flex-col gap-5">
          <h2 className="text-[28px] font-black text-[var(--vs-noir)]">Ça pourrait vous plaire</h2>
          <GrilleProduits produits={listerProduits().slice(0, 4)} colonnes={4} />
        </section>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
