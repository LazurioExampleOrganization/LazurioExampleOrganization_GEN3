---
name: design-system-lookup
description: Pouzij, kdyz mas produkovat cokoliv vizualniho nebo formatovaneho pro GEN2 firmu — web page, prezentaci, dokument, nabidku, tabulku, merch, e-mail sablonu nebo UI. Skill nejdrive najde firemni source-of-truth a potom te navede do `design-system/`.
---

# Skill: design-system-lookup

## Kdy skill pouzit

- Uživatel chce web layout, hero sekci, landing page nebo UI komponentu.
- Uživatel chce prezentaci, dokument, nabidku, report, tabulku nebo merch.
- Uživatel rekne "v nasi identite", "podle brandu", "hezky to
  layoutni", "design systemem" nebo podobne.
- Menis vizualni pravidlo, barvu, font, spacing, logo usage nebo format
  opakovatelneho vystupu.

## Kdy skill nepouzivat

- Cisty backend bug fix bez UI dopadu.
- Plain interní Markdown bez custom formatu.
- Jednorazovy technicky diff, kde se nevytvari vizualni vystup.

## Preflight

1. Otevri `design-system/README.md`.
2. Otevri `design-system/BASELINE.md`.
3. Otevri `design-system/content/brand/colors/tokens.json`.
4. Otevri `design-system/content/brand/typography/typography.md`.
5. Pokud existuje relevantni produkcni source:
   - `modules/website/`
   - `modules/knowledgebase/`
   - `company/agents/voice/`
   - prislusny app modul

## Authority Matrix

| Vystup | Primarni source-of-truth | Design-system reference |
|---|---|---|
| Web / UI | `modules/website/` nebo produkcni app modul | `design-system/content/examples/web/` |
| Dokument / nabidka | modul, ktery dokument generuje, nebo `modules/deals/` | `design-system/content/examples/documents/` |
| Prezentace | `modules/presentation/` nebo brand brief | `design-system/content/examples/presentations/` |
| Tabulka / report | modul vlastnici data | `design-system/content/examples/tables/` |
| Merch / asset | brand source + logo/license source | `design-system/content/examples/merch/` |
| Tone/copy | `company/agents/voice/` + knowledgebase | `design-system/BASELINE.md` |

## Pravidla

- Nekopiruj brand assety jine firmy.
- Neimaginuj barvy a fonty, pokud existuje produkcni source.
- Pri konfliktu vitezi produkcni source-of-truth; design-system se
  aktualizuje.
- Appka v `design-system/app/` je read-only viewer, ne authoring UI.
- Stabilni design rozhodnuti zapis do `design-system/`, ne jen do chatu.

## Preview

```bash
cd design-system/app
npm install
npm run dev
```

Přesný listener ověř v `design-system/lazurio.module.json`; do skillu ani do
lokálního `.env` se jeho číslo nekopíruje.
