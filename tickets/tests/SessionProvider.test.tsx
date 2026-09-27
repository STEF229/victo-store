import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_SESSION, SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

let dernierRetour: boolean | null = null;
function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="client">{s.client ? `${s.client.prenom} ${s.client.nom}` : 'aucun'}</span>
      <span data-testid="pret">{String(s.pret)}</span>
      <button type="button" onClick={() => { dernierRetour = s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO); }}>bon</button>
      <button type="button" onClick={() => { dernierRetour = s.connecter(COURRIEL_DEMO, 'faux'); }}>faux</button>
      <button type="button" onClick={() => s.inscrire({ prenom: ' Léa ', nom: 'Roy', courriel: 'LEA@exemple.ca', motDePasse: 'motdepasse1' })}>inscrire</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const client = () => screen.getByTestId('client').textContent;
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_SESSION) ?? 'null') as { courriel?: string } | null;

beforeEach(() => { window.localStorage.clear(); dernierRetour = null; });

describe('useSession — hors du fournisseur', () => {
  it('ne connaît aucun client et reste prêt', () => {
    render(<Temoin />);
    expect(client()).toBe('aucun');
    expect(screen.getByTestId('pret').textContent).toBe('true');
    cliquer('bon');
    expect(dernierRetour).toBe(false);
  });
});

describe('SessionProvider', () => {
  it('connecte le compte de démonstration et refuse un mauvais mot de passe', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('faux');
    expect(dernierRetour).toBe(false);
    expect(client()).toBe('aucun');
    cliquer('bon');
    expect(dernierRetour).toBe(true);
    expect(client()).toBe('Camille Tremblay');
    expect(enregistre()?.courriel).toBe(COURRIEL_DEMO);
  });

  it('inscrit un nouveau client, nettoyé', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    expect(client()).toBe('Léa Roy');
    expect(enregistre()?.courriel).toBe('lea@exemple.ca');
  });

  it('déconnecte et oublie la session', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('bon');
    cliquer('sortir');
    expect(client()).toBe('aucun');
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });

  it('relit une session enregistrée et ignore une session illisible', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    const { unmount } = render(<SessionProvider><Temoin /></SessionProvider>);
    expect(client()).toBe('Camille Tremblay');
    unmount();
    window.localStorage.setItem(CLE_SESSION, '{"prenom":1}');
    render(<SessionProvider><Temoin /></SessionProvider>);
    expect(client()).toBe('aucun');
  });
});
