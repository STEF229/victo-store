import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

describe('en-tête — lien du compte', () => {
  it('mène à l’espace client, avec son icône', () => {
    render(<SiteHeader navItems={[]} />);
    const lien = screen.getByRole('link', { name: 'Mon compte' });
    expect(lien).toHaveAttribute('href', '/compte');
    expect(lien.querySelector('svg.lucide-user')).not.toBeNull();
  });
});
