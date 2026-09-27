'use client';

import { useState } from 'react';
import { PILULE, PILULE_OFF, PILULE_ON } from '@/components/catalogue/filtres-affichage';
import { CarteCommande } from '@/components/compte/CarteCommande';
import { SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, filtrerCommandes, libelleCommandes, type Client, type FiltreCommandes } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

const FILTRES: { valeur: FiltreCommandes; libelle: string }[] = [
  { valeur: 'toutes', libelle: 'Toutes' },
  { valeur: 'en-cours', libelle: 'En cours' },
  { valeur: 'livrees', libelle: 'Livrées' },
  { valeur: 'annulees', libelle: 'Annulées' },
];

function Liste({ client }: { client: Client }) {
  const [filtre, setFiltre] = useState<FiltreCommandes>('toutes');
  const commandes = filtrerCommandes(commandesDe(client), filtre);
  return (
    <>
      <h1 className={TITRE_PAGE}>Mes commandes</h1>
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap gap-2.5">
          {FILTRES.map((f) => (
            <button key={f.valeur} type="button" aria-pressed={f.valeur === filtre} onClick={() => setFiltre(f.valeur)}
              className={`${PILULE} ${f.valeur === filtre ? PILULE_ON : PILULE_OFF}`}>
              {f.libelle}
            </button>
          ))}
        </div>
        <p data-testid="commandes-nombre" className={SOUS_TITRE}>{libelleCommandes(commandes.length)}</p>
      </div>
      {commandes.length > 0
        ? commandes.map((c) => <CarteCommande key={c.numero} commande={c} />)
        : <p data-testid="commandes-vides" className={SOUS_TITRE}>Aucune commande dans cette catégorie.</p>}
    </>
  );
}

export default function PageCommandes() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Mes commandes' }]} />
        <EspaceClient actif="commandes">
          {session.client && <Liste client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
