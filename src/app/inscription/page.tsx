'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CHAMP, CHAMP_AIDE, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { validerInscription, type DonneesInscription, type ErreursInscription } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

function Champ(props: {
  id: keyof DonneesInscription;
  libelle: string;
  type: string;
  valeur: string;
  auto: string;
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

export default function PageInscription() {
  const session = useSession();
  const router = useRouter();
  const [donnees, setDonnees] = useState<DonneesInscription>({ prenom: '', nom: '', courriel: '', motDePasse: '' });
  const [erreurs, setErreurs] = useState<ErreursInscription>({});
  const changer = (cle: keyof DonneesInscription) => (valeur: string) => setDonnees({ ...donnees, [cle]: valeur });

  function soumettre(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const trouvees = validerInscription(donnees);
    setErreurs(trouvees);
    if (Object.keys(trouvees).length === 0) {
      session.inscrire(donnees);
      router.push('/compte');
    }
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Créer un compte' }]} />
        <form onSubmit={soumettre} noValidate className="mx-auto flex w-full max-w-[560px] flex-col gap-[22px]">
          <div className="flex flex-col gap-2.5">
            <h1 className={TITRE_PAGE}>Créer un compte</h1>
            <p className={SOUS_TITRE}>Suivez vos commandes et gardez vos favoris.</p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <Champ id="prenom" libelle="Prénom" type="text" auto="given-name" valeur={donnees.prenom} erreur={erreurs.prenom} onChange={changer('prenom')} />
            <Champ id="nom" libelle="Nom" type="text" auto="family-name" valeur={donnees.nom} erreur={erreurs.nom} onChange={changer('nom')} />
          </div>
          <Champ id="courriel" libelle="Courriel" type="email" auto="email" valeur={donnees.courriel} erreur={erreurs.courriel} onChange={changer('courriel')} />
          <Champ id="motDePasse" libelle="Mot de passe" type="password" auto="new-password" valeur={donnees.motDePasse}
            erreur={erreurs.motDePasse} aide="8 caractères minimum, dont au moins un chiffre." onChange={changer('motDePasse')} />
          <label className="flex items-start gap-2.5 text-sm leading-relaxed">
            <input type="checkbox" defaultChecked className="mt-0.5 h-5 w-5 accent-[var(--vs-noir)]" />
            <span>Recevoir les arrivages et les ventes privées par courriel, et −10 % sur ma première commande.</span>
          </label>
          <p className="text-[13px] leading-relaxed text-[var(--vs-gris)]">
            En créant un compte, vous acceptez les conditions de vente et la politique de confidentialité.
          </p>
          <button type="submit" className={BOUTON_PRINCIPAL}>Créer mon compte</button>
          <p className="text-center text-[15px]">
            Déjà un compte ? <Link href="/connexion" className={LIEN}>Se connecter</Link>
          </p>
        </form>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
