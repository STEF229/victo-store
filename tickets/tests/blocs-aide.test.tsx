import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { AComplete, Encadre, Etapes, Liste, Paragraphe, Section, Tableau } from '../src/components/aide/blocs-aide';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('blocs des pages d’aide', () => {
  it('titre une section, avec son texte et sa liste', () => {
    render(<Section titre="Délais"><Paragraphe>Sous 48 heures.</Paragraphe><Liste elements={['Un', 'Deux']} /></Section>);
    expect(screen.getByRole('heading', { level: 2, name: 'Délais' })).toBeInTheDocument();
    expect(screen.getByText('Sous 48 heures.').tagName).toBe('P');
    expect(screen.getAllByRole('listitem').map((li: HTMLElement) => li.textContent)).toEqual(['Un', 'Deux']);
  });

  it('colore l’encadré, en bleu ou en alerte', () => {
    const { unmount } = render(<Encadre icone={<span />} titre="Offerte">Sans minimum.</Encadre>);
    expect(classes(screen.getByTestId('encadre'))).toContain('bg-[#EEF1F8]');
    expect(screen.getByText('Offerte')).toBeInTheDocument();
    unmount();
    render(<Encadre icone={<span />} titre="À valider" alerte>Juriste.</Encadre>);
    expect(classes(screen.getByTestId('encadre'))).toContain('bg-[#FFD3DB]');
  });

  it('met la première colonne du tableau en gras', () => {
    render(<Tableau entetes={['Destination', 'Délai']} lignes={[['Québec', '2 à 4 jours'], ['Ontario', '3 à 5 jours']]} />);
    expect(screen.getAllByRole('columnheader').map((th: HTMLElement) => th.textContent)).toEqual(['Destination', 'Délai']);
    const cellules = screen.getAllByRole('cell');
    expect(cellules.map((td: HTMLElement) => td.textContent)).toEqual(['Québec', '2 à 4 jours', 'Ontario', '3 à 5 jours']);
    expect(classes(cellules[0] as HTMLElement)).toContain('font-bold');
    expect(classes(cellules[1] as HTMLElement)).not.toContain('font-bold');
  });

  it('numérote les étapes', () => {
    render(<Etapes etapes={[{ titre: 'Déclarez', texte: 'a' }, { titre: 'Emballez', texte: 'b' }, { titre: 'Déposez', texte: 'c' }]} />);
    const etapes = screen.getAllByRole('listitem');
    expect(etapes.map((e: HTMLElement) => within(e).getByText(/^[0-9]$/).textContent)).toEqual(['1', '2', '3']);
  });

  it('marque ce qui reste à compléter', () => {
    render(<p>Numéro : <AComplete>NEQ</AComplete></p>);
    const marque = screen.getByText('NEQ');
    expect(marque.tagName).toBe('MARK');
    expect(classes(marque)).toContain('text-[var(--vs-accent)]');
  });
});
