import { describe, expect, it } from 'vitest';
import type { Marque, Produit } from '../src/lib/catalogue';
import { libelleResultats, marquesCorrespondantes, motsDe, normaliser, rechercherProduits } from '../src/lib/recherche';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const NB: Marque = { id: 'm2', nom: 'New Balance', slug: 'new-balance' };
const LACOSTE: Marque = { id: 'm3', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, nom: string, marque: Marque, description?: string): Produit => ({
  id, slug: id, nom, marque, imageUrl: '/x.svg', prixCents: 1000, variantes: [], ...(description ? { description } : {}),
});
const CATALOGUE = [
  P('polo', 'Polo Classic', LACOSTE, 'Coton piqué, crocodile brodé.'),
  P('pegasus', 'Air Zoom Pegasus 41', NIKE, 'Chaussure de course, amorti réactif.'),
  P('nb530', '530 Retro', NB, 'Chaussure rétro inspirée de la course.'),
  P('club', 'Club Fleece', NIKE, 'Sweat molletonné.'),
  P('ete', 'Espadrille Été', LACOSTE),
];
const ids = (l: Produit[]) => l.map((p) => p.id);

describe('recherche — normalisation', () => {
  it('ignore accents, majuscules et ponctuation', () => {
    expect(normaliser('  Été — ÉCHANGÉ, s\u2019il vous plaît ! ')).toBe('ete echange s il vous plait');
    expect(motsDe("Levi's 501")).toEqual(['levi', 's', '501']);
    expect(motsDe('   ')).toEqual([]);
  });
});

describe('recherche — produits', () => {
  it('trouve par marque, nom ou description, sans accents', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'nike'))).toEqual(['pegasus', 'club']);
    expect(ids(rechercherProduits(CATALOGUE, 'ete'))).toEqual(['ete']);
    expect(ids(rechercherProduits(CATALOGUE, 'crocodile'))).toEqual(['polo']);
  });

  it('exige tous les mots', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'nike course'))).toEqual(['pegasus']);
    expect(ids(rechercherProduits(CATALOGUE, 'nike rouge'))).toEqual([]);
  });

  it('met d’abord ce qui correspond au nom, puis l’ordre du catalogue', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'course'))).toEqual(['pegasus', 'nb530']);
    expect(ids(rechercherProduits(CATALOGUE, 'retro'))).toEqual(['nb530']);
    expect(ids(rechercherProduits(CATALOGUE, 'pegasus'))).toEqual(['pegasus']);
  });

  it('ne renvoie rien pour une recherche vide', () => {
    expect(rechercherProduits(CATALOGUE, '  ')).toEqual([]);
  });
});

describe('recherche — marques et libellés', () => {
  it('trouve les marques par le début d’un de leurs mots', () => {
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], 'ni').map((m) => m.nom)).toEqual(['Nike']);
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], 'bal').map((m) => m.nom)).toEqual(['New Balance']);
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], '')).toEqual([]);
  });

  it('accorde le nombre de résultats, zéro au singulier', () => {
    expect([0, 1, 12].map(libelleResultats)).toEqual(['0 résultat', '1 résultat', '12 résultats']);
  });
});
