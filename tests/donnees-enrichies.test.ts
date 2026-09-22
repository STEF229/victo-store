import { describe, expect, it } from 'vitest';
import { correspondAuGenre } from '../src/lib/catalogue';
import { MARQUES, PRODUITS, produitsDeMarque, trouverMarque } from '../src/lib/donnees';

const GENRES = ['femme', 'homme', 'mixte'];
const CATEGORIES = ['chaussures', 'vetements', 'accessoires'];

describe('catalogue complet — champs de fiche', () => {
  it.each(PRODUITS.map((p) => [p.slug, p] as const))('%s est complet', (_slug, p) => {
    expect(GENRES).toContain(p.genre);
    expect(CATEGORIES).toContain(p.categorie);
    expect((p.description ?? '').length).toBeGreaterThanOrEqual(60);
    expect((p.composition ?? '').length).toBeGreaterThanOrEqual(20);
    expect(p.images).toEqual([
      p.imageUrl,
      '/img/produits/vue-2.svg',
      '/img/produits/vue-3.svg',
      '/img/produits/vue-4.svg',
    ]);
  });
});

describe('catalogue complet — répartition', () => {
  it('propose assez de produits femme', () => {
    expect(PRODUITS.filter((p) => correspondAuGenre(p, 'femme')).length).toBeGreaterThanOrEqual(4);
  });

  it('propose assez de produits homme', () => {
    expect(PRODUITS.filter((p) => correspondAuGenre(p, 'homme')).length).toBeGreaterThanOrEqual(4);
  });

  it('propose assez de chaussures', () => {
    expect(PRODUITS.filter((p) => p.categorie === 'chaussures').length).toBeGreaterThanOrEqual(5);
  });

  it('propose assez de vêtements', () => {
    expect(PRODUITS.filter((p) => p.categorie === 'vetements').length).toBeGreaterThanOrEqual(3);
  });
});

describe('accès aux marques', () => {
  it('trouve chaque marque par son slug', () => {
    for (const m of MARQUES) expect(trouverMarque(m.slug)?.id).toBe(m.id);
  });

  it('retourne undefined pour une marque inconnue', () => {
    expect(trouverMarque('marque-inexistante')).toBeUndefined();
  });

  it('liste les produits d’une marque, dans l’ordre du catalogue', () => {
    for (const m of MARQUES) {
      const attendus = PRODUITS.filter((p) => p.marque.slug === m.slug).map((p) => p.id);
      expect(produitsDeMarque(m.slug).map((p) => p.id)).toEqual(attendus);
    }
  });

  it('retourne un nouveau tableau, vide pour une marque inconnue', () => {
    expect(produitsDeMarque('marque-inexistante')).toEqual([]);
    const slug = MARQUES.map((m) => m.slug).slice(0, 1).join('');
    expect(produitsDeMarque(slug)).not.toBe(produitsDeMarque(slug));
  });
});
