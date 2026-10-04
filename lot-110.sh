#!/usr/bin/env bash
# VICTO STORE — lot 110 : mobile, deuxième passe (onze corrections ciblées).
#   110a carrousel compact et à faire glisser   110b sections moins espacées   110c bonnes affaires
#   110d bande des marques   110e mosaïque des catégories   110f champ de l'infolettre   110g engagements
#   110h pied de page (remplace le 109b)   110i menu du compte en pastilles   110j espace client   110k listes sur 2 colonnes
# Chaque ticket fait des remplacements EXACTS relevés dans tes fichiers ; toutes les corrections
# ajoutent des classes (souvent max-sm:, sous 640 px) sans en retirer.
# Usage :  cd ~/victo-store && bash lot-110.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
fusionne 109b && mort "le 109b a été fusionné entre-temps : le 110h ne correspond plus au pied de page, préviens-moi"
# ------------------------------------------------------------ chaque texte « avant », mot pour mot
python3 - <<'VERIF' || mort "un fichier ne correspond pas aux specs (détail ci-dessus) : rien n'a été modifié"
import json, sys
table = json.loads(r'''[["src/components/accueil/Carrousel.tsx", "import { useEffect, useState } from 'react';", "import { useEffect, useRef, useState } from 'react';", 1], ["src/components/accueil/Carrousel.tsx", "  const [index, setIndex] = useState(0);", "  const [index, setIndex] = useState(0);\n  const debutGlisse = useRef<number | null>(null);", 1], ["src/components/accueil/Carrousel.tsx", "      className=\"relative overflow-hidden\"\n    >", "      className=\"relative overflow-hidden\"\n      onTouchStart={(e) => { debutGlisse.current = e.touches[0]?.clientX ?? null; }}\n      onTouchEnd={(e) => {\n        const fin = e.changedTouches[0]?.clientX;\n        if (debutGlisse.current !== null && fin !== undefined) {\n          const ecart = fin - debutGlisse.current;\n          if (ecart < -40) allerSuivant();\n          else if (ecart > 40) allerPrecedent();\n        }\n        debutGlisse.current = null;\n      }}\n    >", 1], ["src/components/accueil/Carrousel.tsx", "className=\"grid grid-cols-1 items-center gap-10 lg:grid-cols-2\"", "className=\"grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7\"", 1], ["src/components/accueil/Carrousel.tsx", "className=\"text-5xl font-black tracking-tight lg:text-7xl\"", "className=\"text-5xl font-black tracking-tight lg:text-7xl max-sm:mt-2 max-sm:text-[30px] max-sm:leading-[1.05]\"", 2], ["src/components/accueil/Carrousel.tsx", "className=\"mt-4 text-lg\"", "className=\"mt-4 text-lg max-sm:hidden\"", 1], ["src/components/accueil/Carrousel.tsx", "className=\"mt-8 flex flex-wrap gap-4\"", "className=\"mt-8 flex flex-wrap gap-4 max-sm:mt-5 max-sm:gap-3\"", 1], ["src/components/accueil/Carrousel.tsx", "className={`rounded-full h-14 px-6 flex items-center justify-center ${", "className={`rounded-full h-14 px-6 flex items-center justify-center font-bold max-sm:h-11 max-sm:px-5 max-sm:text-[15px] ${", 1], ["src/components/accueil/Carrousel.tsx", "              <div>\n                <img src={diapo.image}", "              <div className=\"max-sm:hidden\">\n                <img src={diapo.image}", 1], ["src/components/accueil/Carrousel.tsx", "className=\"absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg\"", "className=\"absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden\"", 1], ["src/components/accueil/Carrousel.tsx", "className=\"absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg\"", "className=\"absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden\"", 1], ["src/app/page.tsx", "className=\"mx-auto max-w-[1440px] px-5 py-24 lg:px-20\"", "className=\"mx-auto max-w-[1440px] px-5 py-24 lg:px-20 max-sm:py-12\"", 1], ["src/app/page.tsx", "className=\"mx-auto max-w-[1440px] px-5 pb-24 lg:px-20\"", "className=\"mx-auto max-w-[1440px] px-5 pb-24 lg:px-20 max-sm:pb-12\"", 2], ["src/app/page.tsx", "className=\"mx-auto max-w-[1440px] px-5 py-14 lg:px-20\"", "className=\"mx-auto max-w-[1440px] px-5 py-14 lg:px-20 max-sm:py-8\"", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "className=\"text-xs uppercase text-[var(--vs-promo)]\"", "className=\"text-xs font-extrabold uppercase tracking-[0.14em] text-[var(--vs-promo)]\"", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "className=\"text-3xl font-900 mt-1\"", "className=\"text-3xl font-900 font-black tracking-tight mt-1 max-sm:text-2xl\"", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "className=\"border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full\"", "className=\"border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full shrink-0 whitespace-nowrap font-bold max-sm:border-0 max-sm:px-0 max-sm:underline max-sm:underline-offset-4\"", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "className=\"flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6\"", "className=\"flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6 max-sm:gap-3\"", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "className=\"w-[250px] shrink-0 snap-start md:w-auto\"", "className=\"w-[250px] shrink-0 snap-start md:w-auto max-sm:w-[170px]\"", 1], ["src/components/accueil/BandeMarques.tsx", "className=\"overflow-hidden border-b border-[var(--vs-ligne)] h-24\"", "className=\"overflow-hidden border-b border-[var(--vs-ligne)] h-24 max-sm:h-16\"", 1], ["src/components/accueil/BandeMarques.tsx", "className=\"uppercase text-[26px] font-900\"", "className=\"uppercase text-[26px] font-900 font-black tracking-wide max-sm:text-lg\"", 2], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"text-3xl font-900\">Par catégorie", "className=\"text-3xl font-900 font-black tracking-tight mb-6 max-sm:mb-4 max-sm:text-2xl\">Par catégorie", 1], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"relative flex h-full min-h-[190px] flex-col justify-end p-7\"", "className=\"relative flex h-full min-h-[190px] flex-col justify-end p-7 max-sm:min-h-[160px] max-sm:p-5\"", 2], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"text-3xl font-900 relative\"", "className=\"text-3xl font-900 font-black relative max-sm:text-lg\"", 1], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)]\"", "className=\"flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)] max-sm:h-10 max-sm:w-10\"", 1], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)]\"", "className=\"flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)] text-[var(--vs-noir)] max-sm:h-10 max-sm:w-10\"", 1], ["src/components/accueil/MosaiqueCategories.tsx", "text-[var(--vs-blanc])\">", "text-[var(--vs-blanc]) text-[var(--vs-blanc)]\">", 1], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"text-sm uppercase\"", "className=\"text-sm font-extrabold uppercase tracking-[0.14em]\"", 1], ["src/components/accueil/MosaiqueCategories.tsx", "className=\"text-4xl font-900\"", "className=\"text-4xl font-900 font-black max-sm:text-[28px]\"", 1], ["src/components/accueil/Infolettre.tsx", "className=\"h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)]\"", "className=\"h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)] max-sm:flex-none\"", 1], ["src/components/accueil/Reassurance.tsx", "className=\"grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12\"", "className=\"grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12 max-sm:gap-5\"", 1], ["src/components/accueil/Reassurance.tsx", "<li key={e.titre} className=\"flex flex-col\">", "<li key={e.titre} className=\"flex flex-col max-sm:flex-row max-sm:items-start max-sm:gap-4\">", 1], ["src/components/accueil/Reassurance.tsx", "className=\"flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4\"", "className=\"flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4 shrink-0 max-sm:mb-0 max-sm:h-11 max-sm:w-11\"", 1], ["src/components/accueil/Reassurance.tsx", "            <h3 className=\"text-lg font-bold mb-2\">{e.titre}</h3>\n            <p className=\"text-[var(--vs-gris)]\">{e.texte}</p>", "            <div>\n              <h3 className=\"text-lg font-bold mb-2 max-sm:mb-1 max-sm:text-base\">{e.titre}</h3>\n              <p className=\"text-[var(--vs-gris)] max-sm:text-sm\">{e.texte}</p>\n            </div>", 1], ["src/components/ui/SiteFooter.tsx", "mx-auto px-4\"", "mx-auto px-4 pt-12 pb-8 max-sm:px-5 sm:px-10 lg:px-20 lg:pt-16\"", 1], ["src/components/ui/SiteFooter.tsx", "className=\"select-none text-[200px] font-black leading-none text-[#1E1E26]\"", "className=\"block max-w-full select-none overflow-hidden whitespace-nowrap text-[200px] font-black leading-none text-[#1E1E26] max-sm:hidden\"", 1], ["src/components/ui/SiteFooter.tsx", "className=\"mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center\"", "className=\"mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center max-sm:mt-10 max-sm:items-start\"", 1], ["src/components/ui/SiteFooter.tsx", "className=\"text-[var(--vs-blanc)] mb-4 md:mb-0\"", "className=\"text-[var(--vs-blanc)] mb-4 md:mb-0 max-sm:hidden\"", 1], ["src/components/compte/MenuCompte.tsx", "className=\"flex flex-col gap-1\"", "className=\"flex flex-col gap-1 max-sm:-mx-5 max-sm:flex-row max-sm:gap-2 max-sm:overflow-x-auto max-sm:px-5 max-sm:pb-1\"", 1], ["src/components/compte/MenuCompte.tsx", "className={e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}", "className={`${e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN} max-sm:shrink-0 max-sm:whitespace-nowrap max-sm:border max-sm:border-[var(--vs-ligne)]`}", 1], ["src/components/compte/MenuCompte.tsx", "className=\"my-3 h-px bg-[var(--vs-ligne)]\"", "className=\"my-3 h-px bg-[var(--vs-ligne)] max-sm:hidden\"", 1], ["src/components/compte/MenuCompte.tsx", "className=\"flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)]\"", "className=\"flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)] max-sm:shrink-0 max-sm:whitespace-nowrap\"", 1], ["src/components/compte/EspaceClient.tsx", "className=\"grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14\"", "className=\"grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14 max-sm:gap-6\"", 1], ["src/components/catalogue/GrilleProduits.tsx", "className={`grid grid-cols-1 gap-6 sm:grid-cols-2 ${COLONNES[colonnes]} ${className}`}", "className={`grid grid-cols-1 gap-6 sm:grid-cols-2 max-sm:grid-cols-2 max-sm:gap-x-3 max-sm:gap-y-6 ${COLONNES[colonnes]} ${className}`}", 1]]''')
ko = 0
for f, avant, apres, n in table:
    try: s = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"  ✗ {f} introuvable"); ko += 1; continue
    if apres in s: print(f"  ✗ {f} : déjà modifié (lot déjà passé ?)"); ko += 1; continue
    c = s.count(avant)
    if c != n: print(f"  ✗ {f} : « {avant.splitlines()[0][:80]} » trouvé {c} fois, attendu {n}"); ko += 1
