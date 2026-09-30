TICKET 106e — formulaire de contact

Crée `src/components/aide/FormulaireContact.tsx`, export nommé `FormulaireContact`.
Aucun courriel n'est encore envoyé : après validation, le formulaire le dit clairement.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Recopie tous les textes exactement, apostrophes droites comprises.

## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR,
} from '@/components/compte/compte-affichage';
import { courrielValide } from '@/lib/compte';
```

## Contenu
Taille attendue : ~95 lignes.
```tsx
const SUJETS = ['Suivi de commande', 'Retour ou échange', 'Question sur un produit', 'Autre'];

type Champs = { nom: string; courriel: string; commande: string; sujet: string; message: string };
type Erreurs = Partial<Record<'nom' | 'courriel' | 'message', string>>;

function valider(c: Champs): Erreurs {
  const erreurs: Erreurs = {};
  if (c.nom.trim() === '') erreurs.nom = 'Indiquez votre nom.';
  if (!courrielValide(c.courriel)) erreurs.courriel = 'Indiquez un courriel valide.';
  if (c.message.trim().length < 10) erreurs.message = 'Écrivez au moins 10 caractères.';
  return erreurs;
}
```
`export function FormulaireContact()` :
```tsx
const [champs, setChamps] = useState<Champs>({ nom: '', courriel: '', commande: '', sujet: 'Suivi de commande', message: '' });
const [erreurs, setErreurs] = useState<Erreurs>({});
const [pret, setPret] = useState(false);
const changer = (cle: keyof Champs) => (valeur: string) => { setChamps({ ...champs, [cle]: valeur }); setPret(false); };

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const trouvees = valider(champs);
  setErreurs(trouvees);
  setPret(Object.keys(trouvees).length === 0);
}
```
Rendu :
```tsx
<form onSubmit={soumettre} noValidate aria-label="Écrire au service client" className="flex flex-col gap-[18px]">
  <div className="grid gap-4 sm:grid-cols-2">
    <div className={CHAMP}>
      <label htmlFor="contact-nom" className={CHAMP_LIBELLE}>Nom</label>
      <input id="contact-nom" type="text" autoComplete="name" value={champs.nom} onChange={(e) => changer('nom')(e.target.value)}
        aria-invalid={erreurs.nom ? true : undefined} className={erreurs.nom ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {erreurs.nom && <p className={CHAMP_ERREUR}>{erreurs.nom}</p>}
    </div>
    <div className={CHAMP}>
      <label htmlFor="contact-courriel" className={CHAMP_LIBELLE}>Courriel</label>
      <input id="contact-courriel" type="email" autoComplete="email" value={champs.courriel} onChange={(e) => changer('courriel')(e.target.value)}
        aria-invalid={erreurs.courriel ? true : undefined} className={erreurs.courriel ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {erreurs.courriel && <p className={CHAMP_ERREUR}>{erreurs.courriel}</p>}
    </div>
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-commande" className={CHAMP_LIBELLE}>Numéro de commande (facultatif)</label>
    <input id="contact-commande" type="text" value={champs.commande} onChange={(e) => changer('commande')(e.target.value)} className={CHAMP_SAISIE} />
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-sujet" className={CHAMP_LIBELLE}>Sujet</label>
    <select id="contact-sujet" value={champs.sujet} onChange={(e) => changer('sujet')(e.target.value)} className={CHAMP_SAISIE}>
      {SUJETS.map((s) => <option key={s} value={s}>{s}</option>)}
    </select>
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-message" className={CHAMP_LIBELLE}>Message</label>
    <textarea id="contact-message" rows={6} value={champs.message} onChange={(e) => changer('message')(e.target.value)}
      aria-invalid={erreurs.message ? true : undefined}
      className={erreurs.message
        ? 'w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] py-3.5 text-base text-[var(--vs-noir)]'
        : 'w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] py-3.5 text-base text-[var(--vs-noir)]'} />
    {erreurs.message && <p className={CHAMP_ERREUR}>{erreurs.message}</p>}
  </div>
  <p className="text-[13px] leading-relaxed text-[var(--vs-gris)]">
    Vos renseignements servent uniquement à répondre à votre demande.
  </p>
  {pret && (
    <p role="status" className="rounded-2xl bg-[#EEF1F8] p-4 text-sm font-bold text-[var(--vs-accent)]">
      Votre message est prêt. L'envoi au service client sera branché à la mise en ligne de la boutique.
    </p>
  )}
  <button type="submit" className={`self-start ${BOUTON_PRINCIPAL} sm:w-auto`}>Envoyer</button>
</form>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
