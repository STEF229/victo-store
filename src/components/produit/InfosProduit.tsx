'use client';

import { ChevronDown, RotateCcw, ShieldCheck, Truck } from 'lucide-react';
import { useState } from 'react';
import type { Produit } from '@/lib/catalogue';
import { TEXTE_LIVRAISON } from '@/lib/fiche-produit';

export function InfosProduit({ produit }: { produit: Produit }) {
  const sections = [
    { titre: 'Description', texte: produit.description ?? '' },
    { titre: 'Détails et composition', texte: produit.composition ?? '' },
    { titre: 'Livraison et retours', texte: TEXTE_LIVRAISON },
  ].filter((s) => s.texte !== '');
  
  const [ouverts, setOuverts] = useState<number[]>([0]);
  
  const basculer = (i: number) => {
    setOuverts((o) => (o.includes(i) ? o.filter((x) => x !== i) : [...o, i]));
  };
  
  return (
    <div data-testid="infos-produit" className="flex flex-col gap-[22px]">
      <ul className="flex flex-col gap-3.5 rounded-[20px] bg-[var(--vs-surface)] p-5">
        <li className="flex items-center gap-3 text-sm">
          <Truck aria-hidden size={18} />
          <span><strong>Livraison offerte</strong> — reçue d'ici 2 à 4 jours ouvrables</span>
        </li>
        <li className="flex items-center gap-3 text-sm">
          <RotateCcw aria-hidden size={18} />
          <span><strong>Retours gratuits</strong> pendant 30 jours</span>
        </li>
        <li className="flex items-center gap-3 text-sm">
          <ShieldCheck aria-hidden size={18} />
          <span><strong>Authenticité garantie</strong>, neuf en boîte d'origine</span>
        </li>
      </ul>
      
      <div className="border-t border-[var(--vs-ligne)]">
        {sections.map((s, i) => {
          const ouvert = ouverts.includes(i);
          return (
            <div key={s.titre} className="border-b border-[var(--vs-ligne)]">
              <button 
                type="button" 
                aria-expanded={ouvert} 
                onClick={() => basculer(i)}
                className="flex h-16 w-full items-center justify-between text-left text-base font-extrabold text-[var(--vs-noir)]"
              >
                {s.titre}
                <ChevronDown aria-hidden size={18} className={ouvert ? 'rotate-180' : undefined} />
              </button>
              {ouvert && (
                <p className="mb-5 text-[15px] leading-relaxed text-[var(--vs-gris)]">{s.texte}</p>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
