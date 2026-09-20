import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 9900,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});

describe('GrilleProduits', () => {
  it('rend une liste avec un élément par produit', () => {
    render(<GrilleProduits produits={[P('a'), P('b'), P('c')]} />);
    const grille = screen.getByTestId('grille');
    expect(grille.tagName).toBe('UL');
    expect(grille.querySelectorAll('li')).toHaveLength(3);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('affiche un message quand il n’y a rien', () => {
    render(<GrilleProduits produits={[]} />);
    expect(screen.queryByTestId('grille')).toBeNull();
    expect(screen.getByTestId('grille-vide').textContent).toBe(
      'Aucun produit ne correspond à ces filtres.',
    );
  });

  it('n’affiche pas le message quand il y a des produits', () => {
    render(<GrilleProduits produits={[P('a')]} />);
    expect(screen.queryByTestId('grille-vide')).toBeNull();
  });
});
