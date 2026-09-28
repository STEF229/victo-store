import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { BlocAchat } from '../src/components/produit/BlocAchat';
import type { Produit } from '../src/lib/catalogue';

const PRODUIT: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const coeur = () => screen.getByRole('button', { name: 'Ajouter aux favoris' });

beforeEach(() => window.localStorage.clear());

describe('BlocAchat — favori gardé', () => {
  it('bascule le favori et le garde', () => {
    render(<FavorisProvider><BlocAchat produit={PRODUIT} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    const icone = coeur().querySelector('svg.lucide-heart');
    expect(icone).not.toBeNull();
    for (const k of ['fill-[var(--vs-promo)]', 'text-[var(--vs-promo)]']) expect(classes(icone as Element)).toContain(k);
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe('["air-zoom-pegasus-41"]');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
  });

  it('montre un favori déjà gardé', () => {
    window.localStorage.setItem(CLE_FAVORIS, '["air-zoom-pegasus-41"]');
    render(<FavorisProvider><BlocAchat produit={PRODUIT} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
  });
});
