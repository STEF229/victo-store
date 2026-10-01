import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PILULE_OFF, PILULE_ON } from '../src/components/catalogue/filtres-affichage';
import { SousCategories } from '../src/components/catalogue/SousCategories';

const ELEMENTS = [
  { libelle: 'Tout', href: '/homme/chaussures', nombre: 3 },
  { libelle: 'Course', href: '/homme/chaussures/course', nombre: 1 },
  { libelle: 'Basket', href: '/homme/chaussures/basket', nombre: 0 },
];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('SousCategories', () => {
  it('affiche des vignettes avec leur nombre de produits, accordé', () => {
    render(<SousCategories titre="Sous-catégories de Homme" elements={ELEMENTS} forme="vignettes" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const liens = within(nav).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual(ELEMENTS.map((e) => e.href));
    expect(within(nav).getByText('3 produits')).toBeInTheDocument();
    expect(within(nav).getByText('1 produit')).toBeInTheDocument();
    expect(within(nav).getByText('0 produit')).toBeInTheDocument();
  });

  it('affiche des pastilles et marque celle de la page', () => {
    render(<SousCategories titre="Sous-catégories de Chaussures" elements={ELEMENTS} forme="pastilles" actif="/homme/chaussures/course" />);
    const course = screen.getByRole('link', { name: 'Course' });
    expect(course).toHaveAttribute('aria-current', 'page');
    for (const k of PILULE_ON.split(' ')) expect(classes(course)).toContain(k);
    const tout = screen.getByRole('link', { name: 'Tout' });
    expect(tout).not.toHaveAttribute('aria-current');
    for (const k of PILULE_OFF.split(' ')) expect(classes(tout)).toContain(k);
  });

  it('ne rend rien sans sous-catégorie', () => {
    const { container } = render(<SousCategories titre="x" elements={[]} forme="pastilles" />);
    expect(container.innerHTML).toBe('');
  });
});
