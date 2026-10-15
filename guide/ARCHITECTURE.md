# ARCHITECTURE.md — `guide/`

Tento soubor popisuje, jak je interaktivní onboarding `guide/` strukturován.

`README.md` je pro lidi. `AGENTS.md` jsou pravidla pro agenta. `ARCHITECTURE.md` (tento soubor) drží technický model.

## 1. Tři vrstvy

```
guide/
├── content/           # 1. CONTENT vrstva — markdown + JSON
├── app/               # 2. APP vrstva — Astro renderer + SSR API
└── company/colleagues/<ty>/guide/   # 3. PROFILE INTEGRATION (per kolega)
```

### 1.1 Content vrstva (`guide/content/`)

**Vlastník:** content tým (autoři lekcí), agenti přes skill `guide-maintenance`.

**Co obsahuje:**

- `cesta.json` — struktura kurzu (sekce + pořadí lekcí)
- `achievements/achievements.json` — definice všech odznaků (interně `achievement`)
- `lekce/<NN-slug>/lekce.md` — markdown body lekce
- `lekce/<NN-slug>/kviz.json` — kvíz (volitelné)
- `lekce/<NN-slug>/ukol.md` — praktický úkol (volitelné)

**Pravidla:**

- Vše v češtině
- Vše verzováno v Gitu (super-repo)
- Žádné runtime data (progres uživatele) — to jde do PROFILE vrstvy

### 1.2 App vrstva (`guide/app/`)

**Vlastník:** SW tým, držitel `guide/app/`. **Tento soubor app NEPOPISUJE detail** — viz `guide/app/README.md` (pokud existuje) nebo Astro config.

**Klíčové vlastnosti:**

