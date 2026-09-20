import { Container } from '@/components/ui/layout';

export interface ColonnePied {
  titre: string;
  liens: Array<{ label: string; href: string }>;
}

interface SiteFooterProps {
  colonnes: ColonnePied[];
  annee?: number;
  className?: string;
}

export function SiteFooter({ colonnes, annee, className = '' }: SiteFooterProps) {
  const anneeAffichee = annee ?? new Date().getFullYear();
  
  return (
    <footer 
      data-testid="pied" 
      role="contentinfo"
      className={className}
    >
      <Container>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 py-8">
          {colonnes.map((colonne, index) => (
            <section key={index}>
              <h2 className="text-lg font-bold mb-4">{colonne.titre}</h2>
              <ul className="space-y-2">
                {colonne.liens.map((lien, idx) => (
                  <li key={idx}>
                    <a 
                      href={lien.href} 
                      className="text-[var(--vs-noir)] hover:text-[var(--vs-accent)] transition-colors"
                    >
                      {lien.label}
                    </a>
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>
        
        <p data-testid="pied-mentions" className="text-center text-[var(--vs-gris)] py-4">
          © {anneeAffichee} VICTO STORE
        </p>
        
        <p data-testid="pied-slogan" className="text-center text-[var(--vs-gris)] py-4">
          Des grandes marques, au bon prix.
        </p>
      </Container>
    </footer>
  );
}
