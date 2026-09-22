TICKET 090 — en-tête : barre noire unique

Réécris `src/components/ui/SiteHeader.tsx` d'après la maquette validée : **une
seule barre noire** contenant le logo, la navigation centrée, la recherche et les
actions, suivie d'un **filet clair** reprenant les arguments de vente. L'ancienne
rangée blanche et l'ancien composant `BarreAnnonce` disparaissent.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Contrats existants à conserver
`tests/SiteHeader.test.tsx` doit rester vert : rôle `banner` ; lien
`data-testid="entete-marque"` vers `/` contenant `VICTO` ; une seule
`<nav aria-label="Navigation principale">` avec un lien par entrée ;
`data-testid="entete-panier"` vers `/panier` avec `data-cart-count` et
`aria-label` `Panier, N article` ou `Panier, N articles` ; pastille
`data-testid="entete-panier-compte"` uniquement si le panier n'est pas vide.
Le type `NavItem` (avec `promo?: boolean`) reste exporté.

## Bloc d'imports exact
```tsx
import { Menu, Search, ShoppingBag, User } from 'lucide-react';
```

## Structure exacte — recopie ce rendu

```tsx
return (
  <>
    <header data-testid="entete" className="bg-[var(--vs-noir)] text-[var(--vs-blanc)]">
      <div className="grid h-20 grid-cols-[auto_1fr_auto] items-center gap-6 px-5 lg:px-12">
        <div className="flex items-center gap-2">
          <button type="button" aria-label="Ouvrir le menu" className="flex h-11 w-11 items-center justify-center lg:hidden">
            <Menu aria-hidden size={22} />
          </button>
          <a href="/" data-testid="entete-marque" className="text-[23px] font-black tracking-[0.1em] whitespace-nowrap">
            VICTO STORE
          </a>
        </div>

        <nav aria-label="Navigation principale" className="hidden justify-self-center gap-8 text-[15px] font-semibold lg:flex">
          {navItems.map((item) => (
            <a key={item.href} href={item.href} className={item.promo ? 'text-[#FF5A74]' : undefined}>
              {item.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center justify-self-end gap-2">
          <label htmlFor="recherche-entete" className="sr-only">Rechercher un produit</label>
          <div className="hidden h-11 w-[250px] items-center gap-2 rounded-full border border-[#2A2A30] bg-[#1E1E26] px-4 lg:flex">
            <Search aria-hidden size={17} />
            <input
              id="recherche-entete"
              type="search"
              placeholder="Rechercher"
              className="h-10 min-w-0 flex-1 border-none bg-transparent text-sm text-[var(--vs-blanc)] outline-none"
            />
          </div>
          <button type="button" aria-label="Mon compte" className="hidden h-11 w-11 items-center justify-center lg:flex">
            <User aria-hidden size={21} />
          </button>
          <a href="/panier" data-testid="entete-panier" data-cart-count={cartCount} aria-label={libellePanier}
             className="relative flex h-11 w-11 items-center justify-center">
            <ShoppingBag aria-hidden size={21} />
            {cartCount > 0 && (
              <span data-testid="entete-panier-compte"
                    className="absolute right-0 top-1 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-[var(--vs-accent)] px-1 text-[11px] font-extrabold">
                {cartCount}
              </span>
            )}
          </a>
        </div>
      </div>
    </header>

    <div data-testid="filet-annonce"
         className="flex h-9 items-center justify-center gap-6 border-b border-[var(--vs-ligne)] bg-[var(--vs-surface)] text-[12.5px] font-semibold text-[var(--vs-gris)]">
      <span>Livraison offerte au Canada</span>
      <span className="hidden sm:inline">Retours gratuits 30 jours</span>
      <span className="hidden sm:inline">Authenticité garantie</span>
    </div>
  </>
);
```

`libellePanier` garde sa formule actuelle : `Panier, N article` quand `N <= 1`,
`Panier, N articles` au-delà. `cartCount` vaut `0` par défaut.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
