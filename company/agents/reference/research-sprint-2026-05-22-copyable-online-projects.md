# Research sprint: copyable online money mechanisms

Ověřeno: 2026-05-22

Scope: najít existující online projekty, firmy nebo solo operátory s
ověřitelným monetizačním signálem v kategoriích micro-SaaS, directories, data
products, templates, Chrome extensions, newsletters a niche tools. Cílem není
kopírovat brand, obsah, databáze ani identitu, ale legálně adaptovat mechanismus
pomocí agentů.

## Shortlist

| Kandidát | Kategorie | Revenue / monetizační signál | Mechanismus | Co může AgentMint adaptovat | Co nekopírovat | Rizika | Confidence |
|---|---|---|---|---|---|---|---|
| Remote Leaf | directory / curated newsletter | Open startup stránka uvádí 209 paid subscribers, MRR ~$1,610, ARR ~$19,410; pricing a testimonials jsou veřejné. | Kurátorovaný feed remote jobs, personalizované e-mailové notifikace, subscription. | Vertikální kurátorovaný job/opportunity feed pro úzkou profesní skupinu; agenti mohou třídit zdroje, deduplikovat nabídky, psát shrnutí a hlídat fit. | Nekopírovat databázi jobů, copy, design ani testimonials; neagregovat zdroje proti ToS. | Nízké MRR, závislost na kvalitě zdrojů, job-board trh je přeplněný. | 5 |
| ScrapingBee | micro-SaaS / developer API | Case studies uvádí růst k $1M ARR a později $5M ARR + exit; pricing je veřejné. | API, které řeší proxy, headless browser a scraping infrastrukturu za vývojáře. | Úzce zaměřené "data extraction as a service" pro konkrétní legální use case, např. public pricing monitors nebo public directory enrichment. | Nekopírovat infrastrukturu, texty ani API surface; nedělat scraping zakázaný ToS nebo privacy-invasive sběr. | Právní a platformní riziko scraping trhu, vysoké infra náklady, anti-bot arms race. | 5 |
| Bannerbear | micro-SaaS / media automation API | Veřejný pricing $49-$299/mo; Indie Hackers zmiňuje portfolio přes $1M ARR a Bannerbear blízko $1M ARR. | Template-based image/video generation API pro marketéry a automatizace. | Vertikální generátor assetů pro konkrétní workflow, např. nabídky, reporty, real-estate listing visuals nebo B2B outbound visuals. | Nekopírovat brand, šablony, UI, API názvy ani assety. | Diferenciace vůči Canvě a AI image tools; nutnost jasného use case a integrací. | 4 |
| Carrd | niche tool / micro-SaaS | SaaS Podcast uvádí přes $100K MRR a 4M hosted sites; Indie Hackers uvádí ~$167K/mo / $2M ARR; pricing začíná od $9/rok. | Extrémně jednoduchý one-page website builder s freemium a nízkou roční cenou. | Vertikální builder pro jednu úzkou práci, např. lead-capture stránky pro lokální služby, agent-generated landing pages nebo microsite pro nabídky. | Nekopírovat editor, templates, branding, UX detaily ani free-site virality přes cizí značku. | Crowded market, nízký ARPU, support burden, AI site builders. | 4 |
| BuiltWith | data product / technographics | Official pricing $295-$995/mo a Team Ultra $6,000/yr; Latka uvádí $22.6M revenue; official page uvádí data z 491.9M domains. | Technografická databáze a lead lists podle používaných technologií. | Menší niche data product: veřejné signály pro jednu technologii/segment, obohacené agentní analýzou a exporty pro sales. | Nekopírovat BuiltWith data, detekční signatury, zákaznické listy ani enrichment. | Data freshness, právní/ToS hranice, commoditizace, náročný sběr. | 4 |
| GummySearch | data product / niche research SaaS | Pricing $29-$199/mo; Arrfounder uvádí $35K MRR před ukončením nového businessu; official pricing říká, že služba je closed as of 2025-11-30. | Reddit audience research: hledání communities, pains, trendů a zákaznických signálů. | Agentní research workflow nad povolenými zdroji: pain-point monitoring, citace zdrojů, human-reviewed outreach drafts. | Nekopírovat Reddit data dumpy, Gummy UX, databázi, brand ani automatické spam posting workflow. | Velké platformní/API riziko; přesně to je důvod, proč projekt skončil pro nové zákazníky. | 4 |
| Easlo | templates / digital products | Gumroad profil ukazuje 7,064 sales u Second Brain za $79; další template katalog má placené položky $5-$79. | Katalog šablon s free lead magnets a placenými produktivity systémy. | Niche "operating system" templates pro konkrétní role, např. agentní research OS, experiment OS, client acquisition OS. | Nekopírovat databáze, copy, názvy, vizuální styl ani PARA packaging. | Saturace template trhu, potřeba distribuce, support a refunds. | 5 |
| ShipFast | code template / boilerplate | Indie Hackers case study uvádí $63K revenue za 60 dní; TrustMRR uvádí aktuální veřejné revenue signály pro ShipFast/portfolio. | One-time boilerplate pro rychlé spuštění SaaS s auth, payments, email a landing page. | Vertikální agent-ready boilerplate pro konkrétní monetizační typ, např. directory starter, data product starter nebo paid newsletter ops kit. | Nekopírovat codebase, marketing claims, docs, design ani checkout flow. | Kvalita/security kritická; boilerplate trh je hlučný a reputačně citlivý. | 4 |
| Text Blaze | Chrome extension / productivity SaaS | Chrome Web Store uvádí 600K users a 4.9 rating; Latka uvádí $2.4M revenue in 2024; public pricing existuje. | Browser text-expander a snippets pro support, sales, teachers, HR a další role. | Vertikální Chrome extension pro jednu opakovanou práci: agent-reviewed snippets, form filling, support macros nebo proposal drafting. | Nekopírovat extension, snippet library, brand, permissions model ani claims. | Browser permissions trust, privacy, Chrome Web Store review, enterprise security. | 4 |
| TLDR Newsletter | newsletter / media business | Official ad site uvádí 7M+ tech professionals, jednotlivé newslettery 280K-1.6M subs a 32-47% open rates; Latka uvádí $6.4M revenue in 2024. | Kurátorované B2B tech newsletters monetizované sponsorships a performance case studies. | Úzký B2B newsletter s agentní rešerší a sponzorským inventory, např. "AI ops opportunities for SMBs" nebo "agent monetization briefs". | Nekopírovat obsah, editorial voice, seznamy odběratelů, reklamní materiály ani case studies. | Newsletter trh má dlouhý growth cycle; sponsorshipy fungují až při kvalitním publiku. | 5 |
| HeadshotPro | niche AI tool | Official site uvádí $19.99-$49.99 one-time pricing a 10,000+ customers; Rewardful case study uvádí $50K+ monthly affiliate revenue a +15% revenue contribution. | Úzký AI output produkt s jasným one-time purchase a affiliate distribution. | AI service pro jeden konkrétní output s vysokou ochotou platit, např. role-specific profile assets, product listing visuals nebo sales collateral. | Nekopírovat model workflow, brand, prompts, sample photos, affiliate copy ani zákaznické výstupy. | AI commoditizace, kvalita výstupu, privacy/biometric sensitivity, refundy. | 5 |

