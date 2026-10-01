TICKET 108m — l'en-tête utilise la nouvelle navigation et le menu mobile

Modifie `src/components/ui/SiteHeader.tsx`. Deux éléments sont remplacés par les
composants des tickets 108k et 108l, qui reprennent exactement leur rôle.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change : logo, champ de recherche, « Mon compte » et panier restent
  tels quels. `export type NavItem` (ou `interface NavItem`) reste exporté par ce fichier.
- `noUnusedLocals` est actif : retire ce qui ne sert plus (voir l'étape 4).

## Les quatre changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { MenuMobile } from '@/components/navigation/MenuMobile';
   import { NavigationPrincipale } from '@/components/navigation/NavigationPrincipale';
   ```
2. Remplace tout l'élément `<nav aria-label="Navigation principale" …>…</nav>` par :
   `<NavigationPrincipale navItems={navItems} />`
3. Remplace tout l'élément `<button … aria-label="Ouvrir le menu" …>…</button>` par :
   `<MenuMobile navItems={navItems} />`
4. Retire de `SiteHeader.tsx` ce qui ne sert plus : la fonction `classeLien`, la ligne
   `const chemin: string | null = usePathname();`, l'import de `usePathname`, et l'icône
   `Menu` de l'import `lucide-react` si plus rien ne l'utilise.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`,
`tests/entete-page-active.test.tsx` et `tests/finitions-SiteHeader.test.tsx`.
