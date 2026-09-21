'use client';

import { useEffect, useState } from 'react';

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
            <div className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2">
              <div>
                <span className="text-sm font-bold tracking-wider uppercase">{diapo.surTitre}</span>
                {n === 0 ? (
                  <h1 className="text-5xl font-black tracking-tight lg:text-7xl">{diapo.titre}</h1>
                ) : (
                  <h2 className="text-5xl font-black tracking-tight lg:text-7xl">{diapo.titre}</h2>
                )}
                <p className="mt-4 text-lg">{diapo.texte}</p>
                <div className="mt-8 flex flex-wrap gap-4">
                  {diapo.actions.map((action, i) => (
                    <a
                      key={i}
                      href={action.href}
                      className={`rounded-full h-14 px-6 flex items-center justify-center ${
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
              <div>
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover" />
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Commandes */}
      <button 
        type="button" 
        aria-label="Diapositive précédente"
        className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
        onClick={allerPrecedent}
      >
        <svg 
          aria-hidden="true" 
          xmlns="http://www.w3.org/2000/svg" 
          fill="none" 
          viewBox="0 0 24 24" 
          strokeWidth={1.5} 
          stroke="currentColor" 
          className="h-6 w-6"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 19l-3-3m0 0l-3 3m3-3v12m0-18l-3 3m3-3l3 3" />
        </svg>
      </button>
      
      <button 
        type="button" 
        aria-label="Diapositive suivante"
        className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
        onClick={allerSuivant}
      >
        <svg 
          aria-hidden="true" 
          xmlns="http://www.w3.org/2000/svg" 
          fill="none" 
          viewBox="0 0 24 24" 
          strokeWidth={1.5} 
          stroke="currentColor" 
          className="h-6 w-6"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
        </svg>
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
