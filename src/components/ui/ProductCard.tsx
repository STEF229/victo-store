import { Produit } from '../../lib/catalogue';
import { Price } from './Price';
import { Badge } from './Badge';
import { hrefProduit } from '../../lib/catalogue';

interface ProductCardProps {
  produit: Produit;
  className?: string;
}

export function ProductCard({ produit, className = '' }: ProductCardProps) {
  return (
    <article 
      data-ui="product-card" 
      data-testid="carte-produit"
      data-produit-id={produit.id}
      className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] ${className}`}
    >
      <a href={hrefProduit(produit)}>
        <div className="relative">
          <img 
            src={produit.imageUrl} 
            alt={`${produit.marque.nom} ${produit.nom}`} 
            className="w-full aspect-[4/5] object-cover"
          />
          {produit.badge && (
            <div className="absolute top-2 right-2">
              <Badge variant="promo">{produit.badge}</Badge>
            </div>
          )}
        </div>
        
        <div className="p-4">
          <span 
            data-testid="carte-marque" 
            className="text-xs uppercase text-[var(--vs-gris)]"
          >
            {produit.marque.nom}
          </span>
          <span 
            data-testid="carte-nom" 
            className="block text-[var(--vs-noir)] font-medium mt-1"
          >
            {produit.nom}
          </span>
          <Price 
            amount={produit.prixCents} 
            compareAt={produit.prixCompareCents} 
          />
        </div>
      </a>
    </article>
  );
}
