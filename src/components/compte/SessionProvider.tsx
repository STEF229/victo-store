'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { CLIENT_DEMO, verifierConnexion, type Client, type DonneesInscription } from '@/lib/compte';

export const CLE_SESSION = 'victo-session';

export interface ContexteSession {
  client: Client | null;
  pret: boolean;
  connecter: (courriel: string, motDePasse: string) => boolean;
  inscrire: (donnees: DonneesInscription) => Client;
  deconnecter: () => void;
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

const Contexte = createContext<ContexteSession>({
  client: null,
  pret: true,
  connecter: () => false,
  inscrire: () => nouveauClient({ prenom: '', nom: '', courriel: '', motDePasse: '' }),
  deconnecter: () => {},
});

export function useSession(): ContexteSession {
  return useContext(Contexte);
}

export function SessionProvider({ children }: { children: ReactNode }) {
  const [client, setClient] = useState<Client | null>(null);
  const [pret, setPret] = useState(false);

  useEffect(() => {
    try {
      const sessionEnregistree = window.localStorage.getItem(CLE_SESSION);
      if (sessionEnregistree) {
        const donnees = JSON.parse(sessionEnregistree);
        if (estClient(donnees)) {
          setClient(donnees);
        }
      }
    } catch {
      // Ignore invalid session data
    } finally {
      setPret(true);
    }
  }, []);

  useEffect(() => {
    if (pret) {
      try {
        if (client) {
          window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
        } else {
          window.localStorage.removeItem(CLE_SESSION);
        }
      } catch {
        // Ignore errors when saving to localStorage
      }
    }
  }, [client, pret]);

  const connecter = (courriel: string, motDePasse: string): boolean => {
    if (verifierConnexion(courriel, motDePasse)) {
      setClient(CLIENT_DEMO);
      return true;
    }
    return false;
  };

  const inscrire = (donnees: DonneesInscription): Client => {
    const c = nouveauClient(donnees);
    setClient(c);
    return c;
  };

  const deconnecter = () => {
    setClient(null);
  };

  return (
    <Contexte.Provider value={{ client, pret, connecter, inscrire, deconnecter }}>
      {children}
    </Contexte.Provider>
  );
}
