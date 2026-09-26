export interface LignePanier {
  slug: string;
  sku: string;
  quantite: number;
}
export type Panier = LignePanier[];
export const CLE_PANIER = 'victo-panier';

function estLigne(x: unknown): x is LignePanier {
  return (
    typeof x === 'object' && x !== null &&
    'slug' in x && typeof x.slug === 'string' && x.slug !== '' &&
    'sku' in x && typeof x.sku === 'string' && x.sku !== '' &&
    'quantite' in x && typeof x.quantite === 'number' && Number.isInteger(x.quantite) && x.quantite > 0
  );
}

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
  
  const existante = panier.find((l) => l.sku === article.sku);
  
  if (existante) {
    const nouvelleQuantite = Math.min(existante.quantite + quantiteArrondie, stock);
    return panier.map((l) => 
      l.sku === article.sku ? { ...l, quantite: nouvelleQuantite } : l
    );
  } else {
    const nouvelleQuantite = Math.min(quantiteArrondie, stock);
    return [...panier, { ...article, quantite: nouvelleQuantite }];
  }
}

export function changerQuantite(panier: Panier, sku: string, quantite: number, stock: number): Panier {
  const existante = panier.find((l) => l.sku === sku);
  
  if (!existante) {
    return panier;
  }
  
  const nouvelleQuantite = Math.min(quantite, stock);
  
  if (nouvelleQuantite <= 0) {
    return panier.filter((l) => l.sku !== sku);
  } else {
    return panier.map((l) => 
      l.sku === sku ? { ...l, quantite: nouvelleQuantite } : l
    );
  }
}

export function retirerDuPanier(panier: Panier, sku: string): Panier {
  return panier.filter((l) => l.sku !== sku);
}

export function nombreArticles(panier: Panier): number {
  return panier.reduce((total, ligne) => total + ligne.quantite, 0);
}

export function lirePanier(texte: string | null): Panier {
  if (texte === null) {
    return [];
  }
  
  try {
    const donnees = JSON.parse(texte);
    if (!Array.isArray(donnees)) {
      return [];
    }
    return donnees
      .filter(estLigne)
      .map((l) => ({ slug: l.slug, sku: l.sku, quantite: l.quantite }));
  } catch {
    return [];
  }
}

export function ecrirePanier(panier: Panier): string {
  return JSON.stringify(panier);
}
