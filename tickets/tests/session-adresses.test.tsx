import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { supprimerAdresse } from '../src/lib/adresses';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="adresses">{s.client ? s.client.adresses.map((a) => a.id).join(',') || 'aucune' : 'déconnecté'}</span>
      <button type="button" onClick={() => s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO)}>entrer</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
      <button type="button" onClick={() => s.client && s.mettreAJourAdresses(supprimerAdresse(s.client.adresses, 'bureau'))}>sans bureau</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const adresses = () => screen.getByTestId('adresses').textContent;

beforeEach(() => window.localStorage.clear());

describe('session — adresses', () => {
  it('met à jour les adresses du client', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('entrer');
    expect(adresses()).toBe('domicile,bureau');
    cliquer('sans bureau');
    expect(adresses()).toBe('domicile');
  });

  it('les garde dans le registre : on les retrouve après s’être reconnecté', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('entrer');
    cliquer('sans bureau');
    cliquer('sortir');
    cliquer('entrer');
    expect(adresses()).toBe('domicile');
  });

  it('ne fait rien sans session, ni hors du fournisseur', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('sans bureau');
    expect(adresses()).toBe('déconnecté');
  });
});
