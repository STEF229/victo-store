import { describe, expect, it } from 'vitest';
import { hrefMarque, LIBELLES_CATEGORIE, type Marque, type Produit } from '../src/lib/catalogue';
import { filAriane, produitsSimilaires, TEXTE_LIVRAISON, texteStockBas } from '../src/lib/fiche-produit';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
function P(id: string, categorie: Produit['categorie'], stocks: Array<[string, number]> = [['41', 5]]): Produit {
  const p: Produit = {
    id, slug: `s-${id}`, nom: `Produit ${id}`, marque: NIKE, imageUrl: '/img/x.svg', prixCents: 1000,
    variantes: stocks.map(([taille, stock]) => ({ id: `${id}-${taille}`, taille, sku: `${id}-${taille}`, stock })),
  };
  return categorie ? { ...p, categorie } : p;
}

describe('filAriane', () => {
  it('relie accueil, catégorie chaussures, marque puis produit', () => {
    const p = P('a', 'chaussures');
    expect(filAriane(p)).toEqual([
      { label: 'Accueil', href: '/' },
      { label: LIBELLES_CATEGORIE.chaussures, href: '/chaussures' },
      { label: 'Nike', href: hrefMarque(NIKE) },
      { label: 'Produit a' },
    ]);
  });

  it('ne met pas de lien sur une catégorie sans page, ni sur le produit', () => {
    const fil = filAriane(P('b', 'vetements'));
    expect(fil.map((e) => e.label)).toEqual(['Accueil', LIBELLES_CATEGORIE.vetements, 'Nike', 'Produit b']);
    expect(fil.map((e) => 'href' in e)).toEqual([true, false, true, false]);
  });

  it('saute la catégorie quand le produit n’en a pas', () => {
    expect(filAriane(P('c', undefined)).map((e) => e.label)).toEqual(['Accueil', 'Nike', 'Produit c']);
  });
});

describe('texteStockBas', () => {
  const chaussure = P('d', 'chaussures', [['40', 1], ['41', 3], ['42', 4], ['43', 0]]);

  it('annonce le stock bas, accordé', () => {
    expect(texteStockBas(chaussure, '40')).toBe('Plus que 1 paire en 40');
    expect(texteStockBas(chaussure, '41')).toBe('Plus que 3 paires en 41');
  });

  it('se tait au-dessus de trois, en rupture, sans taille ou pour une taille inconnue', () => {
    expect(texteStockBas(chaussure, '42')).toBeNull();
    expect(texteStockBas(chaussure, '43')).toBeNull();
    expect(texteStockBas(chaussure, null)).toBeNull();
    expect(texteStockBas(chaussure, '99')).toBeNull();
  });

  it('parle de pièces hors des chaussures', () => {
    const polo = P('e', 'vetements', [['M', 2], ['L', 1]]);
    expect(texteStockBas(polo, 'M')).toBe('Plus que 2 pièces en M');
    expect(texteStockBas(polo, 'L')).toBe('Plus que 1 pièce en L');
  });
});

describe('produitsSimilaires', () => {
  const base = P('x', 'chaussures');
  const tous = [P('v1', 'vetements'), base, P('c1', 'chaussures'), P('v2', 'vetements'), P('c2', 'chaussures')];

  it('exclut le produit, met la même catégorie en premier et garde l’ordre', () => {
    expect(produitsSimilaires(base, tous).map((p) => p.id)).toEqual(['c1', 'c2', 'v1', 'v2']);
  });

  it('respecte le nombre demandé et ne modifie pas la liste', () => {
    const avant = tous.map((p) => p.id);
    expect(produitsSimilaires(base, tous, 3).map((p) => p.id)).toEqual(['c1', 'c2', 'v1']);
    expect(tous.map((p) => p.id)).toEqual(avant);
  });
});

describe('TEXTE_LIVRAISON', () => {
  it('reprend le texte de la maquette', () => {
    expect(TEXTE_LIVRAISON).toContain('Expédiée du Québec sous 48 heures');
    expect(TEXTE_LIVRAISON).toContain('Retours gratuits pendant 30 jours');
  });
});
