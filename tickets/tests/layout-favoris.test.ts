import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — favoris', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe le panier et la session dans les favoris', () => {
    expect(source).toContain("import { FavorisProvider } from '@/components/favoris/FavorisProvider';");
    expect(source).toMatch(/<FavorisProvider>\s*<PanierProvider>[\s\S]*<SessionProvider>\{children\}<\/SessionProvider>[\s\S]*<\/PanierProvider>\s*<\/FavorisProvider>/);
    expect(source).not.toContain('use client');
  });
});
