#!/usr/bin/env bash
# VICTO STORE — lot 113 : fondations du branchement sur Medusa (aucun changement visible).
#   113a un produit peut porter son type   113b traduction Medusa → site (testée sur la vraie réponse)
#   113c lecture de Medusa, page par page   113d source du catalogue (démo par défaut, Medusa sur demande,
#   retour à la démo si Medusa ne répond pas)   113e GET /api/catalogue pour les composants du navigateur
# Hors tickets : la réponse réelle de Medusa pour les tests, l'image de remplacement, .env.local.
# Usage :  cd ~/victo-store && bash lot-113.sh
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
for f in src/lib/medusa src/lib/catalogue-source.ts src/app/api/catalogue; do [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
grep -q "export function normaliser" src/lib/recherche.ts || mort "normaliser absent de recherche.ts"
grep -q "export function listerProduits" src/lib/donnees.ts && grep -q "export function listerMarques" src/lib/donnees.ts || mort "listerProduits ou listerMarques absent de donnees.ts"

# ------------------------------------------------------------ chaque texte « avant », mot pour mot
python3 - <<'VERIF' || mort "un fichier ne correspond pas aux specs (détail ci-dessus) : rien n'a été modifié"
import json, sys
table = json.loads(r'''[["src/lib/catalogue.ts", "  composition?: string;\n  images?: string[];\n}", "  composition?: string;\n  images?: string[];\n  type?: string;\n}", 1]]''')
ko = 0
for f, avant, apres, n in table:
    try: s = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"  ✗ {f} introuvable"); ko += 1; continue
    if apres in s: print(f"  ✗ {f} : déjà modifié (lot déjà passé ?)"); ko += 1; continue
    c = s.count(avant)
    if c != n: print(f"  ✗ {f} : « {avant.splitlines()[0][:80]} » trouvé {c} fois, attendu {n}"); ko += 1
sys.exit(1 if ko else 0)
VERIF
ok "le texte à remplacer est dans catalogue.ts"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

