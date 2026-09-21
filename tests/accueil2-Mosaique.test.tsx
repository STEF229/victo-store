import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('MosaiqueCategories', () => {
  it('titre la section', () => {
    render(<MosaiqueCategories />);
    expect(screen.getByTestId('categories')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 2 }).textContent).toBe('Par catégorie');
  });

  it.each(['grid', 'grid-cols-2', 'gap-4', 'lg:h-[640px]', 'lg:grid-cols-3', 'lg:grid-rows-2'])(
    'la grille porte %s',
    (k) => {
      render(<MosaiqueCategories />);
      const ul = screen.getByTestId('categories').querySelector('ul');
      expect(classes(ul as Element)).toContain(k);
    },
  );

  it('rend quatre tuiles dans l’ordre', () => {
    render(<MosaiqueCategories />);
    const hrefs = screen.getAllByRole('link').map((a) => a.getAttribute('href'));
    expect(hrefs).toEqual(['/femme', '/homme', '/chaussures', '/soldes']);
  });

  it.each(['Femme', 'Homme', 'Chaussures'])('le lien %s ne porte que son titre', (titre) => {
    render(<MosaiqueCategories />);
    expect(screen.getByRole('link', { name: titre })).toBeInTheDocument();
  });

  it('étend la tuile Femme sur deux rangées en grand écran', () => {
    render(<MosaiqueCategories />);
    const li = screen.getByRole('link', { name: 'Femme' }).closest('li') as Element;
    for (const k of ['col-span-2', 'lg:col-span-1', 'lg:row-span-2', 'relative', 'overflow-hidden', 'rounded-[28px]']) {
      expect(classes(li)).toContain(k);
    }
  });

  it('étend la tuile Soldes sur deux colonnes, en rouge', () => {
    render(<MosaiqueCategories />);
    const lien = screen.getAllByRole('link').find((a) => a.getAttribute('href') === '/soldes');
    const li = lien?.closest('li') as Element;
    for (const k of ['col-span-2', 'rounded-[28px]', 'bg-[var(--vs-promo)]']) expect(classes(li)).toContain(k);
  });

  it('remplit trois tuiles d’une photo décorative', () => {
    const { container } = render(<MosaiqueCategories />);
    const imgs = Array.from(container.querySelectorAll('img'));
    expect(imgs.map((i) => i.getAttribute('src'))).toEqual([
      '/img/accueil/photo-8.svg',
      '/img/accueil/photo-9.svg',
      '/img/accueil/photo-10.svg',
    ]);
    for (const i of imgs) {
      expect(i.getAttribute('alt')).toBe('');
      for (const k of ['absolute', 'inset-0', 'h-full', 'w-full', 'object-cover']) expect(classes(i)).toContain(k);
    }
  });
});
