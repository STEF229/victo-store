import { createEvent, fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ChampRecherche } from '../src/components/recherche/ChampRecherche';

describe('recherche — clic dans les suggestions', () => {
  it('garde le focus dans le champ, pour que le clic arrive', () => {
    render(<ChampRecherche />);
    fireEvent.change(screen.getByLabelText('Rechercher un produit'), { target: { value: 'nike' } });
    const zone = screen.getByTestId('suggestions-recherche');
    const lien = screen.getAllByRole('link').find((l) => zone.contains(l)) ?? zone;
    const appui = createEvent.mouseDown(lien);
    fireEvent(lien, appui);
    expect(appui.defaultPrevented).toBe(true);
  });
});
