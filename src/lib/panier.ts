export interface LignePanier {
  slug: string;
  sku: string;
  quantite: number;
}
export type Panier = LignePanier[];
export const CLE_PANIER = 'victo-panier';

export function ajouterAuPanier(
  panier: Panier,
  article: { slug: string; sku: string },
  quantite: number,
  stock: number,
): Panier {
  const quantiteArrondie = Math.floor(quantite);
  
  if (quantiteArrondie <= 0 || stock <= 0) {
    return panier;
  }
  
  const index = panier.findIndex(ligne => ligne.sku === article.sku);
  
  if (index !== -1) {
    // Ligne existe déjà, cumule les quantités
    const ancienneQuantite = panier[index].quantite;
    const nouvelleQuantite = Math.min(ancienneQuantite + quantiteArrondie, stock);
    
    if (nouvelleQuantite === ancienneQuantite) {
      return panier;
    }
    
    // Crée un nouveau tableau avec la ligne mise à jour
    const nouveauPanier = [...panier];
    nouveauPanier[index] = { ...nouveauPanier[index], quantite: nouvelleQuantite };
    return nouveauPanier;
  } else {
    // Ajoute une nouvelle ligne
    const nouvelleQuantite = Math.min(quantiteArrondie, stock);
    return [...panier, { ...article, quantite: nouvelleQuantite }];
  }
}

export function changerQuantite(panier: Panier, sku: string, quantite: number, stock: number): Panier {
  const index = panier.findIndex(ligne => ligne.sku === sku);
  
  if (index === -1) {
    return panier;
  }
  
  const nouvelleQuantite = Math.min(quantite, stock);
  
  if (nouvelleQuantite <= 0) {
    // Retire la ligne
    const nouveauPanier = [...panier];
    nouveauPanier.splice(index, 1);
    return nouveauPanier;
  } else {
    // Met à jour la quantité
    const nouveauPanier = [...panier];
    nouveauPanier[index] = { ...nouveauPanier[index], quantite: nouvelleQuantite };
    return nouveauPanier;
  }
}

export function retirerDuPanier(panier: Panier, sku: string): Panier {
  const index = panier.findIndex(ligne => ligne.sku === sku);
  
  if (index === -1) {
    return panier;
  }
  
  const nouveauPanier = [...panier];
  nouveauPanier.splice(index, 1);
  return nouveauPanier;
}

export function nombreArticles(panier: Panier): number {
  return panier.reduce((total, ligne) => total + ligne.quantite, 0);
}

export function lirePanier(texte: string | null): Panier {
  if (texte === null) {
    return [];
  }
  
  let parsed: unknown;
  try {
    parsed = JSON.parse(texte);
  } catch {
    return [];
  }
  
  if (!Array.isArray(parsed)) {
    return [];
  }
  
  const lignes: LignePanier[] = [];
  
  for (const item of parsed) {
    if (
      item !== null &&
      typeof item === 'object' &&
      typeof item.slug === 'string' &&
      item.slug !== '' &&
      typeof item.sku === 'string' &&
      item.sku !== '' &&
      typeof item.quantite === 'number' &&
      Number.isInteger(item.quantite) &&
      item.quantite > 0
    ) {
      lignes.push({
        slug: item.slug,
        sku: item.sku,
        quantite: item.quantite
      });
    }
  }
  
  return lignes;
}

export function ecrirePanier(panier: Panier): string {
  return JSON.stringify(panier);
}