sys.exit(1 if ko else 0)
VERIF
ok "les 44 textes à remplacer sont dans tes fichiers, au bon nombre d'occurrences"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

# ------------------------------------------------------------ le 109b est remplacé par le 110h
if [ -f tickets/tests/pied-filigrane.test.tsx ] && ! git ls-files --error-unmatch tests/pied-filigrane.test.tsx >/dev/null 2>&1; then
  git rm -q -- tickets/tests/pied-filigrane.test.tsx; ok "test en attente du 109b retiré (remplacé par le 110h)"
fi
git branch -q -D auto/109b 2>/dev/null && ok "branche auto/109b supprimée" || true
GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/109b 2>/dev/null || true
mkdir -p tickets/tests
cat > 'tickets/110a-carrousel.md' <<'__VICTO_FIN_0__'
TICKET 110a — le carrousel de l'accueil, compact sur téléphone et à faire glisser

Modifie `src/components/accueil/Carrousel.tsx`. Sur téléphone : marges intérieures, titre de 30 px, description et image masquées, boutons de 44 px, flèches masquées ; on change de diapositive en glissant le doigt (plus de 40 px).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { useEffect, useState } from 'react';
```
Après :
```tsx
import { useEffect, useRef, useState } from 'react';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [index, setIndex] = useState(0);
```
Après :
```tsx
  const [index, setIndex] = useState(0);
  const debutGlisse = useRef<number | null>(null);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
      className="relative overflow-hidden"
    >
