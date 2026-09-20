import { ReactNode } from 'react';

interface NavItem {
  label: string;
  href: string;
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
    >
      <div className="container mx-auto px-4 py-3 flex items-center justify-between">
        <a 
          href="/" 
          data-testid="entete-marque"
          className="text-[var(--vs-font-display)] font-bold tracking-wide text-xl"
        >
          VICTO STORE
        </a>
        
        <nav aria-label="Navigation principale">
          <ul className="flex space-x-6">
            {navItems.map((item) => (
              <li key={item.href}>
                <a 
                  href={item.href} 
                  className="text-[var(--vs-noir)] hover:text-[var(--vs-accent)] transition-colors"
                >
                  {item.label}
                </a>
              </li>
            ))}
          </ul>
        </nav>
        
        <a 
          href="/panier" 
          data-testid="entete-panier"
          data-cart-count={cartCount}
          aria-label={cartLabel}
          className="relative"
        >
          <span className="sr-only">Panier</span>
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
    </header>
  );
}
