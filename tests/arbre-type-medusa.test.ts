import { describe, expect, it } from 'vitest';
import { ARBRE, produitsDe, sousCategories } from '../src/lib/arbre-categories';
import type { Produit } from '../src/lib/catalogue';

const P = (slug: string, type: string | undefined, categorie: Produit['categorie'] = 'chaussures'): Produit => ({
  id: slug, slug, nom: slug, marque: { id: 'm', nom: 'M', slug: 'm' }, imageUrl: '/x.svg', prixCents: 1, variantes: [], genre: 'homme',
  ...(categorie ? { categorie } : {}), ...(type ? { type } : {}),
});

describe('arbre — le type vient de Medusa', () => {
  it('classe un produit par son type Medusa', () => {
    const liste = [P('medusa-course', 'course'), P('medusa-basket', 'basket'), P('survet', 'survetements', 'vetements')];
    expect(produitsDe(liste, 'chaussures', ['course']).map((p) => p.slug)).toEqual(['medusa-course']);
    expect(produitsDe(liste, 'homme', ['chaussures', 'basket']).map((p) => p.slug)).toEqual(['medusa-basket']);
    expect(produitsDe(liste, 'homme', ['vetements', 'survetements']).map((p) => p.slug)).toEqual(['survet']);
  });

  it('garde le classement de démonstration pour les produits sans type', () => {
    expect(produitsDe([P('air-zoom-pegasus-41', undefined)], 'chaussures', ['course']).map((p) => p.slug)).toEqual(['air-zoom-pegasus-41']);
  });

  it('ajoute Survêtements aux vêtements', () => {
    const vetements = ARBRE.homme.enfants.find((e) => e.slug === 'vetements');
    expect(vetements?.enfants.map((e) => e.slug)).toContain('survetements');
    expect(sousCategories([], 'femme', ['vetements']).map((e) => e.libelle)).toContain('Survêtements');
  });
});
