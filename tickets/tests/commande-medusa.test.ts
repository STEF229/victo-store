import { afterEach, describe, expect, it, vi } from 'vitest';
import { adresseDePanier, choisirLivraison, commander, enregistrerCoordonnees, optionsLivraison, recapDepuisMedusa } from '../src/lib/medusa/commande-medusa';

const D = { libelle: 'Livraison', nomComplet: 'Léa Roy Gagnon', ligne1: '12, rue Ontario', ville: 'Montréal', province: 'QC', codePostal: 'H2X 1Y6', telephone: '514 555-0100' };
type Appel = { cle: string; corps: unknown };
function medusa(reponses: Record<string, unknown>, statut: Record<string, number> = {}): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    const cle = `${init?.method ?? 'GET'} ${url.split('?')[0]}`;
    appels.push({ cle, corps: init?.body ? JSON.parse(String(init.body)) : undefined });
    const corps = reponses[cle];
    return new Response(JSON.stringify(corps ?? {}), { status: statut[cle] ?? (corps === undefined ? 500 : 200) });
  });
  return appels;
}
afterEach(() => { vi.unstubAllGlobals(); });

describe('commande Medusa — traductions', () => {
  it('traduit le récapitulatif du panier, en cents', () => {
    expect(recapDepuisMedusa({ items: [{ id: 'i1', product_title: 'Vomero 17', variant_title: '42', quantity: 2, unit_price: 149 }], shipping_total: 0, tax_total: 44.63, total: 342.63, shipping_methods: [{ id: 'sm' }] }))
      .toEqual({ lignes: [{ id: 'i1', titre: 'Vomero 17', marque: '', taille: '42', quantite: 2, totalCents: 29800 }], sousTotalCents: 29800, livraisonCents: 0, taxesCents: 4463, totalCents: 34263, livraisonChoisie: true });
    expect(recapDepuisMedusa({}).livraisonChoisie).toBe(false);
  });

  it('met l’adresse au format d’un panier Medusa', () => {
    expect(adresseDePanier(D)).toEqual({ first_name: 'Léa', last_name: 'Roy Gagnon', address_1: '12, rue Ontario', city: 'Montréal', province: 'qc', postal_code: 'H2X 1Y6', phone: '514 555-0100', country_code: 'ca' });
  });
});

describe('commande Medusa — étapes par la passerelle', () => {
  it('enregistre le courriel et l’adresse, lit et choisit la livraison', async () => {
    const appels = medusa({ 'POST /api/medusa/store/carts/cart_1': { cart: {} }, 'GET /api/medusa/store/shipping-options': { shipping_options: [{ id: 'so_1', name: 'Livraison standard', amount: 0 }] },
      'POST /api/medusa/store/carts/cart_1/shipping-methods': { cart: {} } });
    await enregistrerCoordonnees('cart_1', ' Lea@Exemple.ca ', D);
    expect(await optionsLivraison('cart_1')).toEqual([{ id: 'so_1', nom: 'Livraison standard', montantCents: 0 }]);
    await choisirLivraison('cart_1', 'so_1');
    expect(appels.map((a) => a.cle)).toEqual(['POST /api/medusa/store/carts/cart_1', 'GET /api/medusa/store/shipping-options', 'POST /api/medusa/store/carts/cart_1/shipping-methods']);
    expect(appels.map((a) => a.corps)).toEqual([{ email: 'lea@exemple.ca', shipping_address: adresseDePanier(D), billing_address: adresseDePanier(D) }, undefined, { option_id: 'so_1' }]);
  });

  it('paie (manuel) puis commande, et renvoie le numéro', async () => {
    const appels = medusa({ 'POST /api/medusa/store/payment-collections': { payment_collection: { id: 'pc_1' } }, 'POST /api/medusa/store/payment-collections/pc_1/payment-sessions': {},
      'POST /api/medusa/store/carts/cart_1/complete': { type: 'order', order: { id: 'order_1', display_id: 7 } } });
    expect(await commander('cart_1')).toEqual({ numero: 'VS-7' });
    expect(appels.map((a) => a.corps)).toEqual([{ cart_id: 'cart_1' }, { provider_id: 'pp_system_default' }, undefined]);
  });

  it('rapporte un refus, sans planter', async () => {
    medusa({ 'POST /api/medusa/store/payment-collections': { payment_collection: { id: 'pc_1' } }, 'POST /api/medusa/store/payment-collections/pc_1/payment-sessions': {},
      'POST /api/medusa/store/carts/cart_1/complete': { type: 'cart', error: { message: 'Paiement refusé' } } });
    expect(await commander('cart_1')).toEqual({ erreur: 'Paiement refusé' });
    medusa({});
    expect('erreur' in (await commander('cart_1'))).toBe(true);
  });
});
