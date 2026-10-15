# AgentMint — Organizace GEN3

> ## Lazurio reference Organization
>
> This repository is the root of **LazurioExampleOrganization**, the public
> reference Organization of [Lazurio](https://github.com/Lazurio/LazurioPlatform).
> It shows how a real Organization repository is laid out, documented and
> migrated.
>
> - **All data is fictional.** The company "AgentMint", its people (for
>   example Jan Novák), plans, prices and offers are illustrative samples.
>   Prices are placeholders in square brackets.
> - **Starting state:** a cleaned snapshot of a GEN2 baseline, imported
>   without its earlier Git history.
> - **Direction:** the Organization migrates from that baseline to GEN3 here,
>   in the open, as a worked example.

`AgentMint` je Organizace GEN3 pro firmu, která hledá ověřitelné cesty, jak
mohou AI agenti vydělávat peníze online.

Cíl není kopírovat cizí brand, obsah, zákaznická data ani šedé taktiky. Cíl
je najít funkční mechanismus, pochopit proč funguje, legálně ho adaptovat a
otestovat tak, aby AgentMint začal generovat vlastní příjem.

Repo je napojené na GitHub organizaci `LazurioExampleOrganization` a
v Launchpad rootu se mountuje jako
`organizations/LazurioExampleOrganization_GEN3`. Začíná vyčištěným snapshotem
GEN2 baseline (bez Git historie; viz „Lazurio reference Organization“ níže).
AgentMint je zároveň rehearsal Organizace pro GEN2 → GEN3 migrační pipeline.

## Začni tady

1. Otevři `AGENTS.md` (pravidla a rozcestník) a `lazurio.organization.json`
   (strojový model firmy).
2. Pojmy ověř v `GLOSSARY.md`.
3. Plánování žije v `mission-control/` (nested repo); aktuální
   implementační práci hledej v `TODO.tasks.json` a rozhodnutí v
   `ISSUES.open.json`.
4. Vstup do kanceláře je přes Launchpad root; tahle Organizace dodává
   Launchpadu jen konfiguraci a manifesty.

## Pracovní princip

AgentMint jede ve smyčce:

1. **Najít mechanismus** — co někde online prokazatelně vydělává.
2. **Rozložit ho na model** — zákazník, nabídka, kanál, jednotková
   ekonomika, provozní kroky, rizika.
3. **Navrhnout legální adaptaci** — vlastní brand, vlastní data, vlastní
   nabídka, žádné obcházení pravidel platformy.
4. **Spustit malý test** — nejmenší měřitelný experiment s jasným rozpočtem
   a stop podmínkou.
5. **Zapsat výsledek** — evidence do `modules/experiments` a task ledgerů.
6. **Škálovat jen to, co má důkaz** — bez důkazu zůstává nápad hypotézou.

## Co je kde

| Cesta | Co drží |
|---|---|
| `lazurio.organization.json` | kanonický strojový model Organizace (business context, role, Teamy, vrstvy) |
| `modules.manifest.json` | GEN3 deskriptor a inventář modulů |
| `company.gen3.json` | generovaná kompatibilní projekce pro starší čtečky; ručně se needituje |
| `company/` | role, colleague overlays, agentní knowledge, scripts, toolbox |
| `infra/` | nested repo: GitHub/access governance a deployment kontext |
| `mission-control/` | nested repo: plánovací vrstva (YAML plány) |
| `modules/` | doctor-managed nested repa: research, experiments, playbooks, … |
| `manual/` | maintenance manuál + GEN2 → GEN3 migrační runbook |
| `blog/` | interní learning surface pro aha momenty |
| `design-system/` | brand baseline a vizuální pravidla |
| `guide/` | onboarding do pracovního stylu workspace |
| `generated/` | historické compiler-managed snapshoty; Launchpad ani Doctor z nich runtime porty nečtou a Lazurio migrátor je nepřepisuje |
| `.agents/skills/` | kanonická skill knihovna (`.claude/skills` je symlink) |
| `launchpad/` | jen redirect — shared Launchpad žije v Launchpad rootu |

Moduly: `modules/knowledgebase` (strategie a guardrails),
`modules/research` (mechanism scans s evidencí), `modules/experiments`
(testy a stop/scale rozhodnutí), `modules/playbooks` (jen ověřené
mechanismy), `modules/automations` (runtime po ověření guardrails),
`modules/content` (veřejné assets), `modules/finance` (unit economics,
restricted).

## Základní hranice

- Kopíruj mechanismus, ne cizí identitu.
- Nezapisuj secrets, tokeny, zákaznická data ani účty platforem do Gitu.
- Nevyráběj spam, phishing, fake engagement, obcházení ToS ani klamavé
  claimy.
- Každý experiment musí mít hypotézu, metriku, rozpočet, stop podmínku a
  zapsaný výsledek.

## Root soubory

| Soubor | Účel |
|---|---|
| `README.md` | rychlý lidský úvod |
| `AGENTS.md` | operační pravidla pro agenty (rozcestník vrstvy) |
| `CLAUDE.md` | Claude Code bootstrap odkazující na `AGENTS.md` |
| `lazurio.organization.json` | kanonický strojový model Organizace |
| `modules.manifest.json` | GEN3 deskriptor a inventář modulů |
| `company.gen3.json` | generovaná kompatibilní projekce; mění se jen přes `lazurio migrate organization-manifest <task-worktree> --write` |
| `GLOSSARY.md` | doménové pojmy AgentMint + GEN3 topologie |
| `TODO.tasks.json` | aktuální vykonatelné kroky |
| `DONE.tasks.json` | hotová nebo archivovaná práce |
| `ISSUES.open.json` | otázky čekající na rozhodnutí |
| `CHANGELOG.md` | doručené významné změny |

`MAP.md`, `ARCHITECTURE.md` a `WORKSPACE_MANUAL.md` jsou po konverzi jen
redirect stuby; plný GEN2 text není součástí tohoto veřejného snapshotu.

## Mission Control

AgentMint používá **Mission Control** jako lokální plánovací a orchestrační
centrum workspace — root-level nested repo v control-plane vrstvě.

- workspace repo: `mission-control/`
- storage model: YAML soubory ve workspace
- UI model: lokální aplikace spouštěná přes Launchpad root

Mission Control drží širší kontext: proč se věc dělá, pro koho, jaké
rozhodnutí padlo, scope a akceptační kritéria. `TODO.tasks.json` drží až
konkrétní implementační kroky, které se dají vzít do práce v tomto
workspace.