```
Après :
```tsx
      className="relative overflow-hidden"
      onTouchStart={(e) => { debutGlisse.current = e.touches[0]?.clientX ?? null; }}
      onTouchEnd={(e) => {
        const fin = e.changedTouches[0]?.clientX;
        if (debutGlisse.current !== null && fin !== undefined) {
          const ecart = fin - debutGlisse.current;
          if (ecart < -40) allerSuivant();
          else if (ecart > 40) allerPrecedent();
        }
        debutGlisse.current = null;
      }}
    >
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2"
```
Après :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7"
```

## Remplacement 5 (chacune des **deux** occurrences)
Avant :
```tsx
className="text-5xl font-black tracking-tight lg:text-7xl"
```
Après :
```tsx
className="text-5xl font-black tracking-tight lg:text-7xl max-sm:mt-2 max-sm:text-[30px] max-sm:leading-[1.05]"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
className="mt-4 text-lg"
```
Après :
```tsx
className="mt-4 text-lg max-sm:hidden"
```

## Remplacement 7 (l'occurrence unique)
Avant :
```tsx
className="mt-8 flex flex-wrap gap-4"
```
Après :
```tsx
className="mt-8 flex flex-wrap gap-4 max-sm:mt-5 max-sm:gap-3"
```

## Remplacement 8 (l'occurrence unique)
Avant :
```tsx
className={`rounded-full h-14 px-6 flex items-center justify-center ${
```
Après :
```tsx
className={`rounded-full h-14 px-6 flex items-center justify-center font-bold max-sm:h-11 max-sm:px-5 max-sm:text-[15px] ${
```

## Remplacement 9 (l'occurrence unique)
Avant :
```tsx
              <div>
                <img src={diapo.image}
```
Après :
```tsx
              <div className="max-sm:hidden">
                <img src={diapo.image}
```

## Remplacement 10 (l'occurrence unique)
Avant :
```tsx
className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
```
Après :
```tsx
className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
```

## Remplacement 11 (l'occurrence unique)
Avant :
```tsx
className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
```
Après :
```tsx
className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/110b-accueil-espacements.md' <<'__VICTO_FIN_1__'
TICKET 110b — l'accueil, des sections moins espacées sur téléphone

Modifie `src/app/page.tsx`. Les espacements de 96 px entre sections passent à 48 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20 max-sm:py-12"
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20 max-sm:pb-12"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20 max-sm:py-8"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/110c-bonnes-affaires.md' <<'__VICTO_FIN_2__'
TICKET 110c — les bonnes affaires, titre en gras et cartes plus petites

Modifie `src/components/accueil/SectionBonnesAffaires.tsx`. `font-900` n'existe pas dans Tailwind : `font-black` est ajouté. « Tout voir » ne passe plus à la ligne (simple lien souligné sur téléphone) ; cartes de 170 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="text-xs uppercase text-[var(--vs-promo)]"
```
Après :
```tsx
className="text-xs font-extrabold uppercase tracking-[0.14em] text-[var(--vs-promo)]"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900 mt-1"
```
Après :
```tsx
className="text-3xl font-900 font-black tracking-tight mt-1 max-sm:text-2xl"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full"
```
Après :
```tsx
className="border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full shrink-0 whitespace-nowrap font-bold max-sm:border-0 max-sm:px-0 max-sm:underline max-sm:underline-offset-4"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6"
```
Après :
```tsx
className="flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6 max-sm:gap-3"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="w-[250px] shrink-0 snap-start md:w-auto"
```
Après :
```tsx
className="w-[250px] shrink-0 snap-start md:w-auto max-sm:w-[170px]"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/110d-bande-marques.md' <<'__VICTO_FIN_3__'
TICKET 110d — la bande des marques, en gras et plus basse sur téléphone

Modifie `src/components/accueil/BandeMarques.tsx`. `font-900` n'existe pas dans Tailwind : `font-black` est ajouté.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="overflow-hidden border-b border-[var(--vs-ligne)] h-24"
```
Après :
```tsx
className="overflow-hidden border-b border-[var(--vs-ligne)] h-24 max-sm:h-16"
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="uppercase text-[26px] font-900"
```
Après :
```tsx
className="uppercase text-[26px] font-900 font-black tracking-wide max-sm:text-lg"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/110e-mosaique.md' <<'__VICTO_FIN_4__'
TICKET 110e — la mosaïque des catégories, lisible sur téléphone

Modifie `src/components/accueil/MosaiqueCategories.tsx`. Titres en gras (`font-black`), marge sous « Par catégorie », flèches visibles (icône blanche sur rond noir, noire sur rond blanc), texte blanc sur la carte Soldes (la classe d'origine contient une faute de frappe : la bonne est ajoutée à côté), libellés plus petits sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900">Par catégorie
```
Après :
```tsx
className="text-3xl font-900 font-black tracking-tight mb-6 max-sm:mb-4 max-sm:text-2xl">Par catégorie
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="relative flex h-full min-h-[190px] flex-col justify-end p-7"
```
Après :
```tsx
className="relative flex h-full min-h-[190px] flex-col justify-end p-7 max-sm:min-h-[160px] max-sm:p-5"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900 relative"
```
Après :
```tsx
className="text-3xl font-900 font-black relative max-sm:text-lg"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)]"
```
Après :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)] max-sm:h-10 max-sm:w-10"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)]"
```
Après :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)] text-[var(--vs-noir)] max-sm:h-10 max-sm:w-10"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
text-[var(--vs-blanc])">
```
Après :
```tsx
text-[var(--vs-blanc]) text-[var(--vs-blanc)]">
```

