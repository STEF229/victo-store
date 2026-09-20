import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Price } from '../src/components/ui/Price';

const NB = '\u00A0';
const MOINS = '\u2212';

// On compare textContent directement : toHaveTextContent de jest-dom normalise
// les espaces, et \s en JavaScript englobe l'espace insécable U+00A0. Le matcher
// transformerait donc l'insécable en espace ordinaire et rendrait le test
// impossible à satisfaire.

describe('Price — prix simple', () => {
  it('affiche le prix courant formaté', () => {
    render(<Price amount={12999} />);
    expect(screen.getByTestId('prix-courant').textContent).toBe(`129,99${NB}$`);
  });

  it("n'affiche ni prix barré ni remise", () => {
    render(<Price amount={12999} />);
    expect(screen.queryByTestId('prix-compare')).toBeNull();
    expect(screen.queryByTestId('prix-remise')).toBeNull();
  });

  it('ne se marque pas en promotion', () => {
    render(<Price amount={12999} />);
    expect(screen.getByTestId('prix')).toHaveAttribute('data-promo', 'false');
  });
});

describe('Price — prix en promotion', () => {
  it('affiche le prix barré dans un élément <s>', () => {
    render(<Price amount={12600} compareAt={18000} />);
    const barre = screen.getByTestId('prix-compare');
    expect(barre.tagName).toBe('S');
    expect(barre.textContent).toBe(`180,00${NB}$`);
  });

  it('calcule et affiche le pourcentage de remise', () => {
    render(<Price amount={12600} compareAt={18000} />);
    expect(screen.getByTestId('prix-remise').textContent).toBe(`${MOINS}30${NB}%`);
  });

  it('arrondit le pourcentage à l’entier le plus proche', () => {
    render(<Price amount={6667} compareAt={10000} />);
    expect(screen.getByTestId('prix-remise').textContent).toBe(`${MOINS}33${NB}%`);
  });

  it('se marque en promotion', () => {
    render(<Price amount={12600} compareAt={18000} />);
    expect(screen.getByTestId('prix')).toHaveAttribute('data-promo', 'true');
  });
});

describe('Price — cas limites', () => {
  it('ignore un compareAt égal au prix', () => {
    render(<Price amount={12999} compareAt={12999} />);
    expect(screen.queryByTestId('prix-compare')).toBeNull();
    expect(screen.getByTestId('prix')).toHaveAttribute('data-promo', 'false');
  });

  it('ignore un compareAt inférieur au prix', () => {
    render(<Price amount={12999} compareAt={9999} />);
    expect(screen.queryByTestId('prix-compare')).toBeNull();
  });

  it('gère un prix à zéro', () => {
    render(<Price amount={0} />);
    expect(screen.getByTestId('prix-courant').textContent).toBe(`0,00${NB}$`);
  });
});
