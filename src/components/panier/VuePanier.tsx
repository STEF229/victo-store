'use client';

import { ShoppingBag } from 'lucide-react';
import Link from 'next/link';
import { LignePanier } from '@/components/panier/LignePanier';
import { usePanier } from '@/components/panier/PanierProvider';
import { RecapPanier } from '@/components/panier/RecapPanier';
import { trouverProduit } from '@/lib/donnees';
import { detaillerPanier, libelleArticles, recapitulerPanier } from '@/lib/panier-detail';

export function VuePanier() {
  const panier = usePanier();
  
  if (!panier.pret) {
    return (
      <div data-testid="panier-chargement" aria-busy="true" className="min-h-[320px] max-sm:min-h-[96px]" />
    );
  }
  
  const lignes = detaillerPanier(panier.lignes, trouverProduit);
  
  if (lignes.length === 0) {
    return (
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
    );
  }
  
  const recap = recapitulerPanier(lignes);
  
  return (
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
  );
}
