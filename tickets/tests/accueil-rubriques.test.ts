import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('accueil — pastilles des rubriques', () => {
  it('les affiche juste avant les bonnes affaires', () => {
    const s = readFileSync('src/app/page.tsx', 'utf8');
    expect(s).toContain("import { RubriquesRapides } from '@/components/accueil/RubriquesRapides';");
    const pastilles = s.indexOf('<RubriquesRapides items={NAV} />');
    expect(pastilles).toBeGreaterThan(-1);
    expect(pastilles).toBeLessThan(s.indexOf('<SectionBonnesAffaires'));
    expect(pastilles).toBeGreaterThan(s.indexOf('<BandeMarques'));
  });
});
