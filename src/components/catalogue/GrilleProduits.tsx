import type { Produit } from '@/lib/catalogue';
import { ProductCard } from '@/components/ui/ProductCard';

interface GrilleProduitsProps {
  produits: Produit[];
  className?: string;
}

export function GrilleProduits({ produits, className = '' }: GrilleProduitsProps) {
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
      className={`grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 ${className}`}
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
