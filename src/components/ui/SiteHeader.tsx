import { ReactNode } from 'react';
import { Menu, Search, ShoppingBag, User } from 'lucide-react';

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
            <Menu aria-hidden size={22} />
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
            <Search aria-hidden size={21} />
          </button>
          
          <button 
            type="button" 
            aria-label="Mon compte"
          >
            <User aria-hidden size={21} />
          </button>
          
          <a 
            href="/panier" 
            data-testid="entete-panier"
            data-cart-count={cartCount}
            aria-label={cartLabel}
            className="relative"
          >
            <span className="sr-only">Panier</span>
            <ShoppingBag aria-hidden size={21} />
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
