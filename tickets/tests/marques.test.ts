import { describe, expect, it } from 'vitest';
import type { Marque, Produit } from '../src/lib/catalogue';
import { libelleMarques, libelleProduits, resumerMarques } from '../src/lib/marques';

const M = (slug: string, nom: string): Marque => ({ id: slug, nom, slug });
const NIKE = M('nike', 'Nike');
const ADIDAS = M('adidas', 'Adidas');
const PUMA = M('puma', 'Puma');
const P = (id: string, marque: Marque, promo: boolean): Produit => {
  const base: Produit = {
    id, slug: id, nom: id, marque, imageUrl: '/img/x.svg', prixCents: 1000,
    variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 1 }],
  };
  return promo ? { ...base, prixCompareCents: 2000 } : base;
};
const PRODUITS = [P('a', NIKE, true), P('b', NIKE, false), P('c', ADIDAS, true), P('d', NIKE, true)];

describe('resumerMarques', () => {
  it('compte les produits et les soldes, par nom de marque', () => {
    expect(resumerMarques([NIKE, PUMA, ADIDAS], PRODUITS)).toEqual([
      { marque: ADIDAS, nombre: 1, enSoldes: 1 },
      { marque: NIKE, nombre: 3, enSoldes: 2 },
    ]);
  });

  it('écarte une marque sans produit et ne modifie pas la liste reçue', () => {
    const marques = [NIKE, PUMA, ADIDAS];
    resumerMarques(marques, PRODUITS);
    expect(marques.map((m) => m.slug)).toEqual(['nike', 'puma', 'adidas']);
    expect(resumerMarques([PUMA], PRODUITS)).toEqual([]);
  });
});

describe('libellés', () => {
  it('accordent en français, zéro au singulier', () => {
    expect([0, 1, 6].map(libelleMarques)).toEqual(['0 marque', '1 marque', '6 marques']);
    expect([0, 1, 14].map(libelleProduits)).toEqual(['0 produit', '1 produit', '14 produits']);
  });
});
