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

function classes(el: Element): string[] {
  return el.className.split(/\s+/).filter(Boolean);
}

describe('GrilleProduits — mise en page', () => {
  it.each(['grid', 'grid-cols-1', 'gap-6', 'sm:grid-cols-2', 'lg:grid-cols-3'])(
    'porte la classe %s',
    (c) => {
      render(<GrilleProduits produits={[P('a'), P('b')]} />);
      expect(classes(screen.getByTestId('grille'))).toContain(c);
    },
  );

  it('conserve la classe fournie en prop', () => {
    render(<GrilleProduits produits={[P('a')]} className="perso" />);
    expect(classes(screen.getByTestId('grille'))).toContain('perso');
  });
});
