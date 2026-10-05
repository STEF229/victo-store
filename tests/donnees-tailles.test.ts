import { describe, expect, it } from 'vitest';
import type { Produit } from '../src/lib/catalogue';
import * as donnees from '../src/lib/donnees';

// Import par espace de noms : avant le ticket, taillesDe n'existe pas, et le test échoue sans planter.
const avec = (...tailles: string[]): Produit => ({
  id: 'p', slug: 'p', nom: 'P', marque: { id: 'm', nom: 'M', slug: 'm' }, imageUrl: '/x.svg', prixCents: 1,
  variantes: tailles.map((t) => ({ id: t, taille: t, sku: t, stock: 1 })),
});

describe('tailles d’une liste de produits', () => {
  it('range les pointures, puis S, M, L, XL, sans doublon', () => {
    expect(typeof donnees.taillesDe).toBe('function');
    expect(donnees.taillesDe([avec('42', 'M', '40'), avec('L', '40', 'S')])).toEqual(['40', '42', 'S', 'M', 'L']);
    expect(donnees.taillesDe([])).toEqual([]);
  });

  it('donne le même résultat qu’avant pour la démonstration', () => {
    expect(typeof donnees.taillesDe).toBe('function');
    expect(donnees.taillesCatalogue()).toEqual(donnees.taillesDe(donnees.listerProduits()));
  });
});
