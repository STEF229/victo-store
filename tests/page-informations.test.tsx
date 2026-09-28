import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageInformations from '../src/app/compte/informations/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';
import { CLE_COMPTES, authentifier, lireComptes } from '../src/lib/comptes-locaux';

const poser = () => {
  window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  render(<SessionProvider><PageInformations /></SessionProvider>);
};
const formulaire = (nom: string) => screen.getByRole('form', { name: nom });
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const registre = () => lireComptes(window.localStorage.getItem(CLE_COMPTES));

beforeEach(() => window.localStorage.clear());

describe('informations personnelles — profil', () => {
  it('préremplit le profil du client', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Informations personnelles' })).toBeInTheDocument();
    expect(screen.getByLabelText('Prénom')).toHaveValue('Camille');
    expect(screen.getByLabelText('Nom')).toHaveValue('Tremblay');
    expect(screen.getByLabelText('Courriel')).toHaveValue(COURRIEL_DEMO);
    expect(screen.getByRole('link', { name: 'Informations personnelles' })).toHaveAttribute('aria-current', 'page');
  });

  it('enregistre un nouveau nom et le confirme', () => {
    poser();
    saisir('Nom', 'Gagnon');
    fireEvent.click(within(formulaire('Profil')).getByRole('button', { name: 'Enregistrer' }));
    expect(within(formulaire('Profil')).getByRole('status').textContent).toBe('Vos informations sont enregistrées.');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain('Gagnon');
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)?.nom).toBe('Gagnon');
  });

  it('signale un courriel invalide sans enregistrer', () => {
    poser();
    saisir('Courriel', 'pas un courriel');
    fireEvent.click(within(formulaire('Profil')).getByRole('button', { name: 'Enregistrer' }));
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    expect(screen.getByLabelText('Courriel')).toHaveAttribute('aria-invalid', 'true');
    expect(within(formulaire('Profil')).queryByRole('status')).toBeNull();
  });
});

describe('informations personnelles — mot de passe', () => {
  it('refuse un mot de passe actuel faux', () => {
    poser();
    saisir('Mot de passe actuel', 'faux');
    saisir('Nouveau mot de passe', 'nouveau2026');
    fireEvent.click(screen.getByRole('button', { name: 'Changer le mot de passe' }));
    expect(screen.getByText('Mot de passe actuel incorrect.')).toBeInTheDocument();
    expect(within(formulaire('Mot de passe')).queryByRole('status')).toBeNull();
  });

  it('change le mot de passe, vide les champs et confirme', () => {
    poser();
    saisir('Mot de passe actuel', MOT_DE_PASSE_DEMO);
    saisir('Nouveau mot de passe', 'nouveau2026');
    fireEvent.click(screen.getByRole('button', { name: 'Changer le mot de passe' }));
    expect(within(formulaire('Mot de passe')).getByRole('status').textContent).toBe('Mot de passe modifié.');
    expect(screen.getByLabelText('Mot de passe actuel')).toHaveValue('');
    expect(authentifier(registre(), COURRIEL_DEMO, 'nouveau2026')).not.toBeNull();
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBeNull();
  });
});

describe('informations personnelles — sans session', () => {
  it('invite à se connecter', () => {
    render(<SessionProvider><PageInformations /></SessionProvider>);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
