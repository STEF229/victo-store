import { describe, expect, it } from 'vitest';
import {
  correspondAuGenre,
  economieCents,
  imagesProduit,
  LIBELLES_CATEGORIE,
  type Produit,
} from '../src/lib/catalogue';

const BASE: Produit = {
  id: 'p1',
  slug: 'p-1',
  nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

describe('champs optionnels', () => {
  it('accepte un produit sans les nouveaux champs', () => {
    expect(BASE.genre).toBeUndefined();
    expect(imagesProduit(BASE)).toEqual(['/img/pegasus.svg']);
  });

  it('accepte un produit complet', () => {
    const complet: Produit = {
      ...BASE,
      genre: 'femme',
      categorie: 'chaussures',
      description: 'Une description.',
      composition: 'Mesh et caoutchouc.',
      images: ['/a.svg', '/b.svg'],
    };
    expect(imagesProduit(complet)).toEqual(['/a.svg', '/b.svg']);
  });
});

describe('imagesProduit', () => {
  it('retombe sur imageUrl quand la liste est vide', () => {
    expect(imagesProduit({ ...BASE, images: [] })).toEqual(['/img/pegasus.svg']);
  });

  it('retourne une copie', () => {
    const images = ['/a.svg'];
    const r = imagesProduit({ ...BASE, images });
    r.push('/x.svg');
    expect(images).toEqual(['/a.svg']);
  });
});

describe('correspondAuGenre', () => {
  it('reconnaît le genre exact', () => {
    expect(correspondAuGenre({ ...BASE, genre: 'femme' }, 'femme')).toBe(true);
    expect(correspondAuGenre({ ...BASE, genre: 'femme' }, 'homme')).toBe(false);
  });

  it('place les produits mixtes dans les deux', () => {
    expect(correspondAuGenre({ ...BASE, genre: 'mixte' }, 'femme')).toBe(true);
    expect(correspondAuGenre({ ...BASE, genre: 'mixte' }, 'homme')).toBe(true);
  });

  it('écarte un produit sans genre', () => {
    expect(correspondAuGenre(BASE, 'femme')).toBe(false);
    expect(correspondAuGenre(BASE, 'homme')).toBe(false);
  });
});

describe('economieCents', () => {
  it('calcule l’économie d’une promotion', () => {
    expect(economieCents(BASE)).toBe(5400);
  });

  it('vaut zéro hors promotion', () => {
    const { prixCompareCents: _r, ...plein } = BASE;
    expect(economieCents(plein)).toBe(0);
    expect(economieCents({ ...BASE, prixCompareCents: 12600 })).toBe(0);
  });
});

describe('libellés de catégorie', () => {
  it('couvre les trois catégories', () => {
    expect(LIBELLES_CATEGORIE).toEqual({
      chaussures: 'Chaussures',
      vetements: 'Vêtements',
      accessoires: 'Accessoires',
    });
  });
});
