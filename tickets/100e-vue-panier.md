TICKET 100e — contenu de la page panier

Crée `src/components/panier/VuePanier.tsx`, export nommé `VuePanier`. Il lit le
panier, affiche les lignes et le récapitulatif, ou l'état vide. Le titre `<h1>`
n'est **pas** dans ce composant : la page le porte.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { ShoppingBag } from 'lucide-react';
import Link from 'next/link';
import { LignePanier } from '@/components/panier/LignePanier';
import { usePanier } from '@/components/panier/PanierProvider';
import { RecapPanier } from '@/components/panier/RecapPanier';
import { trouverProduit } from '@/lib/donnees';
import { detaillerPanier, libelleArticles, recapitulerPanier } from '@/lib/panier-detail';
```

## Logique et rendu
Taille attendue : ~55 lignes.

`export function VuePanier()` :
1. `const panier = usePanier();`
2. si `!panier.pret` : renvoie
   `<div data-testid="panier-chargement" aria-busy="true" className="min-h-[320px]" />`
   (le panier n'est pas encore relu : ne pas afficher un faux « panier vide ») ;
3. `const lignes = detaillerPanier(panier.lignes, trouverProduit);`
4. si `lignes.length === 0` : renvoie l'**état vide** :
```tsx
<div data-testid="panier-vide" className="flex flex-col items-center gap-[22px] py-20 text-center">
  <div className="flex h-24 w-24 items-center justify-center rounded-full bg-[var(--vs-surface)]">
    <ShoppingBag aria-hidden size={38} />
  </div>
  <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[44px]">Votre panier est vide</h2>
  <p className="max-w-[460px] text-base leading-relaxed text-[var(--vs-gris)]">Les grandes marques vous attendent, au bon prix.</p>
  <Link href="/soldes" className="flex h-14 items-center rounded-full bg-[var(--vs-accent)] px-8 text-base font-extrabold text-[var(--vs-blanc)]">
    Voir les soldes
  </Link>
</div>
```
5. sinon, `const recap = recapitulerPanier(lignes);` et renvoie :
```tsx
<div data-testid="panier-plein" className="grid gap-10 lg:grid-cols-[minmax(0,8fr)_minmax(0,4fr)] lg:items-start lg:gap-14">
  <div className="flex flex-col gap-5">
    <p data-testid="panier-articles" className="text-[15px] text-[var(--vs-gris)]">{libelleArticles(recap.articles)}</p>
    <ul className="border-t border-[var(--vs-ligne)]">
      {lignes.map((l) => (
        <LignePanier key={l.sku} ligne={l} onQuantite={panier.changerQuantite} onRetirer={panier.retirer} />
      ))}
    </ul>
    <Link href="/" className="self-start text-[15px] font-bold text-[var(--vs-noir)] underline">
      Continuer mes achats
    </Link>
  </div>
  <RecapPanier recap={recap} />
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
