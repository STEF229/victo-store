import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { PanierProvider, usePanier } from '../src/components/panier/PanierProvider';
import { CLE_PANIER_MEDUSA } from '../src/lib/medusa/panier-medusa';

const MARQUE = { id: 'm', nom: 'Nike', slug: 'nike' };
const P = { id: 'prod_1', slug: 'pegasus', nom: 'Pegasus', marque: MARQUE, imageUrl: '/x.svg', prixCents: 12900, variantes: [{ id: 'variant_42', taille: '42', sku: 'peg-42', stock: 5 }] };
function Bouton() {
  const panier = usePanier();
  return <button type="button" onClick={() => panier.ajouter({ slug: 'pegasus', sku: 'peg-42' }, 2, 5)}>{`ajouter ${panier.panierMedusa ?? 'aucun'}`}</button>;
}
let appels: string[] = [];
beforeEach(() => {
  window.localStorage.clear(); appels = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    appels.push(`${init?.method ?? 'GET'} ${url} ${init?.body ?? ''}`);
    return new Response(JSON.stringify({ cart: { id: 'cart_1', items: [] } }), { status: 200 });
  });
});
afterEach(() => { vi.unstubAllGlobals(); });

describe('panier — recopie dans Medusa', () => {
  it('en mode Medusa, crée le panier Medusa et y ajoute la variante', async () => {
    render(<CatalogueProvider valeur={{ produits: [P], marques: [MARQUE], source: 'medusa' }}><PanierProvider><Bouton /></PanierProvider></CatalogueProvider>);
    fireEvent.click(screen.getByRole('button'));
    await waitFor(() => expect(window.localStorage.getItem(CLE_PANIER_MEDUSA)).toBe('cart_1'));
    expect(appels.some((a) => a.startsWith('POST /api/medusa/store/carts '))).toBe(true);
    expect(appels.some((a) => a.startsWith('POST /api/medusa/store/carts/cart_1/line-items') && a.includes('"variant_id":"variant_42"') && a.includes('"quantity":2'))).toBe(true);
    await waitFor(() => expect(screen.getByRole('button').textContent).toBe('ajouter cart_1'));
  });

  it('en mode démonstration, n’appelle jamais Medusa', async () => {
    render(<PanierProvider><Bouton /></PanierProvider>);
    fireEvent.click(screen.getByRole('button'));
    await new Promise((r) => setTimeout(r, 50));
    expect(appels).toEqual([]);
    expect(screen.getByRole('button').textContent).toBe('ajouter aucun');
  });
});
