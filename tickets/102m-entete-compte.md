TICKET 102m — « Mon compte » mène à l'espace client

Modifie `src/components/ui/SiteHeader.tsx`. L'élément qui porte
`aria-label="Mon compte"` est aujourd'hui un `<button>` : il devient un lien Next
vers `/compte`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre ligne ne change : ni les classes, ni l'icône, ni les autres éléments.

## Les deux changements
1. Remplace la balise ouvrante `<button …>` de cet élément par `<Link href="/compte" …>`,
   avec **exactement les mêmes attributs**, sauf `type="button"` et un éventuel
   `onClick`, que tu retires. Remplace sa balise fermante `</button>` par `</Link>`.
   Son contenu (l'icône) ne change pas.
2. Si la ligne `import Link from 'next/link';` n'est pas déjà dans les imports,
   ajoute-la à la suite des imports existants.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
