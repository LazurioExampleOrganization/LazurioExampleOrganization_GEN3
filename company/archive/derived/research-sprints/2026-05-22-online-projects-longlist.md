# AgentMint research sprint: online projekty s monetizačním signálem

Datum ověření: 2026-05-22

Scope: první veřejný scan projektů, ze kterých lze legálně adaptovat
monetizační mechanismus pro AgentMint. Cílem není kopírovat brand, obsah,
účty, zákaznická data ani neveřejné know-how. Cílem je rozebrat, kde vznikají
peníze, jaká část workflow se dá dělat agentně a jaký nejmenší test by šel
spustit po lidském potvrzení.

## Metodika

Použité typy zdrojů:

- verified revenue databáze a marketplace profily: TrustMRR, ProvenMRR,
  Surgent, RankYourApp
- founder case studies: Indie Hackers, Starter Story, MRR Story, The Futur
- official/company stránky tam, kde ukazují pricing, zákazníky nebo model

Confidence:

- 5: platební data deklarovaně ověřená přes payment API nebo official company
  revenue statement
- 4: credible founder/case-study source s konkrétními čísly
- 3: sekundární case study nebo databáze bez přímého payment-proof detailu
- 2: slabší veřejný signál, použít jen jako inspiraci a znovu ověřit

## Top kandidáti pro první deep dive

1. **Chatwith / Chatbase pattern** - white-label AI chatbots pro agentury.
   Důvod: jasný B2B buyer, vysoká agentní leverage, Chatwith má verified MRR a
   zakladatel explicitně popisuje problém jako nedostatek sales kapacity.
2. **Launch Club / Reddit-AI-search pattern** - řízená viditelnost značek v
   kanálech, které krmí Google a AI odpovědi. Důvod: vysoký revenue signál,
   ale vyžaduje přepsat do reputačně bezpečné a transparentní verze.
3. **PipeLime / AI SDR pattern** - AI sales agents pro research, enrichment,
   follow-up a booking meetings. Důvod: přímo sedí na agentní workflow a B2B
   hodnotu, ale nesmí sklouznout do spamu.
4. **Vid.AI / Vidgenie / Flibbo pattern** - AI video/content creation pro
   short-form a creator/business segment. Důvod: velké revenue signály, rychlá
   poptávka, opakovatelné asset workflow.
5. **DesignJoy-for-automation pattern** - produktizovaná služba s jedním
   aktivním requestem, asynchronním provozem a subscription cenou. Důvod:
   nejrychlejší cesta k první fakturaci bez stavby plného SaaS.

## Longlist kandidátů

