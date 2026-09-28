import { describe, expect, it } from 'vitest';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, type Client } from '../src/lib/compte';
import {
  authentifier, changerMotDePasse, cleCourriel, comptesInitiaux, ecrireComptes, enregistrer, lireComptes,
  modifierProfil, validerProfil, type Comptes,
} from '../src/lib/comptes-locaux';

const LEA: Client = { prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', membreDepuis: '2026-09-27', adresses: [] };
const avecLea = (): Comptes => enregistrer(comptesInitiaux(), LEA, 'motdepasse1');

describe('registre — base', () => {
  it('contient le compte de démonstration', () => {
    expect(authentifier(comptesInitiaux(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBe(CLIENT_DEMO);
    expect(authentifier(comptesInitiaux(), ' Camille.Tremblay@Exemple.CA ', MOT_DE_PASSE_DEMO)).toBe(CLIENT_DEMO);
    expect(authentifier(comptesInitiaux(), COURRIEL_DEMO, 'faux')).toBeNull();
    expect(authentifier(comptesInitiaux(), 'inconnu@exemple.ca', 'x')).toBeNull();
  });

  it('enregistre un compte sans modifier le registre reçu', () => {
    const avant = comptesInitiaux();
    const apres = enregistrer(avant, LEA, 'motdepasse1');
    expect(authentifier(apres, 'LEA@exemple.ca', 'motdepasse1')).toEqual(LEA);
    expect(authentifier(avant, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
    expect(cleCourriel(' A@B.ca ')).toBe('a@b.ca');
  });

  it('relit ce qu’il écrit, garde le compte de démonstration et ignore l’illisible', () => {
    const relu = lireComptes(ecrireComptes(avecLea()));
    expect(authentifier(relu, 'lea@exemple.ca', 'motdepasse1')).toEqual(LEA);
    expect(authentifier(relu, COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
    expect(authentifier(lireComptes('{pas du json'), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
    expect(Object.keys(lireComptes(JSON.stringify({ 'x@y.ca': { motDePasse: 1 } })))).toEqual([COURRIEL_DEMO]);
    expect(authentifier(lireComptes(null), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
  });
});

describe('registre — profil', () => {
  it('valide prénom, nom et courriel', () => {
    expect(validerProfil({ prenom: '', nom: ' ', courriel: 'x' })).toEqual({
      prenom: 'Indiquez votre prénom.', nom: 'Indiquez votre nom.', courriel: 'Indiquez un courriel valide.',
    });
    expect(validerProfil({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca' })).toEqual({});
  });

  it('modifie le profil et déplace le compte vers le nouveau courriel', () => {
    const r = modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: ' Léa-Marie ', nom: 'Roy', courriel: 'LM@Exemple.ca' });
    if (!('comptes' in r)) throw new Error('erreurs inattendues');
    expect(r.client.prenom).toBe('Léa-Marie');
    expect(r.client.courriel).toBe('lm@exemple.ca');
    expect(authentifier(r.comptes, 'lm@exemple.ca', 'motdepasse1')?.prenom).toBe('Léa-Marie');
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
  });

  it('refuse un courriel déjà pris et un profil invalide', () => {
    expect(modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: 'Léa', nom: 'Roy', courriel: COURRIEL_DEMO }))
      .toEqual({ erreurs: { courriel: 'Ce courriel est déjà utilisé.' } });
    expect(modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: '', nom: 'Roy', courriel: 'lea@exemple.ca' }))
      .toEqual({ erreurs: { prenom: 'Indiquez votre prénom.' } });
    expect(modifierProfil(avecLea(), 'personne@exemple.ca', { prenom: 'A', nom: 'B', courriel: 'a@b.ca' }))
      .toEqual({ erreurs: { courriel: 'Compte introuvable.' } });
  });
});

describe('registre — mot de passe', () => {
  it('change le mot de passe quand l’actuel est bon', () => {
    const r = changerMotDePasse(avecLea(), 'lea@exemple.ca', 'motdepasse1', 'nouveau2026');
    if (!('comptes' in r)) throw new Error('erreurs inattendues');
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'nouveau2026')).toEqual(LEA);
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
  });

  it('signale un mot de passe actuel faux et un nouveau trop faible', () => {
    expect(changerMotDePasse(avecLea(), 'lea@exemple.ca', 'faux', 'court')).toEqual({
      erreurs: { actuel: 'Mot de passe actuel incorrect.', nouveau: 'Au moins 8 caractères, dont un chiffre.' },
    });
    expect(changerMotDePasse(avecLea(), 'lea@exemple.ca', 'motdepasse1', 'sanschiffre')).toEqual({
      erreurs: { nouveau: 'Au moins 8 caractères, dont un chiffre.' },
    });
  });
});
