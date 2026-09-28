'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import type { Client, DonneesInscription } from '@/lib/compte';
import {
  CLE_COMPTES, authentifier, changerMotDePasse as changerMotDePasseRegistre, comptesInitiaux, ecrireComptes,
  enregistrer, lireComptes, modifierProfil as modifierProfilRegistre,
  type Comptes, type ErreursMotDePasse, type ErreursProfil, type Profil,
} from '@/lib/comptes-locaux';

export const CLE_SESSION = 'victo-session';

export interface ContexteSession {
  client: Client | null;
  pret: boolean;
  connecter: (courriel: string, motDePasse: string) => boolean;
  inscrire: (donnees: DonneesInscription) => Client;
  deconnecter: () => void;
  modifierProfil: (profil: Profil) => ErreursProfil;
  changerMotDePasse: (actuel: string, nouveau: string) => ErreursMotDePasse;
}

function nouveauClient(d: DonneesInscription): Client {
  return {
    prenom: d.prenom.trim(),
    nom: d.nom.trim(),
    courriel: d.courriel.trim().toLowerCase(),
    membreDepuis: new Date().toISOString().slice(0, 10),
    adresses: [],
  };
}

function estClient(x: unknown): x is Client {
  return (
    typeof x === 'object' && x !== null &&
    'prenom' in x && typeof x.prenom === 'string' &&
    'nom' in x && typeof x.nom === 'string' &&
    'courriel' in x && typeof x.courriel === 'string' &&
    'membreDepuis' in x && typeof x.membreDepuis === 'string' &&
    'adresses' in x && Array.isArray(x.adresses)
  );
}

const contexteSession = createContext<ContexteSession>({
  client: null,
  pret: true,
  connecter: () => false,
  inscrire: () => nouveauClient({ prenom: '', nom: '', courriel: '', motDePasse: '' }),
  deconnecter: () => {},
  modifierProfil: () => ({}),
  changerMotDePasse: () => ({}),
});

export function useSession(): ContexteSession {
  return useContext(contexteSession);
}

export function SessionProvider({ children }: { children: ReactNode }) {
  const [client, setClient] = useState<Client | null>(null);
  const [comptes, setComptes] = useState<Comptes>(comptesInitiaux());
  const [pret, setPret] = useState(false);

  useEffect(() => {
    try {
      setComptes(lireComptes(window.localStorage.getItem(CLE_COMPTES)));
      
      const session = window.localStorage.getItem(CLE_SESSION);
      if (session) {
        try {
          const parsed = JSON.parse(session);
          if (estClient(parsed)) {
            setClient(parsed);
          }
        } catch {
          // Ignore invalid session data
        }
      }
    } finally {
      setPret(true);
    }
  }, []);

  useEffect(() => {
    if (!pret) return;
    
    if (client) {
      try {
        window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
      } catch {
        // Ignore errors when setting session
      }
    } else {
      try {
        window.localStorage.removeItem(CLE_SESSION);
      } catch {
        // Ignore errors when removing session
      }
    }
  }, [client, pret]);

  useEffect(() => {
    if (!pret) return;
    
    try {
      window.localStorage.setItem(CLE_COMPTES, ecrireComptes(comptes));
    } catch {
      // Ignore errors when setting comptes
    }
  }, [comptes, pret]);

  const connecter = (courriel: string, motDePasse: string): boolean => {
    const c = authentifier(comptes, courriel, motDePasse);
    if (c) {
      setClient(c);
      return true;
    }
    return false;
  };

  const inscrire = (donnees: DonneesInscription): Client => {
    const c = nouveauClient(donnees);
    setComptes(enregistrer(comptes, c, donnees.motDePasse));
    setClient(c);
    return c;
  };

  const deconnecter = () => {
    setClient(null);
  };

  const modifierProfil = (profil: Profil): ErreursProfil => {
    if (!client) {
      return { courriel: 'Connectez-vous pour modifier votre profil.' };
    }
    
    const r = modifierProfilRegistre(comptes, client.courriel, profil);
    if ('erreurs' in r) {
      return r.erreurs;
    }
    
    setComptes(r.comptes);
    setClient(r.client);
    return {};
  };

  const changerMotDePasse = (actuel: string, nouveau: string): ErreursMotDePasse => {
    if (!client) {
      return { actuel: 'Connectez-vous pour changer votre mot de passe.' };
    }
    
    const r = changerMotDePasseRegistre(comptes, client.courriel, actuel, nouveau);
    if ('erreurs' in r) {
      return r.erreurs;
    }
    
    setComptes(r.comptes);
    return {};
  };

  return (
    <contexteSession.Provider value={{
      client,
      pret,
      connecter,
      inscrire,
      deconnecter,
      modifierProfil,
      changerMotDePasse,
    }}>
      {children}
    </contexteSession.Provider>
  );
}
