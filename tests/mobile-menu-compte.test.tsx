import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';
import { MenuCompte } from '../src/components/compte/MenuCompte';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('menu de l’espace client — téléphone', () => {
  it('tient sur une ligne qui défile', () => {
    render(<MenuCompte actif="favoris" />);
    const menu = screen.getByTestId('menu-compte');
    for (const k of ['flex-col', 'max-sm:flex-row', 'max-sm:overflow-x-auto']) expect(classes(menu), k).toContain(k);
  });

  it('garde le style des entrées et les empêche de se couper', () => {
    render(<MenuCompte actif="favoris" />);
    const actif = screen.getByRole('link', { name: 'Favoris' });
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif), k).toContain(k);
    for (const k of ['max-sm:shrink-0', 'max-sm:whitespace-nowrap']) expect(classes(actif), k).toContain(k);
    expect(classes(screen.getByRole('button', { name: 'Se déconnecter' }))).toContain('max-sm:shrink-0');
  });
});
