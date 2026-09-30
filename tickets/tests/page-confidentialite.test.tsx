import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageConfidentialite from '../src/app/confidentialite/page';

describe('page Confidentialité', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageConfidentialite />);
    expect(screen.getByRole('heading', { level: 1, name: 'Confidentialité' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Confidentialité' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Responsable de la protection des renseignements personnels', 'Ce que nous recueillons, et pourquoi',
      'Votre consentement', 'Qui y a accès', 'Durée de conservation', 'Vos droits', 'Incidents de confidentialité',
    ]);
  });

  it('dit ce qui est recueilli, et ce qui reste à compléter', () => {
    render(<PageConfidentialite />);
    expect(screen.getAllByRole('row')).toHaveLength(6);
    expect(screen.getByText("Commission d'accès à l'information du Québec", { exact: false })).toBeInTheDocument();
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(4);
  });
});
