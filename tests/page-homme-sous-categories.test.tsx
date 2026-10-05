import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/homme/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Homme — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', async () => {
    render(await Page());
    expect(screen.getByTestId('liste-titre').textContent).toBe('Homme');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const attendues = sousCategories(listerProduits(), 'homme', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
