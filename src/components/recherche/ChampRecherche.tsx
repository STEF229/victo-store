'use client';

import { Search } from 'lucide-react';
import Link from 'next/link';
import { useState, type FocusEvent } from 'react';
import { hrefMarque, hrefProduit } from '@/lib/catalogue';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { formatPrice } from '@/lib/formatPrice';
import { marquesCorrespondantes, rechercherProduits } from '@/lib/recherche';

export function ChampRecherche() {
  const catalogue = useCatalogue();
  const [terme, setTerme] = useState('');
  const [ouvert, setOuvert] = useState(false);
  const actif = terme.trim().length >= 2;
  const produits = actif ? rechercherProduits(catalogue.produits, terme) : [];
  const marques = actif ? marquesCorrespondantes(catalogue.marques, terme).slice(0, 3) : [];
  const visible = ouvert && (produits.length > 0 || marques.length > 0);

  function quitter(e: FocusEvent<HTMLFormElement>) {
    if (!(e.relatedTarget instanceof Node && e.currentTarget.contains(e.relatedTarget))) setOuvert(false);
  }

  return (
    <form role="search" action="/recherche" method="get" onBlur={quitter} className="relative">
      <label htmlFor="recherche-entete" className="sr-only">Rechercher un produit</label>
      <div className="flex h-11 w-[250px] items-center gap-2.5 rounded-full bg-[#1E1E26] px-[18px]">
        <Search aria-hidden size={17} className="shrink-0 text-[#B5B5BA]" />
        <input id="recherche-entete" name="q" type="search" autoComplete="off" placeholder="Rechercher" value={terme}
          onChange={(e) => { setTerme(e.target.value); setOuvert(true); }}
          onFocus={() => setOuvert(true)}
          onKeyDown={(e) => { if (e.key === 'Escape') setOuvert(false); }}
          className="h-10 min-w-0 flex-1 border-none bg-transparent text-sm text-[var(--vs-blanc)] outline-none placeholder:text-[#B5B5BA]" />
      </div>
      {visible && (
        <div data-testid="suggestions-recherche"
          className="absolute right-0 top-[54px] z-50 flex w-[480px] max-w-[calc(100vw-40px)] flex-col gap-3.5 rounded-[22px] bg-[var(--vs-blanc)] p-4 text-[var(--vs-noir)] shadow-[0_18px_50px_rgba(16,16,20,0.22)]">
          {marques.length > 0 && (
            <div className="flex flex-wrap gap-2 px-2.5">
              {marques.map((m) => (
                <Link key={m.slug} href={hrefMarque(m)} className="rounded-full bg-[var(--vs-noir)] px-3.5 py-1.5 text-sm font-bold text-[var(--vs-blanc)]">
                  {m.nom}
                </Link>
              ))}
            </div>
          )}
          {produits.length > 0 && (
            <ul className="flex flex-col gap-0.5">
              {produits.slice(0, 4).map((p) => (
                <li key={p.slug}>
                  <Link href={hrefProduit(p)} className="grid grid-cols-[52px_minmax(0,1fr)_auto] items-center gap-3.5 rounded-[14px] px-2.5 py-2">
                    <img src={p.imageUrl} alt="" className="h-[52px] w-[52px] rounded-xl bg-[var(--vs-surface)] object-cover" />
                    <span className="flex flex-col">
                      <span className="text-[11px] font-extrabold uppercase tracking-[0.14em] text-[var(--vs-gris)]">{p.marque.nom}</span>
                      <span className="text-[15px] font-bold">{p.nom}</span>
                    </span>
                    <span className="text-[15px] font-extrabold">{formatPrice(p.prixCents)}</span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
          {produits.length > 0 && (
            <Link href={`/recherche?q=${encodeURIComponent(terme.trim())}`}
              className="flex h-[50px] items-center justify-center rounded-full bg-[var(--vs-accent)] text-[15px] font-extrabold text-[var(--vs-blanc)]">
              {produits.length > 1 ? `Voir les ${produits.length} résultats pour « ${terme.trim()} »` : `Voir le résultat pour « ${terme.trim()} »`}
            </Link>
          )}
        </div>
      )}
    </form>
  );
}
