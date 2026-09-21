import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const champ = () => screen.getByLabelText('Votre courriel');
const envoyer = () => fireEvent.submit(screen.getByTestId('infolettre-formulaire'));

describe('Infolettre — présentation', () => {
  it('rend le bandeau cobalt sur deux colonnes', () => {
    render(<Infolettre />);
    const bloc = screen.getByRole('heading', { level: 2 }).closest('.rounded-\\[28px\\]');
    expect(bloc).not.toBeNull();
    for (const k of ['grid', 'grid-cols-1', 'items-center', 'gap-8', 'rounded-[28px]', 'bg-[var(--vs-accent)]', 'text-[var(--vs-blanc)]', 'lg:grid-cols-2']) {
      expect(classes(bloc as Element)).toContain(k);
    }
  });

  it('étiquette le champ de courriel', () => {
    render(<Infolettre />);
    expect(champ()).toHaveAttribute('type', 'email');
    expect(champ()).toHaveAttribute('id', 'infolettre-courriel');
  });

  it('propose le bouton d’envoi', () => {
    render(<Infolettre />);
    expect(screen.getByRole('button', { name: 'Recevoir le code' })).toHaveAttribute('type', 'submit');
  });

  it('dispose le formulaire', () => {
    render(<Infolettre />);
    const f = screen.getByTestId('infolettre-formulaire');
    for (const k of ['flex', 'flex-col', 'gap-3', 'sm:flex-row']) expect(classes(f)).toContain(k);
  });
});

describe('Infolettre — comportement', () => {
  it('refuse une adresse sans arobase', () => {
    render(<Infolettre />);
    fireEvent.change(champ(), { target: { value: 'pas-une-adresse' } });
    envoyer();
    expect(screen.getByRole('alert').textContent).toBe('Entrez une adresse courriel valide.');
    expect(screen.queryByTestId('infolettre-merci')).toBeNull();
  });

  it('refuse un champ vide', () => {
    render(<Infolettre />);
    envoyer();
    expect(screen.getByRole('alert')).toBeInTheDocument();
  });

  it('remercie après une adresse valide', () => {
    render(<Infolettre />);
    fireEvent.change(champ(), { target: { value: 'moi@exemple.com' } });
    envoyer();
    expect(screen.getByTestId('infolettre-merci').textContent).toBe('Merci, votre code arrive par courriel.');
    expect(screen.queryByTestId('infolettre-formulaire')).toBeNull();
    expect(screen.queryByRole('alert')).toBeNull();
  });
});
