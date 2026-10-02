import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('panier — chargement sur téléphone', () => {
  it('réduit la réserve de hauteur sous 640 px', () => {
    const source = readFileSync('src/components/panier/VuePanier.tsx', 'utf8');
    expect(source).toContain('data-testid="panier-chargement"');
    expect(source).toContain('className="min-h-[320px] max-sm:min-h-[96px]"');
  });
});
