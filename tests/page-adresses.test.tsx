import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageAdresses from '../src/app/compte/adresses/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const poser = (client: object = CLIENT_DEMO) => {
  window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
  render(<SessionProvider><PageAdresses /></SessionProvider>);
};
const carte = (id: string) => screen.getByTestId(`adresse-${id}`);
const cartes = () => screen.queryAllByTestId(/^adresse-/).map((c: HTMLElement) => c.getAttribute('data-testid'));
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_SESSION) ?? '{}') as { adresses?: { id: string; parDefaut: boolean; ville: string }[] };

beforeEach(() => window.localStorage.clear());

describe('mes adresses', () => {
  it('liste les adresses du client, la principale marquée', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Mes adresses' })).toBeInTheDocument();
    expect(cartes()).toEqual(['adresse-domicile', 'adresse-bureau']);
    expect(within(carte('domicile')).getByText('Par défaut')).toBeInTheDocument();
    expect(within(carte('bureau')).queryByText('Par défaut')).toBeNull();
    expect(screen.getByRole('link', { name: 'Adresses' })).toHaveAttribute('aria-current', 'page');
  });

  it('ajoute une adresse, et la garde', () => {
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Ajouter une adresse' }));
    expect(screen.getByLabelText('Destinataire')).toHaveValue('Camille Tremblay');
    saisir("Nom de l'adresse (ex. Domicile, Bureau)", 'Chalet');
    saisir('Adresse', '12, chemin du Lac');
    saisir('Ville', 'Mont-Tremblant');
    saisir('Code postal', 'j8e1t1');
    saisir('Téléphone', '819 555-0101');
    fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));
    expect(cartes()).toHaveLength(3);
    expect(screen.queryByRole('form')).toBeNull();
    // Les lignes de l'adresse sont séparées par des <br /> : on lit le texte de la carte entière.
    expect(screen.getAllByTestId(/^adresse-adr-/).map((c: HTMLElement) => c.textContent).join('')).toContain('Mont-Tremblant (QC) J8E 1T1');
    expect(enregistre().adresses).toHaveLength(3);
  });

  it('modifie une adresse existante', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Modifier' }));
    expect(screen.getByRole('form', { name: "Modifier l'adresse" })).toBeInTheDocument();
    saisir('Ville', 'Laval');
    fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));
    expect(enregistre().adresses?.find((a) => a.id === 'bureau')?.ville).toBe('Laval');
  });

  it('change l’adresse par défaut', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Définir par défaut' }));
    expect(within(carte('bureau')).getByText('Par défaut')).toBeInTheDocument();
    expect(within(carte('domicile')).queryByText('Par défaut')).toBeNull();
  });

  it('supprime après confirmation seulement', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Supprimer' }));
    expect(cartes()).toHaveLength(2);
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Annuler' }));
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Supprimer' }));
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Confirmer la suppression' }));
    expect(cartes()).toEqual(['adresse-domicile']);
  });

  it('invite un nouveau client à ajouter sa première adresse', () => {
    poser({ ...CLIENT_DEMO, courriel: 'lea@exemple.ca', adresses: [] });
    expect(screen.getByTestId('adresses-vides')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Ajouter une adresse' })).toBeInTheDocument();
  });
});
