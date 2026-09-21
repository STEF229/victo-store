import { ReactNode } from 'react';

export interface NavItem {
  label: string;
  href: string;
  promo?: boolean;
}

interface SiteHeaderProps {
  navItems: NavItem[];
  cartCount?: number;
  className?: string;
}

export function SiteHeader({ 
  navItems, 
  cartCount = 0, 
  className = '' 
}: SiteHeaderProps) {
  const cartLabel = cartCount <= 1 
    ? `Panier, ${cartCount} article` 
    : `Panier, ${cartCount} articles`;

  return (
    <header 
      data-ui="site-header" 
      className={`border-b border-[var(--vs-ligne)] bg-[var(--vs-blanc)] ${className}`}
      role="banner"
    >
      <div className="grid grid-cols-3 items-center container mx-auto px-4 py-3">
        {/* Left zone - Menu button */}
        <div className="flex justify-start">
          <button 
            type="button" 
            aria-label="Ouvrir le menu"
            className="lg:hidden"
          >
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-11 w-11" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor" 
              aria-hidden="true"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M4 6h16M4 12h16M4 18h16" 
              />
            </svg>
          </button>
        </div>

        {/* Center zone - Brand */}
        <div className="flex justify-center">
          <a 
            href="/" 
            data-testid="entete-marque"
            className="text-[var(--vs-font-display)] font-bold tracking-wide text-2xl"
          >
            VICTO STORE
          </a>
        </div>

        {/* Right zone - Actions */}
        <div className="flex justify-end space-x-4">
          <button 
            type="button" 
            aria-label="Rechercher"
          >
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-11 w-11" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor" 
              aria-hidden="true"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M21 21l-6-6m2-7a9 9 0 11-18 0 9 9 0 0118 0z" 
              />
            </svg>
          </button>
          
          <button 
            type="button" 
            aria-label="Mon compte"
          >
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-11 w-11" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor" 
              aria-hidden="true"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" 
              />
            </svg>
          </button>
          
          <a 
            href="/panier" 
            data-testid="entete-panier"
            data-cart-count={cartCount}
            aria-label={cartLabel}
            className="relative"
          >
            <span className="sr-only">Panier</span>
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-11 w-11" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor" 
              aria-hidden="true"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" 
              />
            </svg>
            {cartCount > 0 && (
              <span 
                data-testid="entete-panier-compte"
                className="absolute -top-2 -right-2 bg-[var(--vs-accent)] text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold"
              >
                {cartCount}
              </span>
            )}
          </a>
        </div>
      </div>
      
      {/* Navigation - hidden on mobile, visible on large screens */}
      <nav aria-label="Navigation principale" className="hidden lg:flex">
        <ul className="flex space-x-6 justify-center">
          {navItems.map((item) => (
            <li key={item.href}>
              <a 
                href={item.href} 
                className={`text-[var(--vs-noir)] hover:text-[var(--vs-accent)] transition-colors ${item.promo ? 'text-[var(--vs-promo)]' : ''}`}
              >
                {item.label}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  );
}
