'use client';

import { ArrowLeft, Check, Truck } from 'lucide-react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { CARTE, CLASSES_STATUT, LIBELLES_STATUT, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, formaterDate, totauxCommande, type Client, type StatutCommande } from '@/lib/compte';
import { formatPrice } from '@/lib/formatPrice';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { libelleArticles } from '@/lib/panier-detail';

const ETAPES = ['Confirmée', 'En préparation', 'Expédiée', 'Livrée'] as const;
const ATTEINTE: Record<Exclude<StatutCommande, 'annulee'>, number> = { preparation: 1, expediee: 2, livree: 3 };
const LIGNE_RECAP = 'flex justify-between';

function Detail({ client, numero }: { client: Client; numero: string }) {
  const commande = commandesDe(client).find((c) => c.numero === numero);
  
  if (!commande) {
    return (
      <>
        <h1 className={TITRE_PAGE}>Commande introuvable</h1>
        <p data-testid="commande-introuvable" className={SOUS_TITRE}>{`Aucune commande ${numero} dans votre compte.`}</p>
        <Link href="/compte/commandes" className={LIEN}>Toutes mes commandes</Link>
      </>
    );
  }
  
  const totaux = totauxCommande(commande);
  const adresse = client.adresses.find((a) => a.id === commande.adresseId);
  const atteinte = commande.statut === 'annulee' ? -1 : ATTEINTE[commande.statut];
  
  return (
    <>
      <Link href="/compte/commandes" className="flex items-center gap-1.5 self-start text-[15px] font-bold text-[var(--vs-noir)]">
        <ArrowLeft aria-hidden size={18} />
        Toutes mes commandes
      </Link>
      <div className="flex flex-col gap-2.5">
        <h1 className={TITRE_PAGE}>{`Commande ${commande.numero}`}</h1>
        <p className={SOUS_TITRE}>{`Passée le ${formaterDate(commande.date)}`}</p>
      </div>
      <section data-testid="suivi" className={CARTE}>
        <div className="flex items-center justify-between gap-4">
          <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Suivi</h2>
          <span data-testid="detail-statut" className={CLASSES_STATUT[commande.statut]}>{LIBELLES_STATUT[commande.statut]}</span>
        </div>
        {commande.statut === 'annulee' ? (
          <p data-testid="commande-annulee" className={SOUS_TITRE}>Cette commande a été annulée. Aucun montant n'a été débité.</p>
        ) : (
          <ol className="grid grid-cols-4 gap-2">
            {ETAPES.map((etape, i) => (
              <li key={etape} data-testid="etape" data-etat={i <= atteinte ? 'faite' : 'a-venir'} className="flex flex-col gap-2">
                <span className={i <= atteinte
                  ? 'flex h-[30px] w-[30px] items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
                  : 'flex h-[30px] w-[30px] rounded-full border-2 border-[var(--vs-ligne)]'}>
                  {i <= atteinte && <Check aria-hidden size={16} />}
                </span>
                <span className="text-sm font-bold text-[var(--vs-noir)]">{etape}</span>
              </li>
            ))}
          </ol>
        )}
        {commande.suivi !== null && (
          <p data-testid="suivi-colis" className="flex items-center gap-2.5 text-sm text-[var(--vs-gris)]">
            <Truck aria-hidden size={19} />
            {`Postes Canada · n° de suivi ${commande.suivi}`}
          </p>
        )}
      </section>
      <div className="grid gap-7 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:items-start">
        <section className="flex flex-col gap-1.5">
          <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">{libelleArticles(totaux.articles)}</h2>
          <ul>
            {commande.lignes.map((l) => (
              <li key={`${l.slug}-${l.taille}`} data-testid="ligne-commande"
                className="flex items-center justify-between gap-4 border-b border-[var(--vs-ligne)] py-4">
                <div className="flex flex-col gap-1">
                  <span className="text-xs font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]">{l.marque}</span>
                  <Link href={`/produits/${l.slug}`} className="text-base font-extrabold text-[var(--vs-noir)]">{l.nom}</Link>
                  <span className="text-sm text-[var(--vs-gris)]">{`Pointure ${l.taille} · Quantité ${l.quantite}`}</span>
                </div>
                <span className="text-base font-extrabold text-[var(--vs-noir)]">{formatPrice(l.prixCents * l.quantite)}</span>
              </li>
            ))}
          </ul>
        </section>
        <div className="flex flex-col gap-5">
          <section className="flex flex-col gap-3 rounded-3xl bg-[var(--vs-surface)] p-[26px] text-[15px]">
            <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Récapitulatif</h2>
            <div className={LIGNE_RECAP}><span>Sous-total</span><span data-testid="detail-sous-total" className="font-bold">{formatPrice(totaux.sousTotalCents)}</span></div>
            {totaux.economiesCents > 0 && (
              <div className={`${LIGNE_RECAP} text-[var(--vs-promo)]`}><span>Vos économies</span><span className="font-bold">{`\u2212${formatPrice(totaux.economiesCents)}`}</span></div>
            )}
            <div className={LIGNE_RECAP}><span>Livraison</span><span className="font-bold">Offerte</span></div>
            <div className={LIGNE_RECAP}><span>TPS (5 %)</span><span data-testid="detail-tps" className="font-bold">{formatPrice(totaux.tpsCents)}</span></div>
            <div className={LIGNE_RECAP}><span>TVQ (9,975 %)</span><span data-testid="detail-tvq" className="font-bold">{formatPrice(totaux.tvqCents)}</span></div>
            <div className="h-px bg-[var(--vs-ligne)]" />
            <div className="flex items-baseline justify-between"><span className="font-extrabold">Total payé</span><span data-testid="detail-total" className="text-2xl font-black">{formatPrice(totaux.totalCents)}</span></div>
          </section>
          <section data-testid="detail-livraison" className={CARTE}>
            <h2 className="text-base font-extrabold text-[var(--vs-noir)]">Livraison</h2>
            {adresse ? (
              <p className="text-[15px] leading-relaxed">
                {adresse.nomComplet}<br />{adresse.ligne1}<br />{`${adresse.ville} (${adresse.province}) ${adresse.codePostal}`}
              </p>
            ) : (
              <p className={SOUS_TITRE}>Adresse non disponible.</p>
            )}
            <h2 className="text-base font-extrabold text-[var(--vs-noir)]">Paiement</h2>
            <p className="text-[15px]">{commande.paiement}</p>
          </section>
        </div>
      </div>
    </>
  );
}

export default function PageDetailCommande() {
  const session = useSession();
  const params = useParams<{ numero: string }>();
  const numero = params.numero;
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[
          { label: 'Accueil', href: '/' },
          { label: 'Mon compte', href: '/compte' },
          { label: 'Mes commandes', href: '/compte/commandes' },
          { label: `Commande ${numero}` },
        ]} />
        <EspaceClient actif="commandes">
          {session.client && <Detail client={session.client} numero={numero} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
