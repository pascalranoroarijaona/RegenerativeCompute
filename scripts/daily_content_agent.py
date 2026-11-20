#!/usr/bin/env python3
"""
daily_content_agent.py — 24-Hour Autonomous Content, Video Warmth & Prospect Lead Generator
Uses the official Google GenAI SDK (`google-genai`) with `GEMINI_API_KEY` to generate:
  1. Bilingual (EN + FR) technical/philosophical blog dispatch
  2. High-conversion LinkedIn & X/Nostr posts
  3. "Video Design Warmth" cinematography prompt (Veo / Runway / Sora / macro studio)
  4. Targeted Prospect Lead Angle & outreach script (VCs, Madagascar/Indian Ocean NGOs, Bitaxe makers, NSW CleanTech)
Saves outputs directly into:
  - content/daily/YYYY-MM-DD.md
  - content/prospects/YYYY-MM-DD-leads.md
  - data/feed.json (consumed live by index.html on GitHub Pages)
"""

import os
import json
import urllib.request
from datetime import datetime, timezone
from google import genai
from google.genai import types

PILLARS = [
    "Physics & Thermodynamics (Joule Heating 100% Efficiency, Scale Invariance L0-L5)",
    "Completing the Bitaxe Equation (17W BM1370 + Snap-On Borosilicate Biosphere Dome)",
    "The 114-Year Madagascan & Lemurian Uplift KPI (Lifting Civilization from the Most Vulnerable)",
    "Earth-to-Mars Dual-Use Engineering (MOF-303 Atmospheric Water, Terra Preta Biochar & Lava Tubes)",
    "Post-Fiat Economics & Low Time Preference (Block #1,000,000 Anchor, Inverting Jevons & Cantillon)",
    "Sydney Tech Central & NSW Brownfield Mine Shafts (Convective Cooling & Sub-50ms Grid Balancing)"
]

def get_live_block_height():
    try:
        req = urllib.request.Request(
            "https://mempool.space/api/blocks/tip/height",
            headers={"User-Agent": "RegenerativeCompute-Agent/1.0"}
        )
        with urllib.request.urlopen(req, timeout=8) as r:
            return int(r.read().decode().strip())
    except Exception:
        return 971500

