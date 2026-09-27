import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PanierProvider, usePanier } from '../src/components/panier/PanierProvider';

function Temoin() {
  const p = usePanier();
  return <span data-testid="pret">{String(p.pret)}</span>;
}

describe('PanierProvider — pret', () => {
  it('est prêt hors du fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('pret').textContent).toBe('true');
  });

  it('est prêt une fois le panier relu', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(screen.getByTestId('pret').textContent).toBe('true');
  });

  it('déclare le champ dans le contrat', () => {
    const source = readFileSync('src/components/panier/PanierProvider.tsx', 'utf8');
    expect(source).toMatch(/nombre: number;\s*pret: boolean;/);
    expect(source).toContain('pret: true');
  });
});
