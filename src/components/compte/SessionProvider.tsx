'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import {
  connecterClient, deconnecterClient, inscrireClient, lireClientMedusa, lireCommandesMedusa, modifierProfilClient, synchroniserAdresses,
} from '@/lib/medusa/clients-medusa';
import type { Adresse, Client, Commande, DonneesInscription } from '@/lib/compte';
import {
  CLE_COMPTES, authentifier, changerMotDePasse as changerMotDePasseRegistre, comptesInitiaux, ecrireComptes,
  enregistrer, lireComptes, modifierProfil as modifierProfilRegistre,
  type Comptes, type ErreursMotDePasse, type ErreursProfil, type Profil,
  cleCourriel, validerProfil,
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
  mettreAJourAdresses: (adresses: Adresse[]) => void;
  /** Comme connecter, inscrire, modifierProfil et changerMotDePasse, mais valables aussi en mode Medusa
   *  (résultat asynchrone). Les pages utilisent celles-ci, avec quand(). */
  connexion: (courriel: string, motDePasse: string) => boolean | Promise<boolean>;
  inscription: (donnees: DonneesInscription) => Client | Promise<Client | null>;
  enregistrerProfil: (profil: Profil) => ErreursProfil | Promise<ErreursProfil>;
  enregistrerMotDePasse: (actuel: string, nouveau: string) => ErreursMotDePasse | Promise<ErreursMotDePasse>;
  /** Les commandes du client en mode Medusa ; null en démonstration (voir commandesDe). */
  commandes: Commande[] | null;
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
  mettreAJourAdresses: () => {},
  connexion: () => false,
  inscription: () => nouveauClient({ prenom: '', nom: '', courriel: '', motDePasse: '' }),
  enregistrerProfil: () => ({}),
  enregistrerMotDePasse: () => ({}),
  commandes: null,
});

export function useSession(): ContexteSession {
  return useContext(contexteSession);
}

export function SessionProvider({ children }: { children: ReactNode }) {
  const [client, setClient] = useState<Client | null>(null);
  const [comptes, setComptes] = useState<Comptes>(comptesInitiaux());
  const [pret, setPret] = useState(false);
  const medusa = useCatalogue().source === 'medusa';
  const [commandes, setCommandes] = useState<Commande[] | null>(null);

  useEffect(() => {
    if (medusa) {
      // Mode Medusa : la session vient du cookie gardé par la passerelle.
      void Promise.all([lireClientMedusa(), lireCommandesMedusa()])
        .then(([c, liste]) => { setClient(c); setCommandes(c ? liste : []); })
        .catch(() => setClient(null))
        .finally(() => setPret(true));
      return;
    }
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
  }, [medusa]);

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

  function mettreAJourAdresses(adresses: Adresse[]) {
    if (client === null) return;
    const suivant: Client = { ...client, adresses };
    const cle = cleCourriel(client.courriel);
    const compte = comptes[cle];
    setClient(suivant);
    if (compte) setComptes({ ...comptes, [cle]: { client: suivant, motDePasse: compte.motDePasse } });
  }

  // Mode Medusa : les mêmes actions, par la passerelle ; leurs résultats arrivent un peu plus tard.
  const connecterMedusa = async (courriel: string, motDePasse: string): Promise<boolean> => {
    if (!(await connecterClient(courriel, motDePasse))) return false;
    const c = await lireClientMedusa();
    setClient(c);
    setCommandes(c ? await lireCommandesMedusa() : []);
    return c !== null;
  };
  const inscrireMedusa = async (donnees: DonneesInscription): Promise<Client | null> => {
    const c = await inscrireClient(donnees);
    setClient(c);
    setCommandes([]);
    return c;
  };
  const deconnecterMedusa = () => {
    setClient(null);
    setCommandes(null);
    void deconnecterClient();
  };
  const modifierProfilMedusa = async (profil: Profil): Promise<ErreursProfil> => {
    if (!client) return { courriel: 'Connectez-vous pour modifier votre profil.' };
    const erreurs = validerProfil(profil);
    if (Object.keys(erreurs).length > 0) return erreurs;
    if (cleCourriel(profil.courriel) !== cleCourriel(client.courriel)) return { courriel: 'Pour changer de courriel, écrivez-nous depuis la page Contact.' };
    const c = await modifierProfilClient(profil);
    if (!c) return { prenom: 'Enregistrement impossible pour le moment. Réessayez plus tard.' };
    setClient(c);
    return {};
  };
  const changerMotDePasseMedusa = async (): Promise<ErreursMotDePasse> =>
    ({ actuel: 'Le changement de mot de passe arrive bientôt : il passera par un courriel de confirmation.' });
  const mettreAJourAdressesMedusa = async (adresses: Adresse[]): Promise<void> => {
    if (!client) return;
    const c = await synchroniserAdresses(client.adresses, adresses);
    if (c) setClient(c);
  };

  return (
    <contexteSession.Provider value={{
      client,
      pret,
      connecter,
      inscrire,
      deconnecter: medusa ? deconnecterMedusa : deconnecter,
      modifierProfil,
      changerMotDePasse,
      mettreAJourAdresses: medusa ? mettreAJourAdressesMedusa : mettreAJourAdresses,
      connexion: medusa ? connecterMedusa : connecter,
      inscription: medusa ? inscrireMedusa : inscrire,
      enregistrerProfil: medusa ? modifierProfilMedusa : modifierProfil,
      enregistrerMotDePasse: medusa ? changerMotDePasseMedusa : changerMotDePasse,
      commandes,
    }}>
      {children}
    </contexteSession.Provider>
  );
}
