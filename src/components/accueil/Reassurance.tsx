'use client';

import { ReactNode } from 'react';

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
              {e.icone === 'camion' && (
                <svg 
                  aria-hidden="true" 
                  width="24" 
                  height="24" 
                  viewBox="0 0 24 24" 
                  fill="none" 
                  stroke="currentColor"
                  strokeWidth="2"
                >
                  <path d="M1 12v6a2 2 0 0 0 2 2h18a2 2 0 0 0 2-2v-6" />
                  <path d="M19 12V8a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v4" />
                  <path d="M12 12h.01" />
                  <path d="M12 16h.01" />
                </svg>
              )}
              {e.icone === 'retour' && (
                <svg 
                  aria-hidden="true" 
                  width="24" 
                  height="24" 
                  viewBox="0 0 24 24" 
                  fill="none" 
                  stroke="currentColor"
                  strokeWidth="2"
                >
                  <path d="M3 12h.01M3 12a9 9 0 1 1 18 0 9 9 0 0 1-18 0z" />
                  <path d="M12 16v-4m0-4l-4 4" />
                </svg>
              )}
              {e.icone === 'cadenas' && (
                <svg 
                  aria-hidden="true" 
                  width="24" 
                  height="24" 
                  viewBox="0 0 24 24" 
                  fill="none" 
                  stroke="currentColor"
                  strokeWidth="2"
                >
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
              )}
            </div>
            <h3 className="text-lg font-bold mb-2">{e.titre}</h3>
            <p className="text-[var(--vs-gris)]">{e.texte}</p>
          </li>
        ))}
      </ul>
    </section>
  );
}
