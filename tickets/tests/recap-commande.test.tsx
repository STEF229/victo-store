import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { RecapPanier } from '../src/components/panier/RecapPanier';

const RECAP = { articles: 1, sousTotalCents: 14900, economiesCents: 0, totalCents: 14900 };

describe('panier — passer la commande', () => {
  it('mène au tunnel en mode Medusa', () => {
    render(<CatalogueProvider valeur={{ produits: [], marques: [], source: 'medusa' }}><RecapPanier recap={RECAP} /></CatalogueProvider>);
    expect(screen.getByRole('link', { name: 'Passer la commande' })).toHaveAttribute('href', '/commande');
    expect(screen.queryByText('Le paiement en ligne arrive bientôt.')).toBeNull();
  });

  it('reste désactivé en démonstration', () => {
    render(<RecapPanier recap={RECAP} />);
    expect(screen.getByRole('button', { name: 'Passer la commande' })).toBeDisabled();
    expect(screen.getByText('Le paiement en ligne arrive bientôt.')).toBeInTheDocument();
  });
});
