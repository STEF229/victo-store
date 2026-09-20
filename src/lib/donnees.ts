import type { Marque, Produit } from '@/lib/catalogue';

// Marques du catalogue
export const MARQUES: Marque[] = [
  { id: 'nike', nom: 'Nike', slug: 'nike' },
  { id: 'adidas', nom: 'Adidas', slug: 'adidas' },
  { id: 'converse', nom: 'Converse', slug: 'converse' },
  { id: 'lacoste', nom: 'Lacoste', slug: 'lacoste' },
  { id: 'levis', nom: 'Levi\'s', slug: 'levis' },
  { id: 'newbalance', nom: 'New Balance', slug: 'newbalance' }
];

// Produits du catalogue
export const PRODUITS: Produit[] = [
  {
    id: 'chaussure-nike-air-max',
    slug: 'chaussure-nike-air-max',
    nom: 'Chaussure Nike Air Max',
    marque: MARQUES[0],
    imageUrl: '/img/pegasus.svg',
    prixCents: 12900,
    prixCompareCents: 15900,
    variantes: [
      { id: 'air-max-42', taille: '42', sku: 'NAM42', stock: 5 },
      { id: 'air-max-43', taille: '43', sku: 'NAM43', stock: 3 }
    ],
    badge: 'promo'
  },
  {
    id: 'chaussure-adidas-ultraboost',
    slug: 'chaussure-adidas-ultraboost',
    nom: 'Chaussure Adidas Ultraboost',
    marque: MARQUES[1],
    imageUrl: '/img/chuck70.svg',
    prixCents: 14900,
    variantes: [
      { id: 'ultraboost-41', taille: '41', sku: 'AUB41', stock: 2 },
      { id: 'ultraboost-42', taille: '42', sku: 'AUB42', stock: 0 }
    ]
  },
  {
    id: 'chaussure-converse-all-star',
    slug: 'chaussure-converse-all-star',
    nom: 'Chaussure Converse All Star',
    marque: MARQUES[2],
    imageUrl: '/img/polo.svg',
    prixCents: 7900,
    prixCompareCents: 9900,
    variantes: [
      { id: 'all-star-38', taille: '38', sku: 'CAS38', stock: 10 },
      { id: 'all-star-39', taille: '39', sku: 'CAS39', stock: 7 }
    ],
    badge: 'promo'
  },
  {
    id: 'pull-lacoste-coton',
    slug: 'pull-lacoste-coton',
    nom: 'Pull en coton Lacoste',
    marque: MARQUES[3],
    imageUrl: '/img/pegasus.svg',
    prixCents: 4900,
    variantes: [
      { id: 'coton-s', taille: 'S', sku: 'LCS', stock: 15 },
      { id: 'coton-m', taille: 'M', sku: 'LCM', stock: 8 }
    ]
  },
  {
    id: 'jean-levis-classic',
    slug: 'jean-levis-classic',
    nom: 'Jean Levi\'s Classic',
    marque: MARQUES[4],
    imageUrl: '/img/chuck70.svg',
    prixCents: 8900,
    prixCompareCents: 10900,
    variantes: [
      { id: 'classic-32', taille: '32', sku: 'LCL32', stock: 4 },
      { id: 'classic-34', taille: '34', sku: 'LCL34', stock: 6 }
    ],
    badge: 'promo'
  },
  {
    id: 'chaussure-newbalance-990',
    slug: 'chaussure-newbalance-990',
    nom: 'Chaussure New Balance 990',
    marque: MARQUES[5],
    imageUrl: '/img/polo.svg',
    prixCents: 13900,
    variantes: [
      { id: '990-40', taille: '40', sku: 'NB99040', stock: 0 },
      { id: '990-41', taille: '41', sku: 'NB99041', stock: 0 }
    ]
  },
  {
    id: 't-shirt-nike-club',
    slug: 't-shirt-nike-club',
    nom: 'T-Shirt Nike Club',
    marque: MARQUES[0],
    imageUrl: '/img/pegasus.svg',
    prixCents: 2900,
    variantes: [
      { id: 'club-s', taille: 'S', sku: 'NCLUBS', stock: 12 },
      { id: 'club-m', taille: 'M', sku: 'NCLUBM', stock: 9 }
    ]
  },
  {
    id: 'veste-adidas-warm',
    slug: 'veste-adidas-warm',
    nom: 'Veste Adidas Warm',
    marque: MARQUES[1],
    imageUrl: '/img/chuck70.svg',
    prixCents: 6900,
    prixCompareCents: 8900,
    variantes: [
      { id: 'warm-l', taille: 'L', sku: 'AWARML', stock: 3 },
      { id: 'warm-xl', taille: 'XL', sku: 'AWARMXL', stock: 5 }
    ],
    badge: 'promo'
  },
  {
    id: 'pantalon-converse-jean',
    slug: 'pantalon-converse-jean',
    nom: 'Pantalon Converse Jean',
    marque: MARQUES[2],
    imageUrl: '/img/polo.svg',
    prixCents: 5900,
    variantes: [
      { id: 'jean-36', taille: '36', sku: 'CJ36', stock: 8 },
      { id: 'jean-38', taille: '38', sku: 'CJ38', stock: 11 }
    ]
  },
  {
    id: 'chemise-lacoste-coton',
    slug: 'chemise-lacoste-coton',
    nom: 'Chemise en coton Lacoste',
    marque: MARQUES[3],
    imageUrl: '/img/pegasus.svg',
    prixCents: 3900,
    variantes: [
      { id: 'coton-l', taille: 'L', sku: 'LCL', stock: 6 },
      { id: 'coton-xl', taille: 'XL', sku: 'LCXL', stock: 4 }
    ]
  },
  {
    id: 'jean-levis-slim',
    slug: 'jean-levis-slim',
    nom: 'Jean Levi\'s Slim',
    marque: MARQUES[4],
    imageUrl: '/img/chuck70.svg',
    prixCents: 9900,
    prixCompareCents: 12900,
    variantes: [
      { id: 'slim-30', taille: '30', sku: 'LSS30', stock: 2 },
      { id: 'slim-32', taille: '32', sku: 'LSS32', stock: 0 }
    ],
    badge: 'promo'
  },
  {
    id: 'chaussure-newbalance-574',
    slug: 'chaussure-newbalance-574',
    nom: 'Chaussure New Balance 574',
    marque: MARQUES[5],
    imageUrl: '/img/polo.svg',
    prixCents: 10900,
    variantes: [
      { id: '574-39', taille: '39', sku: 'NB57439', stock: 1 },
      { id: '574-40', taille: '40', sku: 'NB57440', stock: 0 }
    ]
  }
];

// Fonctions d'accès
export function listerProduits(): Produit[] {
  return [...PRODUITS];
}

export function listerMarques(): Marque[] {
  return [...MARQUES];
}

export function trouverProduit(slug: string): Produit | undefined {
  return PRODUITS.find(produit => produit.slug === slug);
}

// Fonction pour obtenir toutes les tailles du catalogue triées
export function taillesCatalogue(): string[] {
  const tailles = new Set<string>();
  
  for (const produit of PRODUITS) {
    for (const variante of produit.variantes) {
      tailles.add(variante.taille);
    }
  }
  
  // Convertir en tableau et trier
  const tailleArray = Array.from(tailles);
  
  // Trier les tailles numériques en premier par ordre croissant
  const numeros = tailleArray
    .filter(t => /^\d+$/.test(t))
    .map(Number)
    .sort((a, b) => a - b)
    .map(String);
  
  // Trier les tailles alphabétiques dans l'ordre S, M, L, XL
  const alpha = tailleArray.filter(t => !/^\d+$/.test(t));
  const ordreAlpha = ['S', 'M', 'L', 'XL'];
  const trieesAlpha = ordreAlpha.filter(t => alpha.includes(t));
  
  return [...numeros, ...trieesAlpha];
}
