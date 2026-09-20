import { describe, expect, it } from 'vitest';
import type { Marque, Produit } from '../src/lib/catalogue';
import { filtrerProduits, paginer, trierProduits } from '../src/lib/filtres';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };

function produit(
  id: string,
  marque: Marque,
  prixCents: number,
  opts: { compare?: number; tailles?: Array<[string, number]> } = {},
): Produit {
  const tailles = opts.tailles ?? [['40', 2], ['41', 1]];
  return {
    id,
    slug: `p-${id}`,
    nom: `Produit ${id}`,
    marque,
    imageUrl: '/img/pegasus.svg',
    prixCents,
    ...(opts.compare !== undefined ? { prixCompareCents: opts.compare } : {}),
    variantes: tailles.map(([taille, stock], i) => ({
      id: `${id}-v${i}`,
      taille,
      sku: `${id}-${taille}`,
      stock,
    })),
  };
}

// A : Nike 10000, promo 50 %      B : Lacoste 20000, pas de promo
// C : Nike 5000, promo 20 %, rupture totale, tailles M/L
const A = produit('a', NIKE, 10000, { compare: 20000 });
const B = produit('b', LACOSTE, 20000);
const C = produit('c', NIKE, 5000, { compare: 6250, tailles: [['M', 0], ['L', 0]] });
const TOUS = [A, B, C];

describe('filtrerProduits — absence de critère', () => {
  it('ne filtre rien sans critère', () => {
    expect(filtrerProduits(TOUS, {})).toHaveLength(3);
  });

  it('ne filtre rien avec des tableaux vides', () => {
    expect(filtrerProduits(TOUS, { marques: [], tailles: [] })).toHaveLength(3);
  });

  it('ne mute pas l’entrée et retourne un nouveau tableau', () => {
    const copie = [...TOUS];
    const r = filtrerProduits(TOUS, { marques: ['nike'] });
    expect(r).not.toBe(TOUS);
    expect(TOUS).toEqual(copie);
  });
});

describe('filtrerProduits — critères', () => {
  it('filtre par marque', () => {
    expect(filtrerProduits(TOUS, { marques: ['nike'] }).map((p) => p.id)).toEqual(['a', 'c']);
  });

  it('accepte plusieurs marques', () => {
    expect(filtrerProduits(TOUS, { marques: ['nike', 'lacoste'] })).toHaveLength(3);
  });

  it('filtre par taille, stock ou non', () => {
    expect(filtrerProduits(TOUS, { tailles: ['M'] }).map((p) => p.id)).toEqual(['c']);
    expect(filtrerProduits(TOUS, { tailles: ['40'] }).map((p) => p.id)).toEqual(['a', 'b']);
  });

  it('filtre les promotions', () => {
    expect(filtrerProduits(TOUS, { promotionSeulement: true }).map((p) => p.id)).toEqual(['a', 'c']);
  });

  it('filtre le stock disponible', () => {
    expect(filtrerProduits(TOUS, { enStockSeulement: true }).map((p) => p.id)).toEqual(['a', 'b']);
  });

  it('cumule les critères', () => {
    expect(
      filtrerProduits(TOUS, { marques: ['nike'], enStockSeulement: true }).map((p) => p.id),
    ).toEqual(['a']);
    expect(filtrerProduits(TOUS, { marques: ['lacoste'], promotionSeulement: true })).toHaveLength(0);
  });
});

describe('trierProduits', () => {
  it('conserve l’ordre pour "nouveautes"', () => {
    expect(trierProduits(TOUS, 'nouveautes').map((p) => p.id)).toEqual(['a', 'b', 'c']);
  });

  it('trie par prix croissant', () => {
    expect(trierProduits(TOUS, 'prix-croissant').map((p) => p.id)).toEqual(['c', 'a', 'b']);
  });

  it('trie par prix décroissant', () => {
    expect(trierProduits(TOUS, 'prix-decroissant').map((p) => p.id)).toEqual(['b', 'a', 'c']);
  });

  it('trie par remise décroissante, les non-promos en dernier', () => {
    expect(trierProduits(TOUS, 'remise').map((p) => p.id)).toEqual(['a', 'c', 'b']);
  });

  it('ne mute pas l’entrée', () => {
    const copie = [...TOUS];
    const r = trierProduits(TOUS, 'prix-croissant');
    expect(r).not.toBe(TOUS);
    expect(TOUS).toEqual(copie);
  });
});

describe('paginer', () => {
  const dix = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  it('découpe la première page', () => {
    expect(paginer(dix, 1, 4)).toEqual({ items: [1, 2, 3, 4], page: 1, pages: 3, total: 10 });
  });

  it('découpe la dernière page, incomplète', () => {
    expect(paginer(dix, 3, 4).items).toEqual([9, 10]);
  });

  it('ramène une page trop grande dans les bornes', () => {
    expect(paginer(dix, 99, 4).page).toBe(3);
    expect(paginer(dix, 99, 4).items).toEqual([9, 10]);
  });

  it('ramène une page nulle ou négative à 1', () => {
    expect(paginer(dix, 0, 4).page).toBe(1);
    expect(paginer(dix, -5, 4).items).toEqual([1, 2, 3, 4]);
  });

  it('gère une liste vide', () => {
    expect(paginer([], 1, 4)).toEqual({ items: [], page: 1, pages: 1, total: 0 });
  });

  it('refuse un parPage invalide', () => {
    expect(() => paginer(dix, 1, 0)).toThrow(RangeError);
    expect(() => paginer(dix, 1, -3)).toThrow(RangeError);
  });
});
