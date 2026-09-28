import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FormulaireAdresse } from '../src/components/compte/FormulaireAdresse';
import { adresseVide, type DonneesAdresse } from '../src/lib/adresses';

const COMPLETE: DonneesAdresse = {
  libelle: 'Chalet', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
  province: 'QC', codePostal: 'J8E 1T1', telephone: '819 555-0101',
};
function poser(initiales: DonneesAdresse) {
  const onEnregistrer = vi.fn(); const onAnnuler = vi.fn();
  render(<FormulaireAdresse initiales={initiales} titre="Nouvelle adresse" libelleBouton="Enregistrer l'adresse"
    onEnregistrer={onEnregistrer} onAnnuler={onAnnuler} />);
  return { onEnregistrer, onAnnuler };
}
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));

describe('FormulaireAdresse', () => {
  it('se nomme par son titre et préremplit ses champs', () => {
    poser(COMPLETE);
    expect(screen.getByRole('form', { name: 'Nouvelle adresse' })).toBeInTheDocument();
    expect(screen.getByLabelText('Ville')).toHaveValue('Mont-Tremblant');
    expect(screen.getByLabelText('Province')).toHaveValue('QC');
    expect(screen.getAllByRole('option')).toHaveLength(13);
  });

  it('signale les champs fautifs sans enregistrer', () => {
    const { onEnregistrer } = poser(adresseVide('Camille Tremblay'));
    envoyer();
    expect(screen.getByText('Indiquez la ville.')).toBeInTheDocument();
    expect(screen.getByText('Code postal invalide (ex. H2J 2L3).')).toBeInTheDocument();
    expect(screen.getByLabelText('Ville')).toHaveAttribute('aria-invalid', 'true');
    expect(screen.getByLabelText('Ville').getAttribute('aria-describedby')).toBe('erreur-adresse-ville');
    expect(screen.getByLabelText('Destinataire')).not.toHaveAttribute('aria-invalid');
    expect(onEnregistrer).not.toHaveBeenCalled();
  });

  it('enregistre ce qui a été saisi', () => {
    const { onEnregistrer } = poser(COMPLETE);
    saisir('Ville', 'Saint-Sauveur');
    fireEvent.change(screen.getByLabelText('Province'), { target: { value: 'ON' } });
    envoyer();
    expect(onEnregistrer).toHaveBeenCalledWith({ ...COMPLETE, ville: 'Saint-Sauveur', province: 'ON' });
  });

  it('annule', () => {
    const { onAnnuler, onEnregistrer } = poser(COMPLETE);
    fireEvent.click(screen.getByRole('button', { name: 'Annuler' }));
    expect(onAnnuler).toHaveBeenCalledTimes(1);
    expect(onEnregistrer).not.toHaveBeenCalled();
  });
});
