import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — jamais de défilement horizontal', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');
  const balise = (nom: string) => source.match(new RegExp(`<${nom}\\b[^>]*>`))?.[0] ?? '';

  it('rogne tout débordement horizontal, sur html et body', () => {
    expect(balise('html')).toContain('className="overflow-x-clip"');
    expect(balise('html')).toContain('lang="fr"');
    expect(balise('body')).toContain('className="overflow-x-clip"');
  });

  it('ignore les attributs ajoutés au body par les extensions', () => {
    expect(balise('body')).toContain('suppressHydrationWarning');
  });
});