- **Astro + SSR** — protože potřebujeme file write API endpoints (zápis progresu do `company/colleagues/<ty>/guide/`)
- **Read content/** — všechny lekce, kvízy, úkoly načítá z file system
- **Read profile** — načte postup a odznaky uživatele
- **Write profile** — při dokončení lekce/kvízu/úkolu zapíše do `company/colleagues/<ty>/guide/`
- **Port 5292** — fixní port (mimo Launchpad standardní rozsah, aby nekolidoval)

### 1.3 Profile integration vrstva (`company/colleagues/<ty>/guide/`)

**Vlastník:** každý kolega má svou.

**Co obsahuje:**

```
company/colleagues/<ty>/guide/
├── progress.json         # stav lekcí (in-progress, completed, kviz scores)
└── achievements/         # jeden markdown soubor per získaný odznak
    ├── first-lesson.md
    ├── doctor-green.md
    └── ...
```

**Pravidla:**

- **Trackováno v Gitu** — kolegové vidí tvůj postup, mohou gratulovat
- **Append-only odznaky** — jakmile získáš odznak, zůstává (jeden markdown soubor)
- **`progress.json`** je read+write — ukazuje aktuální stav

## 2. Flow uživatele

```
1. Login (přes osobní složku — workspace ví, kdo jsi)
   ↓
2. Přehled kurzu (čte cesta.json + progress.json + achievements/)
   ↓
3. Vyber lekci → render lekce.md
   ↓
4. Pokud quiz: true → render kviz.json (interaktivní)
   ↓
5. Pokud ukol: true → render ukol.md (checklist)
   ↓
6. Při dokončení → POST /api/complete → write do company/colleagues/<ty>/guide/
   ↓
7. Trigger odznaku se vyhodnotí → pokud match, append do achievements/
   ↓
8. Návrat na přehled kurzu → vidíš nový stav
```

## 3. Odznakový engine

### 3.1 Trigger types

| Type | Trigger podmínka | Příklad |
|---|---|---|
| `lekce-complete` | Uživatel dokončil lekci s daným `ref` | `first-lesson` (ref `01-vek-agentu`) |
| `kviz-pass` | Uživatel prošel kvíz s daným `ref` (skore ≥ pass threshold) | (rezerva, zatím nepoužito) |
| `ukol-complete` | Uživatel označil úkol jako hotový | `doctor-green` (ref `09-doctor`) |
| `section-complete` | Uživatel dokončil všechny lekce v sekci | `mindset-section-done` |
| `cesta-complete` | Uživatel dokončil všechny lekce v cestě | `workspace-master` |

### 3.2 Vyhodnocení

Po každé akci uživatele (complete lesson / quiz / ukol) backend:

1. Načte `achievements.json`
2. Pro každý odznak vyhodnotí trigger
3. Pokud match a uživatel ho ještě nemá, vytvoří `company/colleagues/<ty>/guide/achievements/<id>.md` s:
   ```yaml
   ---
   achievement_id: first-lesson
   name: První krok
   unlocked_at: 2026-04-25T14:32:11Z
   lekce: 01-vek-agentu
   ---
   ```
4. Notifikuje frontend (toast / animace)

### 3.3 Git-native odznaky

Každý odznak je samostatný markdown soubor. To umožňuje:

- **Sociální vizibilitu** — kolega vidí v Gitu, kdy jsi co získal/a
- **Append-only historii** — odznak nikdo nesmaže (kromě tebe explicitně)
- **Gratulační mechaniku** — agent / kolega vidí přes git log nové odznaky
- **Bezstarostná persistance** — žádná databáze, jen soubory

## 4. Proč Astro + SSR

### Důvody pro Astro

- **Statický rendering** lekcí (markdown → HTML) je super rychlý
- **Component islands** pro interaktivní části (kvíz, checklist)
- **Built-in MD/MDX support**
- **Známé patterns** — používáme stejně i v planned modulech, task ledgerech a
  `design-system/`

### Důvody pro SSR (ne jen static)

- Potřebujeme **file write API endpoints** — zápis do `company/colleagues/<ty>/guide/`
- Potřebujeme **file read za runtime** — content se může měnit (zejména přes `guide-maintenance`)
- Potřebujeme **per-user state** — nepatří to do session storage v browseru, patří to na disk

## 5. Vztah k workspace

`guide/` **čte** workspace, ale **necituje fakta** bez zdroje. Pokud lekce
odkazuje na konkrétní fakt o plánovaném modulu, autoritou je manifest nebo
budoucí modul.

Pokud workspace změní strukturu (např. přidání nové vrstvy), `guide/` se musí **aktualizovat** přes skill `guide-maintenance`. Bez aktualizace stárne a stává se zdrojem zmatku.

## 6. Cross-platform

Guide musí fungovat **na macOS i Windows** (z root pravidla).

- File paths v API endpoints používají `path.join` (Node.js / Bun standardní)
- Žádné hard-coded uživatelské ani platform-specific absolutní cesty
- Astro běží stejně na obou OS

## 7. Bezpečnost

- **`guide/app/`** smí číst `guide/content/` a `company/colleagues/<ty>/guide/`
- **NESMÍ** číst `company/colleagues/<jiný_kolega>/` (privacy)
- **NESMÍ** zapisovat mimo `company/colleagues/<ty>/guide/`
- **NESMÍ** spouštět shell příkazy (čtení/zápis pouze přes API)

## 8. Růst

Kurz začíná na ~25 lekcích a 5 sekcích. Předpokládá se, že:

- Sekce 1–2 (Základ + První orientace) zůstanou stabilní (základ se nemění často)
- Sekce 3 (Komunikace) se bude rozšiřovat o nové nástroje (gbrain, MCP, autonomní agenti)
- Sekce 4 (První práce) bude reflektovat vývoj doctor/skills
- Sekce 5 (Přispívání) je otevřená, přidáváme dle potřeby

Odznaky se přidávají s lekcemi, nikoliv izolovaně.

## 9. Co tato vrstva NENÍ

- Není to autoritativní zdroj informací o AgentMintu (to je `modules/`, `GLOSSARY.md`, `ARCHITECTURE.md`)
- Není to research evidence (to bude `modules/research/`)
- Není to experiment log (to bude `modules/experiments/`)
- Není to ChatGPT plugin ani externí webová služba
- Není to gamifikace pro gamifikaci — odznáčky odráží reálné milníky kompetence