def build_fallback_payload(today_str, day_num, pillar, tip_block):
    blocks_left = max(0, 1000000 - tip_block)
    return {
        "pillar": pillar,
        "title_en": f"Day {day_num}: Completing the Bitaxe Equation at Block #{tip_block:,}",
        "title_fr": f"Jour {day_num} : Compléter l'équation Bitaxe au Bloc #{tip_block:,}",
        "hook_en": f"With {blocks_left:,} blocks remaining until Block #1,000,000, every watt of open-source ASIC heat can water moss, fix carbon in Terra Preta, and prototype Mars life support.",
        "hook_fr": f"À {blocks_left:,} blocs du Bloc #1 000 000, chaque watt de chaleur ASIC open-source peut irriguer la mousse, fixer le carbone dans la Terra Preta et prototyper le support de vie martien.",
        "article_en": (
            f"At Bitcoin block #{tip_block:,}, we stand {blocks_left:,} blocks away from our Block #1,000,000 commercial launch milestone. "
            "Open-source hardware like the Bitaxe Gamma 601 proved that anyone on Earth can hash sovereignly at 17 watts. "
            "Yet silicon alone is only half the thermodynamic equation. By placing an anodized aluminum dish and borosilicate condensation dome directly above the heatsink, "
            "100% of Joule heat powers a self-watering micro-biosphere. Scaled from 17W on a desk in Sydney to 50 MW in rehabilitated mine shafts and solar microgrids across Madagascar, "
            "this architecture replaces extractive war-financing with a 114-year covenant to nourish the most vulnerable populations first."
        ),
        "article_fr": (
            f"Au bloc Bitcoin #{tip_block:,}, nous sommes à {blocks_left:,} blocs de notre lancement commercial au Bloc #1 000 000. "
            "Le matériel open-source comme le Bitaxe Gamma 601 a prouvé que chacun peut hacher souverainement à 17 watts. "
            "Mais le silicium seul n'est que la moitié de l'équation thermodynamique. En posant une coupelle en aluminium anodisé et un dôme en borosilicate directement sur le dissipateur, "
            "100 % de la chaleur Joule alimente une micro-biosphère auto-irriguée. Déployée de 17 W sur un bureau à Sydney jusqu'aux micro-réseaux solaires de Madagascar, "
            "cette architecture remplace l'extraction fossile par un pacte de 114 ans visant à nourrir d'abord les populations les plus vulnérables."
        ),
        "x_post": (
            f"Block #{tip_block:,} ({blocks_left:,} left to #1,000,000).\n\n"
            "Bitaxe gave us open-source hash. Now we add the living dome: 17W of Joule heat driving a self-watering Terra Preta biosphere.\n\n"
            "114-year mission: feed all Madagascans & Lemurians first, then terraform Mars.\n\n"
            "regenerativecompute.io #Bitcoin #Bitaxe"
        ),
        "linkedin_post": (
            f"Countdown to Bitcoin Block #1,000,000: {blocks_left:,} blocks remaining.\n\n"
            "What happens when we stop treating compute heat as waste and start measuring civilizational success by how fast we uplift the most vulnerable populations?\n\n"
            "At Regenerative Compute (regenerativecompute.io), we pair open-source ASICs with closed-loop water harvesting (MOF-303), Terra Preta biochar, and hydroponics—starting from a $42 Bitaxe topper on a desk in Sydney and scaling to solar microgrids in Madagascar and Martian lava tubes.\n\n"
            "Low time preference. 114 years (2026–2140). Every watt warms life."
        ),
        "video_warmth_prompt": (
            "4K 60fps tactile macro cinema: warm golden morning sunlight streaming through a Sydney studio window onto a charred-timber desk. "
            "An open-source Bitaxe miner hums silently beneath a brushed aluminum saucer filled with dark Terra Preta biochar and emerald fern moss inside a hand-blown borosilicate glass dome. "
            "Visible warm amber thermal shimmer rises gently, condensing into crystal water droplets that roll down the glass onto the moss. "
            "Warm tungsten glow, shallow depth of field, Kodak Vision3 500T film grain, hopeful human-centric warmth."
        ),
        "prospect_segment": "Open-Source Bitaxe Makers & Climate-Tech Seed Investors",
        "prospect_outreach": (
            "Subject: Completing the Bitaxe Equation — 17W Desk Biosphere to Madagascar & Mars\n\n"
            "Hi [Name],\n\n"
            "You already understand sovereign compute. We built a $42 snap-on borosilicate biosphere topper for the Bitaxe Gamma 601 that uses 100% of its 17W Joule heat to run a self-watering Terra Preta ecosystem—proving on a desk the exact closed-loop thermodynamics we are scaling to solar water/food microgrids in Madagascar ahead of our Block #1,000,000 launch.\n\n"
            "Explore the live countdown and open schematics at https://regenerativecompute.io"
        )
    }

