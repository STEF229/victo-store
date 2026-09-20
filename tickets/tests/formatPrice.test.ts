import { describe, expect, it } from 'vitest';
import { formatPrice } from '../src/lib/formatPrice';

// Espace insécable U+00A0 : séparateur de milliers ET séparateur avant le $.
const NB = '\u00A0';

describe('formatPrice — montants positifs', () => {
  it('formate zéro avec deux décimales', () => {
    expect(formatPrice(0)).toBe(`0,00${NB}$`);
  });

  it('formate les montants sous 1 $ avec un zéro entier', () => {
    expect(formatPrice(5)).toBe(`0,05${NB}$`);
    expect(formatPrice(99)).toBe(`0,99${NB}$`);
  });

  it('formate un montant courant', () => {
    expect(formatPrice(1250)).toBe(`12,50${NB}$`);
    expect(formatPrice(4999)).toBe(`49,99${NB}$`);
  });

  it("n'ajoute pas de séparateur sous 1000", () => {
    expect(formatPrice(99900)).toBe(`999,00${NB}$`);
    expect(formatPrice(99999)).toBe(`999,99${NB}$`);
  });

  it('groupe les milliers par trois', () => {
    expect(formatPrice(100000)).toBe(`1${NB}000,00${NB}$`);
    expect(formatPrice(123456)).toBe(`1${NB}234,56${NB}$`);
    expect(formatPrice(12345678)).toBe(`123${NB}456,78${NB}$`);
    expect(formatPrice(100000000)).toBe(`1${NB}000${NB}000,00${NB}$`);
  });
});

describe('formatPrice — montants négatifs', () => {
  it('place le signe en tête', () => {
    expect(formatPrice(-1250)).toBe(`-12,50${NB}$`);
    expect(formatPrice(-5)).toBe(`-0,05${NB}$`);
    expect(formatPrice(-123456)).toBe(`-1${NB}234,56${NB}$`);
  });

  it('traite -0 comme 0', () => {
    expect(formatPrice(-0)).toBe(`0,00${NB}$`);
  });
});

describe('formatPrice — typographie', () => {
  it("n'utilise jamais l'espace ASCII", () => {
    for (const cents of [0, 5, 1250, 123456, 100000000, -123456]) {
      expect(formatPrice(cents)).not.toContain(' ');
    }
  });

  it('utilise la virgule comme séparateur décimal et un seul $', () => {
    const out = formatPrice(123456);
    expect(out.split(',')).toHaveLength(2);
    expect(out.split('$')).toHaveLength(2);
    expect(out.endsWith('$')).toBe(true);
    expect(out).not.toContain('.');
  });

  it('donne toujours exactement deux décimales', () => {
    for (const cents of [0, 1, 10, 100, 1000, 10000, 999999]) {
      expect(formatPrice(cents)).toMatch(/,\d{2}\u00A0\$$/u);
    }
  });
});

describe('formatPrice — entrées invalides', () => {
  it('refuse les non-entiers', () => {
    expect(() => formatPrice(12.5)).toThrow(TypeError);
    expect(() => formatPrice(-0.1)).toThrow(TypeError);
  });

  it('refuse NaN et les infinis', () => {
    expect(() => formatPrice(Number.NaN)).toThrow(TypeError);
    expect(() => formatPrice(Number.POSITIVE_INFINITY)).toThrow(TypeError);
    expect(() => formatPrice(Number.NEGATIVE_INFINITY)).toThrow(TypeError);
  });

  it('refuse les types non numériques', () => {
    expect(() => formatPrice('1250' as unknown as number)).toThrow(TypeError);
    expect(() => formatPrice(null as unknown as number)).toThrow(TypeError);
    expect(() => formatPrice(undefined as unknown as number)).toThrow(TypeError);
    expect(() => formatPrice({} as unknown as number)).toThrow(TypeError);
  });
});
