import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SousCategories } from '../src/components/catalogue/SousCategories';

const ELEMENTS = [
  { libelle: 'Tout', href: '/femme/vetements', nombre: 2 },
  { libelle: 'Sweats et hoodies', href: '/femme/vetements/sweats', nombre: 1 },
];
const SANS_BARRE = ['[scrollbar-width:none]', '[&::-webkit-scrollbar]:hidden'];
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('sous-catégories — une ligne qui défile sur téléphone', () => {
  it('met les pastilles sur une ligne, sans les couper', () => {
    render(<SousCategories titre="Sous-catégories de Vêtements" elements={ELEMENTS} forme="pastilles" actif="/femme/vetements" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Vêtements' });
    for (const k of ['flex-wrap', 'max-sm:flex-nowrap', 'max-sm:overflow-x-auto', ...SANS_BARRE]) expect(classes(nav), k).toContain(k);
    const longue = screen.getByRole('link', { name: 'Sweats et hoodies' });
    for (const k of ['max-sm:shrink-0', 'max-sm:whitespace-nowrap']) expect(classes(longue), k).toContain(k);
  });

  it('fait des vignettes un bandeau de carrés de 112 px', () => {
    render(<SousCategories titre="Sous-catégories de Femme" elements={ELEMENTS} forme="vignettes" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Femme' });
    for (const k of ['grid', 'max-sm:flex', 'max-sm:overflow-x-auto', ...SANS_BARRE]) expect(classes(nav), k).toContain(k);
    const lien = screen.getByRole('link', { name: /Sweats et hoodies/ });
    for (const k of ['max-sm:w-[112px]', 'max-sm:shrink-0']) expect(classes(lien), k).toContain(k);
    expect(classes(lien.querySelector('[aria-hidden="true"]'))).toContain('max-sm:h-[112px]');
  });
});
