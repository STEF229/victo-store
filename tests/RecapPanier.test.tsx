import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { RecapPanier } from '../src/components/panier/RecapPanier';
import { formatPrice } from '../src/lib/formatPrice';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('RecapPanier', () => {
  it('affiche sous-total, économies, livraison et total', () => {
    render(<RecapPanier recap={{ articles: 3, sousTotalCents: 34700, economiesCents: 10800, totalCents: 34700 }} />);
    expect(screen.getByText('Sous-total (3 articles)')).toBeInTheDocument();
    expect(screen.getByTestId('recap-sous-total').textContent).toBe(formatPrice(34700));
    expect(screen.getByTestId('recap-economies').textContent).toBe(`\u2212${formatPrice(10800)}`);
    expect(screen.getByText('Offerte')).toBeInTheDocument();
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(34700));
    expect(screen.getByRole('heading', { level: 2, name: 'Récapitulatif' })).toBeInTheDocument();
  });

  it('accorde au singulier et masque des économies nulles', () => {
    render(<RecapPanier recap={{ articles: 1, sousTotalCents: 14000, economiesCents: 0, totalCents: 14000 }} />);
    expect(screen.getByText('Sous-total (1 article)')).toBeInTheDocument();
    expect(screen.queryByTestId('recap-economies')).toBeNull();
  });

  it('désactive la commande en attendant le paiement en ligne', () => {
    render(<RecapPanier recap={{ articles: 1, sousTotalCents: 14000, economiesCents: 0, totalCents: 14000 }} />);
    const bouton = screen.getByRole('button', { name: 'Passer la commande' });
    expect(bouton).toBeDisabled();
    for (const k of ['cursor-not-allowed', 'bg-[var(--vs-accent)]', 'opacity-60']) expect(classes(bouton)).toContain(k);
    expect(screen.getByText('Le paiement en ligne arrive bientôt.')).toBeInTheDocument();
  });
});
