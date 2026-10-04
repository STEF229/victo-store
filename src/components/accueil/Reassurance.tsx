'use client';

import { ReactNode } from 'react';
import { Lock, RotateCcw, Truck } from 'lucide-react';

const ENGAGEMENTS = [
  { titre: 'Livraison offerte au Canada', texte: 'Expédiée du Québec sous 48 heures.', icone: 'camion' },
  { titre: 'Retours gratuits 30 jours', texte: 'Une taille qui ne va pas ? On l’échange.', icone: 'retour' },
  { titre: 'Paiement sécurisé', texte: 'Vos données de carte ne transitent jamais par nos serveurs.', icone: 'cadenas' },
] as const;

export function Reassurance() {
  return (
    <section data-testid="reassurance" className="border-t border-[var(--vs-ligne)]">
      <ul className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12 max-sm:gap-5">
        {ENGAGEMENTS.map((e) => (
          <li key={e.titre} className="flex flex-col max-sm:flex-row max-sm:items-start max-sm:gap-4">
            <div className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4 shrink-0 max-sm:mb-0 max-sm:h-11 max-sm:w-11">
              {e.icone === 'camion' && <Truck aria-hidden size={24} />}
              {e.icone === 'retour' && <RotateCcw aria-hidden size={24} />}
              {e.icone === 'cadenas' && <Lock aria-hidden size={24} />}
            </div>
            <div>
              <h3 className="text-lg font-bold mb-2 max-sm:mb-1 max-sm:text-base">{e.titre}</h3>
              <p className="text-[var(--vs-gris)] max-sm:text-sm">{e.texte}</p>
            </div>
          </li>
        ))}
      </ul>
    </section>
  );
}
