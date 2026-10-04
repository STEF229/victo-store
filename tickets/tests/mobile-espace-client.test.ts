import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('espace client — téléphone', () => {
  it('réduit l’écart entre le menu et le contenu', () => {
    expect(readFileSync('src/components/compte/EspaceClient.tsx', 'utf8')).toContain('lg:gap-14 max-sm:gap-6"');
  });
});
