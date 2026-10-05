import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/chaussures/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Chaussures — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', async () => {
    render(await Page());
    expect(screen.getByTestId('liste-titre').textContent).toBe('Chaussures');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Chaussures' });
    const attendues = sousCategories(listerProduits(), 'chaussures', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
