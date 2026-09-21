import { describe, expect, it } from 'vitest';
import { estEnPromotion, stockTotal } from '../src/lib/catalogue';
import {
  listerMarques,
  listerProduits,
  MARQUES,
  PRODUITS,
  taillesCatalogue,
  trouverProduit,
} from '../src/lib/donnees';

const VISUELS = ['/img/pegasus.svg', '/img/chuck70.svg', '/img/polo.svg'];

describe('marques', () => {
  it('en contient exactement 6', () => {
    expect(MARQUES).toHaveLength(6);
  });

  it('a des identifiants et des slugs uniques', () => {
    expect(new Set(MARQUES.map((m) => m.id)).size).toBe(6);
    expect(new Set(MARQUES.map((m) => m.slug)).size).toBe(6);
  });

  it('a des slugs en minuscules sans espace ni accent', () => {
    for (const m of MARQUES) {
      expect(m.slug).toMatch(/^[a-z0-9-]+$/);
      expect(m.nom.length).toBeGreaterThan(1);
    }
  });
});

describe('produits', () => {
  it('en contient exactement 12', () => {
    expect(PRODUITS).toHaveLength(12);
  });

  it('a des identifiants et des slugs uniques', () => {
    expect(new Set(PRODUITS.map((p) => p.id)).size).toBe(12);
    expect(new Set(PRODUITS.map((p) => p.slug)).size).toBe(12);
  });

  it('référence une marque du catalogue', () => {
    const slugs = MARQUES.map((m) => m.slug);
    for (const p of PRODUITS) {
      expect(slugs).toContain(p.marque.slug);
    }
  });

  it('a au moins deux variantes par produit, avec des sku uniques', () => {
    const sku: string[] = [];
    for (const p of PRODUITS) {
      expect(p.variantes.length).toBeGreaterThanOrEqual(2);
      for (const v of p.variantes) sku.push(v.sku);
    }
    expect(new Set(sku).size).toBe(sku.length);
  });

  it('a des prix strictement positifs', () => {
    for (const p of PRODUITS) expect(p.prixCents).toBeGreaterThan(0);
  });

  it('compte au moins quatre promotions', () => {
    expect(PRODUITS.filter(estEnPromotion).length).toBeGreaterThanOrEqual(4);
  });

  it('compte au moins une rupture de stock complète', () => {
    expect(PRODUITS.filter((p) => stockTotal(p) === 0).length).toBeGreaterThanOrEqual(1);
  });

  it("n'utilise que les visuels existants", () => {
    for (const p of PRODUITS) expect(VISUELS).toContain(p.imageUrl);
  });
});

describe('accès', () => {
  it('liste une copie des produits', () => {
    const a = listerProduits();
    expect(a).toHaveLength(12);
    expect(a).not.toBe(PRODUITS);
    a.pop();
    expect(PRODUITS).toHaveLength(12);
  });

  it('liste une copie des marques', () => {
    const a = listerMarques();
    expect(a).not.toBe(MARQUES);
    a.pop();
    expect(MARQUES).toHaveLength(6);
  });

  it('trouve un produit par son slug', () => {
    const cible = PRODUITS[0];
    expect(cible).toBeDefined();
    expect(trouverProduit(cible!.slug)?.id).toBe(cible!.id);
  });

  it('retourne undefined pour un slug inconnu', () => {
    expect(trouverProduit('slug-qui-nexiste-pas')).toBeUndefined();
  });
});

describe('tailles du catalogue', () => {
  const tailles = taillesCatalogue();

  it('ne contient aucun doublon', () => {
    expect(new Set(tailles).size).toBe(tailles.length);
  });

  it('couvre toutes les tailles des produits', () => {
    for (const p of PRODUITS) {
      for (const v of p.variantes) expect(tailles).toContain(v.taille);
    }
  });

  it('place les tailles numériques avant les alphabétiques', () => {
    const num = tailles.filter((t) => /^\d+$/.test(t));
    const alpha = tailles.filter((t) => !/^\d+$/.test(t));
    expect(tailles).toEqual([...num, ...alpha]);
  });

  it('trie les tailles numériques par ordre croissant', () => {
    const num = tailles.filter((t) => /^\d+$/.test(t)).map(Number);
    expect(num).toEqual([...num].sort((a, b) => a - b));
  });

  it('trie les tailles alphabétiques dans l’ordre S, M, L, XL', () => {
    const ordre = ['S', 'M', 'L', 'XL'];
    const alpha = tailles.filter((t) => ordre.includes(t));
    expect(alpha).toEqual(ordre.filter((t) => alpha.includes(t)));
  });
});
