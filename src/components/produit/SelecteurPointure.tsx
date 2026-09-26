import type { Variante } from '@/lib/catalogue';

interface SelecteurPointureProps {
  variantes: Variante[];
  valeur: string | null;
  onChoisir: (taille: string) => void;
}

export function SelecteurPointure({ variantes, valeur, onChoisir }: SelecteurPointureProps) {
  return (
    <div data-testid="selecteur-pointure" className="flex flex-col gap-3.5">
      <span id="libelle-pointure" className="text-[15px] font-extrabold text-[var(--vs-noir)]">
        Pointure{' '}
        <span data-testid="pointure-choisie" className="font-medium text-[var(--vs-gris)]">
          {valeur ?? '— à choisir'}
        </span>
      </span>
      <div role="group" aria-labelledby="libelle-pointure" className="grid grid-cols-3 gap-2.5 sm:grid-cols-6">
        {variantes.map((v) => {
          const choisie = v.taille === valeur;
          const epuisee = v.stock <= 0;
          
          return (
            <button
              key={v.id}
              type="button"
              aria-pressed={choisie}
              disabled={epuisee}
              onClick={() => onChoisir(v.taille)}
              className={choisie
                ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
                : epuisee
                  ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold cursor-not-allowed border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[#B5B5BA] line-through'
                  : 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
            >
              {v.taille}
            </button>
          );
        })}
      </div>
    </div>
  );
}
