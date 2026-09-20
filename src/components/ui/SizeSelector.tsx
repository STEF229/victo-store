import { ReactNode } from 'react';

interface SizeOption {
  value: string;
  available: boolean;
}

interface SizeSelectorProps {
  sizes: SizeOption[];
  value?: string | null;
  onChange: (value: string) => void;
  label?: string;
  className?: string;
}

export function SizeSelector({
  sizes,
  value = null,
  onChange,
  label = 'Taille',
  className = '',
}: SizeSelectorProps) {
  const handleClick = (sizeValue: string) => {
    if (sizes.find(s => s.value === sizeValue)?.available) {
      onChange(sizeValue);
    }
  };

  return (
    <div 
      data-ui="size-selector" 
      role="group"
      aria-label={label}
      className={className}
    >
      {sizes.map((sizeOption) => (
        <button
          key={sizeOption.value}
          type="button"
          onClick={() => handleClick(sizeOption.value)}
          disabled={!sizeOption.available}
          aria-pressed={value === sizeOption.value ? 'true' : 'false'}
          className={`
            w-10 h-10 flex items-center justify-center
            border rounded-md
            ${sizeOption.available 
              ? 'cursor-pointer hover:bg-[var(--vs-surface)]' 
              : 'cursor-not-allowed opacity-50'
            }
            ${value === sizeOption.value 
              ? 'bg-[var(--vs-noir)] text-[var(--vs-blanc]) border-[var(--vs-noir)]' 
              : 'border-[var(--vs-ligne)] text-[var(--vs-gris])'
            }
            ${!sizeOption.available ? 'line-through' : ''}
          `}
        >
          {sizeOption.value}
        </button>
      ))}
    </div>
  );
}