## Remplacement 7 (l'occurrence unique)
Avant :
```tsx
className="text-sm uppercase"
```
Après :
```tsx
className="text-sm font-extrabold uppercase tracking-[0.14em]"
```

## Remplacement 8 (l'occurrence unique)
Avant :
```tsx
className="text-4xl font-900"
```
Après :
```tsx
className="text-4xl font-900 font-black max-sm:text-[28px]"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/110f-infolettre.md' <<'__VICTO_FIN_5__'
TICKET 110f — le champ de l'infolettre garde sa hauteur sur téléphone

Modifie `src/components/accueil/Infolettre.tsx`. Dans le formulaire en colonne (téléphone), `flex-1` réduisait la hauteur du champ à presque rien : `max-sm:flex-none` lui rend ses 56 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)]"
```
Après :
```tsx
className="h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)] max-sm:flex-none"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/110g-reassurance.md' <<'__VICTO_FIN_6__'
TICKET 110g — les engagements, en lignes compactes sur téléphone

Modifie `src/components/accueil/Reassurance.tsx`. Sur téléphone, chaque engagement devient une ligne : l'icône à gauche, le titre et le texte à droite (enveloppés dans un `<div>`).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12"
```
Après :
```tsx
className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12 max-sm:gap-5"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
<li key={e.titre} className="flex flex-col">
```
Après :
```tsx
<li key={e.titre} className="flex flex-col max-sm:flex-row max-sm:items-start max-sm:gap-4">
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4"
```
Après :
```tsx
className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4 shrink-0 max-sm:mb-0 max-sm:h-11 max-sm:w-11"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
            <h3 className="text-lg font-bold mb-2">{e.titre}</h3>
            <p className="text-[var(--vs-gris)]">{e.texte}</p>
```
Après :
```tsx
            <div>
              <h3 className="text-lg font-bold mb-2 max-sm:mb-1 max-sm:text-base">{e.titre}</h3>
              <p className="text-[var(--vs-gris)] max-sm:text-sm">{e.texte}</p>
            </div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/110h-pied.md' <<'__VICTO_FIN_7__'
TICKET 110h — le pied de page, aligné et aéré, sans filigrane ni devise en double sur téléphone

Modifie `src/components/ui/SiteFooter.tsx`. Marges : 48 px en haut, alignement sur la page (20 px sur téléphone, 80 px sur grand écran). Le filigrane est rogné, et masqué sur téléphone ; la devise répétée dans les mentions est masquée sur téléphone (elle reste en haut).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
mx-auto px-4"
```
Après :
```tsx
mx-auto px-4 pt-12 pb-8 max-sm:px-5 sm:px-10 lg:px-20 lg:pt-16"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="select-none text-[200px] font-black leading-none text-[#1E1E26]"
```
Après :
```tsx
className="block max-w-full select-none overflow-hidden whitespace-nowrap text-[200px] font-black leading-none text-[#1E1E26] max-sm:hidden"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center"
```
Après :
```tsx
className="mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center max-sm:mt-10 max-sm:items-start"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="text-[var(--vs-blanc)] mb-4 md:mb-0"
```
Après :
```tsx
className="text-[var(--vs-blanc)] mb-4 md:mb-0 max-sm:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/110i-menu-compte.md' <<'__VICTO_FIN_8__'
TICKET 110i — le menu de l'espace client, en pastilles défilantes sur téléphone

Modifie `src/components/compte/MenuCompte.tsx`. Sur téléphone, le menu tient sur une ligne qui défile horizontalement, au lieu de six lignes avant le contenu.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="flex flex-col gap-1"
```
Après :
```tsx
className="flex flex-col gap-1 max-sm:-mx-5 max-sm:flex-row max-sm:gap-2 max-sm:overflow-x-auto max-sm:px-5 max-sm:pb-1"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className={e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}
```
Après :
```tsx
className={`${e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN} max-sm:shrink-0 max-sm:whitespace-nowrap max-sm:border max-sm:border-[var(--vs-ligne)]`}
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="my-3 h-px bg-[var(--vs-ligne)]"
```
Après :
```tsx
className="my-3 h-px bg-[var(--vs-ligne)] max-sm:hidden"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)]"
```
Après :
```tsx
className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)] max-sm:shrink-0 max-sm:whitespace-nowrap"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_8__
cat > 'tickets/110j-espace-client.md' <<'__VICTO_FIN_9__'
TICKET 110j — l'espace client, moins d'espace sous le menu sur téléphone

Modifie `src/components/compte/EspaceClient.tsx`. L'écart entre le menu et le contenu passe de 40 à 24 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14"
```
Après :
```tsx
className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14 max-sm:gap-6"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_9__
cat > 'tickets/110k-grille.md' <<'__VICTO_FIN_10__'
TICKET 110k — les listes de produits sur deux colonnes sur téléphone

Modifie `src/components/catalogue/GrilleProduits.tsx`. Une seule colonne laissait un produit par écran : deux colonnes sur téléphone, comme les maquettes.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className={`grid grid-cols-1 gap-6 sm:grid-cols-2 ${COLONNES[colonnes]} ${className}`}
```
Après :
```tsx
className={`grid grid-cols-1 gap-6 sm:grid-cols-2 max-sm:grid-cols-2 max-sm:gap-x-3 max-sm:gap-y-6 ${COLONNES[colonnes]} ${className}`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_10__
cat > 'tickets/manifest-110.tsv' <<'__VICTO_FIN_11__'
110a	src/components/accueil/Carrousel.tsx	tests/mobile-carrousel.test.tsx	tickets/110a-carrousel.md			
110b	src/app/page.tsx	tests/mobile-accueil-espacements.test.ts	tickets/110b-accueil-espacements.md			
110c	src/components/accueil/SectionBonnesAffaires.tsx	tests/mobile-bonnes-affaires.test.tsx	tickets/110c-bonnes-affaires.md			
110d	src/components/accueil/BandeMarques.tsx	tests/mobile-bande-marques.test.tsx	tickets/110d-bande-marques.md			
110e	src/components/accueil/MosaiqueCategories.tsx	tests/mobile-mosaique.test.tsx	tickets/110e-mosaique.md			
110f	src/components/accueil/Infolettre.tsx	tests/mobile-infolettre.test.tsx	tickets/110f-infolettre.md			
110g	src/components/accueil/Reassurance.tsx	tests/mobile-reassurance.test.tsx	tickets/110g-reassurance.md			
110h	src/components/ui/SiteFooter.tsx	tests/mobile-pied.test.tsx	tickets/110h-pied.md			
110i	src/components/compte/MenuCompte.tsx	tests/mobile-menu-compte.test.tsx	tickets/110i-menu-compte.md			
110j	src/components/compte/EspaceClient.tsx	tests/mobile-espace-client.test.ts	tickets/110j-espace-client.md			
110k	src/components/catalogue/GrilleProduits.tsx	tests/mobile-grille.test.tsx	tickets/110k-grille.md			
__VICTO_FIN_11__
cat > 'tickets/tests/mobile-accueil-espacements.test.ts' <<'__VICTO_FIN_12__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('accueil — espacements sur téléphone', () => {
  it('réduit les espacements entre les sections', () => {
    const s = readFileSync('src/app/page.tsx', 'utf8');
    expect(s).toContain('px-5 py-24 lg:px-20 max-sm:py-12"');
    expect(s.split('px-5 pb-24 lg:px-20 max-sm:pb-12"').length - 1).toBe(2);
    expect(s).toContain('px-5 py-14 lg:px-20 max-sm:py-8"');
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/mobile-bande-marques.test.tsx' <<'__VICTO_FIN_13__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('bande des marques — téléphone', () => {
  it('écrit les marques en gras, plus petites sur téléphone', () => {
    render(<BandeMarques marques={[{ id: 'm1', nom: 'Nike', slug: 'nike' }]} />);
    expect(classes(screen.getByTestId('bande-marques'))).toContain('max-sm:h-16');
    const lien = screen.getAllByRole('link').find(() => true) ?? null;
    for (const k of ['font-black', 'max-sm:text-lg']) expect(classes(lien), k).toContain(k);
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/mobile-bonnes-affaires.test.tsx' <<'__VICTO_FIN_14__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id, slug: id, nom: `Produit ${id}`, marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 9000, prixCompareCents: 12000,
  variantes: [{ id: `${id}-v`, taille: '42', sku: `${id}-42`, stock: 3 }],
});
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('bonnes affaires — téléphone', () => {
  it('met le titre et le sur-titre en gras', () => {
    render(<SectionBonnesAffaires produits={[P('a'), P('b')]} />);
    const titre = screen.getByRole('heading', { level: 2, name: 'Les bonnes affaires du moment' });
    for (const k of ['font-black', 'max-sm:text-2xl']) expect(classes(titre), k).toContain(k);
    expect(classes(screen.getByText('Prix cassés'))).toContain('font-extrabold');
  });

  it('garde « Tout voir » sur une ligne et réduit les cartes', () => {
    render(<SectionBonnesAffaires produits={[P('a'), P('b')]} />);
    const tout = screen.getByRole('link', { name: 'Tout voir' });
    for (const k of ['whitespace-nowrap', 'shrink-0', 'max-sm:underline']) expect(classes(tout), k).toContain(k);
    expect(classes(screen.getByTestId('rail').querySelector('li'))).toContain('max-sm:w-[170px]');
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/mobile-carrousel.test.tsx' <<'__VICTO_FIN_15__'
import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('carrousel — téléphone', () => {
  it('donne des marges et un titre compact aux diapositives', () => {
    render(<Carrousel auto={false} />);
    const titre = screen.getByRole('heading', { level: 1 });
    for (const k of ['text-5xl', 'max-sm:text-[30px]', 'max-sm:leading-[1.05]']) expect(classes(titre), k).toContain(k);
    const grille = titre.closest('.grid');
    for (const k of ['max-sm:px-5', 'max-sm:pt-7', 'max-sm:pb-14']) expect(classes(grille), k).toContain(k);
  });

  it('masque la description, l’image et les flèches sur téléphone', () => {
    const { container } = render(<Carrousel auto={false} />);
    expect(classes(screen.getByText(/^Les marques que vous aimez/))).toContain('max-sm:hidden');
    expect(classes(container.querySelector('img')?.closest('div') ?? null)).toContain('max-sm:hidden');
    for (const nom of ['Diapositive précédente', 'Diapositive suivante']) {
      expect(classes(screen.getByRole('button', { name: nom })), nom).toContain('max-sm:hidden');
    }
  });

  it('réduit les boutons d’action', () => {
    render(<Carrousel auto={false} />);
    const action = screen.getByRole('link', { name: 'Découvrir la boutique' });
    for (const k of ['h-14', 'max-sm:h-11', 'max-sm:px-5']) expect(classes(action), k).toContain(k);
  });

  it('change de diapositive en glissant le doigt', () => {
    const source = readFileSync('src/components/accueil/Carrousel.tsx', 'utf8');
    expect(source).toContain('onTouchStart');
    expect(source).toContain('onTouchEnd');
    expect(source).toContain('if (ecart < -40) allerSuivant();');
    expect(source).toContain('else if (ecart > 40) allerPrecedent();');
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/mobile-espace-client.test.ts' <<'__VICTO_FIN_16__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('espace client — téléphone', () => {
  it('réduit l’écart entre le menu et le contenu', () => {
    expect(readFileSync('src/components/compte/EspaceClient.tsx', 'utf8')).toContain('lg:gap-14 max-sm:gap-6"');
  });
});
__VICTO_FIN_16__
cat > 'tickets/tests/mobile-grille.test.tsx' <<'__VICTO_FIN_17__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id, slug: id, nom: `Produit ${id}`, marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 9000,
  variantes: [{ id: `${id}-v`, taille: '42', sku: `${id}-42`, stock: 3 }],
});

describe('grille de produits — téléphone', () => {
  it('passe sur deux colonnes sur téléphone', () => {
    render(<GrilleProduits produits={[P('a'), P('b')]} />);
    const classes = (screen.getByTestId('grille').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['grid-cols-1', 'sm:grid-cols-2', 'max-sm:grid-cols-2', 'max-sm:gap-x-3']) expect(classes, k).toContain(k);
  });
});
__VICTO_FIN_17__
cat > 'tickets/tests/mobile-infolettre.test.tsx' <<'__VICTO_FIN_18__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

describe('infolettre — téléphone', () => {
  it('garde la hauteur du champ dans le formulaire en colonne', () => {
    render(<Infolettre />);
    const classes = (screen.getByLabelText('Votre courriel').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['h-14', 'max-sm:flex-none']) expect(classes, k).toContain(k);
  });
});
__VICTO_FIN_18__
cat > 'tickets/tests/mobile-menu-compte.test.tsx' <<'__VICTO_FIN_19__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';
import { MenuCompte } from '../src/components/compte/MenuCompte';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('menu de l’espace client — téléphone', () => {
  it('tient sur une ligne qui défile', () => {
    render(<MenuCompte actif="favoris" />);
    const menu = screen.getByTestId('menu-compte');
    for (const k of ['flex-col', 'max-sm:flex-row', 'max-sm:overflow-x-auto']) expect(classes(menu), k).toContain(k);
  });

  it('garde le style des entrées et les empêche de se couper', () => {
    render(<MenuCompte actif="favoris" />);
    const actif = screen.getByRole('link', { name: 'Favoris' });
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif), k).toContain(k);
    for (const k of ['max-sm:shrink-0', 'max-sm:whitespace-nowrap']) expect(classes(actif), k).toContain(k);
    expect(classes(screen.getByRole('button', { name: 'Se déconnecter' }))).toContain('max-sm:shrink-0');
  });
});
__VICTO_FIN_19__
cat > 'tickets/tests/mobile-mosaique.test.tsx' <<'__VICTO_FIN_20__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('mosaïque des catégories — téléphone', () => {
  it('met le titre en gras, avec une marge sous lui', () => {
    render(<MosaiqueCategories />);
    const titre = screen.getByRole('heading', { level: 2, name: 'Par catégorie' });
    for (const k of ['font-black', 'mb-6', 'max-sm:text-2xl']) expect(classes(titre), k).toContain(k);
  });

  it('rend les flèches visibles : icône claire sur rond noir', () => {
    render(<MosaiqueCategories />);
    const rond = screen.getByRole('link', { name: 'Homme' }).querySelector('.rounded-full');
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(rond), k).toContain(k);
    expect(classes(screen.getByText('Homme'))).toContain('font-black');
  });

  it('écrit en blanc sur la carte Soldes', () => {
    render(<MosaiqueCategories />);
    const carte = screen.getByRole('link', { name: /Jusqu/ }).closest('li');
    expect(classes(carte)).toContain('text-[var(--vs-blanc)]');
    const rond = screen.getByRole('link', { name: /Jusqu/ }).querySelector('.rounded-full');
    expect(classes(rond)).toContain('text-[var(--vs-noir)]');
  });
});
__VICTO_FIN_20__
cat > 'tickets/tests/mobile-pied.test.tsx' <<'__VICTO_FIN_21__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pied de page — téléphone', () => {
  it('aère le haut et aligne le pied sur la page', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const interieur = screen.getByTestId('pied').querySelector('div');
    for (const k of ['pt-12', 'pb-8', 'max-sm:px-5', 'lg:px-20']) expect(classes(interieur), k).toContain(k);
  });

  it('rogne le filigrane et le masque sur téléphone', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const filigrane = screen.getByTestId('pied-filigrane');
    for (const k of ['block', 'max-w-full', 'overflow-hidden', 'whitespace-nowrap', 'text-[200px]', 'max-sm:hidden']) {
      expect(classes(filigrane), k).toContain(k);
    }
  });

  it('ne répète pas la devise sur téléphone', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    expect(classes(screen.getByTestId('pied-slogan'))).toContain('max-sm:hidden');
  });
});
__VICTO_FIN_21__
cat > 'tickets/tests/mobile-reassurance.test.tsx' <<'__VICTO_FIN_22__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('engagements — téléphone', () => {
  it('place l’icône à gauche du titre et du texte', () => {
    render(<Reassurance />);
    const titre = screen.getByRole('heading', { name: 'Paiement sécurisé' });
    expect(classes(titre.closest('li'))).toContain('max-sm:flex-row');
    const bloc = titre.closest('div');
    expect(bloc?.contains(screen.getByText(/ne transitent jamais/))).toBe(true);
    expect(bloc?.querySelector('svg')).toBeNull();
  });
});
__VICTO_FIN_22__
TESTS=(mobile-accueil-espacements.test.ts mobile-bande-marques.test.tsx mobile-bonnes-affaires.test.tsx mobile-carrousel.test.tsx mobile-espace-client.test.ts mobile-grille.test.tsx mobile-infolettre.test.tsx mobile-menu-compte.test.tsx mobile-mosaique.test.tsx mobile-pied.test.tsx mobile-reassurance.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "11 specs, 11 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/110*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-110.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    existe = os.path.isfile(cible)
    if mode != 'neuf' and existe: car += len(open(cible).read())
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    sortie = int(n.group(1)) * 40 // 3 if n else (len(open(cible).read()) * 11 // 30 if existe else 0)
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB
ok "contrôle : 0 alerte ; budgets dans le plafond"

# ------------------------------------------------------------ pré-vol de chaque test
MAUVAIS='TypeError|ReferenceError|SyntaxError|Transform failed|is not a function|Cannot read propert|is not defined'
mkdir -p tests   # git rm peut avoir retiré le dossier devenu vide
for t in "${TESTS[@]}"; do
  p="tests/zz-prevol-$t"; cp "tickets/tests/$t" "$p"
  npx --no-install vitest run "$p" > /tmp/victo-prevol.log 2>&1 || true
  rm -f "$p"; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
  if grep -qE "$MAUVAIS" /tmp/victo-prevol.log; then
    grep -nE "$MAUVAIS" /tmp/victo-prevol.log | head -4; annuler "pré-vol de $t : le test PLANTE — c'est le test qui est faux"
  elif grep -qE "Failed to resolve import|Cannot find module|Does the file exist" /tmp/victo-prevol.log; then
    ok "pré-vol $t : module à créer, pas encore exécutable (normal)"
  elif grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log; then
    ok "pré-vol $t : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' '), sans plantage"
  else
    tail -12 /tmp/victo-prevol.log; annuler "pré-vol de $t : résultat illisible"
  fi
done

# ------------------------------------------------------------ base verte, commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 110 — mobile, deuxième passe ; le 110h remplace le 109b"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-110.tsv ./run.sh\n\nOnze tickets courts, indépendants les uns des autres. Compte environ deux heures.\n'
