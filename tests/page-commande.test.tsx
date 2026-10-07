import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';

const etat = vi.hoisted(() => ({ panier: { pret: true, nombre: 1, panierMedusa: 'cart_1' as string | null, vider: () => {} } }));
vi.mock('../src/components/panier/PanierProvider', async (original) => ({
  ...(await original<typeof import('../src/components/panier/PanierProvider')>()),
  usePanier: () => etat.panier,
}));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: () => {} }),
}));
import PageCommande from '../src/app/commande/page';

const RECAP = { cart: { items: [{ id: 'i1', product_title: 'Vomero 17', variant_title: '42', quantity: 1, unit_price: 149 }], shipping_total: 0, tax_total: 0, total: 149, shipping_methods: [] } };
beforeEach(() => {
  etat.panier = { pret: true, nombre: 1, panierMedusa: 'cart_1', vider: () => {} };
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    if (url.startsWith('/api/medusa/store/shipping-options')) return new Response(JSON.stringify({ shipping_options: [{ id: 'so_1', name: 'Livraison standard', amount: 0 }] }), { status: 200 });
    if (url.startsWith('/api/medusa/store/carts/cart_1') && (init?.method ?? 'GET') === 'GET') return new Response(JSON.stringify(RECAP), { status: 200 });
    return new Response(JSON.stringify({ cart: {} }), { status: 200 });
  });
});
afterEach(() => { vi.unstubAllGlobals(); });
const enMedusa = () => render(<CatalogueProvider valeur={{ produits: [], marques: [], source: 'medusa' }}><PageCommande /></CatalogueProvider>);
const saisir = (id: string, valeur: string) => fireEvent.change(document.getElementById(id) as HTMLElement, { target: { value: valeur } });

describe('tunnel de commande', () => {
  it('est indisponible en démonstration', () => {
    render(<PageCommande />);
    expect(screen.getByTestId('commande-indisponible')).toBeInTheDocument();
  });

  it('signale un panier vide', () => {
    etat.panier = { pret: true, nombre: 0, panierMedusa: null, vider: () => {} };
    enMedusa();
    expect(screen.getByTestId('commande-vide')).toBeInTheDocument();
  });

  it('mène un invité de l’adresse au choix de la livraison', async () => {
    enMedusa();
    await waitFor(() => expect(screen.getByTestId('commande-recap').textContent).toContain('Vomero 17'));
    saisir('commande-courriel', 'lea@exemple.ca');
    saisir('adresse-nomComplet', 'Léa Roy');
    saisir('adresse-ligne1', '12, rue Ontario');
    saisir('adresse-ville', 'Montréal');
    saisir('adresse-codePostal', 'H2X 1Y6');
    saisir('adresse-telephone', '514 555 0100');
    fireEvent.click(screen.getByRole('button', { name: 'Continuer vers la livraison' }));
    await waitFor(() => expect(screen.getByRole('radiogroup', { name: 'Mode de livraison' }).textContent).toContain('Livraison standard'));
    expect(screen.getByRole('radiogroup', { name: 'Mode de livraison' }).textContent).toContain('Offerte');
    expect(screen.getByRole('button', { name: 'Continuer vers le paiement' })).toBeInTheDocument();
  });

  it('refuse un courriel invalide', async () => {
    enMedusa();
    saisir('commande-courriel', 'pas-un-courriel');
    saisir('adresse-nomComplet', 'Léa Roy'); saisir('adresse-ligne1', '12, rue Ontario'); saisir('adresse-ville', 'Montréal');
    saisir('adresse-codePostal', 'H2X 1Y6'); saisir('adresse-telephone', '514 555 0100');
    fireEvent.click(screen.getByRole('button', { name: 'Continuer vers la livraison' }));
    await waitFor(() => expect(screen.getByTestId('commande-erreur').textContent).toContain('courriel'));
  });
});
