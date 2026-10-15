---
name: guide-maintenance
description: Udržuj guide/ interaktivní onboarding v souladu s reálným stavem Workspace GEN2. Spusť, když vznikl nový skill, změnila se ARCHITECTURE.md/MAP.md/AGENTS.md, přidal/odebral se MCP server, změnil se doctor flow, přibyl top-level docs file, nebo přibyl/zmizel modul. Cílem je, aby lekce v guide/content/ vždy reflektovaly skutečnou strukturu workspace.
---

# Skill: guide-maintenance

Údržba `guide/` — interaktivní onboarding aplikace pro nové kolegy
přecházející z fáze 1 (web AI nástroje, ChatGPT) na Workspace GEN2.

`guide/` je sourozenec `design-system/` — top-level in-tree adresář
(ne submodul) v super-repu. Obsahuje:

- `guide/content/` — lekce (markdown), kvízy (json), úkoly (markdown),
  achievementy (json) v češtině
- `guide/app/` — Astro 5 SSR appka na portu 5692, volitelně
  registrovaná v Launchpadu

Lekce čerpají fakta z `ARCHITECTURE.md`, `MAP.md`, `GLOSSARY.md`,
`AGENTS.md` a z `.claude/skills/`. Když se workspace mění, guide
musí dohnat — jinak nový kolega dostane zastaralý mentální model.

## Kdy tenhle skill použít

- Vznikl nový skill v `/.claude/skills/` (nebo se starý odstranil/přejmenoval)
- Změnila se `ARCHITECTURE.md`, `MAP.md`, `GLOSSARY.md` nebo `AGENTS.md`
  v kořeni (zvlášť sekce o vrstvách, modulech, doctor flow, MCP)
- Přidal/odebral se MCP server v baseline (root `AGENTS.md §5`)
- Změnil se `doctor.sh` flow nebo přibyl/odebral doctor command
- Přibyl nový top-level docs file v rootu workspace
- Přibyl nový modul v `modules/`, nebo se nějaký přejmenoval/odstranil
- Změnila se `company/colleagues/_template/` šablona
- Změnila se naming/role konvence v `company/roles/`
- Uživatel řekne „guide je out-of-date", „aktualizuj onboarding lekci",
  „přidej zmínku o X do guide"

## Kdy ho NEpoužít

- **Fakta o struktuře workspace patří do `ARCHITECTURE.md`, `MAP.md`,
  `GLOSSARY.md`, ne do guide.** Guide je pedagogická vrstva, ne source
  of truth. Pokud se mění fakta, nejdřív aktualizuj autoritativní
  dokument; teprve pak (s odstupem) reflektuj v guide.
- Drobná typografická oprava ve workspace dokumentu, která neovlivní
  mentální model nováčka — guide se nemusí dotknout.
- Změna uvnitř nested repo modulu, která nemá top-level dopad — guide se primárně dívá
  na strukturu workspace, ne na vnitřek modulů.
- Práce v `guide/app/` (Astro renderer) bez změny obsahu — to je
  app-level práce, řiď se `guide/app/AGENTS.md`.

## Klíčová pravidla

1. **Guide reflektuje stav workspace, neudává ho.** Když lekce a
   `ARCHITECTURE.md` říkají něco jiného, vyhrává `ARCHITECTURE.md`.
   Lekce se opraví.
2. **Netechnický jazyk.** Cílovka jsou nováčci přicházející z fáze 1
   (ChatGPT, browser AI nástroje). Žádný `git submodule update --remote`
   bez vysvětlení, žádné nedefinované zkratky. Termíny vytahuj
   z `GLOSSARY.md`.
3. **Každá lekce 5–15 minut.** Když roste přes 15 minut, rozděl ji,
   nebo přesuň hloubku do volitelného „pro pokročilé" odkazu.
4. **Achievementy se nepřidávají bez přemýšlení.** Achievement je
   git-tracked artefakt v `company/colleagues/<ty>/guide/achievements/<id>.md`,
   ke kterému kolegové appendují gratulace. Přidávej jen pro milníky,
   které dávají kolegovi smysl oslavit (dokončil cestu, první commit,
   první PR, první deal).
5. **Vždy ověř, že lekce funguje.** Kvíz má smysluplné otázky a
   odpovědi, úkol je proveditelný v reálném workspace, odkazy fungují.

## Postup

1. **Zjisti, co se konkrétně změnilo.** Nestačí „někdo upravil
   `ARCHITECTURE.md`" — musíš vědět *která sekce*, *jaká fakta*.
   Použij `git log -p -- ARCHITECTURE.md` nebo zeptej se uživatele.
