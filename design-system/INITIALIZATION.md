# Design System Initialization

Tento checklist pouzij pri zalozeni nebo vetsim refreshi design systemu.

## 1. Najdi source-of-truth

Projdi, pokud existuji:

- `modules/website/README.md`
- `modules/website/ARCHITECTURE.md`
- `modules/website/AGENTS.md`
- produkcni CSS / theme tokens ve website aplikaci
- `modules/knowledgebase/` brand, strategy nebo service docs
- `company/agents/voice/`
- existujici prezentace, nabidky, datasheety a dokumenty

## 2. Vytahni baseline

Zapis do `BASELINE.md`:

- kanonicky nazev a public brand name
- tone-of-voice source
- primary colors
- typography
- layout principles
- forbidden claims / zakazane vizualni smery
- kde se maji aktualizovat produkcni surfaces

## 3. Napln content/

Minimalni prvni commit:

- `content/brand/colors/tokens.json`
- `content/brand/colors/palette.md`
- `content/brand/typography/typography.md`
- `content/examples/README.md`
- `content/templates/README.md`

## 4. Over viewer

```bash
cd design-system/app
npm install
npm run build
```

Pak viewer otevři přes centrální Launchpad jako modul `design-system`, nebo ho
pro vývoj spusť přímo pomocí `npm run dev`. Obě cesty čtou stejný pevný
listener z `lazurio.module.json`; ruční `.env` ani Organization pool zavedený
port nemění.

## 5. Zapis drift

Kdyz zjistis rozpor mezi produkci a design-systemem:

1. produkce zustava pravda
2. design-system oprav
3. pokud je produkce zjevne zastarala, zapis otevreny follow-up do
   `TODO.md` nebo do prislusneho modulu
