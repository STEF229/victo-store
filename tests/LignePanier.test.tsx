import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LignePanier } from '../src/components/panier/LignePanier';
import { hrefProduit, type Produit } from '../src/lib/catalogue';
import { formatPrice } from '../src/lib/formatPrice';
import type { LigneDetaillee } from '../src/lib/panier-detail';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.textContent;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const SIMPLE: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, categorie: 'chaussures',
  variantes: [{ id: 'v42', taille: '42', sku: 'peg-42', stock: 2 }],
};
const PROMO: Produit = { ...SIMPLE, prixCompareCents: 18000 };
function ligne(produit: Produit, quantite: number): LigneDetaillee {
  const variante = { id: 'v42', taille: '42', sku: 'peg-42', stock: 2 };
  return { slug: produit.slug, sku: 'peg-42', quantite, produit, variante, totalCents: produit.prixCents * quantite, economieCents: 0 };
}
function poser(l: LigneDetaillee) {
  const onQuantite = vi.fn();
  const onRetirer = vi.fn();
  render(<ul><LignePanier ligne={l} onQuantite={onQuantite} onRetirer={onRetirer} /></ul>);
  return { onQuantite, onRetirer };
}
const bouton = (nom: string) => screen.getByRole('button', { name: nom });
// Le prix barré est lu par textContent : formatPrice met une espace insécable, que
// getByText normalise dans la page mais pas dans le motif cherché.
const prixBarre = () => screen.getByTestId('ligne-panier').querySelector('s');

describe('LignePanier — contenu', () => {
  it('affiche marque, nom, pointure, prix remisé, prix barré et total', () => {
    poser(ligne(PROMO, 2));
    expect(screen.getByText('Nike')).toBeInTheDocument();
    expect(screen.getByTestId('ligne-pointure').textContent).toBe('Pointure 42');
    expect(screen.getByTestId('ligne-prix').textContent).toBe(formatPrice(12600));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-promo)]');
    expect(prixBarre()?.textContent).toBe(formatPrice(18000));
    expect(screen.getByTestId('ligne-total').textContent).toBe(formatPrice(25200));
    expect(screen.getByTestId('ligne-quantite').textContent).toBe('2');
  });

  it('affiche un prix simple hors promotion', () => {
    poser(ligne(SIMPLE, 1));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-noir)]');
    expect(prixBarre()).toBeNull();
  });

  it('relie l’image et le nom à la fiche produit', () => {
    poser(ligne(SIMPLE, 1));
    const liens = screen.getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual([hrefProduit(SIMPLE), hrefProduit(SIMPLE)]);
    expect(screen.getAllByRole('link', { name: 'Pegasus' })).toHaveLength(2);
  });

  it('signale un stock bas', () => {
    poser(ligne(SIMPLE, 1));
    expect(screen.getByTestId('ligne-stock-bas').textContent).toBe('Plus que 2 paires en 42');
  });
});

describe('LignePanier — actions', () => {
  it('bloque la baisse à 1 et la hausse au stock', () => {
    const { unmount } = render(<ul><LignePanier ligne={ligne(SIMPLE, 1)} onQuantite={() => {}} onRetirer={() => {}} /></ul>);
    expect(bouton('Diminuer la quantité')).toBeDisabled();
    porte(bouton('Diminuer la quantité'), 'text-[#B5B5BA]');
    expect(bouton('Augmenter la quantité')).not.toBeDisabled();
    unmount();
    poser(ligne(SIMPLE, 2));
    expect(bouton('Augmenter la quantité')).toBeDisabled();
    expect(bouton('Diminuer la quantité')).not.toBeDisabled();
  });

  it('remonte la nouvelle quantité, le stock et le retrait', () => {
    const f = poser(ligne(SIMPLE, 2));
    fireEvent.click(bouton('Diminuer la quantité'));
    expect(f.onQuantite).toHaveBeenCalledWith('peg-42', 1, 2);
    fireEvent.click(bouton('Retirer'));
    expect(f.onRetirer).toHaveBeenCalledWith('peg-42');
  });
});
