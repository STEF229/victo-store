TICKET 104c — formulaire d'une adresse

Crée `src/components/compte/FormulaireAdresse.tsx`, export nommé `FormulaireAdresse`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, CARTE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR,
} from '@/components/compte/compte-affichage';
import { PROVINCES, validerAdresse, type DonneesAdresse, type ErreursAdresse } from '@/lib/adresses';
```

## Un champ texte — fonction locale, non exportée, recopiée telle quelle
Taille attendue : ~105 lignes.
```tsx
function Champ(props: {
  id: keyof DonneesAdresse;
  libelle: string;
  auto: string;
  valeur: string;
  erreur: string | undefined;
  onChange: (valeur: string) => void;
}) {
  return (
    <div className={CHAMP}>
      <label htmlFor={`adresse-${props.id}`} className={CHAMP_LIBELLE}>{props.libelle}</label>
      <input id={`adresse-${props.id}`} type="text" autoComplete={props.auto} value={props.valeur}
        onChange={(e) => props.onChange(e.target.value)}
        aria-invalid={props.erreur ? true : undefined}
        aria-describedby={props.erreur ? `erreur-adresse-${props.id}` : undefined}
        className={props.erreur ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {props.erreur && <p id={`erreur-adresse-${props.id}`} className={CHAMP_ERREUR}>{props.erreur}</p>}
    </div>
  );
}
```

## Le formulaire
```tsx
export function FormulaireAdresse({ initiales, titre, libelleBouton, onEnregistrer, onAnnuler }: {
  initiales: DonneesAdresse;
  titre: string;
  libelleBouton: string;
  onEnregistrer: (donnees: DonneesAdresse) => void;
  onAnnuler: () => void;
})
```
Contenu :
```tsx
const [donnees, setDonnees] = useState<DonneesAdresse>(initiales);
const [erreurs, setErreurs] = useState<ErreursAdresse>({});
const changer = (cle: keyof DonneesAdresse) => (valeur: string) => setDonnees({ ...donnees, [cle]: valeur });

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const trouvees = validerAdresse(donnees);
  setErreurs(trouvees);
  if (Object.keys(trouvees).length === 0) onEnregistrer(donnees);
}
```
Rendu :
```tsx
<form onSubmit={soumettre} noValidate aria-labelledby="titre-formulaire-adresse" className={`${CARTE} gap-5`}>
  <h2 id="titre-formulaire-adresse" className="text-lg font-extrabold text-[var(--vs-noir)]">{titre}</h2>
  <div className="grid gap-4 sm:grid-cols-2">
    <Champ id="libelle" libelle="Nom de l'adresse (ex. Domicile, Bureau)" auto="off" valeur={donnees.libelle} erreur={erreurs.libelle} onChange={changer('libelle')} />
    <Champ id="nomComplet" libelle="Destinataire" auto="name" valeur={donnees.nomComplet} erreur={erreurs.nomComplet} onChange={changer('nomComplet')} />
  </div>
  <Champ id="ligne1" libelle="Adresse" auto="address-line1" valeur={donnees.ligne1} erreur={erreurs.ligne1} onChange={changer('ligne1')} />
  <div className="grid gap-4 sm:grid-cols-3">
    <Champ id="ville" libelle="Ville" auto="address-level2" valeur={donnees.ville} erreur={erreurs.ville} onChange={changer('ville')} />
    <div className={CHAMP}>
      <label htmlFor="adresse-province" className={CHAMP_LIBELLE}>Province</label>
      <select id="adresse-province" value={donnees.province} onChange={(e) => changer('province')(e.target.value)}
        aria-invalid={erreurs.province ? true : undefined} className={erreurs.province ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE}>
        {PROVINCES.map((p) => <option key={p.code} value={p.code}>{p.nom}</option>)}
      </select>
      {erreurs.province && <p className={CHAMP_ERREUR}>{erreurs.province}</p>}
    </div>
    <Champ id="codePostal" libelle="Code postal" auto="postal-code" valeur={donnees.codePostal} erreur={erreurs.codePostal} onChange={changer('codePostal')} />
  </div>
  <Champ id="telephone" libelle="Téléphone" auto="tel" valeur={donnees.telephone} erreur={erreurs.telephone} onChange={changer('telephone')} />
  <div className="flex flex-col gap-3 sm:flex-row">
    <button type="submit" className={`${BOUTON_PRINCIPAL} sm:w-auto`}>{libelleBouton}</button>
    <button type="button" onClick={onAnnuler} className={`${BOUTON_SECONDAIRE} sm:w-auto`}>Annuler</button>
  </div>
</form>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
