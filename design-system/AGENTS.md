# AGENTS.md — design-system

Tento soubor platí pro práci uvnitř `design-system/`.

Před jakoukoliv vizuální nebo formátovanou prací použij skill
`design-system-lookup`. Pokud skill ještě není dostupný v cílovém workspace,
čti minimálně `README.md`, `ARCHITECTURE.md`, `INITIALIZATION.md` a
`BASELINE.md`.

## Source-of-truth

Pořadí autority:

1. Produkční zdroje firmy (`modules/website/`, produkční UI, brand brief)
2. Explicitní brand a voice dokumenty (`modules/knowledgebase/`,
   `company/agents/voice/`)
3. `design-system/` jako sjednocená a reviewovatelná vrstva

Když se `design-system/` rozchází s produkcí, produkce má pravdu a
design-system se aktualizuje.

## Co sem patří

- brand baseline a design tokens
- typography, color, spacing a layout pravidla
- reference examples pro web, slides, dokumenty, tabulky, merch
- templates a startery pro opakované formáty
- cross-platform UI poznámky pro `launchpad/` a `company/toolbox/`

## Co sem nepatří

- secrets, API klíče, OAuth session data
- náhodné moodboardy bez vazby na produkční brand
- produkční authoring UI
- velké exporty bez metadat a bez jasného source-of-truth
- kopie brand assetů jiné firmy

## Viewer

`app/` je read-only Astro viewer. Přesný listener vlastní
`lazurio.module.json`; centrální Launchpad stejný lease předá runtime a drží
single-instance zámek. Přímý `npm run dev` načte tentýž lease, takže port není
závislý na ručně připraveném `.env`.

Authoring zůstává souborový: edituj `content/`, ne app UI.