| # | Projekt | Kategorie | Monetizační signál | Mechanismus | Co může AgentMint adaptovat | Co nekopírovat / riziko | Confidence | Zdroj |
|---|---|---|---|---|---|---|---:|---|
| 1 | Chatwith | AI customer support / white-label | TrustMRR ukazuje all-time revenue 115k USD, MRR 5.9k USD, 62 subscriptions, Paddle verified | White-label chatbot builder pro agentury, které resellují AI support klientům | Vertikální white-label agent pro jednu agenturní niku, plus done-with-you sales onboarding | Nekopírovat značku, UI, datasety ani klientské bot šablony | 5 | https://trustmrr.com/startup/chatwith |
| 2 | Chatbase | AI agents / customer support | Indie Hackers uvádí přes 5M ARR a růst z 64k MRR | Self-serve AI chatbot, později agents/API/integrace pro firmy | Specializovaný agent support pro úzký segment, ne obecný chatbot builder | Trh je přeplněný, nestačí wrapper bez distribuce | 4 | https://www.indiehackers.com/post/from-viral-side-project-to-a-5m-yr-b2b-ai-platform-TpbhTVyp1sjBk0uzo4tR |
| 3 | Vid.AI | AI short-form video | TrustMRR ukazuje all-time revenue 1.38M USD, MRR 95k USD, 1.5k subscriptions | Generování ready-to-post videí z nápadu nebo skriptu | Agentní video factory pro B2B niku, ne obecný consumer tool | Vysoké AI náklady, ad fatigue, copyright/likeness rizika | 5 | https://trustmrr.com/startup/vidai-llc |
| 4 | Vidgenie.ai | AI video marketing | TrustMRR ukazuje all-time revenue 558k USD, MRR 15k USD, 330 subscriptions | AI marketing videa pro business a creators | Vertikální video balíčky pro jednu niku, například lokální služby nebo B2B SaaS | Nekopírovat šablony, claimy ani marketing copy | 5 | https://trustmrr.com/startup/vidgenie-ai |
| 5 | Flibbo | AI mobile creator app | MRR Story uvádí 55k MRR, peak přes 90k MRR a 500k users | AI model wrapper do mobilní aplikace, growth přes TikTok/Reels a paywall testing | Mobilní nebo webový wrapper pro konkrétní use case s tvrdým paywall testingem | Neopírat business jen o placené virály; hlídat unit economics generování | 4 | https://www.mrrstory.com/stories/he-built-a-55k-mrr-ai-app-without-knowing-how-to-code |
| 6 | Cuppa.ai | AI SEO content | Indie Hackers uvádí 41-45k MRR pro SaaS a 13.5k MRR pro DFY service | AI article workflow pro SEO, plus done-for-you agency automation | Agentní content operations pro úzký typ agentury nebo publishera | SEO spam a nekvalitní AI content mohou poškodit reputaci | 4 | https://www.indiehackers.com/post/tech/acquiring-an-ai-micro-saas-and-building-it-to-58k-mrr-within-two-years-kIRoiABUe3yTPC6AgvrN |
| 7 | Jenni AI | Academic writing SaaS | Sacra odhaduje 7.0M ARR v červenci 2025 | AI writing environment pro akademiky, citations, research library, Word/LaTeX export | Vertikální research assistant pro legální, business nebo grant workflow | Akademická integrita, plagiarism a school policy rizika | 3 | https://sacra.com/c/jenni-ai/ |
| 8 | HeadshotPro | AI professional images | Starter Story / Startup Founder Stories uvádí 300k monthly revenue | Praktická AI image služba s rychlým výstupem a jasnou ochotou platit | B2B asset generator pro jasný profesní výstup: profile, listing, product image | Likeness consent, dataset rights, biometric/privacy rizika | 4 | https://startupfounderstories.com/stories/danny-postma-headshotpro-100k-2-weeks |
| 9 | PhotoAI | AI photographer | Veřejné build-in-public zdroje uvádějí desítky až 150k MRR, nutné znovu ověřit | Consumer AI photo generation přes web, frictionless upload-to-result | Pouze mechanismus: rychlý placený personal asset generator | Zdroj je slabší; image rights a deepfake rizika | 2 | https://www.indiehackers.com/post/how-to-build-ai-products-that-make-98cb49badb |
| 10 | Launch Club | Reddit / AI search visibility | TrustMRR ukazuje all-time revenue 969k USD, MRR 45k USD, 18 subscriptions | Pomáhá firmám být vidět v Reddit/AI-search kontextu, kombinuje SaaS a content service | Transparentní research a content placement strategie pro legitimní thought leadership | Nekopírovat astroturfing, aged accounts, fake engagement ani manipulaci | 5 | https://trustmrr.com/startup/launch-club |
| 11 | Reddit Agency | Productized Reddit marketing | TrustMRR ukazuje all-time revenue 192k USD, MRR 10k USD | Done-for-you Reddit content, reputation a AI search support | Reputace/answer-engine optimization jako konzultační služba s disclosure pravidly | Vysoké ToS/reputační riziko; nepřebírat account farming ani stealth posting | 5 | https://trustmrr.com/startup/reddit-agency |
| 12 | PipeLime | AI outbound sales agents | TrustMRR ukazuje all-time revenue 47.9k USD, MRR 11.6k USD, 15 subscriptions | AI SDR: lead research, email verification, contextual outreach, follow-ups, meeting booking | Agentní B2B sales ops pro jednu niku s ručním approval krokem | Spam, deliverability, GDPR/consent, platform ToS | 5 | https://trustmrr.com/startup/pipelime |
| 13 | 1Lookup | Data validation API | TrustMRR ukazuje all-time revenue 3.35M USD, MRR 265k USD | API pro validaci phone/email/IP a fraud prevention | Datová utility API pro jeden bolestivý B2B operation problém | Nekopírovat data; privacy a compliance jsou kritické | 5 | https://trustmrr.com/startup/1lookup |
| 14 | SimpleWeb by @Yasers | Productized local websites | TrustMRR ukazuje MRR 2.46k USD a 115 subscriptions | Automatizované one-page weby pro malé firmy, hosting jako recurring | Agentní "website-in-24h" pro jednu lokální niku s jasným scope | Nízký ARPU, support/revision creep, lokální compliance | 5 | https://trustmrr.com/startup/simpleweb-by-yasers |
| 15 | DesignJoy | Productized service | The Futur uvádí přes 1M USD roční revenue, Starter Story 145k monthly revenue | One-person subscription agency, async, fixed scope, one active request | "DesignJoy for agent automations": subscription, async board, jeden aktivní request | Nekopírovat brand; model závisí na vysoké kvalitě delivery a trustu | 4 | https://thefutur.com/content/productize-design |
| 16 | ShipFast | Boilerplate / digital product | Indie Hackers uvádí 63.6k USD revenue za méně než dva měsíce | Jednorázově placený boilerplate šetřící čas founderům | Agent-ready boilerplate nebo implementation kit pro velmi úzký workflow | Security kvalita, support debt, commoditization | 4 | https://www.indiehackers.com/post/case-study-shipfast-made-63k-in-revenue-in-60-days-8jj06RfVwjLR01CSDvxb |
| 17 | TrustMRR | Verified revenue database / marketplace | TrustMRR vlastní profil ukazuje all-time revenue 191k USD, MRR 13k USD | Verified revenue data jako marketplace, lead-gen a trust layer | Revenue-verified opportunity intelligence pro AgentMint research | Nekopírovat listing data ve velkém; respektovat ToS a attribution | 5 | https://trustmrr.com/startup/trustmrr |
| 18 | Plausible Analytics | Open-source SaaS | Official blog uvádí 1M ARR v roce 2022 a 7k+ paying subscribers | Open-source alternative + paid hosted service | Managed service nad open workflow pro privacy/ops niku | Stavba trvá déle; vyžaduje důvěru a technickou kvalitu | 5 | https://plausible.io/blog/open-source-saas |
| 19 | Bannerbear | API automation SaaS | FirstMRR uvádí 16k MRR, Indie Hackers milestone 6k MRR | API pro generování obrázků/video assetů, no-code integrace | Agentní asset generation API pro marketing ops | Konkurence Canvy/AI tools, nutná jasná integrace | 4 | https://first-mrr.com/study/banner-bear |
| 20 | Rezi | AI resume builder | Surgent/TrustMRR data uvádějí okolo 283k MRR a 8.7M all-time revenue | Product-led SEO pro konkrétní job-seeker workflow | Vertikální career agent pro jednu profesi nebo region | ATS/personal data, claims bez důkazu, přeplněný trh | 4 | https://surgent.dev/inspirations/rezi |
| 21 | Search+ | Ecommerce AI search | TrustMRR ukazuje all-time revenue 28.8k USD, MRR 4.5k USD | AI search/personalization pro ecommerce, B2B high-ticket subscriptions | Agentní conversion utility pro Shopify/SMB ecommerce | Jen 3 subscriptions, nutné ověřit churn a acquisition | 5 | https://trustmrr.com/startup/search |
| 22 | ToneAdapt | AI niche mobile app | MRR Story uvádí kolem 25k monthly revenue a 100k users | Překlad známého guitar tone na gear uživatele, niche pain + app subscription | Vysoce niche "translate expert knowledge to user context" app | Zdrojová data, copyright asociace se songs/artists, App Store závislost | 4 | https://www.mrrstory.com/stories/how-one-tiktok-video-brought-100000-users |
| 23 | Glamour | AI personal color analysis | RankYourApp uvádí verified MRR 14.5k USD a 865 active customers | AI selfie analysis pro beauty/fashion advice, subscription | Niche visual analysis s jasným consumer willingness-to-pay | Face/photo privacy, accuracy claims, beauty sensitivity | 4 | https://www.rankyourapp.com/app/glamour |
| 24 | Private Location Intelligence API | Data/API | TrustMRR search result uvádí MRR 6.9k USD, total 50k USD | API pro foot-traffic/venue busyness data a city guides | AI-ready public data API pro jednu decision niche | Privacy, data licensing, location data compliance | 3 | https://trustmrr.com/startup/localweb |
| 25 | Cold email agency case | Productized B2B service | Borks anonymized case uvádí 30k MRR za 6 měsíců | Narrow ICP, fixed retainer, booked-call promise, outbound ops | Produktizovaný B2B appointment-setting experiment s ručním approval | Anonymizovaný zdroj; cold email musí řešit consent, deliverability a laws | 3 | https://borks.io/blog/cold-email-agency-case-study-30k-mrr |
| 26 | Crawlbyte | Web data extraction API | PolyMRR uvádí 47k total revenue a 1.7k MRR; official site ukazuje paid API pricing | No-code/API scraping a structured extraction | Agentní public-data extraction pro povolené zdroje a konkrétní workflow | Nepřekračovat robots/ToS, CAPTCHA bypass je reputační a právní riziko | 3 | https://www.polymrr.com/startups/crawlbyte |

