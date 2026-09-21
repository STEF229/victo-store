'use client';

import { ProductCard } from '@/components/ui/ProductCard';
import type { Produit } from '@/lib/catalogue';

interface SectionBonnesAffairesProps {
  produits: Produit[];
}

export function SectionBonnesAffaires({ produits }: SectionBonnesAffairesProps) {
  return (
    <section data-testid="bonnes-affaires">
      <div className="flex items-end justify-between gap-4">
        <div>
          <span className="text-xs uppercase text-[var(--vs-promo)]">Prix cassés</span>
          <h2 className="text-3xl font-900 mt-1">Les bonnes affaires du moment</h2>
        </div>
        <a 
          href="/soldes" 
          className="border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full"
        >
          Tout voir
        </a>
      </div>
      
      <ul 
        data-testid="rail" 
        className="flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6"
      >
        {produits.map((p) => (
          <li 
            key={p.id} 
            className="w-[250px] shrink-0 snap-start md:w-auto"
          >
            <ProductCard produit={p} />
          </li>
        ))}
      </ul>
    </section>
  );
}