# ------------------------------------------------------------ ce dont les tickets ont besoin, hors tickets
mkdir -p tests/fixtures public/img
cat > tests/fixtures/medusa-essai.json <<'__VICTO_FIXTURE__'
{
 "produit_vu_par_la_boutique": {
  "products": [
   {
    "id": "prod_01M44NZSNKV1SQH53B1XNAWRCH",
    "title": "Air Zoom Pegasus 41 (essai)",
    "subtitle": "Nike",
    "description": "Produit d'essai créé par l'équipe technique pour brancher la boutique. À supprimer ensuite.",
    "handle": "essai-air-zoom-pegasus-41",
    "is_giftcard": false,
    "discountable": true,
    "thumbnail": null,
    "collection_id": null,
    "type_id": null,
    "weight": null,
    "length": null,
    "height": null,
    "width": null,
    "hs_code": null,
    "origin_country": null,
    "mid_code": null,
    "material": null,
    "created_at": "2026-10-05T00:04:02.358Z",
    "updated_at": "2026-10-05T00:04:02.358Z",
    "variants": [
     {
      "id": "variant_01M44NZSTW7P1PTBDRZFDG818P",
      "title": "41",
      "sku": "essai-pegasus-41",
      "barcode": null,
      "ean": null,
      "upc": null,
      "allow_backorder": false,
      "manage_inventory": true,
      "hs_code": null,
      "origin_country": null,
      "mid_code": null,
      "material": null,
      "weight": null,
      "length": null,
      "height": null,
      "width": null,
      "metadata": null,
      "variant_rank": 0,
      "thumbnail": null,
      "product_id": "prod_01M44NZSNKV1SQH53B1XNAWRCH",
      "created_at": "2026-10-05T00:04:02.525Z",
      "updated_at": "2026-10-05T00:04:02.525Z",
      "deleted_at": null,
      "options": [
       {
        "id": "optval_01M44NZSNNNTJ907M2XXAQXQDT",
        "value": "41",
        "rank": null,
        "metadata": null,
        "option_id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
        "option": {
         "id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
         "title": "Pointure",
         "is_exclusive": true,
         "metadata": null,
         "created_at": "2026-10-05T00:04:02.358Z",
         "updated_at": "2026-10-05T00:04:02.358Z",
         "deleted_at": null
        },
        "created_at": "2026-10-05T00:04:02.358Z",
        "updated_at": "2026-10-05T00:04:02.358Z",
        "deleted_at": null
       }
      ],
      "calculated_price": {
       "id": "pset_01M44NZSYPQ9ADZMK18B64WYS0",
       "is_calculated_price_price_list": true,
       "is_calculated_price_tax_inclusive": false,
       "calculated_amount": 129,
       "raw_calculated_amount": {
        "value": "129",
        "precision": 20
       },
       "is_original_price_price_list": false,
       "is_original_price_tax_inclusive": false,
       "original_amount": 159,
       "raw_original_amount": {
        "value": "159",
        "precision": 20
       },
       "currency_code": "cad",
       "calculated_price": {
        "id": "price_01M44NZTH94Y5RX5ZMRZ04E17P",
        "price_list_id": "plist_01M44NZTH9W70KBKCT409T21NT",
        "price_list_type": "sale",
        "min_quantity": null,
        "max_quantity": null
       },
       "original_price": {
        "id": "price_01M44NZSYNJP9ZJ6BYV9RFBDYJ",
        "price_list_id": null,
        "price_list_type": null,
        "min_quantity": null,
        "max_quantity": null
       }
      },
      "inventory_quantity": 5
     },
     {
      "id": "variant_01M44NZSTWSTC0VQFX44ZP5R21",
      "title": "42",
      "sku": "essai-pegasus-42",
      "barcode": null,
      "ean": null,
      "upc": null,
      "allow_backorder": false,
      "manage_inventory": true,
      "hs_code": null,
      "origin_country": null,
      "mid_code": null,
      "material": null,
      "weight": null,
      "length": null,
      "height": null,
      "width": null,
      "metadata": null,
      "variant_rank": 0,
      "thumbnail": null,
      "product_id": "prod_01M44NZSNKV1SQH53B1XNAWRCH",
      "created_at": "2026-10-05T00:04:02.525Z",
      "updated_at": "2026-10-05T00:04:02.525Z",
      "deleted_at": null,
      "options": [
       {
        "id": "optval_01M44NZSNN9BEM545GZ38B5BDB",
        "value": "42",
        "rank": null,
        "metadata": null,
        "option_id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
        "option": {
         "id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
         "title": "Pointure",
         "is_exclusive": true,
         "metadata": null,
         "created_at": "2026-10-05T00:04:02.358Z",
         "updated_at": "2026-10-05T00:04:02.358Z",
         "deleted_at": null
        },
        "created_at": "2026-10-05T00:04:02.358Z",
        "updated_at": "2026-10-05T00:04:02.358Z",
        "deleted_at": null
       }
      ],
      "calculated_price": {
       "id": "pset_01M44NZSYPTETTT3WHVQM1WKDM",
       "is_calculated_price_price_list": true,
       "is_calculated_price_tax_inclusive": false,
       "calculated_amount": 129,
       "raw_calculated_amount": {
        "value": "129",
        "precision": 20
       },
       "is_original_price_price_list": false,
       "is_original_price_tax_inclusive": false,
       "original_amount": 159,
       "raw_original_amount": {
        "value": "159",
        "precision": 20
       },
       "currency_code": "cad",
       "calculated_price": {
        "id": "price_01M44NZTH9XRQJVFNRFNSHQ2B0",
        "price_list_id": "plist_01M44NZTH9W70KBKCT409T21NT",
        "price_list_type": "sale",
        "min_quantity": null,
        "max_quantity": null
       },
       "original_price": {
        "id": "price_01M44NZSYPN2P7WZDATTCW5YF7",
        "price_list_id": null,
        "price_list_type": null,
        "min_quantity": null,
        "max_quantity": null
       }
      },
      "inventory_quantity": 5
     }
    ],
    "type": null,
    "collection": null,
    "options": [
     {
      "id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
      "title": "Pointure",
      "is_exclusive": true,
      "metadata": null,
      "created_at": "2026-10-05T00:04:02.358Z",
      "updated_at": "2026-10-05T00:04:02.358Z",
      "deleted_at": null,
      "values": [
       {
        "id": "optval_01M44NZSNNNTJ907M2XXAQXQDT",
        "value": "41",
        "rank": null,
        "metadata": null,
        "option_id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
        "created_at": "2026-10-05T00:04:02.358Z",
        "updated_at": "2026-10-05T00:04:02.358Z",
        "deleted_at": null
       },
       {
        "id": "optval_01M44NZSNN9BEM545GZ38B5BDB",
        "value": "42",
        "rank": null,
        "metadata": null,
        "option_id": "opt_01M44NZSNKNRAHJWZNKB00FDVA",
        "created_at": "2026-10-05T00:04:02.358Z",
        "updated_at": "2026-10-05T00:04:02.358Z",
        "deleted_at": null
       }
      ]
     }
    ],
    "tags": [
     {
      "id": "ptag_01M44NZNN6ZQR6TS98FTJ09QM4",
      "value": "homme",
      "external_id": null,
      "metadata": null,
      "created_at": "2026-10-05T00:03:58.246Z",
      "updated_at": "2026-10-05T00:03:58.246Z",
      "deleted_at": null
     }
    ],
    "images": [],
    "categories": [
     {
      "id": "pcat_01M44NZJPH8Z1CY3HXWADBPZQ2",
      "name": "Course",
      "description": "",
      "handle": "course",
      "mpath": "pcat_01M44NZJDKRFHQNFDV031D4VXP.pcat_01M44NZJPH8Z1CY3HXWADBPZQ2",
      "is_active": true,
      "is_internal": false,
      "rank": 1,
      "external_id": null,
      "metadata": null,
      "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP",
      "parent_category": {
       "id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
      },
      "created_at": "2026-10-05T00:03:55.217Z",
      "updated_at": "2026-10-05T00:03:55.217Z",
      "deleted_at": null
     },
     {
      "id": "pcat_01M44NZMT1V09TM0T564QY74JN",
      "name": "Nike",
      "description": "",
      "handle": "nike",
      "mpath": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T.pcat_01M44NZMT1V09TM0T564QY74JN",
      "is_active": true,
      "is_internal": false,
      "rank": 0,
      "external_id": null,
      "metadata": null,
      "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T",
      "parent_category": {
       "id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
      },
      "created_at": "2026-10-05T00:03:57.377Z",
      "updated_at": "2026-10-05T00:03:57.377Z",
      "deleted_at": null
     }
    ]
   }
  ],
  "count": 1,
  "offset": 0,
  "limit": 50
 },
 "categories_vues_par_la_boutique": {
  "product_categories": [
   {
    "id": "pcat_01M3TNQ6NBEWKTSM4MF3CSTTQ9",
    "name": "Urban_Set",
    "handle": "Survetement Complet",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M3TP06B5RGPN0NTADS0XZT6S",
    "name": "Sneackers",
    "handle": "Chaussures",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M44NZJDKRFHQNFDV031D4VXP",
    "name": "Chaussures",
    "handle": "chaussures",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M44NZJJ37952YJQWZBFP3SS5",
    "name": "Sneakers",
    "handle": "sneakers",
    "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
   },
   {
    "id": "pcat_01M44NZJPH8Z1CY3HXWADBPZQ2",
    "name": "Course",
    "handle": "course",
    "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
   },
   {
    "id": "pcat_01M44NZJV4Y1YDR7DRPWFMQX49",
    "name": "Basket",
    "handle": "basket",
    "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
   },
   {
    "id": "pcat_01M44NZJZ9KERE91RJ1C8XNWE9",
    "name": "Sandales",
    "handle": "sandales",
    "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
   },
   {
    "id": "pcat_01M44NZK49WGMDPWZSX8MP4N46",
    "name": "Bottes",
    "handle": "bottes",
    "parent_category_id": "pcat_01M44NZJDKRFHQNFDV031D4VXP"
   },
   {
    "id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3",
    "name": "Vêtements",
    "handle": "vetements",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M44NZKC6MPEPCFMRRHPTYM9G",
    "name": "T-shirts",
    "handle": "t-shirts",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZKH10J45CDBY9ZQ8V1C8",
    "name": "Polos",
    "handle": "polos",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZKN2J9P71Q89NCKGM98X",
    "name": "Sweats et hoodies",
    "handle": "sweats",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZKRXZ944PY5T8XK6XG9X",
    "name": "Jeans",
    "handle": "jeans",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZKWP2DEH7SKS83Q84PAZ",
    "name": "Vestes",
    "handle": "vestes",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZM0K6J9CMQ86JYMH29YE",
    "name": "Survêtements",
    "handle": "survetements",
    "parent_category_id": "pcat_01M44NZK7Q4WMN1RPYS05H3SX3"
   },
   {
    "id": "pcat_01M44NZM3QJYR29EW578WECDGT",
    "name": "Accessoires",
    "handle": "accessoires",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M44NZM9FD6X2Z5DTKRJMS8A6",
    "name": "Casquettes",
    "handle": "casquettes",
    "parent_category_id": "pcat_01M44NZM3QJYR29EW578WECDGT"
   },
   {
    "id": "pcat_01M44NZMEABD0PCAH2QWZSANFA",
    "name": "Sacs",
    "handle": "sacs",
    "parent_category_id": "pcat_01M44NZM3QJYR29EW578WECDGT"
   },
   {
    "id": "pcat_01M44NZMJAXKJWTEJJN0D5TVNG",
    "name": "Chaussettes",
    "handle": "chaussettes",
    "parent_category_id": "pcat_01M44NZM3QJYR29EW578WECDGT"
   },
   {
    "id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T",
    "name": "Marques",
    "handle": "marques",
    "parent_category_id": null
   },
   {
    "id": "pcat_01M44NZMT1V09TM0T564QY74JN",
    "name": "Nike",
    "handle": "nike",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   },
   {
    "id": "pcat_01M44NZMYKH4ZR86NGQ1JF4W6T",
    "name": "Adidas",
    "handle": "adidas",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   },
   {
    "id": "pcat_01M44NZN2YFZ54PQFAXFAJ0GKA",
    "name": "Converse",
    "handle": "converse",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   },
   {
    "id": "pcat_01M44NZN76WTQ585DERVQ4GEX1",
    "name": "Lacoste",
    "handle": "lacoste",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   },
   {
    "id": "pcat_01M44NZNBA7CWAWADC38X91C2B",
    "name": "Levi's",
    "handle": "levis",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   },
   {
    "id": "pcat_01M44NZNFFTNWDTFA49ZVNMMSM",
    "name": "New Balance",
    "handle": "new-balance",
    "parent_category_id": "pcat_01M44NZMNGTMDNMJTWWXVNAA1T"
   }
  ],
  "count": 26,
  "offset": 0,
  "limit": 100
 }
}
__VICTO_FIXTURE__
ok "réponse réelle de Medusa enregistrée pour les tests (tests/fixtures/medusa-essai.json)"
if [ ! -e public/img/sans-photo.svg ]; then
cat > public/img/sans-photo.svg <<'__VICTO_SVG__'
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="1000" viewBox="0 0 800 1000" role="img" aria-label="Photo à venir">
  <rect width="800" height="1000" fill="#F0F0EE"/>
  <g fill="none" stroke="#B5B5BA" stroke-width="14" stroke-linecap="round" stroke-linejoin="round" transform="translate(290 400)">
    <path d="M30 60h40l20-30h40l20 30h40a20 20 0 0 1 20 20v100a20 20 0 0 1-20 20H30a20 20 0 0 1-20-20V80a20 20 0 0 1 20-20z"/>
    <circle cx="110" cy="130" r="38"/>
  </g>
  <text x="400" y="680" text-anchor="middle" font-family="Arial, sans-serif" font-size="34" font-weight="700" fill="#6B6B70">Photo à venir</text>
