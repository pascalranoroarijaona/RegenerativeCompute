# ☀ Regenerative Compute (`regenerativecompute.io` | `regenerativecompute.org`)

> **Make the Earth Bloom with Bitcoin Regenerative Mining.**
> *Sustaining life on Earth and beyond—anchoring our 114-year covenant (2026–2140) at Bitcoin Block #1,000,000 to bring food, clean water, and fertile soil to all Madagascans and Lemurians first, while flight-qualifying closed-loop life support for Mars.*

---

## 1. Repository Architecture (`https://github.com/pascalranoroarijaona/RegenerativeCompute`)

```text
RegenerativeCompute/
├── index.html                        # GitHub Pages Web App (Block #1M Countdown, Warmth Visualizer, Simulator, Live AI Feed)
├── CNAME                             # Custom domain lock: regenerativecompute.io
├── requirements.txt                  # google-genai, requests, pyyaml
├── scripts/
│   ├── init_repo.py                  # One-command repository & git remote initializer
│   ├── anchor_promise.py             # Live mempool.space height + SHA-256 / OP_RETURN Timechain Covenant generator
│   └── daily_content_agent.py        # 24h autonomous Gemini API Content, Video Warmth & Prospect Lead Agent
├── .github/workflows/
│   └── daily_pipeline.yml            # GitHub Actions cron job running every 24h at 21:00 UTC (08:00 AEDT)
├── data/
│   ├── feed.json                     # Live JSON feed consumed by index.html
│   ├── prospects.json                # 4-tier Growth & Prospect Lead playbook
│   └── timechain_covenant.json       # Cryptographic Block #1,000,000 promise record
└── content/
    ├── daily/YYYY-MM-DD.md           # Daily bilingual (EN/FR) essay, X/Nostr post, LinkedIn post & Video Warmth prompt
    └── prospects/YYYY-MM-DD-leads.md # Daily targeted investor / NGO / maker outreach script
```

---

## 2. Quickstart Deployment (Sydney → GitHub Pages)

```bash
# 1. Clone or initialize the repository
git clone https://github.com/pascalranoroarijaona/RegenerativeCompute.git
cd RegenerativeCompute
python scripts/init_repo.py

# 2. Test the Timechain Anchor & Daily Gemini Agent locally
export GEMINI_API_KEY="your_google_ai_studio_key"
python scripts/anchor_promise.py
python scripts/daily_content_agent.py

# 3. Push to GitHub
git add .
git commit -m "feat: launch RegenerativeCompute Block #1,000,000 web app & 24h AI agent"
git push -u origin main
```

### Enable GitHub Pages & Custom Domain (`regenerativecompute.io`)
1. Go to **GitHub Repo → Settings → Pages**.
2. Under **Build and deployment**, select **Deploy from a branch** → `main` / `/ (root)`.
3. Verify **Custom domain** is set to `regenerativecompute.io` (read automatically from `CNAME`) and check **Enforce HTTPS**.
4. In your DNS registrar (where you just registered `regenerativecompute.io` & `regenerativecompute.org` [cite: 7]):
   - Point `@` (`A` records) to GitHub Pages IPs: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.
   - Point `www` (`CNAME`) to `pascalranoroarijaona.github.io`.
5. Go to **Settings → Secrets and variables → Actions → New repository secret** and add `GEMINI_API_KEY`.

---

## 3. Dual-Domain Governance (`regenerativecompute.io` vs `.org`)
- **`regenerativecompute.io` (Commercial Venture — Lemuria Technologies):** YC-style investor landing page, BitTerrarium™ & BitPlant™ commercial kits, NSW brownfield energy partnerships, and Sydney Tech Central / Atlassian Central (June 2027) HQ roadmap.
- **`regenerativecompute.org` (Non-Profit & Open Commons):** Open-source OpenSCAD/STL files for the $42 AUD Bitaxe Snap-On Topper, DIY MOF-303 atmospheric water & Terra Preta biochar guides, and Madagascar community microgrid blueprints.
- **`thesunstandard.net` (Theoretical & Philosophical Treatises):** Long-form physics, chrono-thermodynamics, and *Horizon Zero 2044* writings.
