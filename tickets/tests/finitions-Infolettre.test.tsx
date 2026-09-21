import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const bloc = () => screen.getByRole('heading', { level: 2 }).closest('.rounded-\\[28px\\]') as Element;

describe('Infolettre — marges', () => {
  it.each(['p-8', 'sm:p-12', 'lg:p-16'])('le bandeau porte %s', (k) => {
    render(<Infolettre />);
    expect(classes(bloc())).toContain(k);
  });

  it.each(['text-3xl', 'font-black', 'tracking-tight', 'lg:text-4xl'])('le titre porte %s', (k) => {
    render(<Infolettre />);
    expect(classes(screen.getByRole('heading', { level: 2 }))).toContain(k);
  });
});

describe('Infolettre — champ et bouton', () => {
  it.each(['h-14', 'w-full', 'min-w-0', 'flex-1', 'rounded-full', 'bg-[var(--vs-blanc)]', 'px-6'])(
    'le champ porte %s',
    (k) => {
      render(<Infolettre />);
      expect(classes(screen.getByLabelText('Votre courriel'))).toContain(k);
    },
  );

  it.each(['h-14', 'shrink-0', 'whitespace-nowrap', 'rounded-full', 'bg-[var(--vs-noir)]', 'px-8'])(
    'le bouton porte %s',
    (k) => {
      render(<Infolettre />);
      expect(classes(screen.getByRole('button', { name: 'Recevoir le code' }))).toContain(k);
    },
  );

  it('aligne champ et bouton sur une ligne en grand écran', () => {
    render(<Infolettre />);
    expect(classes(screen.getByTestId('infolettre-formulaire'))).toContain('sm:items-center');
  });
});

describe('Infolettre — message d’erreur', () => {
  it('affiche l’erreur sous le formulaire, hors de lui', () => {
    render(<Infolettre />);
    const form = screen.getByTestId('infolettre-formulaire');
    fireEvent.submit(form);
    const alerte = screen.getByRole('alert');
    expect(form.contains(alerte)).toBe(false);
    expect(form.compareDocumentPosition(alerte) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(form.parentElement?.contains(alerte)).toBe(true);
  });
});
