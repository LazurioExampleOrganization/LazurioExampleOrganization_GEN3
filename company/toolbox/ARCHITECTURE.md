# Toolbox Architecture

`company/toolbox/` je **utility vrstva**, ne business source of truth.

## Návrh

- Jedna složka per capability (např. `pdf-to-png/`)
- Každá capability má **stejné CLI rozhraní** na macOS i Windows
- Platform-specific implementace v jednotlivých wrapperech (`.sh`,
  `.ps1`) nebo shared Python/JS s platform detection
- Dependency install notes v `platform/<os>/README.md`

## Kdy přidat capability do toolboxu

Když:

- **Víc kolegů** to používá (ne jen jeden — to patří do
  `company/colleagues/<ty>/tools/`)
- Je to **cross-platform** (dává smysl na macOS i Windows)
- Je to **stabilní** (ne prototyp — ten žije v
  `company/colleagues/<ty>/playgrounds/`)

## Kdy NEpřidávat

- Capability je **svázaná s konkrétním modulem** — patří do toho
  modulu
- Capability je **osobní workflow** — patří do
  `company/colleagues/<ty>/tools/`
- Capability je **deployment / CI** — patří do `infra/` (org-level vrstva
  v rootu Organizace) nebo `.github/workflows/`
- Capability je **agent skill** (opakovaný postup) — patří do
  `.claude/skills/`

## Příklad: `pdf-to-png` (referenční pattern)

```
company/toolbox/pdf-to-png/
├── README.md        # jak použít, install notes, příklady
├── convert.py       # shared Python script
├── pdf-to-png.sh    # macOS wrapper (pdftoppm dep)
└── pdf-to-png.ps1   # Windows wrapper (poppler-windows dep)
```

CLI rozhraní (stejné na obou OS):

```bash
# macOS
company/toolbox/pdf-to-png/pdf-to-png.sh <input.pdf> [output-dir]

# Windows
.\company\toolbox\pdf-to-png\pdf-to-png.ps1 <input.pdf> [output-dir]
```

## Cross-platform dep strategie

Pro každou capability rozhodni:

1. **Jednotná runtime** — např. Python + knihovny, funguje všude
   stejně. Nejčistší, ale může vyžadovat managed Python (rye / uv /
   pipx).
2. **Platform native** — bash wrapper nad pdftoppm na macOS,
   PowerShell nad poppler-windows na Windows. Menší dep, ale je to
   dvě implementace.
3. **Container** — Docker image, run on both OS. Nejvíc reprodukce,
   ale největší overhead.

Default: (2) — platform native. (1) nebo (3) když dep je příliš
složitá.