</svg>
__VICTO_SVG__
ok "image de remplacement créée (public/img/sans-photo.svg)"
fi
git add -- tests/fixtures/medusa-essai.json public/img/sans-photo.svg
# .env.local : jamais suivi par git ; on n'ajoute que les valeurs absentes
if ! git check-ignore -q .env.local; then printf '\n# configuration locale\n.env*.local\n' >> .gitignore; git add .gitignore; ok ".env*.local ajouté au .gitignore"; fi
touch .env.local
ajoute(){ grep -q "^$1=" .env.local || { printf '%s=%s\n' "$1" "$2" >> .env.local; echo "    + $1"; }; }
echo "  configuration locale (.env.local) :"
ajoute MEDUSA_URL http://192.168.40.40:9000
ajoute MEDUSA_CLE pk_33177f308579cd7d2ca021468f64d3eb9c298e219636e221e2b1fd7f608015f0
ajoute MEDUSA_REGION reg_01M3JVP1K56T5Z1BS39NJ0ZTWZ
ajoute CATALOGUE_SOURCE demo
git check-ignore -q .env.local || annuler ".env.local ne serait pas ignoré par git"
ok ".env.local prêt, ignoré par git (CATALOGUE_SOURCE=$(grep '^CATALOGUE_SOURCE=' .env.local | cut -d= -f2))"

