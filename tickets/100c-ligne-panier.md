TICKET 100c — une ligne du panier

Crée `src/components/panier/LignePanier.tsx`, export nommé `LignePanier`.
Composant **sans état** : il affiche une ligne et remonte les actions par ses props.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Balise `<img>` ordinaire.

## Bloc d'imports exact
```tsx
import { Minus, Plus } from 'lucide-react';
import Link from 'next/link';
import { hrefProduit } from '@/lib/catalogue';
import { texteStockBas } from '@/lib/fiche-produit';
import { formatPrice } from '@/lib/formatPrice';
import type { LigneDetaillee } from '@/lib/panier-detail';
```

## Props
Taille attendue : ~75 lignes.
```ts
interface LignePanierProps {
  ligne: LigneDetaillee;
  onQuantite: (sku: string, quantite: number, stock: number) => void;
  onRetirer: (sku: string) => void;
}
```
Dans le corps : `const { produit, variante, quantite, sku } = ligne;`,
`const promo = produit.prixCompareCents !== undefined && produit.prixCompareCents > produit.prixCents;`
et `const alerte = texteStockBas(produit, variante.taille);`.

## Rendu
Racine :
`<li data-testid="ligne-panier" className="grid grid-cols-[96px_minmax(0,1fr)] gap-3.5 border-b border-[var(--vs-ligne)] py-[18px] sm:grid-cols-[140px_minmax(0,1fr)_auto] sm:gap-6 sm:py-6">`
contenant, dans l'ordre :

**1. Image** :
```tsx
<Link href={hrefProduit(produit)} aria-label={produit.nom} className="block aspect-square overflow-hidden rounded-2xl bg-[var(--vs-surface)] sm:rounded-[20px]">
  <img src={produit.imageUrl} alt="" className="h-full w-full object-contain" />
</Link>
```

**2. Détails** — `<div className="flex flex-col gap-1.5">` :
- `<span className="text-xs font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]">{produit.marque.nom}</span>`
- `<Link href={hrefProduit(produit)} className="text-base font-extrabold text-[var(--vs-noir)] sm:text-lg">{produit.nom}</Link>`
- `<span data-testid="ligne-pointure" className="text-sm text-[var(--vs-gris)]">{`Pointure ${variante.taille}`}</span>`
- `<div className="flex items-baseline gap-2.5">` avec
  `<span data-testid="ligne-prix" className={promo ? 'text-[15px] font-extrabold text-[var(--vs-promo)]' : 'text-[15px] font-extrabold text-[var(--vs-noir)]'}>{formatPrice(produit.prixCents)}</span>`
  puis, seulement si `promo` et `produit.prixCompareCents !== undefined` :
  `<s className="text-[13px] text-[var(--vs-gris)]">{formatPrice(produit.prixCompareCents)}</s>`
- seulement si `alerte !== null` :
  `<p data-testid="ligne-stock-bas" className="text-[13px] font-bold text-[var(--vs-promo)]">{alerte}</p>`

**3. Actions** — `<div className="col-span-2 flex items-center justify-between gap-3 sm:col-span-1 sm:flex-col sm:items-end sm:justify-between">` :
- `<span data-testid="ligne-total" className="text-lg font-black text-[var(--vs-noir)]">{formatPrice(ligne.totalCents)}</span>`
- la quantité :
```tsx
<div className="flex h-11 items-center rounded-full border-[1.5px] border-[var(--vs-ligne)]">
  <button type="button" aria-label="Diminuer la quantité" disabled={quantite <= 1}
    onClick={() => onQuantite(sku, quantite - 1, variante.stock)}
    className={quantite <= 1
      ? 'flex h-10 w-11 items-center justify-center text-[#B5B5BA]'
      : 'flex h-10 w-11 items-center justify-center text-[var(--vs-noir)]'}>
    <Minus aria-hidden size={14} />
  </button>
  <span data-testid="ligne-quantite" className="min-w-[22px] text-center text-[15px] font-extrabold">{quantite}</span>
  <button type="button" aria-label="Augmenter la quantité" disabled={quantite >= variante.stock}
    onClick={() => onQuantite(sku, quantite + 1, variante.stock)}
    className={quantite >= variante.stock
      ? 'flex h-10 w-11 items-center justify-center text-[#B5B5BA]'
      : 'flex h-10 w-11 items-center justify-center text-[var(--vs-noir)]'}>
    <Plus aria-hidden size={14} />
  </button>
</div>
```
- `<button type="button" onClick={() => onRetirer(sku)} className="text-sm font-semibold text-[var(--vs-gris)] underline">Retirer</button>`

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
