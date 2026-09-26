import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider, usePanier } from '../src/components/panier/PanierProvider';
import { CLE_PANIER } from '../src/lib/panier';

function Temoin() {
  const p = usePanier();
  return (
    <div>
      <span data-testid="nombre">{p.nombre}</span>
      <span data-testid="lignes">{JSON.stringify(p.lignes)}</span>
      <button type="button" onClick={() => p.ajouter({ slug: 'pegasus', sku: 'peg-41' }, 2, 5)}>ajouter</button>
      <button type="button" onClick={() => p.changerQuantite('peg-41', 1, 5)}>une</button>
      <button type="button" onClick={() => p.retirer('peg-41')}>retirer</button>
      <button type="button" onClick={() => p.vider()}>vider</button>
    </div>
  );
}
const cliquer = (nom: string) => fireEvent.click(screen.getByRole('button', { name: nom }));
const nombre = () => screen.getByTestId('nombre').textContent;
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_PANIER) ?? 'null') as unknown;

beforeEach(() => window.localStorage.clear());

describe('usePanier — hors du fournisseur', () => {
  it('voit un panier vide et ne plante pas', () => {
    render(<Temoin />);
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    cliquer('vider');
    expect(nombre()).toBe('0');
  });
});

describe('PanierProvider — actions', () => {
  it('ajoute, cumule et plafonne au stock', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    expect(nombre()).toBe('2');
    cliquer('ajouter');
    cliquer('ajouter');
    expect(nombre()).toBe('5');
  });

  it('change la quantité, retire et vide', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    cliquer('une');
    expect(nombre()).toBe('1');
    cliquer('retirer');
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    cliquer('vider');
    expect(screen.getByTestId('lignes').textContent).toBe('[]');
  });
});

describe('PanierProvider — localStorage', () => {
  it('enregistre chaque changement', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    cliquer('ajouter');
    expect(enregistre()).toEqual([{ slug: 'pegasus', sku: 'peg-41', quantite: 2 }]);
  });

  it('relit le panier enregistré au montage, sans l’écraser', () => {
    const stocke = [{ slug: 'polo', sku: 'polo-m', quantite: 3 }];
    window.localStorage.setItem(CLE_PANIER, JSON.stringify(stocke));
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(nombre()).toBe('3');
    expect(enregistre()).toEqual(stocke);
  });

  it('ignore un enregistrement illisible', () => {
    window.localStorage.setItem(CLE_PANIER, '{pas du json');
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(nombre()).toBe('0');
    cliquer('ajouter');
    expect(nombre()).toBe('2');
  });
});
