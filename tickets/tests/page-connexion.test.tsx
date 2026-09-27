import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageConnexion from '../src/app/connexion/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

const { pousser } = vi.hoisted(() => ({ pousser: vi.fn() }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: pousser, replace: vi.fn(), prefetch: vi.fn(), back: vi.fn(), forward: vi.fn(), refresh: vi.fn() }),
}));

const poser = () => render(<SessionProvider><PageConnexion /></SessionProvider>);
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });

beforeEach(() => { window.localStorage.clear(); pousser.mockClear(); });

describe('page de connexion', () => {
  it('assemble titre, champs, liens et rappel du compte de démonstration', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Connexion' })).toBeInTheDocument();
    expect(screen.getByLabelText('Courriel')).toHaveAttribute('type', 'email');
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'password');
    expect(screen.getByTestId('connexion-demo').textContent).toContain(COURRIEL_DEMO);
    expect(screen.getByRole('link', { name: 'Mot de passe oublié ?' })).toHaveAttribute('href', '/mot-de-passe-oublie');
    expect(screen.getByRole('link', { name: 'Créer un compte' })).toHaveAttribute('href', '/inscription');
  });

  it('refuse un mauvais mot de passe, sans rediriger', () => {
    poser();
    saisir('Courriel', COURRIEL_DEMO);
    saisir('Mot de passe', 'mauvais');
    fireEvent.click(screen.getByRole('button', { name: 'Se connecter' }));
    expect(screen.getByRole('alert').textContent).toBe('Courriel ou mot de passe incorrect.');
    expect(pousser).not.toHaveBeenCalled();
  });

  it('connecte le compte de démonstration et mène au compte', () => {
    poser();
    saisir('Courriel', COURRIEL_DEMO);
    saisir('Mot de passe', MOT_DE_PASSE_DEMO);
    fireEvent.click(screen.getByRole('button', { name: 'Se connecter' }));
    expect(pousser).toHaveBeenCalledWith('/compte');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain(COURRIEL_DEMO);
    expect(screen.queryByRole('alert')).toBeNull();
  });

  it('affiche et masque le mot de passe', () => {
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Afficher le mot de passe' }));
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'text');
    fireEvent.click(screen.getByRole('button', { name: 'Masquer le mot de passe' }));
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'password');
  });
});
