# Sdílené firemní skills

Tato složka drží **sdílené skills** pro AI asistenty
`AgentMint`. Je to jediný Git-tracked source of truth pro
company-wide postupy.

Kanonický adresář je `.agents/skills`; `.claude/skills` je Git-tracked
symlink na `.agents/skills` (`.claude/skills -> ../.agents/skills`). OpenAI
Codex čte `.agents/skills` přímo, Claude Code čte tutéž knihovnu přes symlink
`.claude/skills`.

**Nikdy neudržuj druhou kopii skillů.** `.claude/skills` musí zůstat symlink,
ne fork. Když se symlink rozbije, oprav symlink nebo spusť doctor check;
neopravuj obsah ve dvou adresářích.

## Jazyk

Workspace-owned skills piš **česky s diakritikou**. Anglické technické
termíny, command names, API fields, product names a zavedené workflow
zkratky nepřekládej násilím, pokud by to zhoršilo přesnost. Instrukční
text, nadpisy, frontmatter `description` a handoff guidance ale mají být
primárně česky. Nadpisy piš českým sentence case (`Jsme na main a worktree
je clean`), ne anglickým Title Case.

## Struktura

Každý skill je v samostatné podsložce:

```
.agents/skills/<název-skillu>/SKILL.md
.agents/skills/<název-skillu>/<další podpůrné soubory>
```

## Baseline skills

Tyto skills jsou součást Organizace AgentMint:

- [`commit-push-submodule`](commit-push-submodule/SKILL.md) — standard
  flow pro úpravu v jednom nested repo modulu (historický název skillu)
- [`resolve-pointer-conflict`](resolve-pointer-conflict/SKILL.md) —
  legacy pointer konflikt v pre-migration super-repu
- [`upstream-rebase-fork`](upstream-rebase-fork/SKILL.md) — rebase fork
  modulu proti upstreamu (viz `ARCHITECTURE.md §19`)
- [`module-agent-maintenance`](module-agent-maintenance/SKILL.md) —
  maintenance modulových docs (README, ARCHITECTURE,
  IMPLEMENTATION_PLAN, AGENTS)
- [`create-new-module`](create-new-module/SKILL.md) — end-to-end flow
  pro proměnu planned slotu ve skutečný top-level nested repo modul
- [`design-system-lookup`](design-system-lookup/SKILL.md) — povinný
  lookup před vizuální nebo formátovanou prací; směruje agenta do
  `design-system/` a na firemní source-of-truth
- [`agent-execution-discipline`](agent-execution-discipline/SKILL.md) —
  guardrail pro kód, docs, research a experiment workflow: zodpovědnost za
  výsledek, plán v Mission Control, worktree a udržitelná, ověřená změna
- [`mission-control-planning`](mission-control-planning/SKILL.md) —
  AgentMint flow pro ukotvení feature/experiment plánu v lokálním
  Mission Control/YAML modelu a následný rozpad do `TODO.tasks.json`
- [`guide-maintenance`](guide-maintenance/SKILL.md) — údržba
  interaktivního onboardingu v `guide/`; používá se, když se změní
  workspace struktura, doctor flow, skills, MCP baseline, role nebo
  modulový model
- [`workspace-initialization`](workspace-initialization/SKILL.md) —
  první lokální příprava už vytvořené Workspace GEN2 instance pro
  konkrétního kolegu: Doctor/bootstrap, dependencies, Launchpad/Guide
  handoff a oprava opakovatelných onboarding bugů
- [`dobre-rano`](dobre-rano/SKILL.md) — ranní sync, Doctor repair,
  branch/PR review a návrat workspace na aktuální `main`
- [`dobrou-noc`](dobrou-noc/SKILL.md) — večerní push/PR cleanup,
  `.gitignore` hygiena, Doctor repair, handoff a návrat na `main`
- [`uklidit-pracovni-stul`](uklidit-pracovni-stul/SKILL.md) — samostatný
  workspace cleanup: Doctor repair, `.gitignore` hygiena, branch/PR úklid,
  push hotové práce a návrat na aktuální `main`
- [`worktree-stewardship`](worktree-stewardship/SKILL.md) — zakládání,
  evidence, předávka a bezpečný cleanup dočasných Git worktrees (primární
  checkout na `main`, feature branch ve worktree, sidecar metadata, decision
  0049)

## Company-specific skills

Firma si přidává vlastní skills podle domény. Konvence:

- **Skill je proces k vykonání** (how-to).
- **Reference knowledge** patří do `company/agents/reference/`.
- **Tone of voice** patří do `company/agents/voice/`.

## Vztah k `company/agents/runbooks/`

Legacy slot, default prázdný. Skills jsou kanonický GEN2 formát —
runbook neodvozovat, rovnou skill.

## Kde je osobní varianta

Osobní (person-specific) skills patří do
`company/colleagues/<ty>/.claude/skills/`. Aktivují se jen pro konkrétního
uživatele / jeho lokální assistant setup, ne jako firemní baseline pro
všechny.

## Jak vytvořit nový skill

1. Vytvoř složku `<skill-name>/`
2. Napiš `SKILL.md` s frontmatter:
   ```markdown
   ---
   name: <skill-name>
   description: <Kdy použít, v 1–3 větách. Trigger slova. Kontext.>
   ---
   ```
3. Obsah: preflight checks + flow kroky + edge cases + co NEDĚLAT
4. Commit změny podle aktuální Git policy workspace; push jen pokud existuje
   remote a člověk ho výslovně schválil

## Pravidla pro commit

- Skills patří do sdíleného repa, takže necommituj OS-specific cesty,
  tokens ani osobní scratch.
- `.claude/skills` musí zůstat jen symlink na kanonický `.agents/skills`.
  Drift mezi Claude a Codex entrypointem je bug ve workspace setupu.
- Pokud skill volá externí službu,
  očekávej, že kolega má odpovídající MCP nastavený (viz `AGENTS.md §5`).
- Cross-platform: pokud skill obsahuje shell příkazy, musí mít i
  PowerShell variantu — nebo musí být jasně označený, že funguje jen na
  jednom OS.
