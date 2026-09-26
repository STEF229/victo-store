import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — fournisseur du panier', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe tout le site dans PanierProvider', () => {
    expect(source).toContain("import { PanierProvider } from '@/components/panier/PanierProvider';");
    expect(source).toContain('<PanierProvider>{children}</PanierProvider>');
  });

  it('reste un composant serveur, avec ses métadonnées', () => {
    expect(source).not.toContain('use client');
    expect(source).toContain('export const metadata');
    expect(source).toContain('suppressHydrationWarning');
    expect(source).toContain("import './globals.css';");
  });
});