mkdir -p tickets/tests
cat > 'tickets/113a-produit-type.md' <<'__VICTO_FIN_0__'
TICKET 113a — un produit peut porter son type

Modifie `src/lib/catalogue.ts`. L'interface `Produit` gagne un champ facultatif `type` (le
troisième niveau de l'arbre : `course`, `polos`…), fourni par les catégories de Medusa.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier. Rien d'autre ne change.

## Le remplacement (l'occurrence unique)
Avant :
```ts
  composition?: string;
  images?: string[];
}
```
Après :
```ts
  composition?: string;
  images?: string[];
  type?: string;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/113b-medusa-convertir.md' <<'__VICTO_FIN_1__'
TICKET 113b — traduire un produit Medusa au format du site

Crée `src/lib/medusa/convertir.ts`. Fonctions **pures** : un produit de l'API boutique de Medusa devient un `Produit` du site (prix en cents, prix barré pendant les soldes, pointures et stock, marque, rayon et type par les catégories, genre par les étiquettes).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~115 lignes.
```ts
import type { Categorie, Genre, Marque, Produit, Variante } from '@/lib/catalogue';
import { normaliser } from '@/lib/recherche';

/** Les champs de l'API boutique de Medusa dont le site se sert (le reste est ignoré). */
export interface CategorieMedusa {
  id: string;
  name: string;
  handle: string;
  parent_category_id: string | null;
}
export interface VarianteMedusa {
  id: string;
  title: string | null;
  sku: string | null;
  manage_inventory: boolean | null;
  inventory_quantity?: number | null;
  options?: { value: string; option?: { title: string } | null }[] | null;
  calculated_price?: { calculated_amount: number | null; original_amount: number | null } | null;
}
export interface ProduitMedusa {
  id: string;
  title: string;
  subtitle: string | null;
  handle: string;
  description: string | null;
  thumbnail: string | null;
  images?: { url: string }[] | null;
  tags?: { value: string }[] | null;
  categories?: { id: string }[] | null;
  variants?: VarianteMedusa[] | null;
}

export const IMAGE_ABSENTE = '/img/sans-photo.svg';
/** Stock affiché quand Medusa ne suit pas l'inventaire d'une variante. */
export const STOCK_NON_SUIVI = 99;
const RAYONS: Categorie[] = ['chaussures', 'vetements', 'accessoires'];

const enCents = (montant: number) => Math.round(montant * 100);
const estRayon = (handle: string | undefined): handle is Categorie => RAYONS.some((r) => r === handle);

function genreDe(tags: { value: string }[]): Genre | undefined {
  const femme = tags.some((t) => t.value === 'femme');
  const homme = tags.some((t) => t.value === 'homme');
  if (femme && homme) return 'mixte';
  if (femme) return 'femme';
  if (homme) return 'homme';
  return undefined;
}

function varianteDe(v: VarianteMedusa): Variante {
  const valeur = (v.options ?? []).find(() => true)?.value;
  return {
    id: v.id,
    taille: valeur ?? v.title ?? '',
    sku: v.sku ?? v.id,
    stock: v.manage_inventory ? Math.max(0, v.inventory_quantity ?? 0) : STOCK_NON_SUIVI,
  };
}

/** Les marques : les catégories rangées sous « Marques ». */
export function convertirMarques(categories: CategorieMedusa[]): Marque[] {
  const racine = categories.find((c) => c.handle === 'marques');
  if (!racine) return [];
  return categories.filter((c) => c.parent_category_id === racine.id).map((c) => ({ id: c.id, nom: c.name, slug: c.handle }));
}

