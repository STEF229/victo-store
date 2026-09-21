'use client';

import { hrefMarque, type Marque } from '@/lib/catalogue';

interface BandeMarquesProps {
  marques: Marque[];
}

export function BandeMarques({ marques }: BandeMarquesProps) {
  return (
    <section 
      data-testid="bande-marques" 
      aria-label="Nos marques"
      className="overflow-hidden border-b border-[var(--vs-ligne)] h-24"
    >
      <style>
        {`@keyframes vs-defile{from{transform:translateX(0)}to{transform:translateX(-50%)}}`}
      </style>
      
      <div data-testid="bande-piste" className="flex w-max items-center animate-[vs-defile_38s_linear_infinite] motion-reduce:animate-none">
        <ul className="flex items-center gap-16 pr-16">
          {marques.map((m) => (
            <li key={m.id}>
              <a 
                href={hrefMarque(m)} 
                className="uppercase text-[26px] font-900"
              >
                {m.nom} <span aria-hidden="true" className="text-[var(--vs-promo)]">✦</span>
              </a>
            </li>
          ))}
        </ul>
        
        <ul aria-hidden="true" className="flex items-center gap-16 pr-16">
          {marques.map((m) => (
            <li key={`copie-${m.id}`}>
              <a 
                href={hrefMarque(m)} 
                className="uppercase text-[26px] font-900"
                tabIndex={-1}
              >
                {m.nom} <span aria-hidden="true" className="text-[var(--vs-promo)]">✦</span>
              </a>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
