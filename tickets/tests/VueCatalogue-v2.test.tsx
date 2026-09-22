import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans la barre de filtres, ce ticket est BLOQUÉ.
import { FiltresBarre as _dependance } from '../src/components/catalogue/FiltresBarre';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, marque: Marque, prix: number): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`, marque,
  imageUrl: '/img/pegasus.svg', prixCents: prix,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [
  P('a', NIKE, 5000), P('b', NIKE, 6000), P('c', LACOSTE, 7000), P('d', NIKE, 8000),
  P('e', LACOSTE, 9000), P('f', NIKE, 10000), P('g', LACOSTE, 11000), P('h', NIKE, 12000),
];

describe('VueCatalogue — nouvelle disposition', () => {
  it('rend en-tête, titre, description et pied', () => {
    render(<VueCatalogue titre="Soldes" description="Une description." produits={HUIT} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('liste-titre').textContent).toBe('Soldes');
    expect(screen.getByTestId('liste-description').textContent).toBe('Une description.');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('remplace la colonne de filtres par la barre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('filtres')).toBeNull();
  });

  it('affiche la grille sur quatre colonnes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(classes(screen.getByTestId('grille'))).toContain('lg:grid-cols-4');
  });

  it('impose la taille du titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    for (const k of ['text-5xl', 'font-black', 'tracking-tight', 'lg:text-6xl']) {
      expect(classes(screen.getByTestId('liste-titre'))).toContain(k);
    }
  });

  it('aligne le compteur avec le titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    const rangee = screen.getByTestId('compteur').closest('.justify-between') as Element;
    expect(rangee).not.toBeNull();
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-8']) expect(classes(rangee)).toContain(k);
    expect(rangee.contains(screen.getByTestId('liste-titre'))).toBe(true);
  });
});

describe('VueCatalogue — contenu', () => {
  it('compte les produits et en montre six par page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('compteur').textContent).toBe('8 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(6);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(2);
  });

  it('filtre par marque depuis la barre et revient à la première page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('ne propose que les marques présentes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.queryByTestId('filtre-marque-adidas')).toBeNull();
  });

  it('trie par prix croissant', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'prix-croissant' } });
    expect(screen.getAllByTestId('carte-nom').map((e) => e.textContent)).toEqual(
      [...HUIT].sort((a, b) => a.prixCents - b.prixCents).slice(0, 6).map((p) => p.nom),
    );
  });

  it('accorde le compteur et gère la liste vide', () => {
    const { unmount } = render(<VueCatalogue titre="Nike" produits={[P('z', NIKE, 9000)]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('1 produit');
    unmount();
    render(<VueCatalogue titre="Marque introuvable" produits={[]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
    expect(screen.getByTestId('grille-vide')).toBeInTheDocument();
  });
});
