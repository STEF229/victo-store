import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/homme/[...chemin]/page';
import { titreDe } from '../src/lib/arbre-categories';

describe('route /homme/…', () => {
  it('affiche la sous-catégorie demandée', async () => {
    const chemin = ['chaussures'];
    render(await Page({ params: Promise.resolve({ chemin }) }));
    expect(screen.getByTestId('liste-titre').textContent).toBe(titreDe('homme', chemin));
  });
});
