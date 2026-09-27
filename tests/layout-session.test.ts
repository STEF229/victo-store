import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — session', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe le site dans la session, à l’intérieur du panier', () => {
    expect(source).toContain("import { SessionProvider } from '@/components/compte/SessionProvider';");
    expect(source).toMatch(/<PanierProvider>\s*<SessionProvider>\{children\}<\/SessionProvider>\s*<\/PanierProvider>/);
    expect(source).not.toContain('use client');
  });
});
