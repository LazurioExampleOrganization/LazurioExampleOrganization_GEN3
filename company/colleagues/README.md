# Colleague Overlays

Tato složka drží **osobní workspace overlays** pro kolegy AgentMint.
Každý kolega má svou složku `company/colleagues/<os-user>/`.

`<os-user>` musí být stejné jako uživatelské jméno na počítači. Když je
domovská složka `/Users/jannovak`, složka kolegy je
`company/colleagues/jannovak/`. GEN2 `company/team/` se už nepoužívá.

## Formát

```
company/colleagues/
├── README.md             # tenhle soubor
├── TODO.md               # úkoly a stav overlays
├── _template/            # vzor pro nového kolegu
│   ├── README.md         # scaffold pro osobní README
│   ├── AGENTS.md         # scaffold pro person overlay
│   ├── *.code-workspace  # VS Code/Cursor multi-root workspace template
│   └── .claude/skills/   # osobní skills
└── <os-user>/            # jeden pro každého kolegu
    ├── README.md
    ├── AGENTS.md
    ├── *.code-workspace  # osobní VS Code/Cursor workspace
    ├── .claude/skills/   # osobní skills kolegy
    ├── archive/          # lokální odkladiště mimo Git (gitignored)
    ├── private/          # privátní lokální vrstva (gitignored)
    ├── tools/            # osobní skripty (volitelné)
    └── voice/            # osobní tone of voice (volitelné, jinak
                          # v company/agents/voice/)
```

## Co `company/colleagues/<ty>/` JE

- **Normální složka v super-repu** — trackovaná přímo, ne submodul.
- Místo pro **osobní konfiguraci a preference** (preferovaný jazyk,
  multi-role disambiguace).
- Místo pro **osobní skills**, které používá jen daný kolega.
- Slot pro **per-person MCP konfiguraci** (v `.claude/settings.json` —
  gitignored, secrets mimo Git).
- Slot pro lokální **`archive/`** a **`private/`** složky mimo Git.

## Co `company/colleagues/<ty>/` NENÍ

- Není to **samostatný Git submodul** — byl by overhead.
- Není to **secrets store** — tokeny a API keys patří do gitignored
  `.claude/settings.json`, OS keychainu, nebo `.env.local`.
- Není to **paměť agenta** — žádný `memory/` ani `MEMORY.md`.
- Není to **kopie firemní knowledge** — sdílené patří do
  `modules/knowledgebase/` nebo skills.

## Kaskáda AGENTS.md

Person overlay je třetí vrstva v kaskádě:

1. root `/AGENTS.md` — company baseline
2. `/company/roles/<role>/AGENTS.md` — role baseline
3. `/company/colleagues/<os-user>/AGENTS.md` — **person override**
4. `/modules/<modul>/AGENTS.md` — modulový scope override

**Pravidlo:** bližší vyhrává. Person overlay může roli přebít, modul může
přebít cokoliv pro svůj vlastní scope.

## Jak přidat nového kolegu

1. Zkopíruj `_template/` jako `company/colleagues/<os-user>/`
2. Vyplň `README.md` a `AGENTS.md` podle reality (role, kontakt,
   preference)
3. V osobním `*.code-workspace` změň druhý folder name z `_template`
   na os-user kolegy
4. Přidej kolegu do
   `lazurio.organization.json#extensions.legacy.colleague_overlays.active_colleagues`
   s potvrzenou primární rolí a projekci `company.gen3.json` přegeneruj přes
   `lazurio migrate organization-manifest <task-worktree> --write` (ručně ji
   needituj)
5. Commit do super-repa; nový kolega si doladí `.claude/settings.json`
   (OAuth, MCP tokeny) lokálně — ty se **necommitují**

## Co musí kolega vyplnit

Person overlay má být užitečný pro agenty, ale nesmí obsahovat secrets ani
neověřené domněnky o člověku. Každý kolega si ve své složce doplní:

- **role** — primární role, další role a disambiguace, kdy se která používá
- **ownership** — co vlastní, o čem smí rozhodovat a kdy eskaluje
- **moduly** — které nested repozitáře typicky potřebuje
- **pracovní identita** — pracovní e-mail a externí služby bez tokenů
- **preference** — jazyk, délka odpovědí, míra detailu a styl práce
- **externí akce** — co agent nesmí udělat bez potvrzení
- **handoff** — komu předává práci a od koho ji přebírá

Dokud nejsou role nebo ownership vyplněné, agent se má doptat a nesmí je
domýšlet podle jména.

## Aktuální kolegové

| Složka | Kolega | Primární role |
|---|---|---|
| `jannovak/` | Jan Novák | `founder` (drží i research/experiment operator práci první fáze) |
| `tomas/` | Tomáš | onboarding scaffold, role nepotvrzená |
| `petr/` | Petr | onboarding scaffold, role nepotvrzená |

Aktivní kolegy s potvrzenou rolí drží
`lazurio.organization.json#extensions.legacy.colleague_overlays.active_colleagues`.
