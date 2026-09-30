import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FormulaireContact } from '../src/components/aide/FormulaireContact';

const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Envoyer' }));

describe('FormulaireContact', () => {
  it('propose les quatre sujets', () => {
    render(<FormulaireContact />);
    expect(screen.getByRole('form', { name: 'Écrire au service client' })).toBeInTheDocument();
    expect(screen.getAllByRole('option').map((o: HTMLElement) => o.textContent)).toEqual([
      'Suivi de commande', 'Retour ou échange', 'Question sur un produit', 'Autre',
    ]);
  });

  it('signale les champs fautifs, sans rien annoncer', () => {
    render(<FormulaireContact />);
    saisir('Message', 'court');
    envoyer();
    expect(screen.getByText('Indiquez votre nom.')).toBeInTheDocument();
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    expect(screen.getByText('Écrivez au moins 10 caractères.')).toBeInTheDocument();
    expect(screen.getByLabelText('Message')).toHaveAttribute('aria-invalid', 'true');
    expect(screen.queryByRole('status')).toBeNull();
  });

  it('dit honnêtement que l’envoi n’est pas encore branché', () => {
    render(<FormulaireContact />);
    saisir('Nom', 'Camille Tremblay');
    saisir('Courriel', 'camille@exemple.ca');
    saisir('Message', 'Je voudrais échanger ma pointure 41 contre une 42.');
    envoyer();
    expect(screen.getByRole('status').textContent).toBe("Votre message est prêt. L'envoi au service client sera branché à la mise en ligne de la boutique.");
    expect(screen.getByLabelText('Nom')).not.toHaveAttribute('aria-invalid');
    saisir('Message', 'Autre chose encore à dire.');
    expect(screen.queryByRole('status')).toBeNull();
  });
});