## Mechanismy, které se opakují

1. **White-label B2B tool pro agentury**: Chatwith, Chatbase, ChatDash-like
   patterny. AgentMint může začít jako service wrapper a až potom produkt.
2. **AI content/video app s paywallem**: Vid.AI, Vidgenie, Flibbo, HeadshotPro.
   Funguje, když je výstup vizuální, okamžitý a dobře se distribuuje.
3. **Produktizovaná služba s async provozem**: DesignJoy, cold email agency,
   Reddit/AI-search services. Nejrychlejší cesta k první fakturaci.
4. **Data/API utility**: 1Lookup, Crawlbyte, location intelligence, Bannerbear.
   Vyšší B2B hodnota, ale víc compliance a technické spolehlivosti.
5. **Verified database / opportunity marketplace**: TrustMRR. Data sama jsou
   produkt, pokud řeší důvěru, discovery a transakci.
6. **Vertical expert translator**: ToneAdapt, Glamour, Rezi, Jenni. AI bere
   expert knowledge a překládá ho do osobního kontextu uživatele.

## Doporučené první experimenty

### Experiment A: White-label AI support agent pro agentury

- Inspirace: Chatwith, Chatbase
- Nabídka: "Do 72 hodin nastavíme klientovi agenturní AI support widget nad
  FAQ, webem a objednávkovými pravidly."
