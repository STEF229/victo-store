'use client';

import { Menu, Search, ShoppingBag, User } from 'lucide-react';
import { usePanier } from '@/components/panier/PanierProvider';

export interface NavItem {
  label: string;
  href: string;
  promo?: boolean;
}

interface SiteHeaderProps {
  navItems: NavItem[];
  cartCount: number;
  className?: string;
}

export function SiteHeader({ 
  navItems, 
  cartCount, 
  className = '' 
}: SiteHeaderProps) {
  const { nombre } = usePanier();
  const compte = cartCount ?? nombre;

  const libellePanier = compte <= 1 
    ? `Panier, ${compte} article` 
    : `Panier, ${compte} articles`;

  return (
    <>
      <header 
        data-testid="entete" 
        className={`bg-[var(--vs-noir)] text-[var(--vs-blanc)] ${className}`}
        role="banner"
      >
        <div 
          data-testid="entete-ligne"
          className="grid h-20 grid-cols-[auto_1fr_auto] items-center gap-6 px-5 lg:px-12"
        >
          <div className="flex items-center gap-2">
            <button 
              type="button" 
              aria-label="Ouvrir le menu" 
              className="flex h-11 w-11 items-center justify-center lg:hidden"
            >
              <Menu aria-hidden size={22} />
            </button>
            <a 
              href="/" 
              data-testid="entete-marque" 
              className="text-[23px] font-black tracking-[0.1em] whitespace-nowrap"
            >
              VICTO STORE
            </a>
          </div>

          <nav 
            aria-label="Navigation principale" 
            className="hidden justify-self-center gap-8 text-[15px] font-semibold lg:flex"
          >
            {navItems.map((item) => (
              <a 
                key={item.href} 
                href={item.href} 
                className={item.promo ? 'text-[#FF5A74]' : undefined}
              >
                {item.label}
              </a>
            ))}
          </nav>

          <div className="flex items-center justify-self-end gap-2">
            <label 
              htmlFor="recherche-entete" 
              className="sr-only"
            >
              Rechercher un produit
            </label>
            <button 
              type="button" 
              aria-label="Rechercher" 
              className="hidden h-11 w-11 items-center justify-center lg:flex"
            >
              <Search aria-hidden size={17} />
            </button>
            <div className="hidden h-11 w-[250px] items-center gap-2 rounded-full border border-[#2A2A30] bg-[#1E1E26] px-4 lg:flex">
              <input
                id="recherche-entete"
                type="search"
                placeholder="Rechercher"
                className="h-10 min-w-0 flex-1 border-none bg-transparent text-sm text-[var(--vs-blanc)] outline-none"
              />
            </div>
            <button 
              type="button" 
              aria-label="Mon compte" 
              className="hidden h-11 w-11 items-center justify-center lg:flex"
            >
              <User aria-hidden size={21} />
            </button>
            <a 
              href="/panier" 
              data-testid="entete-panier" 
              data-cart-count={compte} 
              aria-label={libellePanier}
              className="relative flex h-11 w-11 items-center justify-center"
            >
              <ShoppingBag aria-hidden size={21} />
              {compte > 0 && (
                <span 
                  data-testid="entete-panier-compte"
                  className="absolute right-0 top-1 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-[var(--vs-accent)] px-1 text-[11px] font-extrabold"
                >
                  {compte}
                </span>
              )}
            </a>
          </div>
        </div>
      </header>

      <div 
        data-testid="filet-annonce"
        className="flex h-9 items-center justify-center gap-6 border-b border-[var(--vs-ligne)] bg-[var(--vs-surface)] text-[12.5px] font-semibold text-[var(--vs-gris)]"
      >
        <span>Livraison offerte au Canada</span>
        <span className="hidden sm:inline">Retours gratuits 30 jours</span>
        <span className="hidden sm:inline">Authenticité garantie</span>
      </div>
    </>
  );
}
