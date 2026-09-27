import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageCompte from '../src/app/compte/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const connecter = (client: object) => window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
const poser = () => render(<SessionProvider><PageCompte /></SessionProvider>);

beforeEach(() => window.localStorage.clear());

describe('tableau de bord', () => {
  it('invite à se connecter quand personne ne l’est', () => {
    poser();
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
    expect(screen.queryByRole('heading', { level: 1 })).toBeNull();
  });

  it('accueille le client de démonstration avec ses informations', () => {
    connecter(CLIENT_DEMO);
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Bonjour, Camille' })).toBeInTheDocument();
    expect(screen.getByText('Membre depuis mars 2026')).toBeInTheDocument();
    expect(within(screen.getByTestId('carte-derniere-commande')).getByText('VS-10482 · 24 septembre 2026')).toBeInTheDocument();
    expect(within(screen.getByTestId('carte-derniere-commande')).getByText('Expédiée')).toBeInTheDocument();
    expect(screen.getByTestId('carte-adresse').textContent).toContain('4520, rue Saint-Denis, app. 3');
    expect(screen.getAllByTestId('carte-commande')).toHaveLength(2);
    expect(screen.getByRole('navigation', { name: 'Espace client' })).toBeInTheDocument();
  });

  it('reste utile à un nouveau client sans commande ni adresse', () => {
    connecter({ ...CLIENT_DEMO, prenom: 'Léa', courriel: 'lea@exemple.ca', adresses: [] });
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Bonjour, Léa' })).toBeInTheDocument();
    expect(screen.getByText("Aucune commande pour l'instant.")).toBeInTheDocument();
    expect(screen.getByText('Aucune adresse enregistrée.')).toBeInTheDocument();
    expect(screen.queryAllByTestId('carte-commande')).toHaveLength(0);
  });
});
