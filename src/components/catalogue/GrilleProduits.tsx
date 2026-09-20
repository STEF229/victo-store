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
      className={`grid gap-6 ${className}`}
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
