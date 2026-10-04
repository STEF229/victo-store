import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id, slug: id, nom: `Produit ${id}`, marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 9000,
  variantes: [{ id: `${id}-v`, taille: '42', sku: `${id}-42`, stock: 3 }],
});

describe('grille de produits — téléphone', () => {
  it('passe sur deux colonnes sur téléphone', () => {
    render(<GrilleProduits produits={[P('a'), P('b')]} />);
    const classes = (screen.getByTestId('grille').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['grid-cols-1', 'sm:grid-cols-2', 'max-sm:grid-cols-2', 'max-sm:gap-x-3']) expect(classes, k).toContain(k);
  });
});