2. **Najdi dotčené lekce v `guide/content/lekce/`.** Hledej podle
   klíčových slov ze změny (např. „doctor", „MCP", „skill",
   „modul", název konkrétního modulu). Použij Grep.
3. **Edituj jen lekci.** Tělo `lekce.md`, případně sourozenecký
   `kviz.json` a `ukol.md`. Drž jazyk a registr (čeština, vykání
   nebo tykání podle existujícího stylu lekce).
4. **Bumpni `guide/CHANGELOG.md`** krátkým záznamem (datum + co se
   změnilo a proč).
5. **Ověř build.** `cd guide/app && npm run build` musí projít. Pokud
   appka není naklonovaná lokálně, aspoň lintni markdown a JSON
   ručně.
6. **Commit.** `guide/` **není module repo**, je to in-tree adresář
   v super-repu. Tedy přímý commit do super-repa — ne přes
   `commit-push-submodule`. Použij `doctor push` se scoped
   `--include guide/content/...` (viz `doctor-workflow` skill).

## Mapování změn → lekce

Tabulka pro rychlou orientaci, kterou lekci sáhnout:

| Změna ve workspace | Dotčená lekce v `guide/content/lekce/` |
|---|---|
| Nový skill v `.claude/skills/` | 14 (Skills) — možná update seznamu příkladů |
| Nový MCP server v baseline | 15 (MCP servery) |
| Změna `ARCHITECTURE.md §16` (vrstvy) | 6 (Pět vrstev workspace) |
| Změna `doctor.sh` flow | 9 (Doctor), 19 (Commit/push/PR) |
| Nový top-level docs file v rootu | 7 (AGENTS/README/MAP) |
| Nový modul v `modules/` | 8 (GLOSSARY) — pokud nese nový pojem |
| Změna `company/colleagues/_template/` | 16 (Tvůj profil) |
| Změna naming/role konvence | 17 (Tvá role) |
| Změna `design-system/` struktury | lekce o design-systému (pokud existuje) |
| Změna role/ownership modelu | 17 (Tvá role), případně 18 (první pracovní úkol) |

Pokud změna spadá mimo tabulku, použij common sense + Grep podle
klíčových slov. Tabulku průběžně rozšiřuj, jak guide roste.

## Co kontroluješ při review

- **Odkazy fungují.** Relativní cesty na soubory existují, externí
  URL se neslomily.
- **Jazyk zůstává jednoduchý a český.** Žádný technický žargon bez
  vysvětlení, žádný anglicismus, kde existuje český ekvivalent.
- **Úkoly odkazují na soubory a příkazy, které opravdu existují.**
  Pokud lekce říká „spusť `company/scripts/doctor.sh check-my-context`",
  ten command musí být skutečně v doctoru.
- **`achievement_id` v `lekce.md` (frontmatter) se shoduje s `id`
  v `achievements.json`.** Jinak se achievement neudělí.
- **Frontmatter `prerequisites`** odkazuje na lekce, které opravdu
  existují a mají dřívější pořadí v `cesta.json`.

## `cesta.json`

`guide/content/cesta.json` drží pořadí lekcí (learning path).

- Pokud **přidáváš novou lekci**, aktualizuj `cesta.json` — vlož ji
  na správnou pozici a ověř, že její `prerequisites` v frontmatteru
  jsou všechny dřívější v cestě.
- Pokud **měníš pořadí lekcí**, projdi všechny `prerequisites`
  v dotčených lekcích — mohou se rozbít.
- Pokud **odstraňuješ lekci**, najdi všechny lekce, které ji
  uvedly v `prerequisites`, a oprav (přesměruj na jinou lekci nebo
  odstraň prerequisite).

## Když si nejsi jist

**Neměň guide.** Eskaluj ownerovi guidu, který rozhoduje o pedagogické
struktuře. Lepší ponechat guide chvíli
mírně zastaralý, než přidat lekci, která zmate nováčka.

Konkrétní situace pro eskalaci:

- Změna ve workspace mění mentální model (nová vrstva, nový
  fundamentální koncept) — guide možná potřebuje novou lekci, ne jen
  edit existující.
- Lekce vypadá zastarale a chybí ti kontext, kdo ji psal a proč.
- Achievement by měl vzniknout/zaniknout, ale není jasné, jestli to
  dává smysl pro celkový arc cesty.
- Konflikt mezi `ARCHITECTURE.md` a guide, kde si nejsi jist, kdo má
  pravdu — v takovém případě vyhrává `ARCHITECTURE.md`, ale ujisti se
  nejdřív, že to není ARCHITECTURE.md, co je out-of-date.

## Spuštění guide appky pro preview

```bash
# přes Launchpad (doporučeno)
curl -X POST http://127.0.0.1:8889/api/v1/apps/guide/start

# nebo ručně
cd guide/app && npm run dev
```

Pak otevři `http://localhost:5692/`.
