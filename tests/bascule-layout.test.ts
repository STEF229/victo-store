import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync('src/app/layout.tsx', 'utf8');

describe('bascule — le gabarit charge le catalogue', () => {
  it('charge le catalogue côté serveur', () => {
    expect(SOURCE).toContain("import { CatalogueProvider } from '@/components/catalogue/CatalogueProvider';");
    expect(SOURCE).toContain("import { chargerCatalogue } from '@/lib/catalogue-source';");
    expect(SOURCE).toMatch(/export default async function RootLayout\(/);
    expect(SOURCE).toContain('const catalogue = await chargerCatalogue();');
  });

  it('l’entoure autour des fournisseurs existants', () => {
    const ouvre = SOURCE.indexOf('<CatalogueProvider valeur={catalogue}>');
    const favoris = SOURCE.indexOf('<FavorisProvider>');
    expect(ouvre).toBeGreaterThan(-1);
    expect(favoris).toBeGreaterThan(ouvre);
    expect(SOURCE.indexOf('</CatalogueProvider>')).toBeGreaterThan(SOURCE.indexOf('</FavorisProvider>'));
  });
});
