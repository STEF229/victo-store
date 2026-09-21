export interface Marque {
  id: string;
  nom: string;
  slug: string;
}

export interface Variante {
  id: string;
  taille: string;      // « 40 », « M », « 32/34 »
  sku: string;
  stock: number;       // entier >= 0
}

export type Genre = 'femme' | 'homme' | 'mixte';
export type Categorie = 'chaussures' | 'vetements' | 'accessoires';

export const LIBELLES_CATEGORIE: Record<Categorie, string> = {
  chaussures: 'Chaussures',
  vetements: 'Vêtements',
  accessoires: 'Accessoires',
};

export interface Produit {
  id: string;
  slug: string;
  nom: string;
  marque: Marque;
  imageUrl: string;
  prixCents: number;
  prixCompareCents?: number;
  variantes: Variante[];
  badge?: string;
  genre?: Genre;
  categorie?: Categorie;
  description?: string;
  composition?: string;
  images?: string[];
}

export function hrefProduit(produit: Produit): string {
  return `/produits/${produit.slug}`;
}

export function hrefMarque(marque: Marque): string {
  return `/marques/${marque.slug}`;
}

export function estEnPromotion(produit: Produit): boolean {
  return produit.prixCompareCents !== undefined && 
         produit.prixCompareCents > produit.prixCents;
}

export function remisePourcent(produit: Produit): number | null {
  if (!estEnPromotion(produit)) {
    return null;
  }
  
  const remise = 1 - (produit.prixCents / produit.prixCompareCents!);
  return Math.round(remise * 100);
}

export function optionsDeTaille(produit: Produit): Array<{ value: string; available: boolean }> {
  return produit.variantes.map((variante) => ({
    value: variante.taille,
    available: variante.stock > 0
  }));
}

export function stockTotal(produit: Produit): number {
  return produit.variantes.reduce((total, variante) => total + variante.stock, 0);
}

export function estEnRupture(produit: Produit): boolean {
  return stockTotal(produit) === 0;
}

export function imagesProduit(produit: Produit): string[] {
  if (produit.images && produit.images.length > 0) {
    return [...produit.images];
  }
  return [produit.imageUrl];
}

export function correspondAuGenre(produit: Produit, genre: 'femme' | 'homme'): boolean {
  return produit.genre === genre || produit.genre === 'mixte';
}

export function economieCents(produit: Produit): number {
  if (estEnPromotion(produit)) {
    return produit.prixCompareCents! - produit.prixCents;
  }
  return 0;
}
