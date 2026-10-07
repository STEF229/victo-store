import { describe, expect, it } from 'vitest';
import { quand } from '../src/lib/quand';

describe('quand', () => {
  it('exécute la suite tout de suite pour un résultat immédiat', () => {
    const vus: number[] = [];
    quand(4, (v) => vus.push(v));
    expect(vus).toEqual([4]);
  });

  it('attend une promesse', async () => {
    const vus: string[] = [];
    quand(Promise.resolve('ok'), (v) => vus.push(v));
    expect(vus).toEqual([]);
    await Promise.resolve(); await Promise.resolve();
    expect(vus).toEqual(['ok']);
  });
});
