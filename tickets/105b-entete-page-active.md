TICKET 105b — l'en-tête marque la rubrique de la page en cours

Modifie `src/components/ui/SiteHeader.tsx`. Le fichier actuel est correct et testé :
les liens de la navigation principale indiquent la page active, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucun autre élément, aucune autre classe de l'en-tête ne change.

## Les quatre changements
1. Si elle n'y est pas déjà, ajoute à la suite des imports existants :
   `import { usePathname } from 'next/navigation';`
2. Au-dessus du composant `SiteHeader`, ajoute cette fonction locale, non exportée,
   recopiée telle quelle (un lien peut être en solde, actif, les deux, ou aucun) :
   ```tsx
   function classeLien(promo: boolean | undefined, actif: boolean): string | undefined {
     if (promo && actif) return 'text-[#FF5A74] font-extrabold underline decoration-2 underline-offset-[10px]';
     if (promo) return 'text-[#FF5A74]';
     if (actif) return 'font-extrabold underline decoration-2 underline-offset-[10px]';
     return undefined;
   }
   ```
3. Au début du corps de `SiteHeader`, ajoute exactement :
   `const chemin: string | null = usePathname();`
4. Dans `<nav aria-label="Navigation principale" …>`, remplace le `navItems.map(…)` actuel
   par exactement :
   ```tsx
   {navItems.map((item) => {
     const actif = chemin !== null && (chemin === item.href || chemin.startsWith(`${item.href}/`));
     return (
       <a key={item.href} href={item.href} aria-current={actif ? 'page' : undefined} className={classeLien(item.promo, actif)}>
         {item.label}
       </a>
     );
   })}
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`
et `tests/finitions-SiteHeader.test.tsx`.
