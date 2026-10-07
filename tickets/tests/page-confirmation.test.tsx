import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageConfirmation from '../src/app/commande/confirmation/page';

describe('confirmation de commande', () => {
  it('affiche le numéro et le lien de suivi', async () => {
    render(await PageConfirmation({ searchParams: Promise.resolve({ numero: 'VS-7' }) }));
    expect(screen.getByTestId('commande-confirmee').textContent).toContain('Commande VS-7');
    expect(screen.getByRole('link', { name: 'Suivre ma commande' })).toHaveAttribute('href', '/compte/commandes/VS-7');
  });

  it('reste correcte sans numéro', async () => {
    render(await PageConfirmation({ searchParams: Promise.resolve({}) }));
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Merci, votre commande est confirmée');
    expect(screen.queryByRole('link', { name: 'Suivre ma commande' })).toBeNull();
  });
});
