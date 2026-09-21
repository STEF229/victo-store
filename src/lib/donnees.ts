import type { Marque, Produit } from '@/lib/catalogue';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const ADIDAS: Marque = { id: 'm2', nom: 'Adidas', slug: 'adidas' };
const CONVERSE: Marque = { id: 'm3', nom: 'Converse', slug: 'converse' };
const LACOSTE: Marque = { id: 'm4', nom: 'Lacoste', slug: 'lacoste' };
const LEVIS: Marque = { id: 'm5', nom: "Levi's", slug: 'levis' };
const NEW_BALANCE: Marque = { id: 'm6', nom: 'New Balance', slug: 'new-balance' };

export const MARQUES: Marque[] = [NIKE, ADIDAS, CONVERSE, LACOSTE, LEVIS, NEW_BALANCE];

const PRODUIT_1: Produit = {
  id: 'p1',
  slug: 'air-zoom-pegasus-41',
  nom: 'Air Zoom Pegasus 41',
  marque: NIKE,
  imageUrl: '/img/pegasus.svg',
  prixCents: 12900,
  prixCompareCents: 15900,
  variantes: [
    { id: 'v1', taille: '40', sku: 'nike-pegasus-41-40', stock: 5 },
    { id: 'v2', taille: '41', sku: 'nike-pegasus-41-41', stock: 3 },
  ],
};

const PRODUIT_2: Produit = {
  id: 'p2',
  slug: 'ultra-boost-22',
  nom: 'Ultra Boost 22',
  marque: ADIDAS,
  imageUrl: '/img/chuck70.svg',
  prixCents: 18900,
  prixCompareCents: 21900,
  variantes: [
    { id: 'v3', taille: '42', sku: 'adidas-boost-22-42', stock: 2 },
    { id: 'v4', taille: '43', sku: 'adidas-boost-22-43', stock: 0 },
  ],
};

const PRODUIT_3: Produit = {
  id: 'p3',
  slug: 'chuck-taylor-all-star',
  nom: 'Chuck Taylor All Star',
  marque: CONVERSE,
  imageUrl: '/img/chuck70.svg',
  prixCents: 8900,
  variantes: [
    { id: 'v5', taille: '38', sku: 'converse-chuck-38', stock: 10 },
    { id: 'v6', taille: '39', sku: 'converse-chuck-39', stock: 7 },
  ],
};

const PRODUIT_4: Produit = {
  id: 'p4',
  slug: 'polo-shirt',
  nom: 'Polo Shirt',
  marque: LACOSTE,
  imageUrl: '/img/polo.svg',
  prixCents: 5900,
  prixCompareCents: 7900,
  variantes: [
    { id: 'v7', taille: 'M', sku: 'lacoste-polo-m', stock: 4 },
    { id: 'v8', taille: 'L', sku: 'lacoste-polo-l', stock: 6 },
  ],
};

const PRODUIT_5: Produit = {
  id: 'p5',
  slug: '501-original',
  nom: '501 Original',
  marque: LEVIS,
  imageUrl: '/img/pegasus.svg',
  prixCents: 11900,
  variantes: [
    { id: 'v9', taille: '32', sku: 'levis-501-32', stock: 8 },
    { id: 'v10', taille: '34', sku: 'levis-501-34', stock: 12 },
  ],
};

const PRODUIT_6: Produit = {
  id: 'p6',
  slug: 'fresh-foam-x',
  nom: 'Fresh Foam X',
  marque: NEW_BALANCE,
  imageUrl: '/img/chuck70.svg',
  prixCents: 13900,
  prixCompareCents: 16900,
  variantes: [
    { id: 'v11', taille: '40', sku: 'nb-fresh-foam-40', stock: 3 },
    { id: 'v12', taille: '41', sku: 'nb-fresh-foam-41', stock: 5 },
  ],
};