def main():
    now_utc = datetime.now(timezone.utc)
    today_str = now_utc.strftime("%Y-%m-%d")
    day_num = (now_utc - datetime(2026, 11, 19, tzinfo=timezone.utc)).days
    day_num = max(1, day_num)
    pillar = PILLARS[(day_num - 1) % len(PILLARS)]
    tip_block = get_live_block_height()
    blocks_left = max(0, 1000000 - tip_block)

    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    payload = None

    if api_key:
        try:
            client = genai.Client(api_key=api_key)
            prompt = f"""
You are the Autonomous Chief Storytelling, Video Warmth & Growth Lead Agent for Regenerative Compute (regenerativecompute.io & regenerativecompute.org), founded by Pascal Ranoroarijaona in Sydney (Tech Central / Atlassian Central June 2027).

Core Thesis & Non-Negotiables:
- Current Bitcoin Block: #{tip_block:,} | Target Commercial Launch: Block #1,000,000 ({blocks_left:,} blocks remaining) | 114-Year Horizon (2026–2140).
- New Civilizational KPI: Lift human civilizations starting from the most vulnerable populations—bringing sovereign food, atmospheric water (MOF-303), and Terra Preta biochar soil regeneration to all Madagascans and Lemurians over the next century, while flight-qualifying closed-loop life support for Mars.
- Hardware Wedge: Bitaxe Gamma 601 (17W) was the first half of the equation; snapping a borosilicate glass cloche dome + anodized aluminum dish over it completes the thermodynamic loop on any desk.
- Tone: Y Combinator DeepTech clarity + warm, tactile, poetic Solarpunk humanism ("Video design warmth": golden tungsten light, living moss, water droplets, human dignity).
- Today's Focus Pillar (Day {day_num}): {pillar}

Generate a complete daily marketing & R&D dispatch strictly as valid JSON matching this schema:
{{
  "pillar": "{pillar}",
  "title_en": "Compelling English headline",
  "title_fr": "Titre français percutant",
  "hook_en": "2-sentence English hook",
  "hook_fr": "Accroche française de 2 phrases",
  "article_en": "250-word high-signal English micro-essay",
  "article_fr": "Micro-essai français de 250 mots",
  "x_post": "Punchy X / Nostr post under 270 chars with #RegenerativeCompute",
  "linkedin_post": "Executive LinkedIn post (150-220 words) with clear line breaks and CTA to regenerativecompute.io",
  "video_warmth_prompt": "Detailed 4K cinematography prompt for Veo/Sora/Runway emphasizing golden warmth, tactile hardware, water condensation, living plants, and human hope",
  "prospect_segment": "Specific high-leverage target segment for today",
  "prospect_outreach": "Ready-to-send personalized cold email / DM script for that segment"
}}
"""
            response = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.75
                )
            )
            payload = json.loads(response.text)
            print("[OK] Generated fresh daily content via Gemini API (gemini-2.5-flash).")
        except Exception as exc:
            print(f"[WARN] Gemini API call failed ({exc}); falling back to deterministic template.")

    if not payload:
        payload = build_fallback_payload(today_str, day_num, pillar, tip_block)

    os.makedirs("content/daily", exist_ok=True)
    os.makedirs("content/prospects", exist_ok=True)
    os.makedirs("data", exist_ok=True)

    # 1. Save Markdown Daily Dispatch
    daily_md_path = f"content/daily/{today_str}.md"
    md_content = f"""# {payload['title_en']}
## {payload['title_fr']}

- **Date (UTC):** {today_str} (Day #{day_num})
- **Bitcoin Block:** #{tip_block:,} ({blocks_left:,} blocks to Block #1,000,000)
- **Pillar:** {payload['pillar']}

---

### 🇬🇧 English Dispatch
**{payload['hook_en']}**

{payload['article_en']}

---

### 🇫🇷 Édition Française
**{payload['hook_fr']}**

{payload['article_fr']}

---

### 📱 Social Media Ready-to-Post
#### X / Nostr
```text
{payload['x_post']}
```

#### LinkedIn
```text
{payload['linkedin_post']}
```

---

### 🎥 Video Design Warmth Prompt (Veo / Sora / Macro Studio)
> {payload['video_warmth_prompt']}
"""
    with open(daily_md_path, "w", encoding="utf-8") as f:
        f.write(md_content)

    # 2. Save Daily Prospect Lead Brief
    lead_md_path = f"content/prospects/{today_str}-leads.md"
    lead_content = f"""# Daily Prospect & Growth Agent — {today_str}
- **Target Segment:** {payload['prospect_segment']}
- **Block Anchor:** #{tip_block:,} -> #1,000,000

## Outreach Script
```text
{payload['prospect_outreach']}
```
"""
    with open(lead_md_path, "w", encoding="utf-8") as f:
        f.write(lead_content)

    # 3. Prepend to data/feed.json (keep latest 30 days)
    feed_path = "data/feed.json"
    if os.path.exists(feed_path):
        with open(feed_path, "r", encoding="utf-8") as f:
            feed = json.load(f)
    else:
        feed = {"genesis_promise_block": 970500, "target_launch_block": 1000000, "horizon_year": 2140, "posts": []}

    entry = {
        "date": today_str,
        "day_number": day_num,
        "block_height": tip_block,
        "pillar": payload["pillar"],
        "title_en": payload["title_en"],
        "title_fr": payload["title_fr"],
        "hook_en": payload["hook_en"],
        "hook_fr": payload["hook_fr"],
        "x_post": payload["x_post"],
        "linkedin_post": payload["linkedin_post"],
        "video_warmth_prompt": payload["video_warmth_prompt"],
        "prospect_segment": payload["prospect_segment"]
    }

    feed["updated_at"] = now_utc.isoformat()
    feed["latest_block"] = tip_block
    feed["posts"] = [entry] + [p for p in feed.get("posts", []) if p.get("date") != today_str][:29]

    with open(feed_path, "w", encoding="utf-8") as f:
        json.dump(feed, f, indent=2, ensure_ascii=False)

    print(f"[OK] Saved {daily_md_path}, {lead_md_path}, and updated {feed_path}.")

if __name__ == "__main__":
    main()
