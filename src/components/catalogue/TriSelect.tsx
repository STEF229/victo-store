'use client';

import type { Tri } from '@/lib/filtres';

interface TriSelectProps {
  value: Tri;
  onChange: (tri: Tri) => void;
  className?: string;
}

export function TriSelect({ value, onChange, className = '' }: TriSelectProps) {
  return (
    <div className={className}>
      <label htmlFor="tri">Trier par</label>
      <select
        id="tri"
        data-testid="tri"
        value={value}
        onChange={(e) => onChange(e.target.value as Tri)}
        className="border border-[var(--vs-ligne)] rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--vs-accent)]"
      >
        <option value="nouveautes">Nouveautés</option>
        <option value="prix-croissant">Prix croissant</option>
        <option value="prix-decroissant">Prix décroissant</option>
        <option value="remise">Meilleures remises</option>
      </select>
    </div>
  );
}
