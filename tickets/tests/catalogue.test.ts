import { describe, expect, it } from 'vitest';
import {
  estEnPromotion,
  estEnRupture,
  hrefMarque,
  hrefProduit,
  optionsDeTaille,
  remisePourcent,
  stockTotal,
  type Marque,
  type Produit,
} from '../src/lib/catalogue';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };

const BASE: Produit = {
  id: 'p1',
  slug: 'air-zoom-pegasus-41',
  nom: 'Air Zoom Pegasus 41',
  marque: NIKE,
  imageUrl: '/img/pegasus.jpg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [
    { id: 'v1', taille: '40', sku: 'PEG-40', stock: 3 },
    { id: 'v2', taille: '41', sku: 'PEG-41', stock: 0 },
    { id: 'v3', taille: '42', sku: 'PEG-42', stock: 7 },
  ],
};

describe('liens', () => {
  it('construit le lien produit depuis le slug', () => {
    expect(hrefProduit(BASE)).toBe('/produits/air-zoom-pegasus-41');
  });

  it('construit le lien marque depuis le slug', () => {
    expect(hrefMarque(NIKE)).toBe('/marques/nike');
  });
});

describe('promotion', () => {
  it('détecte une promotion', () => {
    expect(estEnPromotion(BASE)).toBe(true);
    expect(remisePourcent(BASE)).toBe(30);
  });

  it('ignore un prix comparé absent', () => {
    const { prixCompareCents: _o, ...sansCompare } = BASE;
    expect(estEnPromotion(sansCompare)).toBe(false);
    expect(remisePourcent(sansCompare)).toBeNull();
  });

  it('ignore un prix comparé égal ou inférieur', () => {
    expect(estEnPromotion({ ...BASE, prixCompareCents: 12600 })).toBe(false);
    expect(estEnPromotion({ ...BASE, prixCompareCents: 9900 })).toBe(false);
    expect(remisePourcent({ ...BASE, prixCompareCents: 12600 })).toBeNull();
  });

  it('arrondit le pourcentage', () => {
    expect(remisePourcent({ ...BASE, prixCents: 6667, prixCompareCents: 10000 })).toBe(33);
  });
});

describe('variantes', () => {
  it('convertit les variantes en options de taille, dans l’ordre', () => {
    expect(optionsDeTaille(BASE)).toEqual([
      { value: '40', available: true },
      { value: '41', available: false },
      { value: '42', available: true },
    ]);
  });

  it('rend un tableau vide sans variante', () => {
    expect(optionsDeTaille({ ...BASE, variantes: [] })).toEqual([]);
  });

  it('ne mute pas le produit', () => {
    const copie = structuredClone(BASE);
    optionsDeTaille(BASE);
    stockTotal(BASE);
    expect(BASE).toEqual(copie);
  });
});

describe('stock', () => {
  it('additionne le stock des variantes', () => {
    expect(stockTotal(BASE)).toBe(10);
  });

  it('vaut zéro sans variante', () => {
    expect(stockTotal({ ...BASE, variantes: [] })).toBe(0);
  });

  it('détecte la rupture', () => {
    expect(estEnRupture(BASE)).toBe(false);
    expect(estEnRupture({ ...BASE, variantes: [] })).toBe(true);
    expect(
      estEnRupture({ ...BASE, variantes: [{ id: 'v', taille: '40', sku: 'S', stock: 0 }] }),
    ).toBe(true);
  });
});
