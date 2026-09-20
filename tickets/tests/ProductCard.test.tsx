import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const NB = '\u00A0';

const PRODUIT: Produit = {
  id: 'p1',
  slug: 'air-zoom-pegasus-41',
  nom: 'Air Zoom Pegasus 41',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.jpg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [{ id: 'v1', taille: '41', sku: 'PEG-41', stock: 4 }],
};

describe('ProductCard — contenu', () => {
  it('rend un article identifiable', () => {
    render(<ProductCard produit={PRODUIT} />);
    const carte = screen.getByTestId('carte-produit');
    expect(carte.tagName).toBe('ARTICLE');
    expect(carte).toHaveAttribute('data-produit-id', 'p1');
  });

  it('affiche le nom de la marque et le nom du produit', () => {
    render(<ProductCard produit={PRODUIT} />);
    expect(screen.getByTestId('carte-marque')).toHaveTextContent('Nike');
    expect(screen.getByTestId('carte-nom')).toHaveTextContent('Air Zoom Pegasus 41');
  });

  it('pointe vers la fiche produit construite depuis le slug', () => {
    render(<ProductCard produit={PRODUIT} />);
    expect(screen.getByRole('link')).toHaveAttribute('href', '/produits/air-zoom-pegasus-41');
  });

  it('rend une image avec un texte alternatif décrivant le produit', () => {
    render(<ProductCard produit={PRODUIT} />);
    const img = screen.getByRole('img');
    expect(img).toHaveAttribute('src', PRODUIT.imageUrl);
    expect(img.getAttribute('alt')).toContain('Nike');
    expect(img.getAttribute('alt')).toContain('Air Zoom Pegasus 41');
  });
});

describe('ProductCard — prix', () => {
  it('affiche le prix courant et le prix barré', () => {
    render(<ProductCard produit={PRODUIT} />);
    expect(screen.getByTestId('prix-courant').textContent).toBe(`126,00${NB}$`);
    expect(screen.getByTestId('prix-compare').textContent).toBe(`180,00${NB}$`);
  });

  it('affiche la remise', () => {
    render(<ProductCard produit={PRODUIT} />);
    expect(screen.getByTestId('prix-remise')).toHaveTextContent('30');
  });

  it('omet le prix barré hors promotion', () => {
    const { prixCompareCents: _ignore, ...plein } = PRODUIT;
    render(<ProductCard produit={plein} />);
    expect(screen.queryByTestId('prix-compare')).toBeNull();
  });
});

describe('ProductCard — badge', () => {
  it("n'affiche aucun badge par défaut", () => {
    render(<ProductCard produit={PRODUIT} />);
    expect(screen.queryByTestId('badge')).toBeNull();
  });

  it('affiche le badge fourni', () => {
    render(<ProductCard produit={{ ...PRODUIT, badge: 'Nouveau' }} />);
    expect(screen.getByTestId('badge')).toHaveTextContent('Nouveau');
  });
});
