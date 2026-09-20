import { describe, expect, it } from 'vitest';
import { clampQuantity } from '../src/lib/clampQuantity';

describe('clampQuantity — bornes par défaut (1 à 99)', () => {
  it('laisse passer une valeur valide', () => {
    expect(clampQuantity(1)).toBe(1);
    expect(clampQuantity(5)).toBe(5);
    expect(clampQuantity(99)).toBe(99);
  });

  it('remonte au minimum', () => {
    expect(clampQuantity(0)).toBe(1);
    expect(clampQuantity(-3)).toBe(1);
    expect(clampQuantity(-1000)).toBe(1);
  });

  it('redescend au maximum', () => {
    expect(clampQuantity(100)).toBe(99);
    expect(clampQuantity(1_000_000)).toBe(99);
  });
});

describe('clampQuantity — valeurs non entières', () => {
  it('arrondit vers le bas avant de borner', () => {
    expect(clampQuantity(3.7)).toBe(3);
    expect(clampQuantity(1.999)).toBe(1);
    expect(clampQuantity(99.9)).toBe(99);
  });

  it('remonte au minimum après arrondi', () => {
    expect(clampQuantity(0.5)).toBe(1);
    expect(clampQuantity(0.999)).toBe(1);
  });

  it('arrondit vers le bas aussi pour les négatifs', () => {
    expect(clampQuantity(-2.5, -10, 10)).toBe(-3);
  });
});

describe('clampQuantity — valeurs dégénérées', () => {
  it('retourne le minimum pour NaN', () => {
    expect(clampQuantity(Number.NaN)).toBe(1);
    expect(clampQuantity(Number.NaN, 4, 8)).toBe(4);
  });

  it('retourne le minimum pour une valeur non numérique', () => {
    expect(clampQuantity('7' as unknown as number)).toBe(1);
    expect(clampQuantity(null as unknown as number)).toBe(1);
    expect(clampQuantity(undefined as unknown as number)).toBe(1);
  });

  it('borne les infinis', () => {
    expect(clampQuantity(Number.POSITIVE_INFINITY)).toBe(99);
    expect(clampQuantity(Number.NEGATIVE_INFINITY)).toBe(1);
  });
});

describe('clampQuantity — bornes personnalisées', () => {
  it('respecte min et max fournis', () => {
    expect(clampQuantity(5, 2, 4)).toBe(4);
    expect(clampQuantity(1, 2, 4)).toBe(2);
    expect(clampQuantity(3, 2, 4)).toBe(3);
  });

  it('accepte un minimum à zéro', () => {
    expect(clampQuantity(0, 0, 10)).toBe(0);
    expect(clampQuantity(-1, 0, 10)).toBe(0);
  });

  it('accepte min === max', () => {
    expect(clampQuantity(50, 7, 7)).toBe(7);
  });

  it('lève RangeError si min > max', () => {
    expect(() => clampQuantity(5, 10, 2)).toThrow(RangeError);
  });

  it('lève TypeError si les bornes ne sont pas des entiers finis', () => {
    expect(() => clampQuantity(5, 1.5, 10)).toThrow(TypeError);
    expect(() => clampQuantity(5, 1, 10.5)).toThrow(TypeError);
    expect(() => clampQuantity(5, Number.NaN, 10)).toThrow(TypeError);
    expect(() => clampQuantity(5, 1, Number.POSITIVE_INFINITY)).toThrow(TypeError);
  });

  it('valide les bornes avant de regarder la valeur', () => {
    expect(() => clampQuantity(Number.NaN, 10, 2)).toThrow(RangeError);
  });
});

describe('clampQuantity — pureté', () => {
  it('retourne toujours la même sortie pour la même entrée', () => {
    const results = [clampQuantity(42), clampQuantity(42), clampQuantity(42)];
    expect(new Set(results).size).toBe(1);
  });
});
