'use client';

export function BarreAnnonce() {
  return (
    <div 
      data-testid="barre-annonce"
      className="bg-[var(--vs-noir)] text-[var(--vs-blanc)] h-10 text-sm font-bold flex items-center justify-center"
    >
      <ul className="flex items-center justify-center gap-7">
        <li>Livraison offerte au Canada</li>
        <li className="hidden sm:flex">Retours gratuits 30 jours</li>
        <li className="hidden sm:flex">Authenticité garantie</li>
      </ul>
    </div>
  );
}
