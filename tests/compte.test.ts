import { describe, expect, it } from 'vitest';
import {
  CLIENT_DEMO, COMMANDES_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, commandesDe, courrielValide, filtrerCommandes,
  formaterDate, formaterMois, libelleCommandes, totauxCommande, validerInscription, verifierConnexion, type Commande,
} from '../src/lib/compte';

describe('connexion et inscription', () => {
  it('reconnaît le compte de démonstration, courriel sans casse ni espaces', () => {
    expect(verifierConnexion(COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBe(true);
    expect(verifierConnexion('  Camille.Tremblay@Exemple.ca ', MOT_DE_PASSE_DEMO)).toBe(true);
    expect(verifierConnexion(COURRIEL_DEMO, 'mauvais')).toBe(false);
    expect(verifierConnexion('autre@exemple.ca', MOT_DE_PASSE_DEMO)).toBe(false);
  });

  it('valide un courriel', () => {
    expect(courrielValide('a@b.ca')).toBe(true);
    expect(courrielValide('pas un courriel')).toBe(false);
    expect(courrielValide('a@b')).toBe(false);
  });

  it('signale chaque champ fautif de l’inscription', () => {
    expect(validerInscription({ prenom: ' ', nom: '', courriel: 'x', motDePasse: 'court' })).toEqual({
      prenom: 'Indiquez votre prénom.',
      nom: 'Indiquez votre nom.',
      courriel: 'Indiquez un courriel valide.',
      motDePasse: 'Au moins 8 caractères, dont un chiffre.',
    });
    expect(validerInscription({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'sanschiffre' })).toEqual({
      motDePasse: 'Au moins 8 caractères, dont un chiffre.',
    });
    expect(validerInscription({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'motdepasse1' })).toEqual({});
  });
});

describe('commandes', () => {
  it('ne montre les commandes de démonstration qu’au compte de démonstration', () => {
    expect(commandesDe(CLIENT_DEMO)).toBe(COMMANDES_DEMO);
    expect(commandesDe({ ...CLIENT_DEMO, courriel: 'autre@exemple.ca' })).toEqual([]);
  });

  it('filtre par statut en gardant l’ordre', () => {
    const numeros = (f: Parameters<typeof filtrerCommandes>[1]) => filtrerCommandes(COMMANDES_DEMO, f).map((c) => c.numero);
    expect(numeros('toutes')).toEqual(['VS-10482', 'VS-10417', 'VS-10360', 'VS-10291']);
    expect(numeros('en-cours')).toEqual(['VS-10482']);
    expect(numeros('livrees')).toEqual(['VS-10417', 'VS-10360']);
    expect(numeros('annulees')).toEqual(['VS-10291']);
  });

  it('calcule TPS et TVQ non composées, arrondies au cent', () => {
    const c = COMMANDES_DEMO.find((x) => x.numero === 'VS-10482') as Commande;
    expect(totauxCommande(c)).toEqual({
      articles: 3, sousTotalCents: 27700, economiesCents: 5000, tpsCents: 1385, tvqCents: 2763, totalCents: 31848,
    });
    const deux = COMMANDES_DEMO.find((x) => x.numero === 'VS-10360') as Commande;
    expect(totauxCommande(deux)).toMatchObject({ articles: 2, sousTotalCents: 17800, tpsCents: 890, tvqCents: 1776, totalCents: 20466 });
  });
});

describe('formats', () => {
  it('écrit les dates en français', () => {
    expect(formaterDate('2026-09-24')).toBe('24 septembre 2026');
    expect(formaterMois('2026-03-12')).toBe('mars 2026');
  });

  it('accorde le nombre de commandes, zéro au singulier', () => {
    expect([0, 1, 4].map(libelleCommandes)).toEqual(['0 commande', '1 commande', '4 commandes']);
  });
});
