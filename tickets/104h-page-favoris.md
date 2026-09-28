TICKET 104h — mes favoris

Crée `src/app/compte/favoris/page.tsx`. Page **client** (`'use client'`), un seul
export : l'export par défaut `PageFavoris`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index. Les
  produits se retrouvent **exactement** ainsi (un favori dont le produit n'existe
  plus est ignoré) :
  ```tsx
  const produits = favoris.favoris.flatMap((slug) => {
    const p = trouverProduit(slug);
    return p ? [p] : [];
  });
  ```
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import { BOUTON_PRINCIPAL, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { useFavoris } from '@/components/favoris/FavorisProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { ProductCard } from '@/components/ui/ProductCard';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { trouverProduit } from '@/lib/donnees';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Le contenu — fonction locale `Favoris()`
Taille attendue : ~70 lignes.
```tsx
const favoris = useFavoris();
const produits = favoris.favoris.flatMap((slug) => {
  const p = trouverProduit(slug);
  return p ? [p] : [];
});
const n = produits.length;
```
Si `!favoris.pret`, renvoie `<div aria-busy="true" className="min-h-[320px]" />`. Sinon :
```tsx
<>
  <div className="flex flex-col gap-2.5">
    <h1 className={TITRE_PAGE}>Mes favoris</h1>
    <p data-testid="favoris-nombre" className={SOUS_TITRE}>{`${n} ${n > 1 ? 'produits' : 'produit'}`}</p>
  </div>
  {n === 0 ? (
    <div data-testid="favoris-vide" className="flex flex-col items-start gap-4">
      <p className={SOUS_TITRE}>Vous n'avez pas encore de favori. Touchez le cœur d'une fiche produit pour l'ajouter ici.</p>
      <Link href="/boutique" className={`${BOUTON_PRINCIPAL} sm:w-auto`}>Découvrir la boutique</Link>
    </div>
  ) : (
    <ul className="grid gap-x-5 gap-y-8 sm:grid-cols-2 lg:grid-cols-3">
      {produits.map((p) => (
        <li key={p.slug} data-testid="favori" className="flex flex-col gap-3">
          <ProductCard produit={p} />
          <button type="button" onClick={() => favoris.basculer(p.slug)} aria-label={`Retirer ${p.nom} des favoris`}
            className={`self-start ${LIEN}`}>
            Retirer des favoris
          </button>
        </li>
      ))}
    </ul>
  )}
</>
```

## La page
```tsx
export default function PageFavoris() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Favoris' }]} />
        <EspaceClient actif="favoris">
          {session.client && <Favoris />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```
`n` est le nombre de produits retrouvés, ce qui accorde « produit » au singulier
jusqu'à un, zéro compris.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
