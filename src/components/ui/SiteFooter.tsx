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
      className={`bg-[var(--vs-noir)] text-[var(--vs-blanc)] ${className}`}
    >
      <div className="max-w-[var(--vs-maxw)] mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {/* Brand and slogan section */}
          <div className="md:col-span-2">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
              <div>
                <p className="text-[26px] font-black tracking-[0.1em]">VICTO STORE</p>
                <p className="text-[var(--vs-blanc)] mt-2">Des grandes marques, au bon prix.</p>
              </div>
            </div>
            
            {/* Columns */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {colonnes.map((colonne, index) => (
                <div key={index}>
                  <h3 
                    data-ui="footer-heading" 
                    className="text-sm font-black uppercase mb-4 text-[#B5B5BA]"
                  >
                    {colonne.titre}
                  </h3>
                  <ul className="space-y-2">
                    {colonne.liens.map((lien, idx) => (
                      <li key={idx}>
                        <a 
                          href={lien.href} 
                          data-ui="footer-link"
                          className="text-[var(--vs-blanc)] hover:text-[var(--vs-promo)] transition-colors"
                        >
                          {lien.label}
                        </a>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </div>
        </div>
        
        {/* Decorative watermark */}
        <p 
          aria-hidden="true" 
          data-testid="pied-filigrane"
          className="select-none text-[200px] font-black leading-none text-[#1E1E26]"
        >
          VICTO
        </p>
        
        {/* Mentions with border */}
        <div className="mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center">
          <p 
            data-testid="pied-slogan"
            className="text-[var(--vs-blanc)] mb-4 md:mb-0"
          >
            Des grandes marques, au bon prix.
          </p>
          <p 
            data-testid="pied-mentions"
            className="text-[#B5B5BA]"
          >
            © {annee} VICTO STORE
          </p>
        </div>
      </div>
    </footer>
  );
}
