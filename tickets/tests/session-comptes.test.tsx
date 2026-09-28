import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';
import { CLE_COMPTES, authentifier, lireComptes } from '../src/lib/comptes-locaux';

let retour: unknown = null;
function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="client">{s.client ? `${s.client.prenom} ${s.client.nom} <${s.client.courriel}>` : 'aucun'}</span>
      <button type="button" onClick={() => { retour = s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO); }}>demo</button>
      <button type="button" onClick={() => { retour = s.connecter(COURRIEL_DEMO, 'nouveau2026'); }}>demo-nouveau</button>
      <button type="button" onClick={() => { retour = s.connecter('lea@exemple.ca', 'motdepasse1'); }}>lea</button>
      <button type="button" onClick={() => s.inscrire({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'motdepasse1' })}>inscrire</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
      <button type="button" onClick={() => { retour = s.modifierProfil({ prenom: 'Camille', nom: 'Gagnon', courriel: COURRIEL_DEMO }); }}>profil</button>
      <button type="button" onClick={() => { retour = s.modifierProfil({ prenom: '', nom: 'Gagnon', courriel: COURRIEL_DEMO }); }}>profil-faux</button>
      <button type="button" onClick={() => { retour = s.changerMotDePasse(MOT_DE_PASSE_DEMO, 'nouveau2026'); }}>mdp</button>
      <button type="button" onClick={() => { retour = s.changerMotDePasse('faux', 'nouveau2026'); }}>mdp-faux</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const client = () => screen.getByTestId('client').textContent;
const registre = () => lireComptes(window.localStorage.getItem(CLE_COMPTES));

beforeEach(() => { window.localStorage.clear(); retour = null; });

describe('session — comptes gardés', () => {
  it('retrouve un compte créé à l’inscription après déconnexion', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    cliquer('sortir');
    expect(client()).toBe('aucun');
    cliquer('lea');
    expect(retour).toBe(true);
    expect(client()).toBe('Léa Roy <lea@exemple.ca>');
  });

  it('relit le registre au montage', () => {
    const { unmount } = render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    unmount();
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('sortir');
    cliquer('lea');
    expect(retour).toBe(true);
  });
});

describe('session — modifier le profil', () => {
  it('enregistre le nouveau nom, dans la session et le registre', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('profil');
    expect(retour).toEqual({});
    expect(client()).toBe(`Camille Gagnon <${COURRIEL_DEMO}>`);
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)?.nom).toBe('Gagnon');
  });

  it('renvoie les erreurs sans rien changer', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('profil-faux');
    expect(retour).toEqual({ prenom: 'Indiquez votre prénom.' });
    expect(client()).toBe(`Camille Tremblay <${COURRIEL_DEMO}>`);
  });
});

describe('session — changer le mot de passe', () => {
  it('permet de se reconnecter avec le nouveau mot de passe seulement', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('mdp-faux');
    expect(retour).toEqual({ actuel: 'Mot de passe actuel incorrect.' });
    cliquer('mdp');
    expect(retour).toEqual({});
    cliquer('sortir');
    cliquer('demo');
    expect(retour).toBe(false);
    cliquer('demo-nouveau');
    expect(retour).toBe(true);
  });

  it('refuse sans session', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('mdp');
    expect(retour).toEqual({ actuel: 'Connectez-vous pour changer votre mot de passe.' });
  });
});
