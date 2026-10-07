'use client';

import { Lock } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useEffect, useState, type ReactNode } from 'react';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { FormulaireAdresse } from '@/components/compte/FormulaireAdresse';
import { BOUTON_PRINCIPAL, CARTE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
import { usePanier } from '@/components/panier/PanierProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { adresseVide, donneesDe, type DonneesAdresse } from '@/lib/adresses';
import { courrielValide } from '@/lib/compte';
import { formatPrice } from '@/lib/formatPrice';
import {
  choisirLivraison, commander, enregistrerCoordonnees, lireRecap, optionsLivraison, type OptionLivraison, type RecapCommande,
} from '@/lib/medusa/commande-medusa';
import { CLE_PANIER_MEDUSA } from '@/lib/medusa/panier-medusa';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

type Etape = 'adresse' | 'livraison' | 'paiement';
const ETAPES: { cle: Etape; libelle: string }[] = [{ cle: 'adresse', libelle: 'Adresse' }, { cle: 'livraison', libelle: 'Livraison' }, { cle: 'paiement', libelle: 'Paiement' }];
const montant = (cents: number) => (cents === 0 ? 'Offerte' : formatPrice(cents));

function Recap({ recap }: { recap: RecapCommande | null }) {
  return (
    <aside data-testid="commande-recap" aria-label="Récapitulatif de la commande" className="flex flex-col gap-4 rounded-3xl bg-[var(--vs-surface)] p-7">
      <h2 className="text-lg font-black text-[var(--vs-noir)]">Récapitulatif</h2>
      {recap === null ? <p className={SOUS_TITRE}>Chargement du récapitulatif</p> : (
        <>
          <ul className="flex flex-col gap-3">
            {recap.lignes.map((l) => (
              <li key={l.id} className="flex justify-between gap-3 text-[15px]">
                <span><strong>{l.titre}</strong>{` · ${l.taille} × ${l.quantite}`}</span>
                <span className="font-bold">{formatPrice(l.totalCents)}</span>
              </li>
            ))}
          </ul>
          <div className="h-px bg-[var(--vs-ligne)]" />
          <div className="flex justify-between text-[15px]"><span>Sous-total</span><span className="font-bold">{formatPrice(recap.sousTotalCents)}</span></div>
          <div className="flex justify-between text-[15px]"><span>Livraison</span><span className="font-bold">{recap.livraisonChoisie ? montant(recap.livraisonCents) : 'À choisir'}</span></div>
          <div className="flex justify-between text-[15px]"><span>Taxes (TPS et TVQ)</span><span data-testid="commande-taxes" className="font-bold">{formatPrice(recap.taxesCents)}</span></div>
          <div className="h-px bg-[var(--vs-ligne)]" />
          <div className="flex items-baseline justify-between"><span className="text-[17px] font-black">Total</span><span data-testid="commande-total" className="text-2xl font-black">{formatPrice(recap.totalCents)}</span></div>
          <p className="text-xs text-[var(--vs-gris)]">Prix en dollars canadiens, taxes comprises dès l’adresse connue.</p>
        </>
      )}
    </aside>
  );
}

export default function PageCommande() {
  const router = useRouter();
  const { source } = useCatalogue();
  const panier = usePanier();
  const session = useSession();
  const [etape, setEtape] = useState<Etape>('adresse');
  const [courriel, setCourriel] = useState('');
  const [choix, setChoix] = useState<string>('nouvelle');
  const [adresse, setAdresse] = useState<DonneesAdresse | null>(null);
  const [options, setOptions] = useState<OptionLivraison[]>([]);
  const [optionId, setOptionId] = useState('');
  const [recap, setRecap] = useState<RecapCommande | null>(null);
  const [cgv, setCgv] = useState(false);
  const [erreur, setErreur] = useState<string | null>(null);
  const [envoi, setEnvoi] = useState(false);
  const id = panier.panierMedusa;

  useEffect(() => {
    if (id) void lireRecap(id).then(setRecap).catch(() => setRecap(null));
  }, [id, panier.nombre]);
  useEffect(() => {
    if (!session.client) return;
    setCourriel(session.client.courriel);
    const parDefaut = session.client.adresses.find((a) => a.parDefaut) ?? session.client.adresses.find(() => true);
    if (parDefaut) setChoix(parDefaut.id);
  }, [session.client]);

  async function versLivraison(d: DonneesAdresse) {
    if (!id) return;
    if (!courrielValide(courriel)) { setErreur('Indiquez un courriel valide pour recevoir la confirmation.'); return; }
    setErreur(null); setEnvoi(true);
    try {
      await enregistrerCoordonnees(id, courriel, d);
      const liste = await optionsLivraison(id);
      setAdresse(d); setOptions(liste); setOptionId(liste.find(() => true)?.id ?? ''); setEtape('livraison');
      setRecap(await lireRecap(id));
    } catch { setErreur('Impossible d’enregistrer l’adresse pour le moment. Réessayez.'); }
    setEnvoi(false);
  }
  async function versPaiement() {
    if (!id || !optionId) return;
    setErreur(null); setEnvoi(true);
    try { await choisirLivraison(id, optionId); setRecap(await lireRecap(id)); setEtape('paiement'); }
    catch { setErreur('Impossible de choisir ce mode de livraison pour le moment. Réessayez.'); }
    setEnvoi(false);
  }
  async function passerCommande() {
    if (!id || !cgv) return;
    setErreur(null); setEnvoi(true);
    const r = await commander(id);
    if ('numero' in r) {
      try { window.localStorage.removeItem(CLE_PANIER_MEDUSA); } catch { /* stockage indisponible */ }
      panier.vider();
      router.push(`/commande/confirmation?numero=${encodeURIComponent(r.numero)}`);
      return;
    }
    setErreur(r.erreur); setEnvoi(false);
  }

  let contenu: ReactNode;
  if (source !== 'medusa') {
    contenu = (
      <section data-testid="commande-indisponible" className="flex flex-col gap-4">
        <h1 className={TITRE_PAGE}>Commande</h1>
        <p className={SOUS_TITRE}>Le paiement en ligne arrive bientôt.</p>
        <Link href="/panier" className={LIEN}>Retour au panier</Link>
      </section>
    );
  } else if (panier.pret && panier.nombre === 0) {
    contenu = (
      <section data-testid="commande-vide" className="flex flex-col gap-4">
        <h1 className={TITRE_PAGE}>Votre panier est vide</h1>
        <Link href="/" className={LIEN}>Continuer mes achats</Link>
      </section>
    );
  } else if (!panier.pret || !id) {
    contenu = <p data-testid="commande-preparation" aria-busy="true" className={SOUS_TITRE}>Préparation de votre panier en cours</p>;
  } else {
    const adresses = session.client?.adresses ?? [];
    const choisie = adresses.find((a) => a.id === choix);
    const initiales = { ...adresseVide(session.client ? `${session.client.prenom} ${session.client.nom}`.trim() : ''), libelle: 'Livraison' };
    contenu = (
      <div className="grid gap-10 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:items-start lg:gap-12">
        <div className="flex flex-col gap-7">
          <h1 className={TITRE_PAGE}>Commande</h1>
          <ol aria-label="Étapes de la commande" className="flex flex-wrap gap-3">
            {ETAPES.map((e, i) => (
              <li key={e.cle} aria-current={e.cle === etape ? 'step' : undefined}
                className={e.cle === etape ? 'rounded-full bg-[var(--vs-noir)] px-4 py-2 text-sm font-extrabold text-[var(--vs-blanc)]' : 'rounded-full border-[1.5px] border-[var(--vs-ligne)] px-4 py-2 text-sm font-bold text-[var(--vs-gris)]'}>
                {`${i + 1}. ${e.libelle}`}
              </li>
            ))}
          </ol>
          {erreur && <p role="alert" data-testid="commande-erreur" className={`${CARTE} ${CHAMP_ERREUR}`}>{erreur}</p>}
          {etape === 'adresse' && (
            <section className="flex flex-col gap-5">
              {session.client ? (
                <p className={SOUS_TITRE}>{`Connecté en tant que ${session.client.prenom} ${session.client.nom} · ${session.client.courriel}`}</p>
              ) : (
                <div className={CHAMP}>
                  <label htmlFor="commande-courriel" className={CHAMP_LIBELLE}>Courriel</label>
                  <input id="commande-courriel" type="email" autoComplete="email" value={courriel} onChange={(e) => setCourriel(e.target.value)} className={CHAMP_SAISIE} />
                  <p className="text-[13px] text-[var(--vs-gris)]">Pour la confirmation et le suivi. <Link href="/connexion" className={LIEN}>Se connecter</Link> pour retrouver vos adresses.</p>
                </div>
              )}
              {choisie ? (
                <div className="flex flex-col gap-3" role="radiogroup" aria-label="Adresse de livraison">
                  {adresses.map((a) => (
                    <label key={a.id} className={a.id === choix ? 'flex cursor-pointer items-start gap-3 rounded-2xl border-2 border-[var(--vs-accent)] p-4' : 'flex cursor-pointer items-start gap-3 rounded-2xl border-[1.5px] border-[var(--vs-ligne)] p-4'}>
                      <input type="radio" name="adresse" checked={a.id === choix} onChange={() => setChoix(a.id)} className="mt-1 h-5 w-5 accent-[var(--vs-accent)]" />
                      <span><strong>{a.libelle}</strong>{` — ${a.nomComplet}, ${a.ligne1}, ${a.ville} (${a.province}) ${a.codePostal}`}</span>
                    </label>
                  ))}
                  <button type="button" onClick={() => setChoix('nouvelle')} className={LIEN}>+ Livrer à une nouvelle adresse</button>
                  <button type="button" disabled={envoi} onClick={() => void versLivraison(donneesDe(choisie))} className={BOUTON_PRINCIPAL}>Continuer vers la livraison</button>
                </div>
              ) : (
                <FormulaireAdresse initiales={initiales} titre="Adresse de livraison" libelleBouton="Continuer vers la livraison"
                  onEnregistrer={(d) => void versLivraison(d)}
                  onAnnuler={() => (adresses.length > 0 ? setChoix(adresses.find(() => true)?.id ?? 'nouvelle') : router.push('/panier'))} />
              )}
            </section>
          )}
          {etape === 'livraison' && (
            <section className="flex flex-col gap-4">
              {adresse && <p className={SOUS_TITRE}>{`Livraison à ${adresse.nomComplet}, ${adresse.ligne1}, ${adresse.ville} (${adresse.province})`} <button type="button" onClick={() => setEtape('adresse')} className={LIEN}>Modifier</button></p>}
              <div role="radiogroup" aria-label="Mode de livraison" className="flex flex-col gap-3">
                {options.map((o) => (
                  <label key={o.id} className={o.id === optionId ? 'flex cursor-pointer items-center justify-between gap-3 rounded-2xl border-2 border-[var(--vs-accent)] p-4' : 'flex cursor-pointer items-center justify-between gap-3 rounded-2xl border-[1.5px] border-[var(--vs-ligne)] p-4'}>
                    <span className="flex items-center gap-3">
                      <input type="radio" name="livraison" checked={o.id === optionId} onChange={() => setOptionId(o.id)} className="h-5 w-5 accent-[var(--vs-accent)]" />
                      <strong>{o.nom}</strong>
                    </span>
                    <span className="font-extrabold">{montant(o.montantCents)}</span>
                  </label>
                ))}
              </div>
              <button type="button" disabled={envoi || !optionId} onClick={() => void versPaiement()} className={BOUTON_PRINCIPAL}>Continuer vers le paiement</button>
            </section>
          )}
          {etape === 'paiement' && (
            <section className="flex flex-col gap-4">
              <div className={CARTE}>
                <p className="flex items-center gap-2 font-extrabold"><Lock aria-hidden size={17} />Paiement manuel (mode essai)</p>
                <p className={SOUS_TITRE}>Aucune carte n’est demandée : la commande est enregistrée sans être débitée. Le paiement par carte (Stripe) remplacera cette étape.</p>
              </div>
              <label className="flex items-start gap-2.5 text-sm leading-relaxed">
                <input id="commande-cgv" type="checkbox" checked={cgv} onChange={(e) => setCgv(e.target.checked)} className="mt-0.5 h-5 w-5 accent-[var(--vs-noir)]" />
                <span>J’ai lu et j’accepte les <Link href="/conditions-de-vente" className={LIEN}>conditions de vente</Link> et la <Link href="/confidentialite" className={LIEN}>politique de confidentialité</Link>.</span>
              </label>
              <button type="button" disabled={envoi || !cgv} onClick={() => void passerCommande()} className={BOUTON_PRINCIPAL}>
                {`Commander — ${recap ? formatPrice(recap.totalCents) : ''}`}
              </button>
              <button type="button" onClick={() => setEtape('livraison')} className={LIEN}>← Livraison</button>
            </section>
          )}
        </div>
        <Recap recap={recap} />
      </div>
    );
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Panier', href: '/panier' }, { label: 'Commande' }]} />
        {contenu}
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
