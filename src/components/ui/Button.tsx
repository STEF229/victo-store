import { ButtonHTMLAttributes, forwardRef } from 'react';
import { TOKENS } from '../../lib/tokens';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'ghost' | 'accent';
  size?: 'sm' | 'md' | 'lg';
  block?: boolean;
  loading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      block = false,
      loading = false,
      className = '',
      ...props
    },
    ref
  ) => {
    const baseClasses = `
      inline-flex items-center justify-center
      font-medium rounded-md transition-colors
      focus:outline-none focus:ring-2 focus:ring-offset-2
      disabled:opacity-50 disabled:cursor-not-allowed
    `;

    const variantClasses = {
      primary: `
        bg-[var(--vs-noir)] text-[var(--vs-blanc)]
        hover:bg-[var(--vs-noir)]
        focus:ring-[var(--vs-noir)]
      `,
      accent: `
        bg-[var(--vs-accent)] text-white
        hover:bg-[var(--vs-accent-fonce)]
        focus:ring-[var(--vs-accent)]
      `,
      ghost: `
        bg-transparent text-[var(--vs-noir)] border border-[var(--vs-noir)]
        hover:bg-[var(--vs-surface)]
        focus:ring-[var(--vs-noir)]
      `,
    };

    const sizeClasses = {
      sm: 'text-sm px-3 py-1.5',
      md: 'text-base px-4 py-2',
      lg: 'text-lg px-6 py-3',
    };

    const blockClass = block ? 'w-full' : '';

    const loadingClass = loading ? 'opacity-75 cursor-not-allowed' : '';

    const combinedClasses = [
      baseClasses,
      variantClasses[variant],
      sizeClasses[size],
      blockClass,
      loadingClass,
      className,
    ].join(' ');

    const dataAttributes: Record<string, string> = {
      'data-ui': 'button',
      'data-variant': variant,
      'data-size': size,
    };

    if (block) {
      dataAttributes['data-block'] = 'true';
    }

    // Handle loading state
    const disabled = props.disabled || loading;

    // Handle aria-busy attribute
    const ariaProps = loading ? { 'aria-busy': 'true' } : {};

    return (
      <button
        ref={ref}
        type={props.type || 'button'}
        disabled={disabled}
        className={combinedClasses}
        {...dataAttributes}
        {...ariaProps}
        {...props}
      />
    );
  }
);
