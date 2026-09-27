import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { MENU_LIEN, MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';
import { MenuCompte } from '../src/components/compte/MenuCompte';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

beforeEach(() => window.localStorage.clear());

describe('MenuCompte', () => {
  it('liste les cinq entrées, dans l’ordre, avec leurs liens', () => {
    render(<MenuCompte actif="commandes" />);
    const menu = screen.getByRole('navigation', { name: 'Espace client' });
    expect(within(menu).getAllByRole('link').map((l: HTMLElement) => [l.textContent, l.getAttribute('href')])).toEqual([
      ['Tableau de bord', '/compte'],
      ['Mes commandes', '/compte/commandes'],
      ['Favoris', '/compte/favoris'],
      ['Adresses', '/compte/adresses'],
      ['Informations personnelles', '/compte/informations'],
    ]);
  });

  it('marque l’entrée active, seule', () => {
    render(<MenuCompte actif="commandes" />);
    const actif = screen.getByRole('link', { name: 'Mes commandes' });
    expect(actif).toHaveAttribute('aria-current', 'page');
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif)).toContain(k);
    const autre = screen.getByRole('link', { name: 'Favoris' });
    expect(autre).not.toHaveAttribute('aria-current');
    for (const k of MENU_LIEN.split(' ')) expect(classes(autre)).toContain(k);
  });

  it('déconnecte', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    render(<SessionProvider><MenuCompte actif="tableau" /></SessionProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'Se déconnecter' }));
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });
});
