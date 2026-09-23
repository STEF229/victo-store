] TICKET 095b  →  src/components/catalogue/TiroirsFiltres.tsx   (tests : tests/TiroirsFiltres.test.tsx)
[19:52:18]   dépendances fusionnées : 095a
[19:52:18]   tests activés : tickets/tests/TiroirsFiltres.test.tsx → tests/TiroirsFiltres.test.tsx
[19:52:27]   contexte (déclarations de types) : src/components/catalogue/filtres-affichage.ts
[19:52:27]   budget : ≈ 6641 jetons lus + 1733 écrits = 8374 / 24576 (plafond 22118)
[19:52:27]   tentative 1/3 — appel du modèle…
[20:05:26]     |    × TiroirsFiltres — filtres > marque les choix actifs et les autres 25ms
[20:05:26]     |      → classe border-[var(--vs-noir)]: expected [ 'flex', 'h-[46px]', …(9) ] to include 'border-[var(--vs-noir)]'
[20:05:26]   porte ROUGE — relance avec la spec et les seuls échecs
[20:05:26]   budget de la relance : ≈ 10344 / 24576
[20:05:26]   tentative 2/3 — appel du modèle…
^[[20:16:05]     |    × TiroirsFiltres — filtres > marque les choix actifs et les autres 25ms
[20:16:05]     |      → classe border-[var(--vs-noir)]: expected [ 'flex', 'h-[46px]', …(9) ] to include 'border-[var(--vs-noir)]'
[20:16:05]   MÊME ÉCHEC qu'à la tentative précédente — arrêt, une relance n'y changera rien
[20:16:05]   laissé isolé sur auto/095b — main est intact
[20:16:07]   branche calée poussée sur origin/auto/095b
[20:16:07] ──────────────────────────────────────────────────────────────
[20:16:07] TICKET 095c  →  src/components/catalogue/FiltresBarre.tsx   (tests : tests/FiltresBarre-v3.test.tsx)
[20:16:07]   BLOQUÉ : dépend du ticket 095b, qui n'est pas fusionné dans main

[20:16:07] ═══════════════ RAPPORT  (20260923-194216) ═══════════════
  095a         VERT     (tentatives : 1)
  095b         CALÉ    (tentatives : 2)
  095c         BLOQUÉ  (tentatives : 0)
[20:16:07] logs : .logs/20260923-194216
[20:16:07] main : d70dcd3 — feat(095a): fusionné au vert par le harnais
