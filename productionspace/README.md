# Productionspace

Org-level vrstva nasazených/produkčních systémů Organizace GEN3 (decision 0014):
firmware, connect, produktový monorepo, veřejné docs/web a podobné nasazené
systémy. Mountuje se vedle workspace vrstvy, sdílí ji celá Organizace a nepatří
do žádného jednotlivého Teamu.

Modul sem patří, jakmile je reálně **nasazený** (na serveru, s vlastním CI/CD)
nebo **veřejný** (dokumentace, web) — ne když běží jen lokálně nebo přes
Organization Host. Verze se sem **povyšuje** z workspace (dílny pod univerzálním
Launchpad patternem) poté, co je v dílně označená za dobrou (např. v1.4). Na
rozdíl od workspace tu **není univerzální pattern**: každý produkční modul má
vlastní, historicky navrženou release/CI-CD pipelinu a vlastní pravidla.
Productionspace **není Organization Host** — ten je jen runtime pro vzdálený
přístup k dílně, ne deploy/produkční stage.

AgentMint je výzkumná Organizace bez produkčních systémů, takže
productionspace je zatím prázdná — složka existuje záměrně, aby kanonická
GEN3 struktura byla kompletní a aby bylo jasné, kam release/prod systémy
patří, až vzniknou.

Plánování, roadmapu a rozhodnutí pro productionspace i pro celou Organizaci
drží `mission-control/` v rootu (jedna plánovací vrstva jako ve Workspace
GEN2), ne samostatná planning vrstva.
