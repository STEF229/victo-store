import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CarteCommande } from '../src/components/compte/CarteCommande';
import { COMMANDES_DEMO, type Commande } from '../src/lib/compte';

describe('CarteCommande — détail', () => {
  it('mène au détail de la commande', () => {
    render(<CarteCommande commande={COMMANDES_DEMO.find((c) => c.numero === 'VS-10417') as Commande} />);
    expect(screen.getByRole('link', { name: 'Voir le détail' })).toHaveAttribute('href', '/compte/commandes/VS-10417');
  });
});
