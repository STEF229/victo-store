'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_SECONDAIRE, CARTE, CHAMP, CHAMP_AIDE, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import type { Client } from '@/lib/compte';
import { quand } from '@/lib/quand';
import type { ErreursMotDePasse, ErreursProfil } from '@/lib/comptes-locaux';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

function Champ(props: {
  id: string;
  libelle: string;
  type: string;
  auto: string;
  valeur: string;
  erreur: string | undefined;
  aide?: string | undefined;
  onChange: (valeur: string) => void;
}) {
  const decrit = [props.aide ? `aide-${props.id}` : '', props.erreur ? `erreur-${props.id}` : ''].filter(Boolean).join(' ');
  return (
    <div className={CHAMP}>
      <label htmlFor={props.id} className={CHAMP_LIBELLE}>{props.libelle}</label>
      <input id={props.id} type={props.type} autoComplete={props.auto} value={props.valeur}
        onChange={(e) => props.onChange(e.target.value)}
        aria-invalid={props.erreur ? true : undefined}
        aria-describedby={decrit || undefined}
        className={props.erreur ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {props.aide && <p id={`aide-${props.id}`} className={CHAMP_AIDE}>{props.aide}</p>}
      {props.erreur && <p id={`erreur-${props.id}`} className={CHAMP_ERREUR}>{props.erreur}</p>}
    </div>
  );
}

function Formulaires({ client }: { client: Client }) {
  const session = useSession();
  const [profil, setProfil] = useState({ prenom: client.prenom, nom: client.nom, courriel: client.courriel });
  const [erreursProfil, setErreursProfil] = useState<ErreursProfil>({});
  const [profilEnregistre, setProfilEnregistre] = useState(false);
  const [actuel, setActuel] = useState('');
  const [nouveau, setNouveau] = useState('');
  const [erreursMdp, setErreursMdp] = useState<ErreursMotDePasse>({});
  const [mdpChange, setMdpChange] = useState(false);

  function enregistrerProfil(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    quand(session.enregistrerProfil(profil), (erreurs) => {
      setErreursProfil(erreurs);
      setProfilEnregistre(Object.keys(erreurs).length === 0);
    });
  }
  
  function changerMdp(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    quand(session.enregistrerMotDePasse(actuel, nouveau), (erreurs) => {
      setErreursMdp(erreurs);
      const ok = Object.keys(erreurs).length === 0;
      setMdpChange(ok);
      if (ok) {
        setActuel('');
        setNouveau('');
      }
    });
  }

  return (
    <>
      <h1 className={TITRE_PAGE}>Informations personnelles</h1>
      <form onSubmit={enregistrerProfil} noValidate aria-labelledby="titre-profil" className={`${CARTE} gap-5`}>
        <h2 id="titre-profil" className="text-lg font-extrabold text-[var(--vs-noir)]">Profil</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Champ id="prenom" libelle="Prénom" type="text" auto="given-name" valeur={profil.prenom} erreur={erreursProfil.prenom}
            onChange={(v) => setProfil({ ...profil, prenom: v })} />
          <Champ id="nom" libelle="Nom" type="text" auto="family-name" valeur={profil.nom} erreur={erreursProfil.nom}
            onChange={(v) => setProfil({ ...profil, nom: v })} />
        </div>
        <Champ id="courriel" libelle="Courriel" type="email" auto="email" valeur={profil.courriel} erreur={erreursProfil.courriel}
          onChange={(v) => setProfil({ ...profil, courriel: v })} />
        {profilEnregistre && <p role="status" className="text-sm font-bold text-[var(--vs-accent)]">Vos informations sont enregistrées.</p>}
        <button type="submit" className={`self-start ${BOUTON_SECONDAIRE} sm:w-auto`}>Enregistrer</button>
      </form>
      <form onSubmit={changerMdp} noValidate aria-labelledby="titre-mdp" className={`${CARTE} gap-5`}>
        <h2 id="titre-mdp" className="text-lg font-extrabold text-[var(--vs-noir)]">Mot de passe</h2>
        <div className="grid gap-4 sm:grid-cols-2">
          <Champ id="actuel" libelle="Mot de passe actuel" type="password" auto="current-password" valeur={actuel}
            erreur={erreursMdp.actuel} onChange={setActuel} />
          <Champ id="nouveau" libelle="Nouveau mot de passe" type="password" auto="new-password" valeur={nouveau}
            erreur={erreursMdp.nouveau} aide="8 caractères minimum, dont au moins un chiffre." onChange={setNouveau} />
        </div>
        {mdpChange && <p role="status" className="text-sm font-bold text-[var(--vs-accent)]">Mot de passe modifié.</p>}
        <button type="submit" className={`self-start ${BOUTON_SECONDAIRE} sm:w-auto`}>Changer le mot de passe</button>
      </form>
    </>
  );
}

export default function PageInformations() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Informations personnelles' }]} />
        <EspaceClient actif="informations">
          {session.client && <Formulaires client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
