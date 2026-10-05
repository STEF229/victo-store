import { readFileSync } from 'node:fs';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { chargerCatalogue } from '../src/lib/catalogue-source';
import { listerMarques, listerProduits } from '../src/lib/donnees';

const reel = JSON.parse(readFileSync('tests/fixtures/medusa-essai.json', 'utf8')) as {
  produit_vu_par_la_boutique: { products: unknown[] };
  categories_vues_par_la_boutique: { product_categories: unknown[] };
};
const MEDUSA = { CATALOGUE_SOURCE: 'medusa', MEDUSA_URL: 'http://medusa:9000', MEDUSA_CLE: 'pk_test', MEDUSA_REGION: 'reg_ca' };
afterEach(() => { vi.unstubAllGlobals(); vi.restoreAllMocks(); });

describe('source du catalogue', () => {
  it('donne la démonstration par défaut', async () => {
    const c = await chargerCatalogue({});
    expect(c.source).toBe('demo');
    expect(c.produits).toEqual(listerProduits());
    expect(c.marques).toEqual(listerMarques());
  });

  it('lit Medusa quand on le demande', async () => {
    vi.stubGlobal('fetch', async (url: string) => ({
      ok: true, status: 200,
      json: async () => (url.includes('/store/products') ? { products: reel.produit_vu_par_la_boutique.products, count: 1 } : reel.categories_vues_par_la_boutique),
    }));
    const c = await chargerCatalogue(MEDUSA);
    expect(c.source).toBe('medusa');
    expect(c.produits.map((p) => [p.slug, p.prixCents, p.categorie])).toEqual([['essai-air-zoom-pegasus-41', 12900, 'chaussures']]);
    expect(c.marques).toHaveLength(6);
  });

  it('revient à la démonstration si Medusa ne répond pas, et le signale', async () => {
    const journal = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    vi.stubGlobal('fetch', async () => { throw new Error('connexion refusée'); });
    expect((await chargerCatalogue(MEDUSA)).source).toBe('demo');
    expect(journal).toHaveBeenCalled();
  });

  it('revient à la démonstration si la configuration est incomplète, et le signale', async () => {
    const journal = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    expect((await chargerCatalogue({ CATALOGUE_SOURCE: 'medusa' })).source).toBe('demo');
    expect(journal).toHaveBeenCalled();
  });
});
