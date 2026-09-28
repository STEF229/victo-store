TICKET 103d — lien « Voir le détail » sur chaque carte de commande

Modifie `src/components/compte/CarteCommande.tsx`. Le fichier actuel est correct et
testé : deux ajouts, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde les imports actuels ; aucune classe, aucun texte existant ne change.

## Les deux ajouts
1. En tête des imports, ajoute `import Link from 'next/link';`.
2. Juste après la balise fermante `</ul>`, avant `</article>`, ajoute exactement :
   ```tsx
   <Link href={`/compte/commandes/${commande.numero}`} className="self-start text-[15px] font-bold text-[var(--vs-noir)] underline">
     Voir le détail
   </Link>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/CarteCommande.test.tsx`.
