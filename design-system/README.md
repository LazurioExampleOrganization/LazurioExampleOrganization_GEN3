# Design System

`design-system/` je kanonická design-system vrstva GEN2 workspace. Je to
top-level in-tree slozka super-repa, ne submodul.

Jeji role je jednoducha: agent ani kolega nema vymyslet barvy, fonty,
layouty a vizualni pravidla od nuly. Nejdrive se najde firemni
source-of-truth, potom se sem zapise kuratorovana baseline, ktera se da
opakovat ve webu, prezentacich, dokumentech, tabulkach, nabidkach a internich
toolich.

## Struktura

```text
design-system/
├── README.md
├── AGENTS.md
├── ARCHITECTURE.md
├── INITIALIZATION.md
├── BASELINE.md
├── content/
│   ├── brand/          # logo, barvy, typografie, brand notes
│   ├── examples/       # reviewovatelne reference napric formaty
│   └── templates/      # startery pro dokumenty, slides, tabulky
└── app/                # read-only Astro viewer
```

## Spusteni vieweru

```bash
cd design-system/app
npm install
npm run build
```

Viewer spusť přes centrální Launchpad jako modul `design-system`, nebo přímo
pomocí `npm run dev`. V obou případech načte přesný listener z vedlejšího
`lazurio.module.json`. Appka je jen prohlížeč, authoring se dělá editací
souborů v `design-system/content/`.

## Kriticke pravidlo inicializace

Design system se neinicializuje z dojmu. Pred prvnim zapisem projdi
`INITIALIZATION.md` a najdi realny source-of-truth firmy:

- `modules/website/`, pokud firma ma verejny web
- `modules/knowledgebase/`, pokud drzi brand brief nebo strategii
- `company/agents/voice/`, pokud se resi ton komunikace
- produkcni aplikace v `modules/<app>/`, pokud uz existuje UI

Pri konfliktu vitezi aktualni produkcni source-of-truth. `design-system/`
je kuratorovane zrcadlo a sjednocovaci vrstva, ne paralelni brand silo.
