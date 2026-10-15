---
id: 20-kdyz-se-neco-rozbije
title: "Když se něco rozbije"
section: 4-prvni-prace
order: 20
prerequisites: ["19-commit-push-pr"]
duration_min: 10
quiz: true
ukol: false
---

# Když se něco rozbije

**Co se v této lekci naučíš:**
- jak postupovat bez paniky
- co zkontrolovat jako první
- kdy se ptát agenta a kdy kolegy

## Nejdřív zpomal

Chyba ve workspace neznamená konec světa. Většina změn je dohledatelná v Gitu a doctor umí hodně problémů pojmenovat.

Nejnebezpečnější je začít naslepo klikat, mazat nebo zkoušet náhodné příkazy. Když nevíš, zastav se a nech si vysvětlit stav.

## První kontrola

Začni těmito příkazy:

```bash
company/scripts/doctor.sh status
company/scripts/doctor.sh check --quick
```

Doctor často rovnou řekne, jestli jde o chybějící přístup, neuloženou změnu, problém s portem nebo něco jiného.

## Zeptej se agenta

Zkopíruj celé chybové hlášení a napiš:

> „Tohle mi vrátil doctor. Vysvětli mi lidsky, co to znamená, a navrhni bezpečný další krok."

Důležité je slovo bezpečný. Agent by neměl hned mazat, resetovat nebo pushovat. Nejdřív má vysvětlit stav.

## Časté situace

**Permission denied** znamená, že nemáš přístup. To řeší člověk, který spravuje oprávnění.

**Missing access** znamená, že modul může být pro tvoji roli nedostupný. To je normální.

**Dirty submodule** znamená, že někde jsou neuložené změny. Nejprve zjisti, čí jsou a co obsahují.

**Port je obsazený** znamená, že aplikace nemůže běžet na očekávané adrese. Pomůže `company/scripts/doctor.sh port <cislo>`.

**Agent ignoruje pravidla** může znamenat, že je spuštěný ve špatné složce nebo neudělal preflight. Pomůže `check-my-context`.

## Kdy zapojit kolegu

Kolegu zapoj, když:

- chyba se opakuje
- jde o produkční data
- nerozumíš dopadu navrženého kroku
- agent chce dělat něco destruktivního
- problém se týká přístupů

Do zprávy dej, co jsi spustil/a, co jsi čekal/a a jaké přesné hlášení se objevilo.

## Shrnutí

Když se něco rozbije, nezkoušej náhodné opravy. Spusť doctor, přečti hlášení, zeptej se agenta na bezpečný další krok a u rizikových věcí zapoj kolegu.

**Sekce hotová:** zvládáš první reálnou práci ve workspace. Příště se naučíš, kam zapisovat nové poznatky.
