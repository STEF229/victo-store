import { describe, expect, it } from 'vitest';
import {
  CLE_PANIER, ajouterAuPanier, changerQuantite, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '../src/lib/panier';

const A = { slug: 'pegasus', sku: 'peg-41' };
const B = { slug: 'polo', sku: 'polo-m' };

describe('panier — ajout', () => {
  it('ajoute une ligne à la fin', () => {
    const p = ajouterAuPanier([{ ...A, quantite: 1 }], B, 2, 5);
    expect(p).toEqual([{ ...A, quantite: 1 }, { ...B, quantite: 2 }]);
  });

  it('cumule sur le même sku, plafonné au stock', () => {
    let p: Panier = [];
    p = ajouterAuPanier(p, A, 2, 3);
    p = ajouterAuPanier(p, A, 2, 3);
    expect(p).toEqual([{ ...A, quantite: 3 }]);
  });

  it('plafonne une première ligne au stock et arrondit vers le bas', () => {
    expect(ajouterAuPanier([], A, 9, 4)).toEqual([{ ...A, quantite: 4 }]);
    expect(ajouterAuPanier([], A, 2.9, 5)).toEqual([{ ...A, quantite: 2 }]);
  });

  it('renvoie le même panier pour une quantité nulle ou un stock épuisé', () => {
    const p: Panier = [{ ...A, quantite: 1 }];
    expect(ajouterAuPanier(p, B, 0, 5)).toBe(p);
    expect(ajouterAuPanier(p, B, 0.5, 5)).toBe(p);
    expect(ajouterAuPanier(p, B, 1, 0)).toBe(p);
  });

  it('ne modifie jamais le panier reçu', () => {
    const ligne = { ...A, quantite: 1 };
    const p: Panier = [ligne];
    const suivant = ajouterAuPanier(p, A, 1, 5);
    expect(p).toEqual([{ ...A, quantite: 1 }]);
    expect(ligne.quantite).toBe(1);
    expect(suivant).not.toBe(p);
    expect(suivant[0]).not.toBe(ligne);
  });
});

describe('panier — quantités', () => {
  const p: Panier = [{ ...A, quantite: 2 }, { ...B, quantite: 1 }];

  it('change la quantité en gardant l’ordre, plafonnée au stock', () => {
    expect(changerQuantite(p, 'peg-41', 3, 10)).toEqual([{ ...A, quantite: 3 }, { ...B, quantite: 1 }]);
    expect(changerQuantite(p, 'peg-41', 30, 4)).toEqual([{ ...A, quantite: 4 }, { ...B, quantite: 1 }]);
  });

  it('retire la ligne à zéro', () => {
    expect(changerQuantite(p, 'peg-41', 0, 10)).toEqual([{ ...B, quantite: 1 }]);
  });

  it('renvoie le même panier pour un sku absent', () => {
    expect(changerQuantite(p, 'inconnu', 2, 10)).toBe(p);
  });

  it('retire une ligne', () => {
    expect(retirerDuPanier(p, 'polo-m')).toEqual([{ ...A, quantite: 2 }]);
    expect(p).toHaveLength(2);
  });

  it('compte les articles', () => {
    expect(nombreArticles(p)).toBe(3);
    expect(nombreArticles([])).toBe(0);
  });
});

describe('panier — lecture et écriture', () => {
  it('utilise la clé prévue', () => {
    expect(CLE_PANIER).toBe('victo-panier');
  });

  it('relit ce qu’il a écrit', () => {
    const p: Panier = [{ ...A, quantite: 2 }];
    expect(lirePanier(ecrirePanier(p))).toEqual(p);
    expect(ecrirePanier(p)).toBe(JSON.stringify(p));
  });

  it('rend un panier vide pour une entrée absente ou illisible', () => {
    expect(lirePanier(null)).toEqual([]);
    expect(lirePanier('{pas du json')).toEqual([]);
    expect(lirePanier('{"slug":"a"}')).toEqual([]);
  });

  it('écarte les lignes invalides et les champs inconnus', () => {
    const texte = JSON.stringify([
      { slug: 'a', sku: 'a-1', quantite: 2, prix: 99 },
      { slug: '', sku: 'b-1', quantite: 1 },
      { slug: 'c', sku: 'c-1', quantite: 0 },
      { slug: 'd', sku: 'd-1', quantite: 1.5 },
      null,
      'texte',
    ]);
    expect(lirePanier(texte)).toEqual([{ slug: 'a', sku: 'a-1', quantite: 2 }]);
  });
});
