import { describe, expect, it } from 'vitest';
import { correspondAuGenre, type Marque, type Produit } from '../src/lib/catalogue';
import { ARBRE, estRubrique, hrefDe, produitsDe, sousCategories, titreDe, trouverNoeud } from '../src/lib/arbre-categories';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const P = (slug: string, genre: Produit['genre'], categorie: Produit['categorie']): Produit => ({
  id: slug, slug, nom: slug, marque: NIKE, imageUrl: '/x.svg', prixCents: 1000, variantes: [],
  ...(genre ? { genre } : {}), ...(categorie ? { categorie } : {}),
});
const CATALOGUE = [
  P('air-zoom-pegasus-41', 'homme', 'chaussures'), P('chuck-taylor-all-star', 'mixte', 'chaussures'),
  P('polo-shirt', 'homme', 'vetements'), P('robe-ete', 'femme', 'vetements'), P('casquette', 'homme', 'accessoires'),
];
const slugs = (l: Produit[]) => l.map((p) => p.slug);
// Ce qui compte pour Homme dépend de correspondAuGenre (les produits « mixte ») : on le lui demande.
const homme = CATALOGUE.filter((p) => correspondAuGenre(p, 'homme'));
const hommeChaussures = homme.filter((p) => p.categorie === 'chaussures');

describe('arbre des catégories', () => {
  it('reconnaît les rubriques et construit les adresses', () => {
    expect(['femme', 'homme', 'chaussures', 'marques'].map(estRubrique)).toEqual([true, true, true, false]);
    expect(hrefDe('homme', [])).toBe('/homme');
    expect(hrefDe('homme', ['chaussures', 'course'])).toBe('/homme/chaussures/course');
    expect(ARBRE.homme.enfants.map((e) => e.slug)).toEqual(['chaussures', 'vetements', 'accessoires']);
    expect(ARBRE.chaussures.enfants.map((e) => e.slug)).toEqual(['sneakers', 'course', 'basket', 'sandales', 'bottes']);
  });

  it('retrouve un nœud et sa lignée, et refuse un chemin inconnu', () => {
    expect(trouverNoeud('homme', ['chaussures', 'course'])?.lignee.map((n) => n.libelle)).toEqual(['Homme', 'Chaussures', 'Course']);
    expect(trouverNoeud('homme', [])?.noeud.libelle).toBe('Homme');
    expect(trouverNoeud('homme', ['chaussures', 'inconnu'])).toBeUndefined();
    expect(trouverNoeud('chaussures', ['vetements'])).toBeUndefined();
  });

  it('choisit les produits par genre, catégorie puis type de démonstration', () => {
    expect(slugs(produitsDe(CATALOGUE, 'homme', []))).toEqual(slugs(homme));
    expect(slugs(produitsDe(CATALOGUE, 'homme', ['chaussures']))).toEqual(slugs(hommeChaussures));
    expect(slugs(produitsDe(CATALOGUE, 'homme', ['chaussures', 'course']))).toEqual(['air-zoom-pegasus-41']);
    expect(slugs(produitsDe(CATALOGUE, 'femme', ['vetements']))).toEqual(['robe-ete']);
    expect(slugs(produitsDe(CATALOGUE, 'chaussures', []))).toEqual(['air-zoom-pegasus-41', 'chuck-taylor-all-star']);
    expect(slugs(produitsDe(CATALOGUE, 'chaussures', ['sneakers']))).toEqual(['chuck-taylor-all-star']);
  });

  it('liste les sous-catégories avec leur adresse et leur nombre de produits', () => {
    expect(sousCategories(CATALOGUE, 'homme', [])).toEqual([
      { libelle: 'Chaussures', href: '/homme/chaussures', nombre: hommeChaussures.length },
      { libelle: 'Vêtements', href: '/homme/vetements', nombre: homme.filter((p) => p.categorie === 'vetements').length },
      { libelle: 'Accessoires', href: '/homme/accessoires', nombre: homme.filter((p) => p.categorie === 'accessoires').length },
    ]);
    expect(sousCategories(CATALOGUE, 'homme', ['chaussures', 'course'])).toEqual([]);
    expect(sousCategories(CATALOGUE, 'homme', ['inconnu'])).toEqual([]);
  });

  it('titre les pages', () => {
    expect(titreDe('homme', [])).toBe('Homme');
    expect(titreDe('homme', ['chaussures'])).toBe('Chaussures Homme');
    expect(titreDe('femme', ['vetements', 'jeans'])).toBe('Jeans Femme');
    expect(titreDe('chaussures', ['course'])).toBe('Course');
    expect(titreDe('homme', ['inconnu'])).toBe('');
  });
});
