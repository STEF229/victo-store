// @vitest-environment node
import { describe, expect, it } from 'vitest';
import config from '../next.config';

describe('next.config — photos de Medusa', () => {
  it('relaie /medusa-images vers le dossier static de Medusa', async () => {
    expect(config.rewrites).toBeTypeOf('function');
    const regles = config.rewrites ? await config.rewrites() : [];
    const liste = Array.isArray(regles) ? regles : [...regles.beforeFiles, ...regles.afterFiles, ...regles.fallback];
    const regle = liste.find((r) => r.source === '/medusa-images/:chemin*');
    expect(regle?.destination.endsWith('/static/:chemin*')).toBe(true);
    expect(config.allowedDevOrigins).toEqual(['192.168.40.32']);
  });
});
