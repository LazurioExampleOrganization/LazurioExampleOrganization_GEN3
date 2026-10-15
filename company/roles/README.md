# Roles

Složka `company/roles/` drží **reusable role overlays** pro GEN2
workspace. Role je **reusable pattern** — sedí nad konkrétním člověkem
v `company/colleagues/<ty>/` a poskytuje baseline pro práci v dané roli.

## Co role JE

- **Druhá vrstva kaskády AGENTS.md** — přebívá role přes root baseline
  (viz root `AGENTS.md §1`)
- **Reusable** napříč lidmi (víc kolegů může sdílet stejnou roli)
- **Definice odpovědnosti** — co role vlastní, jaké moduly čte/zapisuje,
  jaké výstupy dodává
- **Handoff hranice** — kdo převezme, kdo převezme od tebe

## Co role NENÍ

- Není to person-specific — osobní věci patří do `company/colleagues/`.
- Není to modul — role je človekovsky zaměřené, modul je kódem.
- Nejsou to Git/SSH práva — ta bude řídit `.gitmodules` a repo access, až
  vzniknou reálné moduly.

## Kaskáda AGENTS.md

Role je druhá vrstva:

1. root `/AGENTS.md` (company baseline)
2. `/company/roles/<role>/AGENTS.md` — **role baseline** (tahle vrstva)
3. `/company/colleagues/<ty>/AGENTS.md` (person override)
4. `/modules/<modul>/AGENTS.md` (submodule scope override)

## Struktura

```
roles/<role>/
├── README.md   # kdo je to, co dělá, jaké výstupy
└── AGENTS.md   # role-specific operační pravidla
```

Template: `company/roles/_template/`.

Starter katalog: `company/roles/_starter/`. Není to aktivní role
overlay; je to bezpečný zdroj obecných role archetypů pro setup nové
firmy.

## Kanonické role pro AgentMint

### Core role

- `founder` — směr firmy, výběr mechanismů, rozpočet, risk appetite a
  rozhodnutí, co se testuje dál.
- `research-operator` — mapování online mechanismů, práce se zdroji, rozklad
  modelu a příprava evidence pro rozhodnutí.
- `experiment-operator` — převod hypotézy na malý měřitelný test, guardrails,
  metriky, run log a stop/scale doporučení.

### Restricted access

- `founder` drží citlivější rozhodnutí a budoucí finanční data.
- Ostatní role nesmí zapisovat citlivé exporty, credentials ani účty platforem
  do Gitu.

## Jak role vytvořit při setupu

1. Zeptej se ownera firmy na skutečné práce a rozhodovací hranice.
2. Použij `company/roles/_starter/` jako katalog archetypů.
3. Pro každou vybranou roli zkopíruj `_template/` do
   `company/roles/<role>/`.
4. Vyplň `README.md` lidsky: co role dělá, typické moduly, výstupy,
   handoff hranice.
5. Vyplň `AGENTS.md` operačně: jak má agent v roli postupovat, kdy se
   doptat, kdy eskalovat.
6. U každého člověka v `company/colleagues/<člověk>/` nastav primární roli a
   případné multi-role disambiguace.

Nezakládej role bez ownera, výstupů a handoff hranic. Pokud role zatím
není jasná, nech ji v TODO a vrať se k ní po prvním reálném týdnu práce.

## Multi-firma úvaha

Role pojmenované obecně (`obchodnik`, `technik`, `marketing`) se mají
dát přepoužít i v jiných firmách z portfolia. Doménová specifika patří
do `AGENTS.md` každé role a zůstávají company-specific.