## První Patterny

1. Nejlépe adaptovatelné pro AgentMint jsou mechanismy, kde agenti zvyšují
   throughput bez nutnosti vlastnit velké publikum: curated feeds, niche data
   products, vertical templates a asset generation.
2. Nejrychlejší "first-dollar" testy jsou pravděpodobně templates / reports /
   curated paid feed, protože nevyžadují hotový SaaS ani dlouhý review proces.
3. Největší riziko je platformní závislost: GummySearch ukazuje, že i funkční
   $35K MRR mechanismus může skončit, když stojí na cizím API nebo ToS.
4. Nejlepší AgentMint adaptace nebude "kopie firmy", ale vlastní vertical:
   konkrétní audience + konkrétní opakovaná bolest + agentní workflow +
   transparentní zdroje.

## Zdroje

- Remote Leaf open metrics: https://remoteleaf.com/open
- ScrapingBee case studies: https://www.foundershut.com/explore/scrapingbee-bootstrapped-saas-1m-arr, https://www.startupsfortherestofus.com/episodes/episode-783-bootstrapping-scrapingbee-to-5m-arr-and-an-8-figure-exit
- ScrapingBee pricing: https://www.scrapingbee.com/pricing/
- Bannerbear pricing: https://www.bannerbear.com/pricing/
- Bannerbear revenue context: https://www.indiehackers.com/post/my-saas-portfolio-crossed-1m-arr-and-bannerbear-will-hit-1m-arr-soon-YbNabGgDDpeniZkjFrzo
- Carrd pricing/docs: https://carrd.co/docs/pro/plans
- Carrd revenue context: https://saasclub.io/podcast/carrd-aj-306/, https://www.indiehackers.com/post/tech/growing-carrd-to-2m-arr-in-a-crowded-market-with-zero-marketing-by-limiting-features-dbeoP4bDlEL3zzsivdgj
- BuiltWith pricing: https://builtwith.com/plans
- BuiltWith revenue context: https://getlatka.com/companies/builtwith
- GummySearch pricing / shutdown notice: https://gummysearch.com/pricing/
- GummySearch revenue context: https://arrfounder.com/news/gummysearch-reaches-35k-mrr
- Easlo Gumroad sales: https://easlo.gumroad.com/
- ShipFast case study: https://www.indiehackers.com/post/case-study-shipfast-made-63k-in-revenue-in-60-days-8jj06RfVwjLR01CSDvxb
- ShipFast current public revenue context: https://trustmrr.com/founder/marclou
- Text Blaze Chrome Web Store: https://chromewebstore.google.com/detail/text-blaze-templates-and/idgadaccgipmpannjkmfddolnnhmeklj
- Text Blaze pricing: https://blaze.today/plans
- Text Blaze revenue context: https://getlatka.com/companies/blaze.today/funding
- TLDR advertising page: https://advertise.tldr.tech/
- TLDR revenue context: https://getlatka.com/companies/tldr-newsletter
- HeadshotPro official pricing/customers: https://www.headshotpro.io/
- HeadshotPro affiliate case study: https://www.rewardful.com/case-studies/headshotpro
