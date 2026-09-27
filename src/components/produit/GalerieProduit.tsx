'use client';

import { useState } from 'react';

interface GalerieProduitProps {
  images: string[];
  nom: string;
  remise: number | null;
}

export function GalerieProduit({ images, nom, remise }: GalerieProduitProps) {
  const [vue, setVue] = useState(0);
  const courante = images.find((_, i) => i === vue) ?? '';
  
  return (
    <div data-testid="galerie" className="flex flex-col gap-4">
      <div className="relative flex aspect-square items-center justify-center overflow-hidden rounded-[28px] bg-[var(--vs-surface)] lg:aspect-auto lg:h-[680px]">
        {remise !== null && (
          <span data-testid="galerie-remise" className="absolute left-6 top-6 rounded-full bg-[var(--vs-promo)] px-[13px] py-[7px] text-sm font-extrabold text-[var(--vs-blanc)]">
            {`\u2212${remise}\u00a0%`}
          </span>
        )}
        <img src={courante} alt={`${nom}, vue ${vue + 1}`} className="h-full w-full object-contain" />
      </div>
      {images.length > 1 && (
        <div className="grid grid-cols-4 gap-4">
          {images.map((src, i) => (
            <button
              key={src + i}
              type="button"
              aria-label={`Afficher la vue ${i + 1}`}
              aria-pressed={i === vue}
              onClick={() => setVue(i)}
              className={i === vue
                ? 'h-[110px] overflow-hidden rounded-[18px] border-2 border-[var(--vs-noir)] bg-[var(--vs-surface)]'
                : 'h-[110px] overflow-hidden rounded-[18px] border-2 border-transparent bg-[var(--vs-surface)]'}
            >
              <img src={src} alt="" className="h-full w-full object-contain" />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
