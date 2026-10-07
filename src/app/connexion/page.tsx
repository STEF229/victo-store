'use client';

import { Eye, EyeOff, Gift, Heart, Package } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { quand } from '@/lib/quand';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';

export default function PageConnexion() {
  const session = useSession();
  const demo = useCatalogue().source !== 'medusa';
  const router = useRouter();
  const [courriel, setCourriel] = useState('');
  const [motDePasse, setMotDePasse] = useState('');
  const [voir, setVoir] = useState(false);
  const [erreur, setErreur] = useState(false);

  function soumettre(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    quand(session.connexion(courriel, motDePasse), (ok) => {
      if (ok) {
        setErreur(false);
        router.push('/compte');
      } else {
        setErreur(true);
      }
    });
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Connexion' }]} />
        <div className="grid gap-12 lg:grid-cols-2 lg:gap-16">
          <form onSubmit={soumettre} noValidate className="flex w-full max-w-[480px] flex-col gap-[22px]">
            <div className="flex flex-col gap-2.5">
              <h1 className={TITRE_PAGE}>Connexion</h1>
              <p className={SOUS_TITRE}>Heureux de vous revoir.</p>
            </div>
            {demo && (
              <p data-testid="connexion-demo" className="rounded-2xl bg-[var(--vs-surface)] p-4 text-sm text-[var(--vs-noir)]">
                {`Compte de démonstration : ${COURRIEL_DEMO} — mot de passe ${MOT_DE_PASSE_DEMO}`}
              </p>
            )}
            <div className={CHAMP}>
              <label htmlFor="courriel" className={CHAMP_LIBELLE}>Courriel</label>
              <input id="courriel" type="email" autoComplete="email" value={courriel}
                onChange={(e) => setCourriel(e.target.value)} className={CHAMP_SAISIE} />
            </div>
            <div className={CHAMP}>
              <label htmlFor="mot-de-passe" className={CHAMP_LIBELLE}>Mot de passe</label>
              <div className="relative">
                <input id="mot-de-passe" type={voir ? 'text' : 'password'} autoComplete="current-password" value={motDePasse}
                  onChange={(e) => setMotDePasse(e.target.value)} className={CHAMP_SAISIE} />
                <button type="button" aria-label={voir ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
                  onClick={() => setVoir(!voir)}
                  className="absolute right-2 top-[7px] flex h-10 w-10 items-center justify-center text-[var(--vs-gris)]">
                  {voir ? <EyeOff aria-hidden size={19} /> : <Eye aria-hidden size={19} />}
                </button>
              </div>
            </div>
            {erreur && <p role="alert" className={CHAMP_ERREUR}>Courriel ou mot de passe incorrect.</p>}
            <div className="flex justify-end">
              <Link href="/mot-de-passe-oublie" className={LIEN}>Mot de passe oublié ?</Link>
            </div>
            <button type="submit" className={BOUTON_PRINCIPAL}>Se connecter</button>
            <Link href="/inscription" className={BOUTON_SECONDAIRE}>Créer un compte</Link>
          </form>
          <aside className="hidden flex-col gap-7 rounded-[28px] bg-[var(--vs-noir)] p-12 text-[var(--vs-blanc)] lg:flex">
            <h2 className="text-4xl font-black leading-tight tracking-tight">Tout votre shopping, au même endroit.</h2>
            <ul className="flex flex-col gap-5">
              <li className="flex items-start gap-3.5"><Package aria-hidden size={20} /><span><strong>Suivez vos commandes</strong>, de la préparation à la livraison.</span></li>
              <li className="flex items-start gap-3.5"><Heart aria-hidden size={20} /><span><strong>Gardez vos favoris</strong> sur tous vos appareils.</span></li>
              <li className="flex items-start gap-3.5"><Gift aria-hidden size={20} /><span><strong>−10 % sur la première commande</strong> avec l'infolettre.</span></li>
            </ul>
          </aside>
        </div>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
