import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { SessionProvider, useSession } from '../src/components/compte/SessionProvider';

const MOI = { customer: { email: 'lea@exemple.ca', first_name: 'Léa', last_name: 'Roy', created_at: '2026-10-06', addresses: [] } };
const COMMANDES = { orders: [{ id: 'order_1', display_id: 7, created_at: '2026-10-06T08:00:00Z', status: 'pending', items: [] }] };
function Temoin() {
  const s = useSession();
  return (
    <div>
      <p data-testid="etat">{`${s.pret ? 'pret' : 'attente'} ${s.client?.prenom ?? 'personne'} ${Array.isArray(s.commandes) ? s.commandes.map((c) => c.numero).join(',') : 'demo'}`}</p>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
    </div>
  );
}
const appels: string[] = [];
function medusa(connecte: boolean) {
  appels.length = 0;
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    appels.push(`${init?.method ?? 'GET'} ${url.split('?')[0]}`);
    if (url.startsWith('/api/medusa/store/customers/me')) return connecte ? new Response(JSON.stringify(MOI), { status: 200 }) : new Response('{}', { status: 401 });
    if (url.startsWith('/api/medusa/store/orders')) return new Response(JSON.stringify(COMMANDES), { status: 200 });
    return new Response('{}', { status: 200 });
  });
}
const enMedusa = (enfant: ReactNode) => <CatalogueProvider valeur={{ produits: [], marques: [], source: 'medusa' }}><SessionProvider>{enfant}</SessionProvider></CatalogueProvider>;
afterEach(() => { vi.unstubAllGlobals(); window.localStorage.clear(); });

describe('session — mode Medusa', () => {
  it('lit le client et ses commandes dans Medusa', async () => {
    medusa(true);
    render(enMedusa(<Temoin />));
    await waitFor(() => expect(screen.getByTestId('etat').textContent).toBe('pret Léa VS-7'));
  });

  it('reste sans client quand personne n’est connecté', async () => {
    medusa(false);
    render(enMedusa(<Temoin />));
    await waitFor(() => expect(screen.getByTestId('etat').textContent).toBe('pret personne '));
  });

  it('déconnecte par la passerelle', async () => {
    medusa(true);
    render(enMedusa(<Temoin />));
    await waitFor(() => expect(screen.getByTestId('etat').textContent).toBe('pret Léa VS-7'));
    fireEvent.click(screen.getByRole('button', { name: 'sortir' }));
    expect(screen.getByTestId('etat').textContent).toBe('pret personne demo');
    await waitFor(() => expect(appels).toContain('POST /api/medusa/deconnexion'));
  });
});

describe('session — mode démonstration', () => {
  it('n’appelle jamais Medusa, et garde des résultats immédiats', () => {
    medusa(true);
    let resultat: unknown = 'rien';
    function Essai() {
      const s = useSession();
      // Avant le ticket 116d, connexion n'existe pas : le test échoue sans planter.
      return <button type="button" onClick={() => { resultat = typeof s.connexion === 'function' ? s.connexion('camille.tremblay@exemple.ca', 'victo2026') : 'absente'; }}>essai</button>;
    }
    render(<SessionProvider><Essai /></SessionProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'essai' }));
    expect(resultat).toBe(true);
    expect(appels).toEqual([]);
  });
});
