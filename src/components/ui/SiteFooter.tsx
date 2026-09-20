import { ReactNode } from 'react';

export interface ColonnePied {
  titre: string;
  liens: Array<{ label: string; href: string }>;
}

interface SiteFooterProps {
  colonnes: ColonnePied[];
  annee?: number;
  className?: string;
}

export function SiteFooter({ colonnes, annee = new Date().getFullYear(), className = '' }: SiteFooterProps) {
  return (
    <footer 
      data-testid="pied" 
      data-ui="site-footer"
      className={`bg-[var(--vs-surface)] border-t border-[var(--vs-ligne)] py-8 ${className}`}
    >
      <div className="max-w-[var(--vs-maxw)] mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {colonnes.map((colonne, index) => (
            <div key={index}>
              <h3 
                data-ui="footer-heading" 
                className="text-lg font-bold mb-4"
              >
                {colonne.titre}
              </h3>
              <ul className="space-y-2">
                {colonne.liens.map((lien, idx) => (
                  <li key={idx}>
                    <a 
                      href={lien.href} 
                      data-ui="footer-link"
                      className="text-[var(--vs-noir)] hover:text-[var(--vs-promo)] transition-colors"
                    >
                      {lien.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        
        <div className="mt-8 pt-8 border-t border-[var(--vs-ligne)] flex flex-col md:flex-row justify-between items-center">
          <p 
            data-testid="pied-slogan"
            className="text-[var(--vs-gris)] mb-4 md:mb-0"
          >
            Des grandes marques, au bon prix.
          </p>
          <p 
            data-testid="pied-mentions"
            className="text-[var(--vs-gris)]"
          >
            © {annee} VICTO STORE
          </p>
        </div>
      </div>
    </footer>
  );
}
