import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/femme/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Femme — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', () => {
    render(<Page />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Femme');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Femme' });
    const attendues = sousCategories(listerProduits(), 'femme', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
