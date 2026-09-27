TICKET 100d — récapitulatif du panier

Crée `src/components/panier/RecapPanier.tsx`, export nommé `RecapPanier`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import { formatPrice } from '@/lib/formatPrice';
import { libelleArticles, type RecapPanier as Recap } from '@/lib/panier-detail';
```
(Le type est importé sous le nom `Recap`, pour ne pas entrer en collision avec le
composant `RecapPanier`.)

## Rendu
Taille attendue : ~45 lignes.

`export function RecapPanier({ recap }: { recap: Recap })` rend :
```tsx
<aside data-testid="recap-panier" className="flex flex-col gap-[18px] rounded-3xl bg-[var(--vs-surface)] p-7">
  <h2 className="text-[22px] font-black text-[var(--vs-noir)]">Récapitulatif</h2>
  <div className="flex flex-col gap-3 text-[15px]">
    <div className="flex justify-between">
      <span>{`Sous-total (${libelleArticles(recap.articles)})`}</span>
      <span data-testid="recap-sous-total" className="font-bold">{formatPrice(recap.sousTotalCents)}</span>
    </div>
    {recap.economiesCents > 0 && (
      <div className="flex justify-between text-[var(--vs-promo)]">
        <span>Vos économies</span>
        <span data-testid="recap-economies" className="font-bold">{`\u2212${formatPrice(recap.economiesCents)}`}</span>
      </div>
    )}
    <div className="flex justify-between">
      <span>Livraison</span>
      <span className="font-bold">Offerte</span>
    </div>
  </div>
  <div className="h-px bg-[var(--vs-ligne)]" />
  <div className="flex items-baseline justify-between">
    <span className="text-[17px] font-extrabold">Total</span>
    <span data-testid="recap-total" className="text-[26px] font-black">{formatPrice(recap.totalCents)}</span>
  </div>
  <p className="text-[13px] text-[var(--vs-gris)]">Taxes (TPS et TVQ) calculées au paiement.</p>
  <button type="button" disabled className="h-[58px] cursor-not-allowed rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] opacity-60">
    Passer la commande
  </button>
  <p className="text-center text-[13px] text-[var(--vs-gris)]">Le paiement en ligne arrive bientôt.</p>
</aside>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
