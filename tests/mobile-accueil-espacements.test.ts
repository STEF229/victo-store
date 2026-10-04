import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('accueil — espacements sur téléphone', () => {
  it('réduit les espacements entre les sections', () => {
    const s = readFileSync('src/app/page.tsx', 'utf8');
    expect(s).toContain('px-5 py-24 lg:px-20 max-sm:py-12"');
    expect(s.split('px-5 pb-24 lg:px-20 max-sm:pb-12"').length - 1).toBe(2);
    expect(s).toContain('px-5 py-14 lg:px-20 max-sm:py-8"');
  });
});
