import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  adresseDepuisMedusa, adresseVersMedusa, clientDepuisMedusa, commandeDepuisMedusa, inscrireClient, statutDepuisMedusa, synchroniserAdresses,
} from '../src/lib/medusa/clients-medusa';

const ADR = { id: 'caaddr_1', address_name: 'Domicile', first_name: 'Camille', last_name: 'Tremblay Roy', address_1: '4520, rue Saint-Denis', city: 'Montréal',
  province: 'qc', postal_code: 'H2J 2L3', phone: '514 555-0142', is_default_shipping: true };
const SITE = { id: 'caaddr_1', libelle: 'Domicile', nomComplet: 'Camille Tremblay Roy', ligne1: '4520, rue Saint-Denis', ville: 'Montréal', province: 'QC',
  codePostal: 'H2J 2L3', telephone: '514 555-0142', parDefaut: true };
type Appel = { url: string; methode: string; corps: unknown };
function medusa(reponses: Record<string, unknown>): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    const methode = init?.method ?? 'GET';
    appels.push({ url, methode, corps: init?.body ? JSON.parse(String(init.body)) : undefined });
    const corps = reponses[`${methode} ${url.split('?')[0]}`];
    return corps === undefined ? new Response('{}', { status: 401 }) : new Response(JSON.stringify(corps), { status: 200 });
  });
  return appels;
}
afterEach(() => { vi.unstubAllGlobals(); });

describe('Medusa → site : clients et adresses', () => {
  it('traduit une adresse, aller et retour', () => {
    expect(adresseDepuisMedusa(ADR)).toEqual(SITE);
    expect(adresseVersMedusa(SITE)).toEqual({ address_name: 'Domicile', first_name: 'Camille', last_name: 'Tremblay Roy', address_1: '4520, rue Saint-Denis',
      city: 'Montréal', province: 'qc', postal_code: 'H2J 2L3', phone: '514 555-0142', country_code: 'ca', is_default_shipping: true });
  });

  it('traduit un client', () => {
    expect(clientDepuisMedusa({ email: 'Camille@Exemple.ca', first_name: 'Camille', last_name: 'Tremblay', created_at: '2026-10-05T12:00:00Z', addresses: [ADR] }))
      .toEqual({ prenom: 'Camille', nom: 'Tremblay', courriel: 'camille@exemple.ca', membreDepuis: '2026-10-05', adresses: [SITE] });
  });
});

describe('Medusa → site : commandes', () => {
  it('traduit une commande, sa remise et son adresse', () => {
    const c = commandeDepuisMedusa({ id: 'order_1', display_id: 12, created_at: '2026-10-06T08:00:00Z', status: 'pending', fulfillment_status: 'not_fulfilled',
      items: [{ product_handle: 'essai-nike-vomero-17', product_title: 'Vomero 17', subtitle: 'Nike', variant_title: '42', quantity: 1, unit_price: 149, compare_at_unit_price: 185 }],
      shipping_address: ADR });
    expect(c).toEqual({ numero: 'VS-12', date: '2026-10-06', statut: 'preparation', adresseId: 'caaddr_1', adresse: SITE, paiement: 'Paiement manuel (essai)', suivi: null,
      lignes: [{ slug: 'essai-nike-vomero-17', nom: 'Vomero 17', marque: 'Nike', taille: '42', quantite: 1, prixCents: 14900, economieCents: 3600 }] });
  });

  it('déduit le statut', () => {
    const base = { id: 'o', created_at: '2026-10-06' };
    expect([statutDepuisMedusa({ ...base, status: 'canceled' }), statutDepuisMedusa({ ...base, fulfillment_status: 'delivered' }),
      statutDepuisMedusa({ ...base, fulfillment_status: 'shipped' }), statutDepuisMedusa({ ...base, fulfillment_status: 'not_fulfilled' })])
      .toEqual(['annulee', 'livree', 'expediee', 'preparation']);
  });
});

describe('Medusa — comptes par la passerelle', () => {
  const MOI = { customer: { email: 'lea@exemple.ca', first_name: 'Léa', last_name: 'Roy', created_at: '2026-10-06', addresses: [] } };
  it('inscrit : identité, fiche client, connexion, puis lecture', async () => {
    const appels = medusa({ 'POST /api/medusa/auth/customer/emailpass/register': { connecte: true }, 'POST /api/medusa/store/customers': { customer: {} },
      'POST /api/medusa/auth/customer/emailpass': { connecte: true }, 'GET /api/medusa/store/customers/me': MOI });
    const c = await inscrireClient({ prenom: ' Léa ', nom: 'Roy', courriel: 'Lea@Exemple.ca', motDePasse: 'secret2026' });
    expect(c?.courriel).toBe('lea@exemple.ca');
    expect(appels.map((a) => `${a.methode} ${a.url.split('?')[0]}`)).toEqual(['POST /api/medusa/auth/customer/emailpass/register', 'POST /api/medusa/store/customers',
      'POST /api/medusa/auth/customer/emailpass', 'GET /api/medusa/store/customers/me']);
    expect(appels.map((a) => a.corps).slice(0, 2)).toEqual([{ email: 'lea@exemple.ca', password: 'secret2026' }, { email: 'lea@exemple.ca', first_name: 'Léa', last_name: 'Roy' }]);
  });

  it('refuse l’inscription quand Medusa refuse l’identité', async () => {
    const appels = medusa({});
    expect(await inscrireClient({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'secret2026' })).toBeNull();
    expect(appels).toHaveLength(1);
  });

  it('synchronise le carnet d’adresses : retire, ajoute et modifie seulement ce qui change', async () => {
    const appels = medusa({ 'DELETE /api/medusa/store/customers/me/addresses/caaddr_2': {}, 'POST /api/medusa/store/customers/me/addresses': {},
      'POST /api/medusa/store/customers/me/addresses/caaddr_1': {}, 'GET /api/medusa/store/customers/me': MOI });
    const bureau = { ...SITE, id: 'caaddr_2', libelle: 'Bureau' };
    const nouvelle = { ...SITE, id: 'adr-123', libelle: 'Chalet' };
    await synchroniserAdresses([SITE, bureau], [{ ...SITE, ville: 'Laval' }, nouvelle]);
    expect(appels.map((a) => `${a.methode} ${a.url.split('?')[0]}`)).toEqual(['DELETE /api/medusa/store/customers/me/addresses/caaddr_2',
      'POST /api/medusa/store/customers/me/addresses/caaddr_1', 'POST /api/medusa/store/customers/me/addresses', 'GET /api/medusa/store/customers/me']);
    const rien = medusa({ 'GET /api/medusa/store/customers/me': MOI });
    await synchroniserAdresses([SITE], [SITE]);
    expect(rien.map((a) => a.methode)).toEqual(['GET']);
  });
});
