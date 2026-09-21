'use client';

import { useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Price } from '@/components/ui/Price';
import { estEnPromotion, hrefProduit, remisePourcent, type Produit } from '@/lib/catalogue';
import { Heart } from 'lucide-react';

interface ProductCardProps {
  produit: Produit;
  className?: string;
}

export function ProductCard({ produit, className = '' }: ProductCardProps) {
  const [favori, setFavori] = useState(false);
  
  return (
    <article 
      data-ui="product-card" 
      data-testid="carte-produit"
      data-produit-id={produit.id}
      className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] ${className}`}
    >
      <div>
        <a href={hrefProduit(produit)}>
          <div data-testid="carte-visuel" className="relative overflow-hidden rounded-[20px] bg-[var(--vs-surface)]">
            <img 
              src={produit.imageUrl} 
              alt={`${produit.marque.nom} ${produit.nom}`} 
              className="h-full w-full object-cover aspect-[4/5]"
            />
            
            {estEnPromotion(produit) && (
              <div className="absolute top-2 left-2">
                <span 
                  data-testid="prix-remise" 
                  className="bg-[var(--vs-promo)] text-white rounded-full px-2 py-1 text-xs font-bold"
                >
                  {`\u2212${remisePourcent(produit)}\u00A0%`}
                </span>
              </div>
            )}
            
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
              afficherRemise={false}
            />
          </div>
        </a>
        
        <button 
          type="button" 
          aria-label="Ajouter aux favoris" 
          aria-pressed={favori}
          onClick={() => setFavori(!favori)}
          className="absolute top-2 right-2 bg-white rounded-full w-11 h-11 flex items-center justify-center ml-4"
        >
          <Heart aria-hidden size={18} fill={favori ? 'currentColor' : 'none'} />
        </button>
      </div>
    </article>
  );
}
