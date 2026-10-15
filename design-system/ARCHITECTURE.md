# Design System Architecture

`design-system/` je in-tree vrstva super-repa. Neni submodul a neobsahuje
privatni runtime stav.

## 1. Role vrstvy

Design system:

- vytahuje reusable pravdy z produkcnich zdroju firmy
- drzi kanonicke tokens a brand pravidla
- poskytuje opakovatelny workflow pro agenty
- dela vizualni vystupy reviewovatelne v Gitu
- poskytuje read-only viewer pro rychle preview

## 2. Authority model

Vychozi precedence:

1. `modules/website/` nebo jina produkcni prezentacni vrstva
2. `modules/knowledgebase/` nebo jiny brand/strategy source-of-truth
3. `company/agents/voice/` pro ton komunikace
4. `design-system/` jako kuratorovana baseline

Design-system nikdy nema prepsat realitu produkce jen proto, ze se nam libi
nejaky novejsi napad.

## 3. Vrstvy

### Brand baseline

`content/brand/` drzi:

- `colors/tokens.json`
- `colors/palette.md`
- `typography/typography.md`
- logo a assety, pokud existuji a smi byt v Gitu
- odkazy na kanonicke brand dokumenty

### Examples

`content/examples/` drzi reference napric kategoriemi. Kazdy vaznejsi asset
ma mit sourozenecky `.md` soubor s metadaty: `title`, `source`, `date`,
`category`, `notes`.

### Templates

`content/templates/` drzi startery pro opakovane formaty. Pokud je template
generovany z jineho modulu, zapis tam primarni source.

### Viewer app

`app/` je Astro read-only viewer:

- přesný listener je deklarovaný pouze v `lazurio.module.json`
- zadne auth
- zadne authoring UI
- pouze renderuje `content/`

## 4. Launchpad vztah

Pokud workspace používá sdílený Lazurio Launchpad, design-system viewer má být
v katalogu jako `design-system`; přesný port vlastní jeho
`lazurio.module.json`. Organization pool slouží jen pro nové alokace, takže
zavedený listener se při adopci Lazuriem nepřečísluje. Pokud Organizace ještě
běží na legacy `modules/launchpad`, neregistruj root viewer nasilim; zapiš
prechodovy stav do Launchpad docs.

## 5. Invarianty

- `design-system/` je in-tree, ne submodul.
- Brand assety jine firmy se nekopiruji.
- Secrets do design-systemu nepatri.
- Produkce ma prednost pred kuratorovanym zrcadlem.
- Viewer zustava read-only.
