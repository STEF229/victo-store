import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PageSousCategorie } from '../src/components/catalogue/PageSousCategorie';

const pastilles = (nom: string) => within(screen.getByRole('navigation', { name: nom })).getAllByRole('link');

describe('PageSousCategorie', () => {
  it('titre la page et propose ses enfants, « Tout » marqué', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures']} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Chaussures Homme');
    const liens = pastilles('Sous-catégories de Chaussures');
    expect(liens.map((l: HTMLElement) => l.textContent)).toEqual(['Tout', 'Sneakers', 'Course', 'Basket', 'Sandales']);
    expect(liens.find((l: HTMLElement) => l.getAttribute('aria-current') === 'page')?.textContent).toBe('Tout');
  });

  it('sur une feuille, propose ses sœurs et se marque elle-même', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures', 'course']} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Course Homme');
    const liens = pastilles('Sous-catégories de Course');
    expect(liens.find((l: HTMLElement) => l.getAttribute('aria-current') === 'page')?.getAttribute('href')).toBe('/homme/chaussures/course');
    expect(liens.find((l: HTMLElement) => l.textContent === 'Tout')?.getAttribute('href')).toBe('/homme/chaussures');
  });

  it('remonte par le fil d’Ariane', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures', 'course']} />);
    const fil = screen.getByTestId('fil-ariane');
    expect(within(fil).getByRole('link', { name: 'Homme' })).toHaveAttribute('href', '/homme');
    expect(within(fil).getByRole('link', { name: 'Chaussures' })).toHaveAttribute('href', '/homme/chaussures');
  });

  it('refuse un chemin inconnu ou vide', () => {
    expect(() => render(<PageSousCategorie rubrique="homme" chemin={['inconnu']} />)).toThrow();
    expect(() => render(<PageSousCategorie rubrique="homme" chemin={[]} />)).toThrow();
  });
});
