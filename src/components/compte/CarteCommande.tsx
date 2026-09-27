import { CARTE, CLASSES_STATUT, LIBELLES_STATUT } from '@/components/compte/compte-affichage';
import { formaterDate, totauxCommande, type Commande } from '@/lib/compte';
import { formatPrice } from '@/lib/formatPrice';
import { libelleArticles } from '@/lib/panier-detail';

export function CarteCommande({ commande }: { commande: Commande }) {
  const totaux = totauxCommande(commande);
  
  return (
    <article data-testid="carte-commande" className={CARTE}>
      <div className="flex items-start justify-between gap-4">
        <div className="flex flex-col gap-1">
          <h3 className="text-[17px] font-extrabold text-[var(--vs-noir)]">{`Commande ${commande.numero}`}</h3>
          <p data-testid="commande-resume" className="text-sm text-[var(--vs-gris)]">
            {`${formaterDate(commande.date)} · ${libelleArticles(totaux.articles)} · ${formatPrice(totaux.totalCents)}`}
          </p>
        </div>
        <span data-testid="commande-statut" className={CLASSES_STATUT[commande.statut]}>
          {LIBELLES_STATUT[commande.statut]}
        </span>
      </div>
      <ul className="flex flex-wrap gap-2">
        {commande.lignes.map((l) => (
          <li key={`${l.slug}-${l.taille}`} className="rounded-full bg-[var(--vs-surface)] px-3 py-1.5 text-[13px] text-[var(--vs-noir)]">
            {`${l.marque} ${l.nom} · ${l.taille}${l.quantite > 1 ? ` × ${l.quantite}` : ''}`}
          </li>
        ))}
      </ul>
    </article>
  );
}
