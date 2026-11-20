#!/usr/bin/env python3
"""
init_repo.py — Bootstrapper for https://github.com/pascalranoroarijaona/RegenerativeCompute
Configures directory structure, CNAME (regenerativecompute.io), GitHub Pages metadata,
and verifies environment readiness for the 24-hour Gemini Content & Leads Agent.
"""

import os
import json
import subprocess
from datetime import datetime, timezone

REPO_URL = "https://github.com/pascalranoroarijaona/RegenerativeCompute.git"
DOMAIN = "regenerativecompute.io"

DIRS = [
    ".github/workflows",
    "scripts",
    "content/daily",
    "content/prospects",
    "data",
    "assets",
]

def run(cmd, check=False):
    print(f"$ {' '.join(cmd)}")
    return subprocess.run(cmd, check=check, text=True, capture_output=True)

def main():
    print("=================================================================")
    print("  REGENERATIVE COMPUTE — REPOSITORY BOOTSTRAPPER (2026 -> 2140)  ")
    print("=================================================================")

    for d in DIRS:
        os.makedirs(d, exist_ok=True)
        print(f"[OK] Directory verified: {d}/")

    with open("CNAME", "w", encoding="utf-8") as f:
        f.write(f"{DOMAIN}\n")
    print(f"[OK] CNAME locked to: {DOMAIN}")

    # Ensure feed.json and prospects.json exist
    if not os.path.exists("data/feed.json"):
        seed_feed = {
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "genesis_promise_block": 970500,
            "target_launch_block": 1000000,
            "horizon_year": 2140,
            "posts": []
        }
        with open("data/feed.json", "w", encoding="utf-8") as f:
            json.dump(seed_feed, f, indent=2, ensure_ascii=False)
        print("[OK] Initialized data/feed.json")

    if not os.path.exists("data/prospects.json"):
        with open("data/prospects.json", "w", encoding="utf-8") as f:
            json.dump({"updated_at": datetime.now(timezone.utc).isoformat(), "segments": []}, f, indent=2)
        print("[OK] Initialized data/prospects.json")

    # Initialize git if not already initialized
    if not os.path.exists(".git"):
        run(["git", "init"])
        run(["git", "branch", "-M", "main"])
        run(["git", "remote", "add", "origin", REPO_URL])
        print(f"[OK] Git initialized and linked to {REPO_URL}")
    else:
        print("[OK] Existing .git repository detected.")

    print("\nNext Steps:")
    print("  1. Set GEMINI_API_KEY in GitHub Repo -> Settings -> Secrets and variables -> Actions")
    print("  2. Enable GitHub Pages -> Deploy from branch: main / (root) -> Custom domain: regenerativecompute.io")
    print("  3. Run: python scripts/daily_content_agent.py")
    print("  4. Push: git add . && git commit -m 'Genesis: Block 1,000,000 Launch' && git push -u origin main")

if __name__ == "__main__":
    main()
