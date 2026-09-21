import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import type { Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const P = (id: string): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 8000,
  prixCompareCents: 10000,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const QUATRE = [P('a'), P('b'), P('c'), P('d')];

describe('SectionBonnesAffaires — en-tête', () => {
  it('titre la section', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(screen.getByRole('heading', { level: 2 }).textContent).toBe('Les bonnes affaires du moment');
    expect(screen.getByText('Prix cassés')).toBeInTheDocument();
  });

  it('aligne le titre et le lien « Tout voir »', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    const lien = screen.getByRole('link', { name: 'Tout voir' });
    expect(lien).toHaveAttribute('href', '/soldes');
    const entete = lien.closest('.justify-between');
    expect(entete).not.toBeNull();
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-4']) expect(classes(entete as Element)).toContain(k);
    expect((entete as Element).contains(screen.getByRole('heading', { level: 2 }))).toBe(true);
  });
});

describe('SectionBonnesAffaires — rail', () => {
  it('rend une carte par produit', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(screen.getByTestId('rail').querySelectorAll(':scope > li')).toHaveLength(4);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(4);
  });

  it.each([
    'flex', 'gap-4', 'overflow-x-auto', 'snap-x', 'snap-mandatory',
    'md:grid', 'md:grid-cols-4', 'md:gap-5', 'md:overflow-visible',
  ])('le rail porte %s', (k) => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(classes(screen.getByTestId('rail'))).toContain(k);
  });

  it('dimensionne chaque élément du rail', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    for (const li of Array.from(screen.getByTestId('rail').querySelectorAll(':scope > li'))) {
      for (const k of ['w-[250px]', 'shrink-0', 'snap-start', 'md:w-auto']) expect(classes(li)).toContain(k);
    }
  });
});
