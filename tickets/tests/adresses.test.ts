import { describe, expect, it } from 'vitest';
import { CLIENT_DEMO, type Adresse } from '../src/lib/compte';
import {
  PROVINCES, adresseVide, ajouterAdresse, definirParDefaut, donneesDe, modifierAdresse, normaliserCodePostal,
  supprimerAdresse, validerAdresse, type DonneesAdresse,
} from '../src/lib/adresses';

const DEMO: Adresse[] = CLIENT_DEMO.adresses;
const CHALET: DonneesAdresse = {
  libelle: ' Chalet ', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
  province: 'QC', codePostal: 'j8e1t1', telephone: '819 555-0101',
};
const parDefaut = (l: Adresse[]) => l.filter((a) => a.parDefaut).map((a) => a.id);

describe('adresses — validation', () => {
  it('signale chaque champ fautif, dans l’ordre', () => {
    expect(validerAdresse({ ...adresseVide(''), province: 'XX' })).toEqual({
      libelle: 'Donnez un nom à cette adresse.',
      nomComplet: 'Indiquez le nom du destinataire.',
      ligne1: 'Indiquez le numéro et la rue.',
      ville: 'Indiquez la ville.',
      province: 'Choisissez une province.',
      codePostal: 'Code postal invalide (ex. H2J 2L3).',
      telephone: 'Indiquez un numéro à 10 chiffres.',
    });
  });

  it('accepte une adresse complète, code postal et téléphone en toute écriture', () => {
    expect(validerAdresse(CHALET)).toEqual({});
    expect(validerAdresse({ ...CHALET, codePostal: 'J8E-1T1', telephone: '(819) 555-0101' })).toEqual({});
    expect(validerAdresse({ ...CHALET, codePostal: '12345' }).codePostal).toBe('Code postal invalide (ex. H2J 2L3).');
  });

  it('normalise le code postal', () => {
    expect(['h2j2l3', 'H2J 2L3', 'h2j-2l3', ' h2j 2l3 '].map(normaliserCodePostal)).toEqual(['H2J 2L3', 'H2J 2L3', 'H2J 2L3', 'H2J 2L3']);
  });

  it('prépare un formulaire vide ou prérempli', () => {
    expect(adresseVide('Léa Roy')).toEqual({ libelle: '', nomComplet: 'Léa Roy', ligne1: '', ville: '', province: 'QC', codePostal: '', telephone: '' });
    const domicile = DEMO.find((a) => a.id === 'domicile') as Adresse;
    expect(donneesDe(domicile)).toEqual({
      libelle: 'Domicile', nomComplet: 'Camille Tremblay', ligne1: '4520, rue Saint-Denis, app. 3', ville: 'Montréal',
      province: 'QC', codePostal: 'H2J 2L3', telephone: '514 555-0142',
    });
    expect(PROVINCES).toHaveLength(13);
  });
});

describe('adresses — opérations', () => {
  it('ajoute une adresse nettoyée, sans toucher au tableau reçu', () => {
    const suivantes = ajouterAdresse(DEMO, 'chalet', CHALET);
    expect(DEMO).toHaveLength(2);
    expect(suivantes).toHaveLength(3);
    expect(suivantes.find((a) => a.id === 'chalet')).toEqual({
      id: 'chalet', libelle: 'Chalet', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
      province: 'QC', codePostal: 'J8E 1T1', telephone: '819 555-0101', parDefaut: false,
    });
  });

  it('fait de la première adresse l’adresse par défaut', () => {
    expect(parDefaut(ajouterAdresse([], 'chalet', CHALET))).toEqual(['chalet']);
  });

  it('modifie une adresse et garde son statut', () => {
    const domicile = DEMO.find((a) => a.id === 'domicile') as Adresse;
    const suivantes = modifierAdresse(DEMO, 'domicile', { ...donneesDe(domicile), ville: 'Laval' });
    expect(suivantes.find((a) => a.id === 'domicile')).toMatchObject({ ville: 'Laval', parDefaut: true });
    expect(suivantes.find((a) => a.id === 'bureau')).toEqual(DEMO.find((a) => a.id === 'bureau'));
  });

  it('change l’adresse par défaut', () => {
    expect(parDefaut(definirParDefaut(DEMO, 'bureau'))).toEqual(['bureau']);
  });

  it('supprime, et reporte le défaut sur la première restante', () => {
    expect(supprimerAdresse(DEMO, 'bureau').map((a) => a.id)).toEqual(['domicile']);
    const sansDomicile = supprimerAdresse(DEMO, 'domicile');
    expect(sansDomicile.map((a) => a.id)).toEqual(['bureau']);
    expect(parDefaut(sansDomicile)).toEqual(['bureau']);
    expect(supprimerAdresse(supprimerAdresse(DEMO, 'domicile'), 'bureau')).toEqual([]);
  });
});
