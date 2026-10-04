import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('mosaïque des catégories — téléphone', () => {
  it('met le titre en gras, avec une marge sous lui', () => {
    render(<MosaiqueCategories />);
    const titre = screen.getByRole('heading', { level: 2, name: 'Par catégorie' });
    for (const k of ['font-black', 'mb-6', 'max-sm:text-2xl']) expect(classes(titre), k).toContain(k);
  });

  it('rend les flèches visibles : icône claire sur rond noir', () => {
    render(<MosaiqueCategories />);
    const rond = screen.getByRole('link', { name: 'Homme' }).querySelector('.rounded-full');
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(rond), k).toContain(k);
    expect(classes(screen.getByText('Homme'))).toContain('font-black');
  });

  it('écrit en blanc sur la carte Soldes', () => {
    render(<MosaiqueCategories />);
    const carte = screen.getByRole('link', { name: /Jusqu/ }).closest('li');
    expect(classes(carte)).toContain('text-[var(--vs-blanc)]');
    const rond = screen.getByRole('link', { name: /Jusqu/ }).querySelector('.rounded-full');
    expect(classes(rond)).toContain('text-[var(--vs-noir)]');
  });
});
