import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, courrielValide, type Client } from '@/lib/compte';

export interface CompteLocal {
  client: Client;
  motDePasse: string;
}
export type Comptes = Partial<Record<string, CompteLocal>>;
export interface Profil {
  prenom: string;
  nom: string;
  courriel: string;
}
export type ErreursProfil = Partial<Record<keyof Profil, string>>;
export type ErreursMotDePasse = Partial<Record<'actuel' | 'nouveau', string>>;
export const CLE_COMPTES = 'victo-comptes';

function estCompte(x: unknown): x is CompteLocal {
  return (
    typeof x === 'object' && x !== null &&
    'motDePasse' in x && typeof x.motDePasse === 'string' &&
    'client' in x && typeof x.client === 'object' && x.client !== null &&
    'prenom' in x.client && typeof x.client.prenom === 'string' &&
    'nom' in x.client && typeof x.client.nom === 'string' &&
    'courriel' in x.client && typeof x.client.courriel === 'string' &&
    'membreDepuis' in x.client && typeof x.client.membreDepuis === 'string' &&
    'adresses' in x.client && Array.isArray(x.client.adresses)
  );
}

export function cleCourriel(courriel: string): string {
  return courriel.trim().toLowerCase();
}

export function comptesInitiaux(): Comptes {
  return { [COURRIEL_DEMO]: { client: CLIENT_DEMO, motDePasse: MOT_DE_PASSE_DEMO } };
}

export function lireComptes(texte: string | null): Comptes {
  let resultats = comptesInitiaux();
  
  if (texte !== null) {
    try {
      const parsed = JSON.parse(texte);
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
        const nouveauxComptes: Comptes = {};
        
        for (const [cle, valeur] of Object.entries(parsed as Record<string, unknown>)) {
          if (estCompte(valeur)) {
            nouveauxComptes[cle] = valeur;
          }
        }
        
        resultats = { ...comptesInitiaux(), ...nouveauxComptes };
      }
    } catch {
      // En cas d'erreur de parsing, retourner les comptes initiaux
    }
  }
  
  return resultats;
}

export function ecrireComptes(comptes: Comptes): string {
  return JSON.stringify(comptes);
}

export function authentifier(comptes: Comptes, courriel: string, motDePasse: string): Client | null {
  const cle = cleCourriel(courriel);
  const compte = comptes[cle];
  
  if (compte && compte.motDePasse === motDePasse) {
    return compte.client;
  }
  
  return null;
}

export function enregistrer(comptes: Comptes, client: Client, motDePasse: string): Comptes {
  const cle = cleCourriel(client.courriel);
  return { ...comptes, [cle]: { client, motDePasse } };
}

export function validerProfil(profil: Profil): ErreursProfil {
  const erreurs: ErreursProfil = {};
  
  if (!profil.prenom.trim()) {
    erreurs.prenom = 'Indiquez votre prénom.';
  }
  
  if (!profil.nom.trim()) {
    erreurs.nom = 'Indiquez votre nom.';
  }
  
  if (!courrielValide(profil.courriel)) {
    erreurs.courriel = 'Indiquez un courriel valide.';
  }
  
  return erreurs;
}

export function modifierProfil(comptes: Comptes, courrielActuel: string, profil: Profil):
  { comptes: Comptes; client: Client } | { erreurs: ErreursProfil } {
  
  const erreurs = validerProfil(profil);
  
  if (Object.keys(erreurs).length > 0) {
    return { erreurs };
  }
  
  const ancienne = cleCourriel(courrielActuel);
  const compte = comptes[ancienne];
  
  if (!compte) {
    return { erreurs: { courriel: 'Compte introuvable.' } };
  }
  
  const nouvelle = cleCourriel(profil.courriel);
  
  if (nouvelle !== ancienne && comptes[nouvelle]) {
    return { erreurs: { courriel: 'Ce courriel est déjà utilisé.' } };
  }
  
  const client: Client = { 
    ...compte.client, 
    prenom: profil.prenom.trim(), 
    nom: profil.nom.trim(), 
    courriel: nouvelle 
  };
  
  const suivants: Comptes = { ...comptes };
  delete suivants[ancienne];
  suivants[nouvelle] = { client, motDePasse: compte.motDePasse };
  
  return { comptes: suivants, client };
}

export function changerMotDePasse(comptes: Comptes, courriel: string, actuel: string, nouveau: string):
  { comptes: Comptes } | { erreurs: ErreursMotDePasse } {
  const cle = cleCourriel(courriel);
  const compte = comptes[cle];
  const erreurs: ErreursMotDePasse = {};
  
  if (!compte || compte.motDePasse !== actuel) {
    erreurs.actuel = 'Mot de passe actuel incorrect.';
  }
  
  if (nouveau.length < 8 || !/\d/.test(nouveau)) {
    erreurs.nouveau = 'Au moins 8 caractères, dont un chiffre.';
  }
  
  if (!compte || Object.keys(erreurs).length > 0) {
    return { erreurs };
  }
  
  return { 
    comptes: { ...comptes, [cle]: { client: compte.client, motDePasse: nouveau } } 
  };
}
