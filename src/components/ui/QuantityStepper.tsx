import { clampQuantity } from '../../lib/clampQuantity';

interface QuantityStepperProps {
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  className?: string;
}

export function QuantityStepper({
  value,
  onChange,
  min = 1,
  max = 99,
  className = '',
}: QuantityStepperProps) {
  const handleDecrement = () => {
    const newValue = clampQuantity(value - 1, min, max);
    if (newValue < value) {
      onChange(newValue);
    }
  };

  const handleIncrement = () => {
    const newValue = clampQuantity(value + 1, min, max);
    if (newValue > value) {
      onChange(newValue);
    }
  };

  return (
    <div data-ui="quantity" className={className}>
      <button
        type="button"
        aria-label="Diminuer la quantité"
        disabled={value <= min}
        onClick={handleDecrement}
        className="p-2 rounded-md bg-[var(--vs-surface)] text-[var(--vs-gris)] hover:bg-[var(--vs-ligne)] disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span className="sr-only">Diminuer la quantité</span>
        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
          <path fillRule="evenodd" d="M5 10a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1z" clipRule="evenodd" />
        </svg>
      </button>
      
      <span data-testid="quantite-valeur" className="mx-2 w-8 text-center">
        {value}
      </span>
      
      <button
        type="button"
        aria-label="Augmenter la quantité"
        disabled={value >= max}
        onClick={handleIncrement}
        className="p-2 rounded-md bg-[var(--vs-surface)] text-[var(--vs-gris)] hover:bg-[var(--vs-ligne)] disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span className="sr-only">Augmenter la quantité</span>
        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
          <path fillRule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z" clipRule="evenodd" />
        </svg>
      </button>
    </div>
  );
}
