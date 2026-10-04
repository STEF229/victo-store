import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

describe('infolettre — téléphone', () => {
  it('garde la hauteur du champ dans le formulaire en colonne', () => {
    render(<Infolettre />);
    const classes = (screen.getByLabelText('Votre courriel').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['h-14', 'max-sm:flex-none']) expect(classes, k).toContain(k);
  });
});
