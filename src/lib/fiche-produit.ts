import { hrefMarque, LIBELLES_CATEGORIE, type Produit } from '@/lib/catalogue';

export interface ElementFil {
  label: string;
  href?: string;
}

export const TEXTE_LIVRAISON =
  "Expédiée du Québec sous 48 heures, livraison offerte partout au Canada. Retours gratuits pendant 30 jours, article non porté dans sa boîte d'origine.";

export function filAriane(produit: Produit): ElementFil[] {
  const fil = [
    { label: 'Accueil', href: '/' },
  ];

  if (produit.categorie) {
    if (produit.categorie === 'chaussures') {
      fil.push({ 
        label: LIBELLES_CATEGORIE[produit.categorie], 
        href: '/chaussures' 
      });
    } else {
      fil.push({ 
        label: LIBELLES_CATEGORIE[produit.categorie] 
      });
    }
  }

  fil.push({ 
    label: produit.marque.nom, 
    href: hrefMarque(produit.marque) 
  });

  fil.push({ 
    label: produit.nom 
  });

  return fil;
}

export function texteStockBas(produit: Produit, taille: string | null): string | null {
  if (taille === null) {
    return null;
  }

  const variante = produit.variantes.find((v) => v.taille === taille);
  
  if (!variante || variante.stock <= 0 || variante.stock > 3) {
    return null;
  }
  
  const n = variante.stock;
  const unite = produit.categorie === 'chaussures' 
    ? (n > 1 ? 'paires' : 'paire') 
    : (n > 1 ? 'pièces' : 'pièce');
  
  return `Plus que ${n} ${unite} en ${taille}`;
}

export function produitsSimilaires(produit: Produit, tous: Produit[], nombre: number = 4): Produit[] {
  const autres = tous.filter((p) => p.id !== produit.id);
  
  const memesCategories = autres.filter((p) => p.categorie === produit.categorie);
  const autresCategories = autres.filter((p) => p.categorie !== produit.categorie);
  
  const resultat = [...memesCategories, ...autresCategories];
  
  return resultat.slice(0, nombre);
}
