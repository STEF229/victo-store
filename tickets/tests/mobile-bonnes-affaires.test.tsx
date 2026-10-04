import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id, slug: id, nom: `Produit ${id}`, marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 9000, prixCompareCents: 12000,
  variantes: [{ id: `${id}-v`, taille: '42', sku: `${id}-42`, stock: 3 }],
});
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('bonnes affaires — téléphone', () => {
  it('met le titre et le sur-titre en gras', () => {
    render(<SectionBonnesAffaires produits={[P('a'), P('b')]} />);
    const titre = screen.getByRole('heading', { level: 2, name: 'Les bonnes affaires du moment' });
    for (const k of ['font-black', 'max-sm:text-2xl']) expect(classes(titre), k).toContain(k);
    expect(classes(screen.getByText('Prix cassés'))).toContain('font-extrabold');
  });

  it('garde « Tout voir » sur une ligne et réduit les cartes', () => {
    render(<SectionBonnesAffaires produits={[P('a'), P('b')]} />);
    const tout = screen.getByRole('link', { name: 'Tout voir' });
    for (const k of ['whitespace-nowrap', 'shrink-0', 'max-sm:underline']) expect(classes(tout), k).toContain(k);
    expect(classes(screen.getByTestId('rail').querySelector('li'))).toContain('max-sm:w-[170px]');
  });
});
