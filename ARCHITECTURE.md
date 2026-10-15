# ARCHITECTURE - technický model se přestěhoval

Tohle repo je Organizace GEN3. Technický model vrstvy drží:

- `lazurio.organization.json` - kanonický strojový model Organizace (vrstvy,
  governance, Teamy, generation policy); jediný soubor, do kterého se
  struktura zapisuje
- `modules.manifest.json` - GEN3 deskriptor doctor-managed nested rep
  a inventář modulů
- `company.gen3.json` - generovaná kompatibilní projekce pro starší čtečky;
  ručně se needituje, mění se jen přes
  `lazurio migrate organization-manifest <task-worktree> --write`
- `manual/` - maintenance manuál a migrační runbook
- `AGENTS.md` - pravidla, Git workflow a source-of-truth mapa
- Lazurio (`Lazurio/LazurioPlatform`) - schémata a rozhodnutí GEN3 systému

Plný GEN2 technický model (19 sekcí) není součástí tohoto veřejného
snapshotu.
