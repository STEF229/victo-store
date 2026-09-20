import type { Produit } from '@/lib/catalogue';
import { estEnPromotion, remisePourcent, stockTotal } from '@/lib/catalogue';

export interface Criteres {
  marques?: string[];        // slugs de marque
  tailles?: string[];        // valeurs de taille
  promotionSeulement?: boolean;
  enStockSeulement?: boolean;
}

export type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';

export interface Page<T> {
  items: T[];
  page: number;
  pages: number;
  total: number;
}

export function filtrerProduits(produits: Produit[], criteres: Criteres): Produit[] {
  // If no criteria or empty arrays, return all products
  if (
    (!criteres.marques || criteres.marques.length === 0) &&
    (!criteres.tailles || criteres.tailles.length === 0) &&
    !criteres.promotionSeulement &&
    !criteres.enStockSeulement
  ) {
    return [...produits];
  }

  return produits.filter(produit => {
    // Filter by marque
    if (criteres.marques && criteres.marques.length > 0) {
      if (!criteres.marques.includes(produit.marque.slug)) {
        return false;
      }
    }

    // Filter by taille
    if (criteres.tailles && criteres.tailles.length > 0) {
      const hasMatchingTaille = produit.variantes.some(variante => 
        criteres.tailles!.includes(variante.taille)
      );
      if (!hasMatchingTaille) {
        return false;
      }
    }

    // Filter by promotion
    if (criteres.promotionSeulement === true) {
      if (!estEnPromotion(produit)) {
        return false;
      }
    }

    // Filter by stock
    if (criteres.enStockSeulement === true) {
      if (stockTotal(produit) <= 0) {
        return false;
      }
    }

    return true;
  });
}

export function trierProduits(produits: Produit[], tri: Tri): Produit[] {
  // Create a copy to avoid mutating the original array
  const result = [...produits];
  
  switch (tri) {
    case 'nouveautes':
      // Keep original order, return a copy
      return result;
      
    case 'prix-croissant':
      return result.sort((a, b) => a.prixCents - b.prixCents);
      
    case 'prix-decroissant':
      return result.sort((a, b) => b.prixCents - a.prixCents);
      
    case 'remise':
      return result.sort((a, b) => {
        const remiseA = estEnPromotion(a) ? (remisePourcent(a) || 0) : 0;
        const remiseB = estEnPromotion(b) ? (remisePourcent(b) || 0) : 0;
        return remiseB - remiseA;
      });
      
    default:
      return result;
  }
}

export function paginer<T>(items: T[], page: number, parPage: number): Page<T> {
  if (parPage < 1) {
    throw new RangeError('paginer: parPage doit être >= 1');
  }

  const total = items.length;
  const pages = Math.max(1, Math.ceil(total / parPage));
  
  // Clamp page to valid range
  const currentPage = Math.max(1, Math.min(page, pages));
  
  const startIndex = (currentPage - 1) * parPage;
  const endIndex = startIndex + parPage;
  
  return {
    items: items.slice(startIndex, endIndex),
    page: currentPage,
    pages,
    total
  };
}
