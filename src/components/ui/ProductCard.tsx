'use client';

import { useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Price } from '@/components/ui/Price';
import { estEnPromotion, hrefProduit, remisePourcent, type Produit } from '@/lib/catalogue';

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
          <svg 
            aria-hidden="true" 
            xmlns="http://www.w3.org/2000/svg" 
            viewBox="0 0 24 24" 
            fill={favori ? "#C70026" : "none"} 
            stroke={favori ? "#C70026" : "#1E1E26"} 
            strokeWidth="1.5" 
            className="w-6 h-6"
          >
            <path 
              strokeLinecap="round" 
              strokeLinejoin="round" 
              d="M21 8.25c0-2.485-2.099-4.5-4.5-4.5s-4.5 2.015-4.5 4.5c0 1.016-.07 2.012-.203 3m-2.118 6.844A12.025 12.025 0 0112 19.5c-2.553 0-4.997-.658-7.077-1.855M12 19.5c2.553 0 4.997-.658 7.077-1.855M12 19.5c2.553 0 4.997-.658 7.077-1.855m-7.077 1.855c-.133.04-.27.067-.41.082a12.025 12.025 0 00-7.077-1.855M12 19.5c2.553 0 4.997-.658 7.077-1.855m-7.077 1.855c-.133.04-.27.067-.41.082a12.025 12.025 0 00-7.077-1.855M12 19.5c2.553 0 4.997-.658 7.077-1.855m-7.077 1.855c-.133.04-.27.067-.41.082a12.025 12.025 0 00-7.077-1.855" 
            />
          </svg>
        </button>
      </div>
    </article>
  );
}
