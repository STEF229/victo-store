import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans la navigation partagée, ce ticket est BLOQUÉ.
import { NAV as _dependance } from '../src/lib/navigation';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const ADIDAS: Marque = { id: 'm3', nom: 'Adidas', slug: 'adidas' };

const P = (id: string, marque: Marque, prix: number): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque,
  imageUrl: '/img/pegasus.svg',
  prixCents: prix,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [
  P('a', NIKE, 5000), P('b', NIKE, 6000), P('c', LACOSTE, 7000), P('d', NIKE, 8000),
  P('e', LACOSTE, 9000), P('f', NIKE, 10000), P('g', LACOSTE, 11000), P('h', NIKE, 12000),
];

describe('VueCatalogue — structure', () => {
  it('rend l’en-tête, le titre, la description et le pied', () => {
    render(<VueCatalogue titre="Femme" description="Une description." produits={HUIT} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Femme');
    expect(screen.getByTestId('liste-description').textContent).toBe('Une description.');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('omet la description quand elle est absente', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.queryByTestId('liste-description')).toBeNull();
  });

  it('propose le menu partagé', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    expect(Array.from(nav.querySelectorAll('a')).map((a) => a.getAttribute('href'))).toEqual([
      '/femme', '/homme', '/chaussures', '/marques', '/soldes',
    ]);
  });

  it('dispose filtres et résultats sur deux colonnes en grand écran', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    const grille = screen.getByTestId('filtres').parentElement as Element;
    for (const k of ['grid', 'grid-cols-1', 'gap-10', 'lg:grid-cols-[260px_minmax(0,1fr)]']) {
      expect(classes(grille)).toContain(k);
    }
  });

  it('impose la taille du titre', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    for (const k of ['text-5xl', 'font-black', 'tracking-tight']) {
      expect(classes(screen.getByTestId('liste-titre'))).toContain(k);
    }
  });
});

describe('VueCatalogue — contenu', () => {
  it('compte tous les produits reçus', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getByTestId('compteur').textContent).toBe('8 produits');
  });

  it('affiche six produits par page', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(6);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(2);
  });

  it('ne propose que les marques présentes, sans doublon', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-marque-lacoste')).toBeInTheDocument();
    expect(screen.queryByTestId('filtre-marque-adidas')).toBeNull();
  });

  it('filtre par marque et revient à la première page', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('accorde le compteur au singulier', () => {
    render(<VueCatalogue titre="Adidas" produits={[P('z', ADIDAS, 9000)]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('1 produit');
  });

  it('gère une liste vide', () => {
    render(<VueCatalogue titre="Marque introuvable" produits={[]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
    expect(screen.getByTestId('grille-vide')).toBeInTheDocument();
  });
});
