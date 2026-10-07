import { afterEach, describe, expect, it, vi } from 'vitest';
import { operationsSynchro, synchroniserPanier } from '../src/lib/medusa/panier-medusa';

type Appel = { url: string; methode: string; corps: unknown };
function medusa(reponses: Record<string, unknown>): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    const methode = init?.method ?? 'GET';
    appels.push({ url, methode, corps: init?.body ? JSON.parse(String(init.body)) : undefined });
    const cle = `${methode} ${url.split('?')[0]}`;
    const corps = reponses[cle];
    return corps === undefined ? new Response('{}', { status: 404 }) : new Response(JSON.stringify(corps), { status: 200 });
  });
  return appels;
}
afterEach(() => { vi.unstubAllGlobals(); });

describe('panier Medusa — opérations', () => {
  it('ajoute, modifie et retire ce qu’il faut', () => {
    const ops = operationsSynchro(
      [{ variantId: 'v1', quantite: 2 }, { variantId: 'v3', quantite: 1 }],
      [{ id: 'l1', variant_id: 'v1', quantity: 1 }, { id: 'l2', variant_id: 'v2', quantity: 4 }],
    );
    expect(ops).toEqual({ ajouter: [{ variantId: 'v3', quantite: 1 }], modifier: [{ ligneId: 'l1', quantite: 2 }], retirer: ['l2'] });
    expect(operationsSynchro([{ variantId: 'v1', quantite: 1 }], [{ id: 'l1', variant_id: 'v1', quantity: 1 }])).toEqual({ ajouter: [], modifier: [], retirer: [] });
  });
});

describe('panier Medusa — synchronisation par la passerelle', () => {
  it('ne crée rien pour un panier vide', async () => {
    const appels = medusa({});
    expect(await synchroniserPanier(null, [])).toBe('');
    expect(appels).toHaveLength(0);
  });

  it('crée le panier puis ajoute les lignes', async () => {
    const appels = medusa({ 'POST /api/medusa/store/carts': { cart: { id: 'cart_1', items: [] } }, 'POST /api/medusa/store/carts/cart_1/line-items': { cart: { id: 'cart_1' } } });
    expect(await synchroniserPanier(null, [{ variantId: 'v1', quantite: 2 }])).toBe('cart_1');
    expect(appels.map((a) => `${a.methode} ${a.url}`)).toEqual(['POST /api/medusa/store/carts', 'POST /api/medusa/store/carts/cart_1/line-items']);
    expect(appels.map((a) => a.corps)).toEqual([{}, { variant_id: 'v1', quantity: 2 }]);
  });

  it('réutilise le panier existant et le met à jour', async () => {
    const appels = medusa({
      'GET /api/medusa/store/carts/cart_9': { cart: { id: 'cart_9', items: [{ id: 'l1', variant_id: 'v1', quantity: 1 }, { id: 'l2', variant_id: 'v2', quantity: 1 }] } },
      'POST /api/medusa/store/carts/cart_9/line-items/l1': { cart: { id: 'cart_9' } },
      'DELETE /api/medusa/store/carts/cart_9/line-items/l2': { deleted: true },
    });
    expect(await synchroniserPanier('cart_9', [{ variantId: 'v1', quantite: 3 }])).toBe('cart_9');
    expect(appels.map((a) => `${a.methode} ${a.url.split('?')[0]}`)).toEqual([
      'GET /api/medusa/store/carts/cart_9', 'POST /api/medusa/store/carts/cart_9/line-items/l1', 'DELETE /api/medusa/store/carts/cart_9/line-items/l2']);
  });

  it('repart d’un nouveau panier quand l’ancien est introuvable ou déjà commandé', async () => {
    medusa({ 'POST /api/medusa/store/carts': { cart: { id: 'cart_2', items: [] } }, 'POST /api/medusa/store/carts/cart_2/line-items': {} });
    expect(await synchroniserPanier('cart_perdu', [{ variantId: 'v1', quantite: 1 }])).toBe('cart_2');
    medusa({ 'GET /api/medusa/store/carts/cart_fini': { cart: { id: 'cart_fini', completed_at: '2026-10-05', items: [] } },
             'POST /api/medusa/store/carts': { cart: { id: 'cart_3', items: [] } }, 'POST /api/medusa/store/carts/cart_3/line-items': {} });
    expect(await synchroniserPanier('cart_fini', [{ variantId: 'v1', quantite: 1 }])).toBe('cart_3');
  });
});
