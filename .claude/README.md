# `.claude/` — Agent konfigurace

Tato složka drží **runtime konfiguraci pro Claude Code** v AgentMint
Organizaci GEN3.

Záměrně žije v rootu (ne pod `company/`), aby ji Claude Code nativně
načetl při otevření workspace.

## Vztah ke `CLAUDE.md`

Root `CLAUDE.md` je nativní Claude Code bootstrap. Drží jen krátký odkaz na
autoritativní `AGENTS.md`; pravidla, role a guardrails se neudržují ve dvou
kopiích.

## Obsah

- `skills/` — **symlink** na kanonickou sdílenou skill knihovnu
  `.agents/skills/`. GEN3 obrací GEN2 směr: source of truth je
  `.agents/skills`, `.claude/skills` je jen kompatibilní vstup pro Claude
  Code. Nikdy tu neudržuj samostatnou kopii skillů.
- `launch.json` — lokální app launch konfigurace pro in-tree viewery.

## Co sem NEpatří

- `settings.json` s OAuth tokeny, API keys — to je **per-person** v
  `company/colleagues/<os-user>/.claude/settings.json` (gitignored) nebo v
  `~/.claude/settings.json`
- Session artifacts, cache, auth tokeny — gitignored
- Jakékoli runtime state s tajnými hodnotami — gitignored

Viz root `.gitignore` a root `AGENTS.md`.

## Vztah k dalším `.claude/` složkám

- **Root `.claude/`** (tento) — sdílené pro celou firmu, trackuje se v Gitu
- **`company/colleagues/<os-user>/.claude/`** — osobní, může mít per-person
  skills, settings, agenty. Settings a tokeny jsou gitignored, skills mohou
  být trackované v osobní vrstvě.

## Vztah k `company/agents/`

`.agents/skills/` je **runtime** (agent to přímo spouští). `company/agents/`
je **knowledge** (reference, voice, legacy runbooks).

- Proces k vykonání → skill
- Knowledge ke konzultaci → `company/agents/reference/`
- Jak psát výstup → `company/agents/voice/`
