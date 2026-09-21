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
      <ul className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12">
        {ENGAGEMENTS.map((e) => (
          <li key={e.titre} className="flex flex-col">
            <div className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4">
              {e.icone === 'camion' && <Truck aria-hidden size={24} />}
              {e.icone === 'retour' && <RotateCcw aria-hidden size={24} />}
              {e.icone === 'cadenas' && <Lock aria-hidden size={24} />}
            </div>
            <h3 className="text-lg font-bold mb-2">{e.titre}</h3>
            <p className="text-[var(--vs-gris)]">{e.texte}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
