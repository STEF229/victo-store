import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { EspaceClient } from '../src/components/compte/EspaceClient';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

beforeEach(() => window.localStorage.clear());

describe('EspaceClient', () => {
  it('invite à se connecter ou à créer un compte', () => {
    render(<SessionProvider><EspaceClient actif="tableau"><p>secret</p></EspaceClient></SessionProvider>);
    const invitation = screen.getByTestId('compte-invitation');
    expect(within(invitation).getByRole('heading', { level: 2 }).textContent).toBe('Connectez-vous pour accéder à votre compte');
    expect(within(invitation).getByRole('link', { name: 'Se connecter' })).toHaveAttribute('href', '/connexion');
    expect(within(invitation).getByRole('link', { name: 'Créer un compte' })).toHaveAttribute('href', '/inscription');
    expect(screen.queryByText('secret')).toBeNull();
  });

  it('montre menu et contenu à un client connecté', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    render(<SessionProvider><EspaceClient actif="commandes"><p>secret</p></EspaceClient></SessionProvider>);
    const espace = screen.getByTestId('espace-client');
    expect(within(espace).getByRole('navigation', { name: 'Espace client' })).toBeInTheDocument();
    expect(within(espace).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('aria-current', 'page');
    expect(within(espace).getByText('secret')).toBeInTheDocument();
    expect(screen.queryByTestId('compte-invitation')).toBeNull();
  });
});