const PRODUIT_7: Produit = {
  id: 'p7',
  slug: 'air-force-1',
  nom: 'Air Force 1',
  marque: NIKE,
  imageUrl: '/img/pegasus.svg',
  prixCents: 10900,
  variantes: [
    { id: 'v13', taille: '42', sku: 'nike-air-force-42', stock: 0 },
    { id: 'v14', taille: '43', sku: 'nike-air-force-43', stock: 0 },
  ],
};

const PRODUIT_8: Produit = {
  id: 'p8',
  slug: 'gazelle',
  nom: 'Gazelle',
  marque: ADIDAS,
  imageUrl: '/img/polo.svg',
  prixCents: 9900,
  prixCompareCents: 12900,
  variantes: [
    { id: 'v15', taille: '40', sku: 'adidas-gazelle-40', stock: 1 },
    { id: 'v16', taille: '41', sku: 'adidas-gazelle-41', stock: 2 },
  ],
};

const PRODUIT_9: Produit = {
  id: 'p9',
  slug: 'high-top',
  nom: 'High Top',
  marque: CONVERSE,
  imageUrl: '/img/chuck70.svg',
  prixCents: 7900,
  variantes: [
    { id: 'v17', taille: '38', sku: 'converse-high-38', stock: 6 },
    { id: 'v18', taille: '39', sku: 'converse-high-39', stock: 4 },
  ],
};

const PRODUIT_10: Produit = {
  id: 'p10',
  slug: 'casual-shirt',
  nom: 'Casual Shirt',
  marque: LACOSTE,
  imageUrl: '/img/polo.svg',
  prixCents: 6900,
  variantes: [
    { id: 'v19', taille: 'S', sku: 'lacoste-shirt-s', stock: 5 },
    { id: 'v20', taille: 'M', sku: 'lacoste-shirt-m', stock: 3 },
  ],
};

const PRODUIT_11: Produit = {
  id: 'p11',
  slug: 'jeans-classic',
  nom: 'Jeans Classic',
  marque: LEVIS,
  imageUrl: '/img/pegasus.svg',
  prixCents: 9900,
  prixCompareCents: 11900,
  variantes: [
    { id: 'v21', taille: '30', sku: 'levis-jeans-30', stock: 7 },
    { id: 'v22', taille: '32', sku: 'levis-jeans-32', stock: 9 },
  ],
};

const PRODUIT_12: Produit = {
  id: 'p12',
  slug: '990-v3',
  nom: '990 V3',
  marque: NEW_BALANCE,
  imageUrl: '/img/chuck70.svg',
  prixCents: 15900,
  variantes: [
    { id: 'v23', taille: '42', sku: 'nb-990-v3-42', stock: 0 },
    { id: 'v24', taille: '43', sku: 'nb-990-v3-43', stock: 0 },
  ],
};

export const PRODUITS: Produit[] = [
  PRODUIT_1,
  PRODUIT_2,
  PRODUIT_3,
  PRODUIT_4,
  PRODUIT_5,
  PRODUIT_6,
  PRODUIT_7,
  PRODUIT_8,
  PRODUIT_9,
  PRODUIT_10,
  PRODUIT_11,
  PRODUIT_12,
];

export function listerProduits(): Produit[] {
  return [...PRODUITS];
}

export function listerMarques(): Marque[] {
  return [...MARQUES];
}

export function trouverProduit(slug: string): Produit | undefined {
  return PRODUITS.find((produit) => produit.slug === slug);
}

const ORDRE_ALPHA = ['S', 'M', 'L', 'XL'];

export function taillesCatalogue(): string[] {
  const vues = new Set<string>();
  for (const p of PRODUITS) for (const v of p.variantes) vues.add(v.taille);
  const toutes = [...vues];
  const num = toutes.filter((t) => /^\d+$/.test(t)).sort((a, b) => Number(a) - Number(b));
  const alpha = ORDRE_ALPHA.filter((t) => vues.has(t));
  return [...num, ...alpha];
}
