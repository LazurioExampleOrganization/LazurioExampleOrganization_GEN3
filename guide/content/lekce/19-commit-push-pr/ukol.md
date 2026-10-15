---
title: "Připrav první uložení změny"
type: terminal
checklist:
  - "Ujisti se, že máš připravenou složku `company/colleagues/<tvoje-jmeno>/` z lekce 16"
  - "Spusť `company/scripts/doctor.sh status`"
  - "Spusť `company/scripts/doctor.sh push --help` a všimni si, že nápověda nic neposílá"
  - "Požádej Codex, aby ti ukázal diff pouze pro tvoji složku"
  - "Připrav dry-run: `company/scripts/doctor.sh push -m $'Team: Add profile for <jmeno>\\n\\nCreate the onboarding profile and agent preferences for <jmeno>.' --include company/colleagues/<tvoje-jmeno> --dry-run`"
  - "Přečti si náhled a ověř, že neobsahuje tajné údaje"
  - "Reálný push udělej až po kontrole s agentem nebo mentorem"
achievement_on_complete: first-pr
---

# Úkol: připrav první uložení změny

Toto je cvičení na bezpečné odeslání změny. Nejdůležitější část není samotný push, ale kontrola před ním.

Nech si od Codexu vysvětlit, co je v diffu. Pokud uvidíš soukromé nastavení, token nebo něco mimo tvoji složku, zastav se.

Po dokončení bezpečného průchodu získáš odznak **První změna uložená**.
