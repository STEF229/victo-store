import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const P = (id: string): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg', prixCents: 9900,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});

describe('GrilleProduits — nombre de colonnes', () => {
  it('reste à trois colonnes par défaut', () => {
    render(<GrilleProduits produits={[P('a')]} />);
    const g = classes(screen.getByTestId('grille'));
    expect(g).toContain('lg:grid-cols-3');
    expect(g).not.toContain('lg:grid-cols-4');
  });

  it('passe à quatre colonnes sur demande', () => {
    render(<GrilleProduits produits={[P('a')]} colonnes={4} />);
    const g = classes(screen.getByTestId('grille'));
    expect(g).toContain('lg:grid-cols-4');
    expect(g).not.toContain('lg:grid-cols-3');
  });

  it('garde les classes de base dans les deux cas', () => {
    for (const c of [3, 4] as const) {
      const { unmount } = render(<GrilleProduits produits={[P('a')]} colonnes={c} />);
      for (const k of ['grid', 'grid-cols-1', 'gap-6', 'sm:grid-cols-2']) {
        expect(classes(screen.getByTestId('grille'))).toContain(k);
      }
      unmount();
    }
  });
});
