import { describe, expect, it } from 'vitest';
import { cssTokens, TOKENS } from '../src/lib/tokens';

const ATTENDUS: Array<[string, string]> = [
  ['--vs-noir', '#101014'],
  ['--vs-blanc', '#FFFFFF'],
  ['--vs-surface', '#F5F5F3'],
  ['--vs-ligne', '#E5E5E1'],
  ['--vs-gris', '#6B6B70'],
  ['--vs-accent', '#0B41CD'],
  ['--vs-accent-fonce', '#082F94'],
  ['--vs-promo', '#E4002B'],
  ['--vs-maxw', '1220px'],
  ['--vs-radius', '6px'],
];

describe('TOKENS — palette VICTO STORE', () => {
  it.each(ATTENDUS)('%s vaut %s', (nom, valeur) => {
    expect(TOKENS[nom as keyof typeof TOKENS]).toBe(valeur);
  });

  it('déclare la typographie Archivo', () => {
    expect(TOKENS['--vs-font-display']).toContain('Archivo');
    expect(TOKENS['--vs-font-display']).toContain('sans-serif');
  });

  it('ne contient aucune clé inattendue', () => {
    expect(Object.keys(TOKENS).sort()).toEqual(
      [...ATTENDUS.map(([n]) => n), '--vs-font-display'].sort(),
    );
  });
});

describe('cssTokens — génération du bloc CSS', () => {
  const css = cssTokens();

  it('ouvre et ferme un bloc :root', () => {
    expect(css.startsWith(':root {')).toBe(true);
    expect(css.trimEnd().endsWith('}')).toBe(true);
  });

  it.each(ATTENDUS)('déclare %s: %s;', (nom, valeur) => {
    expect(css).toContain(`  ${nom}: ${valeur};`);
  });

  it('déclare la police', () => {
    expect(css).toContain(`  --vs-font-display: ${TOKENS['--vs-font-display']};`);
  });

  it('respecte l’ordre des clés de TOKENS', () => {
    const positions = Object.keys(TOKENS).map((k) => css.indexOf(k));
    expect(positions).toEqual([...positions].sort((a, b) => a - b));
    expect(positions.every((p) => p >= 0)).toBe(true);
  });

  it('dérive ses valeurs de TOKENS', () => {
    for (const [nom, valeur] of Object.entries(TOKENS)) {
      expect(css).toContain(`${nom}: ${valeur};`);
    }
  });
});

describe('aucun reste de la marque OUTREMER', () => {
  const tout = (JSON.stringify(TOKENS) + cssTokens()).toLowerCase();

  it.each(['--klein', '--paper', '--bone', '--midnight', 'fraunces', 'bricolage', '#1f2ec8', '#18239a'])(
    'ne contient plus %s',
    (interdit) => {
      expect(tout).not.toContain(interdit);
    },
  );
});
