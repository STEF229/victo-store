// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { GET, revalidate } from '../src/app/api/catalogue/route';
import { listerProduits } from '../src/lib/donnees';

describe('GET /api/catalogue', () => {
  it('renvoie le catalogue en JSON, revalidé chaque minute', async () => {
    const reponse = await GET();
    expect(reponse.status).toBe(200);
    const corps = (await reponse.json()) as { source: string; produits: unknown[]; marques: unknown[] };
    expect(corps.source).toBe('demo');
    expect(corps.produits).toHaveLength(listerProduits().length);
    expect(revalidate).toBe(60);
  });
});
