import { describe, expect, it } from 'vitest';
import type { Produit } from '../src/lib/catalogue';
import { detaillerPanier, libelleArticles, recapitulerPanier } from '../src/lib/panier-detail';

const PROMO: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, prixCompareCents: 18000,
  variantes: [{ id: 'v42', taille: '42', sku: 'peg-42', stock: 3 }],
};
const SIMPLE: Produit = {
  id: 'p2', slug: 'samba', nom: 'Samba', marque: { id: 'm2', nom: 'Adidas', slug: 'adidas' },
  imageUrl: '/img/y.svg', prixCents: 14000,
  variantes: [{ id: 'v41', taille: '41', sku: 'sam-41', stock: 5 }],
};
const trouver = (slug: string) => [PROMO, SIMPLE].find((p) => p.slug === slug);

describe('detaillerPanier', () => {
  it('joint produit et variante, et calcule total et économie', () => {
    const d = detaillerPanier([{ slug: 'pegasus', sku: 'peg-42', quantite: 2 }], trouver);
    expect(d).toHaveLength(1);
    expect(d[0]?.produit).toBe(PROMO);
    expect(d[0]?.variante.taille).toBe('42');
    expect(d[0]?.totalCents).toBe(25200);
    expect(d[0]?.economieCents).toBe(10800);
  });

  it('n’invente pas d’économie hors promotion', () => {
    expect(detaillerPanier([{ slug: 'samba', sku: 'sam-41', quantite: 1 }], trouver)[0]?.economieCents).toBe(0);
  });

  it('ignore un produit ou une pointure disparus, sans changer l’ordre', () => {
    const d = detaillerPanier([
      { slug: 'samba', sku: 'sam-41', quantite: 1 },
      { slug: 'inconnu', sku: 'x', quantite: 1 },
      { slug: 'pegasus', sku: 'peg-99', quantite: 1 },
      { slug: 'pegasus', sku: 'peg-42', quantite: 1 },
    ], trouver);
    expect(d.map((l) => l.sku)).toEqual(['sam-41', 'peg-42']);
  });
});

describe('recapitulerPanier', () => {
  it('additionne articles, sous-total et économies', () => {
    const d = detaillerPanier([
      { slug: 'pegasus', sku: 'peg-42', quantite: 2 },
      { slug: 'samba', sku: 'sam-41', quantite: 1 },
    ], trouver);
    expect(recapitulerPanier(d)).toEqual({ articles: 3, sousTotalCents: 39200, economiesCents: 10800, totalCents: 39200 });
  });

  it('rend quatre zéros pour un panier vide', () => {
    expect(recapitulerPanier([])).toEqual({ articles: 0, sousTotalCents: 0, economiesCents: 0, totalCents: 0 });
  });
});

describe('libelleArticles', () => {
  it('accorde en français, zéro au singulier', () => {
    expect([0, 1, 2].map(libelleArticles)).toEqual(['0 article', '1 article', '2 articles']);
  });
});
