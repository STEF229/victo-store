import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const NB = '\u00A0';
const MOINS = '\u2212';
const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

const PROMO: Produit = {
  id: 'p1',
  slug: 'air-zoom-pegasus-41',
  nom: 'Air Zoom Pegasus 41',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [{ id: 'v1', taille: '41', sku: 'PEG-41', stock: 4 }],
};
const { prixCompareCents: _retire, ...PLEIN_TARIF } = PROMO;

describe('ProductCard — visuel', () => {
  it.each(['relative', 'overflow-hidden', 'rounded-[20px]', 'bg-[var(--vs-surface)]'])(
    'le visuel porte %s',
    (c) => {
      render(<ProductCard produit={PROMO} />);
      expect(classes(screen.getByTestId('carte-visuel'))).toContain(c);
    },
  );

  it('contient l’image, qui remplit le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    const img = screen.getByRole('img');
    expect(screen.getByTestId('carte-visuel').contains(img)).toBe(true);
    for (const c of ['h-full', 'w-full', 'object-cover']) expect(classes(img)).toContain(c);
  });
});

describe('ProductCard — pastille de remise', () => {
  it('affiche la remise exacte sur le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    const pastille = screen.getByTestId('prix-remise');
    expect(pastille.textContent).toBe(`${MOINS}30${NB}%`);
    expect(screen.getByTestId('carte-visuel').contains(pastille)).toBe(true);
  });

  it('n’affiche la remise qu’une seule fois', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getAllByTestId('prix-remise')).toHaveLength(1);
  });

  it('garde le prix barré sous le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getByTestId('prix-compare')).toBeInTheDocument();
  });

  it('n’affiche aucune pastille hors promotion', () => {
    render(<ProductCard produit={PLEIN_TARIF} />);
    expect(screen.queryByTestId('prix-remise')).toBeNull();
  });

  it('ne confond pas la pastille avec le badge', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.queryByTestId('badge')).toBeNull();
  });
});

describe('ProductCard — favori', () => {
  it('propose un bouton favori hors du lien', () => {
    render(<ProductCard produit={PROMO} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton).toHaveAttribute('type', 'button');
    expect(bouton.closest('a')).toBeNull();
  });

  it('bascule l’état favori', () => {
    render(<ProductCard produit={PROMO} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(bouton);
    expect(bouton).toHaveAttribute('aria-pressed', 'true');
    fireEvent.click(bouton);
    expect(bouton).toHaveAttribute('aria-pressed', 'false');
  });

  it('garde un seul lien dans la carte', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getAllByRole('link')).toHaveLength(1);
  });
});
