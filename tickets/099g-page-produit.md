TICKET 099g — page de la fiche produit

Crée `src/app/produits/[slug]/page.tsx`. Ticket d'assemblage : le fichier est
donné presque en entier, recopie-le.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageProduit`.** Aucun export nommé, pas
  de `generateStaticParams`, pas de `metadata`.
- Composant serveur : **pas** de `'use client'`. Les déclarations des modules
  importés te sont fournies en lecture seule.

## Fichier
Taille attendue : ~60 lignes.
```tsx
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { BlocAchat } from '@/components/produit/BlocAchat';
import { FilAriane } from '@/components/produit/FilAriane';
import { GalerieProduit } from '@/components/produit/GalerieProduit';
import { InfosProduit } from '@/components/produit/InfosProduit';
import { ProductCard } from '@/components/ui/ProductCard';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { hrefMarque, imagesProduit, remisePourcent } from '@/lib/catalogue';
import { listerProduits, trouverProduit } from '@/lib/donnees';
import { filAriane, produitsSimilaires } from '@/lib/fiche-produit';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default async function PageProduit({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const produit = trouverProduit(slug);
  if (!produit) notFound();
  const similaires = produitsSimilaires(produit, listerProduits());

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={filAriane(produit)} />
        <section className="grid gap-10 pt-2 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:gap-16">
          <GalerieProduit images={imagesProduit(produit)} nom={produit.nom} remise={remisePourcent(produit)} />
          <div className="flex flex-col gap-[22px]">
            <Link
              href={hrefMarque(produit.marque)}
              data-testid="fiche-marque"
              className="self-start rounded-full border-[1.5px] border-[var(--vs-ligne)] px-3.5 py-1.5 text-[13px] font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]"
            >
              {produit.marque.nom}
            </Link>
            <h1 className="text-4xl font-black leading-[1.02] tracking-tight text-[var(--vs-noir)] lg:text-5xl">
              {produit.nom}
            </h1>
            <BlocAchat produit={produit} />
            <InfosProduit produit={produit} />
          </div>
        </section>
        {similaires.length > 0 && (
          <section data-testid="vous-aimerez-aussi" className="mt-24 flex flex-col gap-8">
            <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[40px]">Vous aimerez aussi</h2>
            <div className="grid grid-cols-2 gap-5 lg:grid-cols-4">
              {similaires.map((p) => (
                <ProductCard key={p.id} produit={p} />
              ))}
            </div>
          </section>
        )}
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
