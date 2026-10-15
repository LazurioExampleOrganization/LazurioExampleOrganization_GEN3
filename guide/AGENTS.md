# AGENTS.md — pravidla pro agenta v `guide/`

Tento soubor řídí, jak má agent (Claude Code, Cursor, Codex) pracovat s interaktivním onboardingem v `guide/`.

Je to AGENTS overlay v kaskádě (viz root `AGENTS.md §1`):

```
root AGENTS.md → company/roles/<role>/ → company/colleagues/<ty>/ → guide/AGENTS.md
```

## 1. Co `guide/` vlastní (a co NE)

`guide/` je **jediný source of truth pro interaktivní onboarding** ve AgentMint Organizace GEN3.

- `guide/content/` drží lekce, kvízy, úkoly, achievementy, strukturu cesty
- `guide/app/` je Astro renderer (čte `content/`, ukazuje uživateli, zapisuje progres do `company/colleagues/<ty>/guide/`)
- root docs (`README.md`, `AGENTS.md`, `ARCHITECTURE.md`, `CHANGELOG.md`) drží mety/pravidla

`guide/` **NENÍ náhrada** za:

- `GLOSSARY.md` — autoritativní pro **definice doménových pojmů**
- `MAP.md` — autoritativní pro **orientaci v rootu**
- root `ARCHITECTURE.md` — autoritativní pro **technický model**
- `modules/research/` — budoucí autorita pro **mechanism scans a zdroje**
- `modules/experiments/` — budoucí autorita pro **testy a výsledky**
- `modules/playbooks/` — budoucí autorita pro **ověřené postupy**

`guide/` je **pedagogická vrstva** nad těmito autoritami. Cituje je, vysvětluje, ale **nepředepisuje** fakta.

### Pravidlo zlaté ruky

Pokud v guide narazíš na něco, co **není v autoritativní vrstvě**, máš dvě možnosti:

1. Buď to do autoritativní vrstvy doplň (a teprve pak do guide cituj)
2. Nebo to z guide odeber jako spekulaci

**Nikdy** nenechávej v guide tvrzení, které nemá oporu v autoritativní vrstvě.

## 2. Kdy guide aktualizovat

Guide musí reflektovat **skutečný stav workspace**, ne idealizovanou verzi. Aktualizuj guide, když nastane:

| Změna v workspace | Co aktualizovat v guide |
|---|---|
| Nový skill v `.claude/skills/` | Lekce 14 (skills); zvažovat samostatný nový lekci |
| Změna v root `ARCHITECTURE.md` (sekce 1–7, 12, 16) | Lekce 6 (pět vrstev), případně lekce 4 |
| Přidaný/odebraný MCP server | Lekce 15 |
| Změna v doctor flow | Lekce 9 (doctor) a lekce 19 (commit/push) |
| Přidaný top-level docs file v rootu | Lekce 7 (AGENTS/README/MAP) |
| Nový/odebraný modul v `modules/` | Lekce 10 (procházka) |
| Změna v task ledger nebo task manager modelu | Lekce 18 (task ledger) |
| Změna v `company/colleagues/_template/` | Lekce 16 (profil) |
| Změna v `company/agents/voice/` nebo reference/ | Lekce 14 (skills není), spíš lekce 21 (kam přidat) |
| Nová role v `company/roles/` | Lekce 17 (role) |

Pokud si nejsi jistý/á, zda změna ovlivňuje guide, použij skill **`guide-maintenance`**.

## 3. Schéma pro lekci

Každá lekce žije v `guide/content/lekce/<NN-slug>/lekce.md`:

```yaml
---
id: <NN-slug>            # např. "01-vek-agentu"
title: <český titulek>
section: <section_id>    # např. "1-mindset"
order: <NN>
prerequisites: [<id>, ...]   # pole IDček předchozích lekcí
duration_min: <číslo>    # 5-15
achievement_on_complete: <achievement_id?>   # volitelné
quiz: true|false
ukol: true|false
---

# Markdown body...
```

**Pravidla pro body:**

