# Skills inventory

Kanonický katalog skillů dostupných ve firmě `AgentMint`.

Slouží jako **rozhodovací matice** pro agenta i kolegu — _kdy kterou
skill volat_, _co dělá_, _kdo ji typicky potřebuje_. Není to náhrada za
samotné `SKILL.md` v `.agents/skills/<název>/`; ty drží detailní postup.

## Princip

Organizace AgentMint používá **AI assistant skills** jako kanonický formát
opakovatelných postupů. Skill musí být použitelný v Claude Code i v OpenAI
Codexu; kanonický adresář je `.agents/skills` a `.claude/skills` je symlink na
něj (`.claude/skills` → `.agents/skills`).

Pokud uživatel popíše nový opakovatelný postup, **navrhni vytvoření
skillu**, ne dlouhého textu v `AGENTS.md` nebo runbooku.

## Kde skilly žijí

- **Sdílené firemní skills (kanonicky):** `.agents/skills/<název>/SKILL.md`
- **Claude Code entrypoint:** `.claude/skills` (Git-tracked symlink na
  `.agents/skills`)
- **Osobní skills:** `company/colleagues/<ty>/.claude/skills/<název>/SKILL.md`
  (jen pro osobní pracovní postupy daného kolegy)

## Workspace lifecycle skills

| Skill | Co dělá | Kdy ji volat |
|---|---|---|
| `workspace-initialization` | První setup po čerstvém klonu super-repa | Po `git clone` super-repa, před první denní prací |
| `dobre-rano` | Ranní sync přes Doctor, agent-safe opravy, branch/PR kontrola, návrat na aktuální `main`, stav workspace a briefing | „dobré ráno", „začni den", „připrav workspace", ranní pull a pracovní stůl |
| `dobrou-noc` | Večerní kontrola hotových změn, push/PR přes GEN2 flow, `.gitignore` hygiena, Doctor opravy, návrat na `main` a handoff | „dobrou noc", „ukonči den", „pushni hotové změny", večerní pracovní stůl |
| `uklidit-pracovni-stul` | Samostatný workspace cleanup: Doctor repair, `.gitignore` hygiena, branch/PR úklid, push hotové práce a návrat na `main` | „ukliď pracovní stůl", „ukliď workspace", „srovnej branche", „dej mě na main", „vyřeš doctora" |
| `doctor-workflow` | Bezpečná práce s `company/scripts/doctor.sh` (status, sync, push, health checks) | Workspace sync, pre-commit health check, dirty stav |
| `worktree-stewardship` | Zakládání, evidence, předávka a bezpečný cleanup dočasných Git worktrees (primární checkout na `main`, feature branch ve worktree, sidecar metadata) | Branch/PR/review/rebase práce, paralelní agenti, cleanup po merge, decision 0049 |

## Nested repo lifecycle skills

| Skill | Co dělá | Kdy ji volat |
|---|---|---|
| `commit-push-submodule` | Historicky pojmenovaný skill pro scoped commit + push v jednom nested repo modulu | Změna v jednom `modules/<X>/` |
| `create-new-module` | End-to-end vytvoření nového top-level nested repo modulu | „vytvoř nový modul", „přidej modul X" |
| `resolve-pointer-conflict` | Legacy skill pro staré pointer konflikty v pre-migration workspacích | Jen při práci se starým submodule workspace |
| `upstream-rebase-fork` | Rebase fork modulu proti upstreamu | Fork modul má novou verzi v upstreamu |

## Documentation maintenance skills

| Skill | Co dělá | Kdy ji volat |
|---|---|---|
| `module-agent-maintenance` | Údržba modulové dokumentace (README, ARCHITECTURE, TODO, CHANGELOG, AGENTS.md) | Práce uvnitř submodulu, která mění zdroj pravdy / datový model / kontrakty |
| `guide-maintenance` | Udržuje `guide/` v souladu s realitou workspace | Nový skill, změna ARCHITECTURE / MAP / AGENTS.md, přidaný/odebraný modul |
| `design-system-lookup` | Nasměruje agenta na canonical brand tokens a reference mockupy | Před produkcí čehokoliv vizuálního/formátovaného (web, slide, datasheet, dokument, nabídka, tabulka) |

## Agent execution skills

| Skill | Co dělá | Kdy ji volat |
|---|---|---|
| `agent-execution-discipline` | Vede od zodpovědnosti za výsledek přes plán v Mission Control a worktree k udržitelné, ověřené změně | Před netriviální změnou kódu, dokumentace nebo workflow |

## Firemně specifické skills

| Skill | Co dělá | Kdy ji volat |
|---|---|---|
| `mission-control-planning` | Ukotví feature/experiment plán v lokálním Mission Control/YAML modelu a rozpadne ho do implementačních `TODO.tasks.json` tasků | Nová feature, experiment, větší změna fungování nebo cross-scope práce |

## Jak přidávat nové skills

1. **Identifikuj opakovatelný postup.** Pokud jsi něco udělal víckrát
   než jednou se stejným strukturálním tvarem, je kandidát na skill.
2. **Vytvoř `.agents/skills/<jasný-slug>/SKILL.md`.** Frontmatter:
   `name`, `description` (jednou větou: kdy ji volat).
3. **Otestuj v Claude Code i Codexu.** `.claude/skills` symlink musí
   fungovat — `ls .claude/skills/` musí ukázat stejnou knihovnu jako
   kanonický `.agents/skills/`.
4. **Doplň záznam do tohoto inventáře** (i jeho popis ve firemně
   specifické sekci).
5. **Pokud je skill obecně použitelný napříč firmami,** zvaž jeho
   anonymizovaný přenos do Lazurio template v samostatné práci mimo AgentMint.

## Anti-pattern

- **Skill bez `description` field.** Agent ji v Claude Code najde, ale
  neví, kdy ji volat.
- **Duplikace mezi `.agents/skills/` a `.claude/skills/` jako
  samostatné kopie.** `.claude/skills` musí být symlink na kanonický
  `.agents/skills`, ne fork.
- **Skill, který obchází Doctor / nested repo flow.** Workspace-wide Git
  operace patří přes Doctor a scoped module flow, ne ad-hoc shell skripty.
- **Skill s firemně specifickými secrets v textu.** Skill je
  Git-tracked; secrets patří do per-person `settings.json`.

## Reference

- Root `AGENTS.md §4` — kanonická pravidla pro skill governance
- `WORKSPACE_MANUAL.md` — proč jsou skilly preferovaný formát před
  runbooky
- `.agents/skills/<název>/SKILL.md` — autoritativní detail každé skill
