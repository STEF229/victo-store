import { InputHTMLAttributes } from 'react';

interface FieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'id'> {
  id: string;
  label: string;
  hint?: string;
  error?: string;
}

export function Field({ 
  id, 
  label, 
  hint, 
  error, 
  type = 'text',
  ...props 
}: FieldProps) {
  const hasHint = !!hint;
  const hasError = !!error;
  const describedBy: string[] = [];

  if (hasHint) {
    describedBy.push(`${id}-hint`);
  }

  if (hasError) {
    describedBy.push(`${id}-error`);
  }

  const ariaDescribedBy = describedBy.length > 0 ? describedBy.join(' ') : undefined;
  
  return (
    <div className="flex flex-col gap-1">
      <label htmlFor={id} className="text-[var(--vs-noir)] font-medium">
        {label}
      </label>
      
      <input
        id={id}
        type={type}
        aria-describedby={ariaDescribedBy}
        aria-invalid={hasError ? 'true' : undefined}
        className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-[var(--vs-accent)] ${
          hasError 
            ? 'border-[var(--vs-accent)] bg-[var(--vs-blanc)]' 
            : 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)]'
        }`}
        {...props}
      />
      
      {hasHint && (
        <p id={`${id}-hint`} className="text-[var(--vs-gris)] text-sm">
          {hint}
        </p>
      )}
      
      {hasError && (
        <p id={`${id}-error`} role="alert" className="text-[var(--vs-accent)] text-sm">
          {error}
        </p>
      )}
    </div>
  );
}
