# Archive

Složka `company/archive/` je určená pro **read-only** nebo **odvozený**
archivní obsah AgentMint.

Typické příklady:

- exporty z Google Drive
- archivy e-mailů
- CRM snapshoty
- jednorázové mirror datasety
- historické snapshoty dokumentace nebo business dat

## Důležitá pravidla

- `company/archive/` **není automaticky** source of truth
- pokud je obsah jen zrcadlený, musí být jasné, **odkud pochází**
- citlivé zdroje se sem **nemají kopírovat** bez jasného důvodu a
  pravidel
- při commitu archivních dat vždy pochyb, jestli opravdu patří do
  Gitu, nebo jen do lokálního backup flow

## Retention a GDPR

Archive může obsahovat **osobní údaje** (kontakty, e-maily, CRM
snapshoty) a podléhá GDPR. Pravidla:

- Nekopíruj sem osobní data bez jasného účelu a právního základu.
- Pokud kolega (nebo klient) požádá o smazání, musíš mít proces, jak
  to z Gitu odstranit včetně historie (BFG repo-cleaner nebo podobný).
- Při odchodu kolegy z firmy rozhodnout, co se děje s archivními daty
  souvisejícími s jeho prací.

## Kategorie archivního obsahu

Doporučujeme udržovat tři kategorie:

- **source archive** — kopie originálního zdroje (např. .mbox export
  e-mailů), needitovatelné
- **working archive** — data, která se ještě zpracovávají (např.
  rozparsovaný e-mail archiv pro analýzu)
- **derived archive** — odvozené datasety (např. summary reporty
  ze starého CRM)

## Co `company/archive/` NENÍ

- odkladiště pro nezařazené soubory (ty patří do `playgrounds/` nebo
  `tmp/` a jsou gitignored)
- kopie aktuální produkční databáze
- long-term dokument store (ten patří do `modules/documentation/`,
  `modules/wiki/`, `modules/knowledgebase/` podle scope)
