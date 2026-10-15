# Guide — interaktivní onboarding do Workspace

`guide/` je jednoduchý kurz pro nové kolegy v AgentMint, kteří přecházejí z
práce s AI v prohlížeči do práce ve Workspace s agentem.

Není to dokumentace ani wiki. Je to výuková vrstva s lekcemi, kvízy,
praktickými úkoly a odznaky. Cílová skupina jsou netechničtí kolegové, kteří
chtějí pochopit, jak s Codexem pracovat efektivně a bezpečně.

## Pro koho

- nový kolega v AgentMint
- kolega, který poprvé otevírá Codex, Cursor nebo Claude Code
- kdokoliv, kdo chce vědět, kde co ve workspace hledat a jak zadávat práci agentovi

## Jak to spustit

```bash
cd guide/app
npm install   # poprvé
npm run dev
```

Otevře se na **http://localhost:5292**.

(Až bude integrované do Launchpadu, půjde spustit i přes `bun run app -- guide`
z `launchpad/app/v1/`.)

## Co tam najdeš

Kurz má **5 sekcí** a 25 krátkých lekcí:

1. **Proč workspace dává smysl** — co se mění, proč nestačí jen chat a jak se vyhnout AI vatě.
2. **První orientace** — kde jsou důležité složky, README, AGENTS, slovník a doctor.
3. **Jak mluvit s agentem** — jak zadávat práci, diktovat zadání a používat uložené postupy.
4. **První práce ve workspace** — profil, role, task ledger, uložení změny a řešení chyb.
5. **Jak přispívat** — kam zapisovat nové věci, jak pomoct kolegům a jak vytvořit první skill.

Každá lekce může mít:

- **`lekce.md`** — krátké vysvětlení obyčejnou češtinou
- **`kviz.json`** — rychlý kvíz na pochopení
- **`ukol.md`** — praktický úkol, který si člověk rovnou vyzkouší

Za dokončené milníky získáváš **odznaky**. Nejsou jen dekorace: ukazují, že
člověk zvládl konkrétní dovednost.

## Struktura adresáře

```
guide/
├── README.md            ← tenhle soubor
├── AGENTS.md            ← pravidla pro agenta, který guide udržuje
├── ARCHITECTURE.md      ← jak je guide strukturován
├── CHANGELOG.md         ← změny v guide
├── content/             ← obsah kurzu
│   ├── cesta.json       ← struktura kurzu (sekce, pořadí lekcí)
│   ├── achievements/
│   │   └── achievements.json
│   └── lekce/
│       ├── 01-vek-agentu/
│       │   ├── lekce.md
│       │   └── kviz.json
│       ├── 09-doctor/
│       │   ├── lekce.md
│       │   ├── kviz.json
│       │   └── ukol.md
│       └── ... (25 lekcí)
└── app/                 ← Astro aplikace
    ├── astro.config.mjs
    ├── package.json
    ├── tsconfig.json
    └── src/
```

## Propojení s `company/colleagues/<ty>/`

Tvůj postup a odznaky se zapisují do tvé osobní složky:

```
company/colleagues/<ty>/guide/
├── progress.json         ← které lekce máš hotové
└── achievements/         ← tvoje odznaky
    ├── first-lesson.md
    ├── doctor-green.md
    └── ...
```

Tahle složka je trackovaná v Gitu, takže kolegové vidí tvůj posun a mohou ti
pogratulovat.

## Když najdeš chybu nebo zastaralou informaci

Použij skill **`guide-maintenance`** v Codexu nebo Claude Code. Provede tě
úpravou lekce, kvízu nebo úkolu a připomene kontrolu lokální aplikace.

Nebo otevři příslušný `lekce.md`, `kviz.json` nebo `ukol.md` v
`content/lekce/<NN-slug>/`, uprav ho a změnu odešli standardním workspace
postupem.

## Vztah k ostatním vrstvám

`guide/` **není náhrada** za:

- `GLOSSARY.md` — autoritativní slovník pojmů
- `MAP.md` — orientace v rootu workspace
- `ARCHITECTURE.md` — technický model workspace
- `modules/research/` — mechanism scans a zdroje
- `modules/experiments/` — testy, metriky a výsledky
- `modules/playbooks/` — ověřené opakovatelné mechanismy

`guide/` je pedagogická vrstva nad nimi. Vysvětluje koncepty, dává kontext a
vede člověka k prvním praktickým krokům. Konkrétní fakta se vždy ověřují ve
zdrojové vrstvě.

## Pravidla pro autora obsahu

Detail je v `AGENTS.md`. Stručně:

- cílová skupina je netechnická
- piš krátce, konkrétně a česky
- technický termín vysvětli hned při prvním použití
- používej příklady z firmy
- vyhýbej se prázdným frázím a AI vatě

Kvalita guidu stojí na kvalitě obsahu. Aplikace je jen způsob, jak obsah
zpřístupnit.
