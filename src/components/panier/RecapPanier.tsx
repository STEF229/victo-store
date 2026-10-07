import { formatPrice } from '@/lib/formatPrice';
import Link from 'next/link';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { libelleArticles, type RecapPanier as Recap } from '@/lib/panier-detail';

export function RecapPanier({ recap }: { recap: Recap }) {
  const enLigne = useCatalogue().source === 'medusa';
  return (
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
      {enLigne ? (
        <Link href="/commande" className="flex h-[58px] items-center justify-center rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)]">
          Passer la commande
        </Link>
      ) : (
        <>
          <button type="button" disabled className="h-[58px] cursor-not-allowed rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] opacity-60">
            Passer la commande
          </button>
          <p className="text-center text-[13px] text-[var(--vs-gris)]">Le paiement en ligne arrive bientôt.</p>
        </>
      )}
    </aside>
  );
}