- Kanál: přímý outbound na malé web/design/marketing agentury.
- Metrika: 10 discovery callů nebo 1 placený setup.
- Guardrail: bez tréninku na cizích neveřejných datech; každé demo jen s
  veřejným webem nebo daty dodanými se souhlasem.

### Experiment B: AgentMint AI visibility audit

- Inspirace: Launch Club, Reddit Agency, Peekaboo/AI visibility pattern
- Nabídka: "Zjistíme, kde se značka objevuje v Google/Reddit/AI odpovědích a
  navrhneme transparentní plán obsahu."
- Kanál: founder-led outreach na B2B SaaS a agentury.
- Metrika: 5 placených auditů po fixní ceně.
- Guardrail: žádné falešné účty, žádné fake engagement, žádné stealth
  testimonials.

### Experiment C: Produktizovaná agentní automation služba

- Inspirace: DesignJoy, SimpleWeb, cold email agency
- Nabídka: "Jedna aktivní automation request fronta za měsíční fee: research,
  enrichment, report, zapojení do nástrojů."
- Kanál: osobní síť a firmy, které už chtějí AI adopci.
- Metrika: 1 platící subscription klient nebo 3 paid pilots.
- Guardrail: externí akce a outreach jen po lidském schválení.

## Další krok

Navrhuji otevřít deep dive pro tři kandidáty:

1. Chatwith / Chatbase: B2B white-label agent.
2. Launch Club / AI visibility: reputačně bezpečná verze AI-search presence.
3. DesignJoy-for-automation: nejrychlejší placená služba bez vývoje SaaS.
