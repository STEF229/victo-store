// @vitest-environment node
import { afterEach, describe, expect, it, vi } from 'vitest';
import { COOKIE_JETON, cheminAutorise, lireJeton, relayer } from '../src/lib/medusa/passerelle';

const ENV = { MEDUSA_URL: 'http://medusa:9000/', MEDUSA_CLE: 'pk_test', MEDUSA_REGION: 'reg_ca' };
type Appel = { url: string; init: RequestInit | undefined };
function medusa(statut: number, corps: unknown): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    appels.push({ url, init });
    return new Response(JSON.stringify(corps), { status: statut, headers: { 'content-type': 'application/json' } });
  });
  return appels;
}
const requete = (chemin: string, methode = 'GET', corps?: unknown, cookie?: string) =>
  new Request(`http://boutique/api/medusa/${chemin}`, {
    method: methode, ...(corps !== undefined ? { body: JSON.stringify(corps) } : {}), ...(cookie ? { headers: { cookie } } : {}),
  });
const entete = (a: Appel, nom: string) => (a.init?.headers as Record<string, string> | undefined)?.[nom];
afterEach(() => { vi.unstubAllGlobals(); });

describe('passerelle — ce qui passe', () => {
  it('n’autorise que la boutique et l’authentification des clients', () => {
    expect(cheminAutorise(['store', 'carts'])).toBe(true);
    expect(cheminAutorise(['auth', 'customer', 'emailpass'])).toBe(true);
    expect(cheminAutorise(['admin', 'products'])).toBe(false);
    expect(cheminAutorise(['auth', 'user', 'emailpass'])).toBe(false);
    expect(cheminAutorise(['store', '..', 'admin'])).toBe(false);
  });

  it('refuse une adresse d’administration sans appeler Medusa', async () => {
    const appels = medusa(200, {});
    expect((await relayer(requete('admin/products'), ['admin', 'products'], ENV)).status).toBe(404);
    expect(appels).toHaveLength(0);
  });
});

describe('passerelle — relais', () => {
  it('relaie avec la clé publique, la requête et le jeton du cookie', async () => {
    const appels = medusa(200, { products: [] });
    const r = await relayer(requete('store/products?limit=2', 'GET', undefined, `autre=1; ${COOKIE_JETON}=jwt%20client`), ['store', 'products'], ENV);
    expect(r.status).toBe(200);
    expect(await r.json()).toEqual({ products: [] });
    expect(appels.map((a) => a.url)).toEqual(['http://medusa:9000/store/products?limit=2']);
    expect(entete(appels.find(() => true) as Appel, 'x-publishable-api-key')).toBe('pk_test');
    expect(entete(appels.find(() => true) as Appel, 'authorization')).toBe('Bearer jwt client');
  });

  it('ajoute la région Canada à un nouveau panier', async () => {
    const appels = medusa(200, { cart: { id: 'cart_1' } });
    await relayer(requete('store/carts', 'POST', {}), ['store', 'carts'], ENV);
    expect(JSON.parse(String(appels.find(() => true)?.init?.body))).toEqual({ region_id: 'reg_ca' });
  });

  it('garde le jeton de connexion dans un cookie HttpOnly, sans le montrer au navigateur', async () => {
    medusa(200, { token: 'jwt-nouveau' });
    const r = await relayer(requete('auth/customer/emailpass', 'POST', { email: 'a@b.ca', password: 'x' }), ['auth', 'customer', 'emailpass'], ENV);
    expect(await r.json()).toEqual({ connecte: true });
    const cookie = r.headers.get('set-cookie') ?? '';
    for (const k of [`${COOKIE_JETON}=jwt-nouveau`, 'HttpOnly', 'Path=/', 'SameSite=Lax']) expect(cookie).toContain(k);
  });

  it('efface le cookie à la déconnexion', async () => {
    const r = await relayer(requete('deconnexion', 'POST'), ['deconnexion'], ENV);
    expect(r.headers.get('set-cookie') ?? '').toContain('Max-Age=0');
  });

  it('signale une configuration incomplète ou un Medusa injoignable', async () => {
    expect((await relayer(requete('store/carts'), ['store', 'carts'], {})).status).toBe(503);
    vi.stubGlobal('fetch', async () => { throw new Error('refusé'); });
    expect((await relayer(requete('store/carts'), ['store', 'carts'], ENV)).status).toBe(502);
  });

  it('lit le jeton dans les cookies', () => {
    expect(lireJeton(`a=1; ${COOKIE_JETON}=abc`)).toBe('abc');
    expect(lireJeton('a=1')).toBeNull();
    expect(lireJeton(null)).toBeNull();
  });
});
