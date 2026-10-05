'use client';

import { useEffect, useRef, useState } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface Diapo {
  surTitre: string;
  titre: string;
  texte: string;
  image: string;
  fond: string;
  actions: Array<{
    label: string;
    href: string;
    principale: boolean;
  }>;
}

const DIAPOS = [
  {
    surTitre: 'Nouvelle saison',
    titre: 'Des grandes marques, au bon prix.',
    texte: 'Les marques que vous aimez, à moitié prix. Neuf, authentique, expédié du Québec.',
    image: '/img/accueil/photo-1.svg',
    fond: 'bg-[var(--vs-noir)] text-[var(--vs-blanc)]',
    actions: [
      { label: 'Découvrir la boutique', href: '/boutique', principale: true },
      { label: 'Voir les soldes', href: '/soldes', principale: false },
    ],
  },
  {
    surTitre: 'Soldes d’automne',
    titre: 'Jusqu’à −50 % sur les sneakers.',
    texte: 'Nike, Adidas, New Balance, Converse. Stocks limités, pointures qui partent vite.',
    image: '/img/accueil/photo-2.svg',
    fond: 'bg-[var(--vs-promo)] text-[var(--vs-blanc)]',
    actions: [{ label: 'Profiter des soldes', href: '/soldes', principale: true }],
  },
  {
    surTitre: 'Arrivages',
    titre: 'Le denim et le polo, réinventés.',
    texte: 'Levi’s et Lacoste rejoignent la sélection. Les classiques, sans le prix des classiques.',
    image: '/img/accueil/photo-3.svg',
    fond: 'bg-[#E9E4DA] text-[var(--vs-noir)]',
    actions: [{ label: 'Voir les nouveautés', href: '/nouveautes', principale: true }],
  },
] as const;

interface CarrouselProps {
  intervalleMs?: number;
  auto?: boolean;
}

export function Carrousel({ intervalleMs = 5000, auto = true }: CarrouselProps) {
  const [index, setIndex] = useState(0);
  const debutGlisse = useRef<number | null>(null);

  useEffect(() => {
    if (!auto) return;
    
    const interval = setInterval(() => {
      setIndex((i) => (i + 1) % DIAPOS.length);
    }, intervalleMs);

    return () => clearInterval(interval);
  }, [auto, intervalleMs]);

  const allerSuivant = () => {
    setIndex((i) => (i + 1) % DIAPOS.length);
  };

  const allerPrecedent = () => {
    setIndex((i) => (i + 2) % DIAPOS.length);
  };

  return (
    <section 
      data-testid="carrousel" 
      aria-label="À la une" 
      aria-roledescription="carrousel"
      className="relative overflow-hidden"
      onTouchStart={(e) => { debutGlisse.current = e.touches[0]?.clientX ?? null; }}
      onTouchEnd={(e) => {
        const fin = e.changedTouches[0]?.clientX;
        if (debutGlisse.current !== null && fin !== undefined) {
          const ecart = fin - debutGlisse.current;
          if (ecart < -40) allerSuivant();
          else if (ecart > 40) allerPrecedent();
        }
        debutGlisse.current = null;
      }}
    >
      {/* Piste */}
      <div 
        data-testid="carrousel-piste"
        className="flex transition-transform duration-700 ease-in-out"
        style={{ transform: `translateX(-${index * 100}%)` }}
      >
        {DIAPOS.map((diapo, n) => (
          <div
            key={n}
            data-testid={`diapo-${n}`}
            className={`w-full shrink-0 ${diapo.fond}`}
            aria-hidden={n !== index}
            inert={n !== index ? true : undefined}
          >
            <div className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7 max-sm:relative max-sm:min-h-[300px] max-sm:items-end max-sm:overflow-hidden">
              <div className="max-sm:relative max-sm:z-10 max-sm:text-[var(--vs-blanc)]">
                <span className="text-sm font-bold tracking-wider uppercase">
                  {diapo.surTitre}
                </span>
                {n === 0 ? (
                  <h1 className="text-5xl font-black tracking-tight lg:text-7xl max-sm:mt-2 max-sm:text-[30px] max-sm:leading-[1.05]">{diapo.titre}</h1>
                ) : (
                  <h2 className="text-5xl font-black tracking-tight lg:text-7xl max-sm:mt-2 max-sm:text-[30px] max-sm:leading-[1.05]">{diapo.titre}</h2>
                )}
                <p className="mt-4 text-lg max-sm:hidden">{diapo.texte}</p>
                <div className="mt-8 flex flex-wrap gap-4 max-sm:mt-5 max-sm:gap-3">
                  {diapo.actions.map((action, i) => (
                    <a
                      key={i}
                      href={action.href}
                      className={`rounded-full h-14 px-6 flex items-center justify-center font-bold max-sm:h-11 max-sm:px-5 max-sm:text-[15px] ${
                        action.principale 
                          ? 'bg-[var(--vs-blanc)] text-[var(--vs-noir)]' 
                          : 'border border-[var(--vs-ligne)]'
                      }`}
                    >
                      {action.label}
                    </a>
                  ))}
                </div>
              </div>
              <div className="max-sm:absolute max-sm:inset-0">
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover max-sm:h-full max-sm:rounded-none" />
                <span aria-hidden="true" data-testid="carrousel-degrade" className="absolute inset-0 hidden bg-[linear-gradient(180deg,rgba(16,16,20,0.05)_25%,rgba(16,16,20,0.72)_100%)] max-sm:block" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Commandes */}
      <button 
        type="button" 
        aria-label="Diapositive précédente"
        className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
        onClick={allerPrecedent}
      >
        <ChevronLeft aria-hidden size={20} />
      </button>
      
      <button 
        type="button" 
        aria-label="Diapositive suivante"
        className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
        onClick={allerSuivant}
      >
        <ChevronRight aria-hidden size={20} />
      </button>

      {/* Points */}
      <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex gap-2">
        {DIAPOS.map((_, n) => (
          <button
            key={n}
            type="button"
            aria-label={`Aller à la diapositive ${n + 1}`}
            aria-current={n === index ? 'true' : undefined}
            className={`h-2 rounded-full ${
              n === index 
                ? 'w-9 bg-[var(--vs-blanc)]' 
                : 'w-2 bg-[var(--vs-ligne)]'
            }`}
            onClick={() => setIndex(n)}
          />
        ))}
      </div>
    </section>
  );
}
