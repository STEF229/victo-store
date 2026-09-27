'use client';

import { ArrowLeft, Mail } from 'lucide-react';
import Link from 'next/link';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CARTE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { courrielValide } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PageMotDePasseOublie() {
  const [courriel, setCourriel] = useState('');
  const [envoye, setEnvoye] = useState(false);
  const [erreur, setErreur] = useState(false);

  function soumettre(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (courrielValide(courriel)) {
      setErreur(false);
      setEnvoye(true);
    } else {
      setErreur(true);
    }
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Connexion', href: '/connexion' }, { label: 'Mot de passe oublié' }]} />
        <div className="mx-auto flex w-full max-w-[560px] flex-col gap-6">
          <h1 className={TITRE_PAGE}>Mot de passe oublié</h1>
          {envoye ? (
            <section data-testid="lien-envoye" className={`${CARTE} bg-[var(--vs-surface)]`}>
              <Mail aria-hidden size={24} />
              <h2 className="text-2xl font-black text-[var(--vs-noir)]">Vérifiez votre boîte de réception</h2>
              <p className={SOUS_TITRE}>{`Si un compte existe pour ${courriel.trim()}, un lien vous attend. Il reste valide une heure.`}</p>
              <button type="button" onClick={() => setEnvoye(false)} className={`self-start ${LIEN}`}>Renvoyer le lien</button>
            </section>
          ) : (
            <form onSubmit={soumettre} noValidate className="flex flex-col gap-[22px]">
              <p className={SOUS_TITRE}>Indiquez le courriel de votre compte : nous vous envoyons un lien pour choisir un nouveau mot de passe.</p>
              <div className={CHAMP}>
                <label htmlFor="courriel" className={CHAMP_LIBELLE}>Courriel</label>
                <input id="courriel" type="email" autoComplete="email" value={courriel}
                  onChange={(e) => setCourriel(e.target.value)} className={CHAMP_SAISIE} />
              </div>
              {erreur && <p role="alert" className={CHAMP_ERREUR}>Indiquez un courriel valide.</p>}
              <button type="submit" className={BOUTON_PRINCIPAL}>Envoyer le lien</button>
            </form>
          )}
          <Link href="/connexion" className="flex items-center gap-1.5 text-[15px] font-bold text-[var(--vs-noir)]">
            <ArrowLeft aria-hidden size={18} />
            Retour à la connexion
          </Link>
        </div>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
