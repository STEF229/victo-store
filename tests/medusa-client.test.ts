import { afterEach, describe, expect, it, vi } from 'vitest';
import { CHAMPS_PRODUITS, configMedusa, lireCategoriesMedusa, lireProduitsMedusa } from '../src/lib/medusa/client';

const C = { url: 'http://medusa:9000', cle: 'pk_test', region: 'reg_ca' };
const P = { id: 'p', title: 'P', subtitle: null, handle: 'p', description: null, thumbnail: null };
type Appel = { url: string; init: RequestInit | undefined };
function simuler(corps: unknown[], statut = 200): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    appels.push({ url, init });
    return { ok: statut < 400, status: statut, json: async () => corps.shift() };
  });
  return appels;
}
afterEach(() => { vi.unstubAllGlobals(); });

describe('Medusa — configuration', () => {
  it('lit les trois variables, et retire la barre finale de l’adresse', () => {
    expect(configMedusa({ MEDUSA_URL: 'http://m:9000/', MEDUSA_CLE: 'k', MEDUSA_REGION: 'r' })).toEqual({ url: 'http://m:9000', cle: 'k', region: 'r' });
    expect(configMedusa({ MEDUSA_URL: 'http://m:9000', MEDUSA_CLE: 'k' })).toBeNull();
  });
});

describe('Medusa — lecture des produits', () => {
  it('lit page par page, avec la clé, la région, les champs et le cache', async () => {
    const appels = simuler([{ products: Array.from({ length: 100 }, () => P), count: 150 }, { products: Array.from({ length: 50 }, () => P), count: 150 }]);
    expect(await lireProduitsMedusa(C)).toHaveLength(150);
    const adresses = appels.map((a) => new URL(a.url));
    expect(adresses.map((u) => u.searchParams.get('offset'))).toEqual(['0', '100']);
    expect(adresses.every((u) => u.pathname === '/store/products' && u.searchParams.get('region_id') === 'reg_ca' && u.searchParams.get('fields') === CHAMPS_PRODUITS)).toBe(true);
    expect(appels.every((a) => (a.init?.headers as Record<string, string>)['x-publishable-api-key'] === 'pk_test')).toBe(true);
    expect(appels.every((a) => (a.init as { next?: { revalidate?: number } } | undefined)?.next?.revalidate === 60)).toBe(true);
  });

  it('s’arrête sur une page vide', async () => {
    simuler([{ products: [], count: 5 }]);
    expect(await lireProduitsMedusa(C)).toEqual([]);
  });

  it('signale un refus de Medusa', async () => {
    simuler([{}], 500);
    await expect(lireProduitsMedusa(C)).rejects.toThrow('500');
  });

  it('lit les catégories', async () => {
    const appels = simuler([{ product_categories: [{ id: 'c', name: 'Course', handle: 'course', parent_category_id: null }] }]);
    expect((await lireCategoriesMedusa(C)).map((c) => c.handle)).toEqual(['course']);
    expect(new URL(appels.map((a) => a.url).join('')).pathname).toBe('/store/product-categories');
  });
});
