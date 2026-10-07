TICKET 116d — en mode Medusa, la session passe par Medusa

Modifie `src/components/compte/SessionProvider.tsx`. En mode Medusa (`useCatalogue().source === 'medusa'`), la session est lue dans Medusa (cookie de la passerelle). Les fonctions d'origine (`connecter`, `inscrire`, `modifierProfil`, `changerMotDePasse`) gardent exactement leur type et leur comportement ; quatre fonctions nouvelles (`connexion`, `inscription`, `enregistrerProfil`, `enregistrerMotDePasse`) passent par Medusa en mode Medusa et par les fonctions d'origine sinon. `deconnecter` et `mettreAJourAdresses` choisissent leur version selon le mode. En démonstration, et sans fournisseur de catalogue (les tests), tout reste identique et synchrone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — la ligne d'import de React reste, et **quatre lignes d'import s'ajoutent juste dessous** : écris-les toutes
Avant :
```tsx
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
```
Après :
```tsx
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import {
  connecterClient, deconnecterClient, inscrireClient, lireClientMedusa, lireCommandesMedusa, modifierProfilClient, synchroniserAdresses,
} from '@/lib/medusa/clients-medusa';
```

## Remplacement 2 — ajoute `Commande` à l'import des types
Avant :
```tsx
import type { Adresse, Client, DonneesInscription } from '@/lib/compte';
```
Après :
```tsx
import type { Adresse, Client, Commande, DonneesInscription } from '@/lib/compte';
```

## Remplacement 3 — ajoute `validerProfil` à l'import des comptes locaux
Avant :
```tsx
  cleCourriel,
} from '@/lib/comptes-locaux';
```
Après :
```tsx
  cleCourriel, validerProfil,
} from '@/lib/comptes-locaux';
```

## Remplacement 4 — la dernière ligne de l'interface reste, et **cinq champs s'ajoutent juste dessous**, avant `}` ; les signatures d'origine ne changent pas
Avant :
```tsx
  mettreAJourAdresses: (adresses: Adresse[]) => void;
}
```
Après :
```tsx
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
```

## Remplacement 5 — **cinq valeurs par défaut s'ajoutent** sous `mettreAJourAdresses: () => {},`, qui reste
Avant :
```tsx
  mettreAJourAdresses: () => {},
});
```
Après :
```tsx
  mettreAJourAdresses: () => {},
  connexion: () => false,
  inscription: () => nouveauClient({ prenom: '', nom: '', courriel: '', motDePasse: '' }),
  enregistrerProfil: () => ({}),
  enregistrerMotDePasse: () => ({}),
  commandes: null,
});
```

## Remplacement 6 — la ligne `const [pret, setPret]…` reste, et **deux lignes s'ajoutent juste dessous**
Avant :
```tsx
  const [pret, setPret] = useState(false);
```
Après :
```tsx
  const [pret, setPret] = useState(false);
  const medusa = useCatalogue().source === 'medusa';
  const [commandes, setCommandes] = useState<Commande[] | null>(null);
```

## Remplacement 7 — au début du premier effet, **un bloc `if (medusa) { … return; }` s'ajoute** avant le `try`, qui reste
Avant :
```tsx
  useEffect(() => {
    try {
      setComptes(lireComptes(window.localStorage.getItem(CLE_COMPTES)));
```
Après :
```tsx
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
```

## Remplacement 8 — le premier effet dépend de `medusa`
Avant :
```tsx
    } finally {
      setPret(true);
    }
  }, []);
```
Après :
```tsx
    } finally {
      setPret(true);
    }
  }, [medusa]);
```

## Remplacement 9 — **six fonctions s'ajoutent juste au-dessus** du `return`, qui reste
Avant :
```tsx
  return (
    <contexteSession.Provider value={{
```
Après :
```tsx
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
```

## Remplacement 10 — les fonctions d'origine restent ; `deconnecter` et `mettreAJourAdresses` choisissent leur version, et **cinq champs s'ajoutent**
Avant :
```tsx
      connecter,
      inscrire,
      deconnecter,
      modifierProfil,
      changerMotDePasse,
      mettreAJourAdresses,
    }}>
```
Après :
```tsx
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
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
