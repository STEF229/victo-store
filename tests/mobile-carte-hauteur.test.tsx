import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'p1', nom: 'Chuck Taylor All Star', marque: { id: 'm1', nom: 'Converse', slug: 'converse' }, imageUrl: '/x.svg', prixCents: 8900,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
};

describe('carte produit — hauteur', () => {
  it('s’étire à la hauteur de sa case', () => {
    render(<ProductCard produit={P} />);
    const classes = (screen.getByTestId('carte-produit').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['h-full', 'rounded-lg', 'bg-[var(--vs-surface)]']) expect(classes, k).toContain(k);
  });
});
