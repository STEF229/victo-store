import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageCommandes from '../src/app/compte/commandes/page';
import { PILULE_ON } from '../src/components/catalogue/filtres-affichage';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const connecter = (client: object) => window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
const poser = () => render(<SessionProvider><PageCommandes /></SessionProvider>);
const filtre = (nom: string) => screen.getByRole('button', { name: nom });
const numeros = () => screen.queryAllByRole('heading', { level: 3 }).map((h: HTMLElement) => h.textContent);

beforeEach(() => window.localStorage.clear());

describe('mes commandes', () => {
  it('liste toutes les commandes du client de démonstration', () => {
    connecter(CLIENT_DEMO);
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Mes commandes' })).toBeInTheDocument();
    expect(numeros()).toEqual(['Commande VS-10482', 'Commande VS-10417', 'Commande VS-10360', 'Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('4 commandes');
    expect(filtre('Toutes')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('aria-current', 'page');
  });

  it('filtre par statut', () => {
    connecter(CLIENT_DEMO);
    poser();
    fireEvent.click(filtre('Livrées'));
    expect(numeros()).toEqual(['Commande VS-10417', 'Commande VS-10360']);
    expect(filtre('Livrées')).toHaveAttribute('aria-pressed', 'true');
    for (const k of PILULE_ON.split(' ')) expect(classes(filtre('Livrées'))).toContain(k);
    fireEvent.click(filtre('Annulées'));
    expect(numeros()).toEqual(['Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('1 commande');
  });

  it('dit qu’il n’y a rien pour un nouveau client', () => {
    connecter({ ...CLIENT_DEMO, courriel: 'lea@exemple.ca' });
    poser();
    expect(screen.getByTestId('commandes-vides')).toBeInTheDocument();
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('0 commande');
  });
});