- Začni odrážkou „Co se v této lekci naučíš:"
- 200–500 slov
- Krátké odstavce (3–5 řádků)
- Konkrétní příklady z firmy (`modules/research/`, „mechanism scan",
  „experiment guardrail")
- Konec: krátké shrnutí + co bude příště
- **Čeština.** Klidně mix s běžnými EN slovy (workspace, commit, repo, prompt, skill, MCP).

## 4. Schéma pro kvíz

Pokud `quiz: true`, soubor `guide/content/lekce/<NN-slug>/kviz.json`:

```json
{
  "questions": [
    {
      "id": "q1",
      "text": "Otázka v češtině",
      "type": "single",
      "options": [
        { "id": "a", "text": "Varianta A", "correct": false, "feedback": "Konkrétní vysvětlení proč ne" },
        { "id": "b", "text": "Varianta B", "correct": true, "feedback": "Krátká pochvala + zopakování důvodu" }
      ],
      "explanation": "Souhrnné vysvětlení po dokončení otázky"
    }
  ],
  "achievement_on_pass": "<achievement_id?>"
}
```

**Pravidla:**

- 3–5 otázek na kvíz (úvodní lekce stačí 2)
- Každá otázka 3–4 varianty
- Vždy konkrétní `feedback` na každou variantu (ne generické „špatně")
- Test pochopení, ne paměti

## 5. Schéma pro úkol

Pokud `ukol: true`, soubor `guide/content/lekce/<NN-slug>/ukol.md`:

```yaml
---
title: <název úkolu>
type: terminal|browser|file|reflection
checklist:
  - "Krok 1"
  - "Krok 2"
  - "..."
achievement_on_complete: <achievement_id?>
---

# Markdown popis úkolu — proč ho děláme, co se naučíš
```

**Které lekce mají úkol:** 9 (doctor), 10 (procházka), 16 (profil), 18 (task ledger), 19 (commit), 23 (skill). Ostatní zvaž případ od případu.

## 6. Schéma pro achievement

`guide/content/achievements/achievements.json`:

```json
{
  "achievements": [
    {
      "id": "first-lesson",
      "name": "První krok",
      "description": "Krátký popis",
      "icon": "compass",
      "level": "bronze",
      "trigger": { "type": "lekce-complete", "ref": "01-vek-agentu" }
    }
  ]
}
```

**Ikony k volbě:** `trophy`, `star`, `zap`, `compass`, `wrench`, `rocket`, `book`, `sparkles`

**Levely:**
- `bronze` — za dokončenou lekci nebo drobný milník
- `silver` — za dokončenou sekci nebo důležitou schopnost
- `gold` — za celou cestu nebo velký milestone

**Trigger types:**
- `lekce-complete` (ref = lesson id)
- `kviz-pass` (ref = lesson id)
- `ukol-complete` (ref = lesson id)
- `section-complete` (ref = section id)
- `cesta-complete` (žádný ref)

## 7. Když přidáváš novou lekci

1. Vytvoř složku `guide/content/lekce/<NN-slug>/`
2. Napiš `lekce.md` podle šablony
3. Napiš `kviz.json` (pokud má kvíz)
4. Napiš `ukol.md` (pokud má úkol)
5. **Aktualizuj `guide/content/cesta.json`** — přidej `id` do správné sekce, ev. uprav pořadí
6. **Zvaž achievement** — pokud je lekce milník, přidej do `achievements/achievements.json`
7. Aktualizuj `CHANGELOG.md`
8. Commit přes doctor

## 8. Cílová skupina je netechnická

Toto je nejdůležitější ze všech pravidel.

- **Drž jednoduchý jazyk.** Když musíš použít technický termín, vždy ho stručně vysvětli.
- **Vyhýbej se žargonu** typu „pointer commit", „dirty worktree" — pokud to musíš použít, vysvětli, co to je.
- **Příklady z firmy.** „Obchodník píše e-mail" je lepší než abstraktní „uživatel".
- **Motivační tón.** Cesta má pomáhat, ne zastrašovat.

## 9. Žádný slop v lekci

Aplikuj to, co lekce 5 učí. **Lekce, která sama o sobě je slop, je trapas.**

Před commitem si projdi:

- Je tam vágní klišé („inovativní řešení")?
- Je tam falešné jistoty (vymyšlený fakt o AgentMintu)?
- Je tam vata (80 % textu, 20 % obsahu)?
- Je tam konkrétní odkaz na realitu?

Pokud nějaká z prvních tří otázek dá ano, přepiš.

## 10. Cross-reference

Skill **`guide-maintenance`** je tvůj hlavní nástroj pro práci s touto vrstvou. Aktivuje se automaticky, když:

- vznikl nový skill v `.claude/skills/`
- změnila se ARCHITECTURE/MAP/AGENTS
- přidal/odebral se MCP server
- změnil se doctor flow
- přibyl top-level docs file
- přibyl/zmizel modul

Skill drží přesné instrukce, jak udržet guide v souladu s realitou workspace.

## 11. Co tento soubor NENÍ

- Není to seznam lekcí (to je `cesta.json`)
- Není to obsah lekcí (to je `content/lekce/`)
- Není to renderer (to je `app/`)

Tento soubor je **operační příručka pro agenta**, který guide udržuje.
