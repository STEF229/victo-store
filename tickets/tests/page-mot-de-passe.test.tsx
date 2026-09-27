import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageMotDePasseOublie from '../src/app/mot-de-passe-oublie/page';

const saisir = (valeur: string) => fireEvent.change(screen.getByLabelText('Courriel'), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Envoyer le lien' }));

describe('page mot de passe oublié', () => {
  it('assemble titre, champ et retour à la connexion', () => {
    render(<PageMotDePasseOublie />);
    expect(screen.getByRole('heading', { level: 1, name: 'Mot de passe oublié' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Retour à la connexion' })).toHaveAttribute('href', '/connexion');
  });

  it('refuse un courriel invalide', () => {
    render(<PageMotDePasseOublie />);
    saisir('pas un courriel');
    envoyer();
    expect(screen.getByRole('alert').textContent).toBe('Indiquez un courriel valide.');
    expect(screen.queryByTestId('lien-envoye')).toBeNull();
  });

  it('confirme l’envoi pour le courriel saisi, puis permet de recommencer', () => {
    render(<PageMotDePasseOublie />);
    saisir(' lea@exemple.ca ');
    envoyer();
    const confirmation = screen.getByTestId('lien-envoye');
    expect(confirmation.textContent).toContain('Si un compte existe pour lea@exemple.ca, un lien vous attend.');
    fireEvent.click(screen.getByRole('button', { name: 'Renvoyer le lien' }));
    expect(screen.getByRole('button', { name: 'Envoyer le lien' })).toBeInTheDocument();
  });
});
