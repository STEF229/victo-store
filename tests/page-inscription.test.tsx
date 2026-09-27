import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageInscription from '../src/app/inscription/page';
import { CHAMP_SAISIE_ERREUR } from '../src/components/compte/compte-affichage';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';

const { pousser } = vi.hoisted(() => ({ pousser: vi.fn() }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: pousser, replace: vi.fn(), prefetch: vi.fn(), back: vi.fn(), forward: vi.fn(), refresh: vi.fn() }),
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const poser = () => render(<SessionProvider><PageInscription /></SessionProvider>);
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Créer mon compte' }));

beforeEach(() => { window.localStorage.clear(); pousser.mockClear(); });

describe('page d’inscription', () => {
  it('assemble titre, champs et lien de connexion', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Créer un compte' })).toBeInTheDocument();
    for (const l of ['Prénom', 'Nom', 'Courriel', 'Mot de passe']) expect(screen.getByLabelText(l)).toBeInTheDocument();
    expect(screen.getByText('8 caractères minimum, dont au moins un chiffre.')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Se connecter' })).toHaveAttribute('href', '/connexion');
  });

  it('signale chaque champ fautif, sans inscrire', () => {
    poser();
    envoyer();
    expect(screen.getByText('Indiquez votre prénom.')).toBeInTheDocument();
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    const courriel = screen.getByLabelText('Courriel');
    expect(courriel).toHaveAttribute('aria-invalid', 'true');
    expect(courriel.getAttribute('aria-describedby')).toBe('erreur-courriel');
    for (const k of CHAMP_SAISIE_ERREUR.split(' ')) expect(classes(courriel)).toContain(k);
    expect(screen.getByLabelText('Mot de passe').getAttribute('aria-describedby')).toBe('aide-motDePasse erreur-motDePasse');
    expect(pousser).not.toHaveBeenCalled();
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });

  it('inscrit et mène au compte quand tout est valide', () => {
    poser();
    saisir('Prénom', 'Léa');
    saisir('Nom', 'Roy');
    saisir('Courriel', 'Lea@Exemple.ca');
    saisir('Mot de passe', 'motdepasse1');
    envoyer();
    expect(pousser).toHaveBeenCalledWith('/compte');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain('lea@exemple.ca');
    expect(screen.getByLabelText('Courriel')).not.toHaveAttribute('aria-invalid');
  });
});