/** Un produit Medusa, au format du site. */
export function convertirProduit(p: ProduitMedusa, categories: CategorieMedusa[]): Produit {
  const parId = (id: string | null) => categories.find((c) => c.id === id);
  const siennes = (p.categories ?? []).map((c) => parId(c.id)).filter((c): c is CategorieMedusa => c !== undefined);
  const marqueCat = siennes.find((c) => parId(c.parent_category_id)?.handle === 'marques');
  const typeCat = siennes.find((c) => estRayon(parId(c.parent_category_id)?.handle));
  const rayon = typeCat ? parId(typeCat.parent_category_id)?.handle : siennes.map((c) => c.handle).find(estRayon);
  const nomMarque = p.subtitle ?? 'Sans marque';
  const marque: Marque = marqueCat
    ? { id: marqueCat.id, nom: marqueCat.name, slug: marqueCat.handle }
    : { id: `marque-${normaliser(nomMarque).replace(/ /g, '-')}`, nom: nomMarque, slug: normaliser(nomMarque).replace(/ /g, '-') };

  const prix = (p.variants ?? [])
    .map((v) => v.calculated_price)
    .filter((c): c is { calculated_amount: number; original_amount: number | null } => typeof c?.calculated_amount === 'number')
    .reduce<{ calculated_amount: number; original_amount: number | null } | undefined>((min, c) => (min === undefined || c.calculated_amount < min.calculated_amount ? c : min), undefined);
  const images = (p.images ?? []).map((i) => i.url);
  const genre = genreDe(p.tags ?? []);
  const original = prix?.original_amount;

  return {
    id: p.id,
    slug: p.handle,
    nom: p.title,
    marque,
    imageUrl: p.thumbnail ?? images.find(() => true) ?? IMAGE_ABSENTE,
    prixCents: prix ? enCents(prix.calculated_amount) : 0,
    ...(prix && typeof original === 'number' && original > prix.calculated_amount ? { prixCompareCents: enCents(original) } : {}),
    variantes: (p.variants ?? []).map(varianteDe),
    ...(genre ? { genre } : {}),
    ...(rayon && estRayon(rayon) ? { categorie: rayon } : {}),
    ...(typeCat ? { type: typeCat.handle } : {}),
    ...(p.description ? { description: p.description } : {}),
    ...(images.length > 0 ? { images } : {}),
  };
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/113c-medusa-client.md' <<'__VICTO_FIN_2__'
TICKET 113c — lire Medusa

Crée `src/lib/medusa/client.ts`. Lecture de l'API boutique de Medusa, côté serveur : la configuration vient des variables d'environnement ; les produits sont lus page par page.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- `fetch` reçoit `next: { revalidate: 60 }` : c'est l'option de cache de Next.js, déjà typée par Next.

## Fichier complet
Taille attendue : ~50 lignes.
```ts
import type { CategorieMedusa, ProduitMedusa } from '@/lib/medusa/convertir';

/** Les champs demandés à Medusa : prix calculés, stock, options, catégories, étiquettes, photos. */
export const CHAMPS_PRODUITS = '*variants.calculated_price,+variants.inventory_quantity,*variants.options,*variants.options.option,*categories,*tags,*images';

export interface ConfigMedusa {
  url: string;
  cle: string;
  region: string;
}

/** Lit MEDUSA_URL, MEDUSA_CLE et MEDUSA_REGION ; null s'il en manque un. */
export function configMedusa(env: Record<string, string | undefined> = process.env): ConfigMedusa | null {
  const url = env.MEDUSA_URL;
  const cle = env.MEDUSA_CLE;
  const region = env.MEDUSA_REGION;
  if (!url || !cle || !region) return null;
  return { url: url.replace(/\/+$/, ''), cle, region };
}

async function lire<T>(c: ConfigMedusa, chemin: string): Promise<T> {
  const reponse = await fetch(`${c.url}${chemin}`, {
    headers: { 'x-publishable-api-key': c.cle },
    next: { revalidate: 60 },
  });
  if (!reponse.ok) throw new Error(`Medusa a répondu ${reponse.status} pour ${chemin}`);
  return (await reponse.json()) as T;
}

/** Tous les produits visibles par la boutique, page par page (100 à la fois). */
export async function lireProduitsMedusa(c: ConfigMedusa): Promise<ProduitMedusa[]> {
  const tous: ProduitMedusa[] = [];
  for (let offset = 0; ; offset += 100) {
    const page = await lire<{ products: ProduitMedusa[]; count: number }>(
      c,
      `/store/products?limit=100&offset=${offset}&region_id=${encodeURIComponent(c.region)}&fields=${encodeURIComponent(CHAMPS_PRODUITS)}`,
    );
    tous.push(...page.products);
    if (page.products.length === 0 || tous.length >= page.count) return tous;
  }
}

export async function lireCategoriesMedusa(c: ConfigMedusa): Promise<CategorieMedusa[]> {
  const r = await lire<{ product_categories: CategorieMedusa[] }>(c, '/store/product-categories?limit=500&fields=id,name,handle,parent_category_id');
  return r.product_categories;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/113d-catalogue-source.md' <<'__VICTO_FIN_3__'
TICKET 113d — choisir la source du catalogue

Crée `src/lib/catalogue-source.ts`. Le point d'entrée unique du catalogue : démonstration par défaut, Medusa avec `CATALOGUE_SOURCE=medusa`, et retour automatique à la démonstration si Medusa ne répond pas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~35 lignes.
```ts
import type { Marque, Produit } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';
import { configMedusa, lireCategoriesMedusa, lireProduitsMedusa } from '@/lib/medusa/client';
import { convertirMarques, convertirProduit } from '@/lib/medusa/convertir';

export interface Catalogue {
  produits: Produit[];
  marques: Marque[];
  source: 'demo' | 'medusa';
}

/**
 * Le catalogue du site. Par défaut, les données de démonstration ; avec CATALOGUE_SOURCE=medusa,
 * celui de Medusa. Si Medusa est mal configuré ou ne répond pas, retour aux données de
 * démonstration (une démonstration ne tombe jamais), avec un message dans les journaux.
 */
export async function chargerCatalogue(env: Record<string, string | undefined> = process.env): Promise<Catalogue> {
  const demo: Catalogue = { produits: listerProduits(), marques: listerMarques(), source: 'demo' };
  if (env.CATALOGUE_SOURCE !== 'medusa') return demo;
  const config = configMedusa(env);
  if (!config) {
    console.error('[catalogue] CATALOGUE_SOURCE=medusa, mais MEDUSA_URL, MEDUSA_CLE ou MEDUSA_REGION manque : données de démonstration.');
    return demo;
  }
  try {
    const [bruts, categories] = await Promise.all([lireProduitsMedusa(config), lireCategoriesMedusa(config)]);
    return { produits: bruts.map((p) => convertirProduit(p, categories)), marques: convertirMarques(categories), source: 'medusa' };
  } catch (erreur) {
    console.error('[catalogue] Medusa ne répond pas : données de démonstration.', erreur);
    return demo;
  }
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/113e-api-catalogue.md' <<'__VICTO_FIN_4__'
TICKET 113e — le catalogue servi aux composants du navigateur

Crée `src/app/api/catalogue/route.ts`. Route `GET /api/catalogue` : renvoie le catalogue en JSON (`produits`, `marques`, `source`). Utilise `Response.json`, standard.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```ts
import { chargerCatalogue } from '@/lib/catalogue-source';

/** Le catalogue, pour les composants du navigateur (recherche, menus, panier). Revalidé chaque minute. */
export const revalidate = 60;

export async function GET() {
  return Response.json(await chargerCatalogue());
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/manifest-113.tsv' <<'__VICTO_FIN_5__'
113a	src/lib/catalogue.ts	tests/produit-type.test.ts	tickets/113a-produit-type.md			
113b	src/lib/medusa/convertir.ts	tests/medusa-convertir.test.ts	tickets/113b-medusa-convertir.md	src/lib/catalogue.ts,src/lib/recherche.ts	113a	
113c	src/lib/medusa/client.ts	tests/medusa-client.test.ts	tickets/113c-medusa-client.md	src/lib/medusa/convertir.ts	113b	
113d	src/lib/catalogue-source.ts	tests/catalogue-source.test.ts	tickets/113d-catalogue-source.md	src/lib/medusa/client.ts,src/lib/medusa/convertir.ts	113b,113c	
113e	src/app/api/catalogue/route.ts	tests/api-catalogue.test.ts	tickets/113e-api-catalogue.md	src/lib/catalogue-source.ts	113d	
__VICTO_FIN_5__
cat > 'tickets/tests/api-catalogue.test.ts' <<'__VICTO_FIN_6__'
// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { GET, revalidate } from '../src/app/api/catalogue/route';
import { listerProduits } from '../src/lib/donnees';

describe('GET /api/catalogue', () => {
  it('renvoie le catalogue en JSON, revalidé chaque minute', async () => {
    const reponse = await GET();
    expect(reponse.status).toBe(200);
    const corps = (await reponse.json()) as { source: string; produits: unknown[]; marques: unknown[] };
    expect(corps.source).toBe('demo');
    expect(corps.produits).toHaveLength(listerProduits().length);
    expect(revalidate).toBe(60);
  });
});
__VICTO_FIN_6__
cat > 'tickets/tests/catalogue-source.test.ts' <<'__VICTO_FIN_7__'
import { readFileSync } from 'node:fs';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { chargerCatalogue } from '../src/lib/catalogue-source';
import { listerMarques, listerProduits } from '../src/lib/donnees';

const reel = JSON.parse(readFileSync('tests/fixtures/medusa-essai.json', 'utf8')) as {
  produit_vu_par_la_boutique: { products: unknown[] };
  categories_vues_par_la_boutique: { product_categories: unknown[] };
};
const MEDUSA = { CATALOGUE_SOURCE: 'medusa', MEDUSA_URL: 'http://medusa:9000', MEDUSA_CLE: 'pk_test', MEDUSA_REGION: 'reg_ca' };
afterEach(() => { vi.unstubAllGlobals(); vi.restoreAllMocks(); });

describe('source du catalogue', () => {
  it('donne la démonstration par défaut', async () => {
    const c = await chargerCatalogue({});
    expect(c.source).toBe('demo');
    expect(c.produits).toEqual(listerProduits());
    expect(c.marques).toEqual(listerMarques());
  });

  it('lit Medusa quand on le demande', async () => {
    vi.stubGlobal('fetch', async (url: string) => ({
      ok: true, status: 200,
      json: async () => (url.includes('/store/products') ? { products: reel.produit_vu_par_la_boutique.products, count: 1 } : reel.categories_vues_par_la_boutique),
    }));
    const c = await chargerCatalogue(MEDUSA);
    expect(c.source).toBe('medusa');
    expect(c.produits.map((p) => [p.slug, p.prixCents, p.categorie])).toEqual([['essai-air-zoom-pegasus-41', 12900, 'chaussures']]);
    expect(c.marques).toHaveLength(6);
  });

  it('revient à la démonstration si Medusa ne répond pas, et le signale', async () => {
    const journal = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    vi.stubGlobal('fetch', async () => { throw new Error('connexion refusée'); });
    expect((await chargerCatalogue(MEDUSA)).source).toBe('demo');
    expect(journal).toHaveBeenCalled();
  });

  it('revient à la démonstration si la configuration est incomplète, et le signale', async () => {
    const journal = vi.spyOn(console, 'error').mockImplementation(() => undefined);
    expect((await chargerCatalogue({ CATALOGUE_SOURCE: 'medusa' })).source).toBe('demo');
    expect(journal).toHaveBeenCalled();
  });
});
__VICTO_FIN_7__
cat > 'tickets/tests/medusa-client.test.ts' <<'__VICTO_FIN_8__'
import { afterEach, describe, expect, it, vi } from 'vitest';
import { CHAMPS_PRODUITS, configMedusa, lireCategoriesMedusa, lireProduitsMedusa } from '../src/lib/medusa/client';

const C = { url: 'http://medusa:9000', cle: 'pk_test', region: 'reg_ca' };
const P = { id: 'p', title: 'P', subtitle: null, handle: 'p', description: null, thumbnail: null };
type Appel = { url: string; init: RequestInit | undefined };
function simuler(corps: unknown[], statut = 200): Appel[] {
  const appels: Appel[] = [];
  vi.stubGlobal('fetch', async (url: string, init?: RequestInit) => {
    appels.push({ url, init });
    return { ok: statut < 400, status: statut, json: async () => corps.shift() };
  });
  return appels;
}
afterEach(() => { vi.unstubAllGlobals(); });

describe('Medusa — configuration', () => {
  it('lit les trois variables, et retire la barre finale de l’adresse', () => {
    expect(configMedusa({ MEDUSA_URL: 'http://m:9000/', MEDUSA_CLE: 'k', MEDUSA_REGION: 'r' })).toEqual({ url: 'http://m:9000', cle: 'k', region: 'r' });
    expect(configMedusa({ MEDUSA_URL: 'http://m:9000', MEDUSA_CLE: 'k' })).toBeNull();
  });
});

describe('Medusa — lecture des produits', () => {
  it('lit page par page, avec la clé, la région, les champs et le cache', async () => {
    const appels = simuler([{ products: Array.from({ length: 100 }, () => P), count: 150 }, { products: Array.from({ length: 50 }, () => P), count: 150 }]);
    expect(await lireProduitsMedusa(C)).toHaveLength(150);
    const adresses = appels.map((a) => new URL(a.url));
    expect(adresses.map((u) => u.searchParams.get('offset'))).toEqual(['0', '100']);
    expect(adresses.every((u) => u.pathname === '/store/products' && u.searchParams.get('region_id') === 'reg_ca' && u.searchParams.get('fields') === CHAMPS_PRODUITS)).toBe(true);
    expect(appels.every((a) => (a.init?.headers as Record<string, string>)['x-publishable-api-key'] === 'pk_test')).toBe(true);
    expect(appels.every((a) => (a.init as { next?: { revalidate?: number } } | undefined)?.next?.revalidate === 60)).toBe(true);
  });

  it('s’arrête sur une page vide', async () => {
    simuler([{ products: [], count: 5 }]);
    expect(await lireProduitsMedusa(C)).toEqual([]);
  });

  it('signale un refus de Medusa', async () => {
    simuler([{}], 500);
    await expect(lireProduitsMedusa(C)).rejects.toThrow('500');
  });

  it('lit les catégories', async () => {
    const appels = simuler([{ product_categories: [{ id: 'c', name: 'Course', handle: 'course', parent_category_id: null }] }]);
    expect((await lireCategoriesMedusa(C)).map((c) => c.handle)).toEqual(['course']);
    expect(new URL(appels.map((a) => a.url).join('')).pathname).toBe('/store/product-categories');
  });
});
__VICTO_FIN_8__
cat > 'tickets/tests/medusa-convertir.test.ts' <<'__VICTO_FIN_9__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import {
  IMAGE_ABSENTE, STOCK_NON_SUIVI, convertirMarques, convertirProduit, type CategorieMedusa, type ProduitMedusa, type VarianteMedusa,
} from '../src/lib/medusa/convertir';

// La vraie réponse de l'API boutique de Medusa, pour le produit d'essai (medusa-6-produit-essai.sh).
const reel = JSON.parse(readFileSync('tests/fixtures/medusa-essai.json', 'utf8')) as {
  produit_vu_par_la_boutique: { products: ProduitMedusa[] };
  categories_vues_par_la_boutique: { product_categories: CategorieMedusa[] };
};
const CATS = reel.categories_vues_par_la_boutique.product_categories;
const PEGASUS = reel.produit_vu_par_la_boutique.products.find(() => true) as ProduitMedusa;
const id = (handle: string) => CATS.find((c) => c.handle === handle)?.id ?? '';
const V = (nom: string, calcule: number, original: number, autre: Partial<VarianteMedusa> = {}): VarianteMedusa => ({
  id: `v-${nom}`, title: nom, sku: `sku-${nom}`, manage_inventory: true, inventory_quantity: 3,
  options: [{ value: nom }], calculated_price: { calculated_amount: calcule, original_amount: original }, ...autre,
});
const avec = (autre: Partial<ProduitMedusa>) => convertirProduit({ ...PEGASUS, ...autre }, CATS);

describe('Medusa → site : la vraie réponse', () => {
  it('traduit le produit d’essai, champ par champ', () => {
    expect(convertirProduit(PEGASUS, CATS)).toEqual({
      id: 'prod_01M44NZSNKV1SQH53B1XNAWRCH',
      slug: 'essai-air-zoom-pegasus-41',
      nom: 'Air Zoom Pegasus 41 (essai)',
      marque: { id: 'pcat_01M44NZMT1V09TM0T564QY74JN', nom: 'Nike', slug: 'nike' },
      imageUrl: IMAGE_ABSENTE,
      prixCents: 12900,
      prixCompareCents: 15900,
      variantes: [
        { id: 'variant_01M44NZSTW7P1PTBDRZFDG818P', taille: '41', sku: 'essai-pegasus-41', stock: 5 },
        { id: 'variant_01M44NZSTWSTC0VQFX44ZP5R21', taille: '42', sku: 'essai-pegasus-42', stock: 5 },
      ],
      genre: 'homme',
      categorie: 'chaussures',
      type: 'course',
      description: 'Produit d\'essai créé par l\'équipe technique pour brancher la boutique. À supprimer ensuite.',
    });
  });

  it('trouve les marques sous « Marques », et seulement elles', () => {
    expect(convertirMarques(CATS).map((m) => m.slug)).toEqual(['nike', 'adidas', 'converse', 'lacoste', 'levis', 'new-balance']);
    expect(convertirMarques(CATS.filter((c) => c.handle !== 'marques'))).toEqual([]);
  });
});

describe('Medusa → site : les cas du client', () => {
  it('lit le genre dans les étiquettes', () => {
    expect(avec({ tags: [{ value: 'femme' }, { value: 'homme' }] }).genre).toBe('mixte');
    expect(avec({ tags: [{ value: 'femme' }] }).genre).toBe('femme');
    expect('genre' in avec({ tags: [] })).toBe(false);
  });

  it('prend le prix le plus bas, et ne barre que pendant des soldes', () => {
    const p = avec({ variants: [V('41', 159, 159), V('42', 139, 179)] });
    expect([p.prixCents, p.prixCompareCents]).toEqual([13900, 17900]);
    const sansSolde = avec({ variants: [V('41', 159, 159)] });
    expect(sansSolde.prixCents).toBe(15900);
    expect('prixCompareCents' in sansSolde).toBe(false);
  });

  it('se rabat sur le sous-titre quand la marque n’est pas cochée', () => {
    expect(avec({ categories: [{ id: id('course') }], subtitle: 'New Balance' }).marque).toEqual({ id: 'marque-new-balance', nom: 'New Balance', slug: 'new-balance' });
    expect(avec({ categories: [], subtitle: null }).marque.nom).toBe('Sans marque');
  });

  it('accepte le rayon coché à la place du type', () => {
    const p = avec({ categories: [{ id: id('chaussures') }, { id: id('nike') }] });
    expect(p.categorie).toBe('chaussures');
    expect('type' in p).toBe(false);
  });

  it('lit le stock, et marque l’inventaire non suivi comme disponible', () => {
    const p = avec({ variants: [V('41', 159, 159, { inventory_quantity: -2 }), V('42', 159, 159, { manage_inventory: false }), V('43', 159, 159, { options: [] })] });
    expect(p.variantes.map((v) => [v.taille, v.stock])).toEqual([['41', 0], ['42', STOCK_NON_SUIVI], ['43', 3]]);
  });

  it('choisit la photo : vignette, sinon première image, sinon l’image de remplacement', () => {
    const images = [{ url: 'https://exemple.ca/a.jpg' }, { url: 'https://exemple.ca/b.jpg' }];
    const complet = avec({ thumbnail: 'https://exemple.ca/vignette.jpg', images });
    expect([complet.imageUrl, complet.images]).toEqual(['https://exemple.ca/vignette.jpg', ['https://exemple.ca/a.jpg', 'https://exemple.ca/b.jpg']]);
    expect(avec({ thumbnail: null, images }).imageUrl).toBe('https://exemple.ca/a.jpg');
    expect(avec({ thumbnail: null, images: [] }).imageUrl).toBe(IMAGE_ABSENTE);
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/produit-type.test.ts' <<'__VICTO_FIN_10__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('catalogue — type de produit', () => {
  it('ajoute un champ « type » facultatif au produit', () => {
    const s = readFileSync('src/lib/catalogue.ts', 'utf8');
    const produit = s.slice(s.indexOf('export interface Produit'));
    expect(produit.slice(0, produit.indexOf('\n}'))).toContain('  type?: string;');
  });
});
__VICTO_FIN_10__
TESTS=(api-catalogue.test.ts catalogue-source.test.ts medusa-client.test.ts medusa-convertir.test.ts produit-type.test.ts)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "5 specs, 5 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/113*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-113.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 113 — fondations Medusa ; réponse réelle et image de remplacement"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-113.tsv ./run.sh\n\nCinq tickets en chaîne, environ une heure et quart. Aucun changement visible : le site reste sur les données de démonstration.\n'
