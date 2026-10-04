import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';

describe('bonnes affaires — défilement', () => {
  it('masque la barre de défilement de la bande', () => {
    render(<SectionBonnesAffaires produits={[]} />);
    const classes = (screen.getByTestId('rail').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['overflow-x-auto', '[scrollbar-width:none]', '[&::-webkit-scrollbar]:hidden']) expect(classes, k).toContain(k);
  });
});
