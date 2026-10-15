# Fix: Windows Launchpad taskbar / icon

Doctor nebo kolega hlásí:

- Launchpad shortcut existuje, ale není vidět na spodní liště Windows.
- Launchpad se na liště objeví, ale má obecnou PowerShell / prázdnou ikonu.
- `doctor.ps1 install-launchpad` doběhne, ale Windows shell změnu neukáže hned.

## Co to znamená

Windows 11 nebere prosté zkopírování `.lnk` do taskbar pinned složky vždy jako
skutečný pin. COM verb `taskbarpin` navíc na některých instalacích není
dostupný nebo je lokalizovaný. Když shortcut míří přímo na `powershell.exe` s
argumenty, Windows umí ikonu seskupit pod obecnou PowerShell aplikaci.

Kanonický fix je user-local launcher s vlastní ikonou a taskbar layout
handoffem. Neřeš to ručním kopírováním náhodných `.lnk` souborů.

## Fix

Z rootu workspace spusť:

```powershell
.\company\scripts\doctor.ps1 install-deps
.\company\scripts\doctor.ps1 install-launchpad
```

`install-launchpad` má vytvořit:

- `%LOCALAPPDATA%\Programs\<firma> Launchpad GEN2\launchpad.ps1`
- `%LOCALAPPDATA%\Programs\<firma> Launchpad GEN2\<firma>LaunchpadGEN2.exe`
- `%LOCALAPPDATA%\Programs\<firma> Launchpad GEN2\<firma>LaunchpadGEN2.ico`
- `%APPDATA%\Microsoft\Windows\Start Menu\Programs\<firma>\<firma> Launchpad GEN2.lnk`
- `%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\<firma> Launchpad GEN2.lnk`
- `%LOCALAPPDATA%\Microsoft\Windows\Shell\LayoutModification.xml`

Ikona je generovaná přímo Doctorem, takže fix nevyžaduje `design-system/` ani
brand assets.

## Refresh Windows shellu

Když se pin nebo ikona neukáže hned, obnov shell:

```powershell
ie4uinit.exe -show
Stop-Process -Name explorer -Force
Start-Process explorer.exe
```

Když je vidět špatná ikona, smaž jen generovanou ikonovou cache a restartuj
Explorer:

```powershell
Stop-Process -Name explorer -Force
Remove-Item -Force "$env:LOCALAPPDATA\IconCache.db" -ErrorAction SilentlyContinue
Remove-Item -Force "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -ErrorAction SilentlyContinue
Start-Process explorer.exe
```

## Verifikace

```powershell
$company = "<firma>"
$taskbarShortcut = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$company Launchpad GEN2.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($taskbarShortcut)
$shortcut.TargetPath
$shortcut.IconLocation
Test-Path "$env:LOCALAPPDATA\Programs\$company Launchpad GEN2\launchpad.ps1"
```

`TargetPath` má preferovat `.exe` wrapper. `IconLocation` má mířit na `.ico,0`
nebo na `.exe,0`.

Ověř i runtime:

```powershell
Invoke-WebRequest http://127.0.0.1:8888/health -UseBasicParsing
```

Pokud workspace nastavuje `LAUNCHPAD_PORT` v `launchpad/app/v1/.env.local`,
použij stejný port i ve health URL.

## Když Windows pin pořád neukáže

Některé Windows policy nebo shell cache mohou programatické pinování odmítnout
i po layout handoffu. V tom případě:

1. Ověř, že Start Menu shortcut existuje a má správnou ikonu.
2. Spusť Launchpad ze Start Menu.
3. Připni aktivní ikonu ručně přes Windows UI.
4. Do reportu napiš, že Doctor připravil launcher a shortcuty, ale finální pin
   zablokoval Windows shell.

