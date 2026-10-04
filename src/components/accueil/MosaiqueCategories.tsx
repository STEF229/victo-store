import { Fragment } from 'react';
import { ArrowUpRight } from 'lucide-react';

const TUILES = [
  { titre: 'Femme', href: '/femme', image: '/img/accueil/photo-8.svg',
    classes: 'col-span-2 lg:col-span-1 lg:row-span-2 bg-[#1E1E26] text-[var(--vs-blanc)]' },
  { titre: 'Homme', href: '/homme', image: '/img/accueil/photo-9.svg',
    classes: 'bg-[#E9E4DA] text-[var(--vs-noir)]' },
  { titre: 'Chaussures', href: '/chaussures', image: '/img/accueil/photo-10.svg',
    classes: 'bg-[#EEF1F8] text-[var(--vs-noir)]' },
] as const;

export function MosaiqueCategories() {
  return (
    <section data-testid="categories">
      <h2 className="text-3xl font-900 font-black tracking-tight mb-6 max-sm:mb-4 max-sm:text-2xl">Par catégorie</h2>
      <ul className="grid grid-cols-2 gap-4 lg:h-[640px] lg:grid-cols-3 lg:grid-rows-2">
        {TUILES.map((t) => (
          <li 
            key={t.href} 
            className={`${t.classes} relative overflow-hidden rounded-[28px]`}
          >
            <a 
              href={t.href} 
              className="relative flex h-full min-h-[190px] flex-col justify-end p-7 max-sm:min-h-[160px] max-sm:p-5"
            >
              <img 
                src={t.image} 
                alt="" 
                className="absolute inset-0 h-full w-full object-cover" 
              />
              <span className="text-3xl font-900 font-black relative max-sm:text-lg">{t.titre}</span>
              <div className="relative flex justify-end">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)] max-sm:h-10 max-sm:w-10">
                  <ArrowUpRight aria-hidden size={20} />
                </div>
              </div>
            </a>
          </li>
        ))}
        <li className="col-span-2 relative overflow-hidden rounded-[28px] bg-[var(--vs-promo)] text-[var(--vs-blanc])">
          <a 
            href="/soldes" 
            className="relative flex h-full min-h-[190px] flex-col justify-end p-7 max-sm:min-h-[160px] max-sm:p-5"
          >
            <span className="text-sm font-extrabold uppercase tracking-[0.14em]">Soldes</span>
            <span className="text-4xl font-900 font-black max-sm:text-[28px]">Jusqu’à −50 %</span>
            <div className="relative flex justify-end">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)] text-[var(--vs-noir)] max-sm:h-10 max-sm:w-10">
                <ArrowUpRight aria-hidden size={20} />
              </div>
            </div>
          </a>
        </li>
      </ul>
    </section>
  );
}
