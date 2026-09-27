import { estEnPromotion, type Marque, type Produit } from '@/lib/catalogue';

export interface ResumeMarque {
  marque: Marque;
  nombre: number;
  enSoldes: number;
}

export function resumerMarques(marques: Marque[], produits: Produit[]): ResumeMarque[] {
  const result = marques
    .map((marque) => {
      const siens = produits.filter((produit) => produit.marque.slug === marque.slug);
      return {
        marque,
        nombre: siens.length,
        enSoldes: siens.filter(estEnPromotion).length,
      };
    })
    .filter((resume) => resume.nombre > 0)
    .sort((a, b) => a.marque.nom.localeCompare(b.marque.nom, 'fr'));
  
  return result;
}

export function libelleMarques(n: number): string {
  return `${n} ${n > 1 ? 'marques' : 'marque'}`;
}

export function libelleProduits(n: number): string {
  return `${n} ${n > 1 ? 'produits' : 'produit'}`;
}
