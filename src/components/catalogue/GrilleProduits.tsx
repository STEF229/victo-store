import type { Produit } from '@/lib/catalogue';
import { ProductCard } from '@/components/ui/ProductCard';

interface GrilleProduitsProps {
  produits: Produit[];
  colonnes?: 3 | 4;
  className?: string;
}

export function GrilleProduits({ produits, colonnes = 3, className = '' }: GrilleProduitsProps) {
  const COLONNES = { 3: 'lg:grid-cols-3', 4: 'lg:grid-cols-4' } as const;
  
  if (produits.length === 0) {
    return (
      <p data-testid="grille-vide" className={className}>
        Aucun produit ne correspond à ces filtres.
      </p>
    );
  }

  return (
    <ul 
      data-testid="grille" 
      className={`grid grid-cols-1 gap-6 sm:grid-cols-2 ${COLONNES[colonnes]} ${className}`}
    >
      {produits.map((produit) => (
        <li 
          key={produit.id} 
          className="w-full"
        >
          <ProductCard produit={produit} />
        </li>
      ))}
    </ul>
  );
}
