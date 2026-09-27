import type { Produit, Variante } from '@/lib/catalogue';
import type { Panier } from '@/lib/panier';

export interface LigneDetaillee {
  slug: string;
  sku: string;
  quantite: number;
  produit: Produit;
  variante: Variante;
  totalCents: number;
  economieCents: number;
}

export interface RecapPanier {
  articles: number;
  sousTotalCents: number;
  economiesCents: number;
  totalCents: number;
}

export function detaillerPanier(lignes: Panier, trouver: (slug: string) => Produit | undefined): LigneDetaillee[] {
  return lignes.flatMap((ligne) => {
    const produit = trouver(ligne.slug);
    
    if (!produit) {
      return [];
    }
    
    const variante = produit.variantes.find((v) => v.sku === ligne.sku);
    
    if (!variante) {
      return [];
    }
    
    const remise = produit.prixCompareCents !== undefined && produit.prixCompareCents > produit.prixCents
      ? produit.prixCompareCents - produit.prixCents
      : 0;
    
    return [{
      slug: ligne.slug,
      sku: ligne.sku,
      quantite: ligne.quantite,
      produit,
      variante,
      totalCents: produit.prixCents * ligne.quantite,
      economieCents: remise * ligne.quantite
    }];
  });
}

export function recapitulerPanier(lignes: LigneDetaillee[]): RecapPanier {
  const articles = lignes.reduce((total, ligne) => total + ligne.quantite, 0);
  const sousTotalCents = lignes.reduce((total, ligne) => total + ligne.totalCents, 0);
  const economiesCents = lignes.reduce((total, ligne) => total + ligne.economieCents, 0);
  const totalCents = sousTotalCents;
  
  return {
    articles,
    sousTotalCents,
    economiesCents,
    totalCents
  };
}

export function libelleArticles(n: number): string {
  return `${n} ${n > 1 ? 'articles' : 'article'}`;
}
