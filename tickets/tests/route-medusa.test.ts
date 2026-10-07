// @vitest-environment node
import { afterEach, describe, expect, it, vi } from 'vitest';
import { DELETE, GET, POST } from '../src/app/api/medusa/[...chemin]/route';

afterEach(() => { vi.unstubAllGlobals(); vi.unstubAllEnvs(); });

describe('route /api/medusa/…', () => {
  it('confie chaque méthode à la passerelle', async () => {
    vi.stubEnv('MEDUSA_URL', 'http://medusa:9000');
    vi.stubEnv('MEDUSA_CLE', 'pk_test');
    const urls: string[] = [];
    vi.stubGlobal('fetch', async (url: string) => { urls.push(url); return new Response('{"regions":[]}', { status: 200 }); });
    const contexte = { params: Promise.resolve({ chemin: ['store', 'regions'] }) };
    expect((await GET(new Request('http://boutique/api/medusa/store/regions'), contexte)).status).toBe(200);
    expect(urls).toEqual(['http://medusa:9000/store/regions']);
    expect(POST).toBe(GET);
    expect(DELETE).toBe(GET);
  });
});
