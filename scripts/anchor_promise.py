#!/usr/bin/env python3
"""
anchor_promise.py — Queries live Bitcoin block height from mempool.space,
computes exact ETA to Block #1,000,000 (Commercial Launch Target) and the
114-year Madagascan / Lemurian Civilization Uplift Horizon (2026–2140),
and generates a deterministic SHA-256 + OP_RETURN payload for Timechain anchoring.
"""

import hashlib
import json
import urllib.request
from datetime import datetime, timezone, timedelta

TARGET_LAUNCH_BLOCK = 1000000
HORIZON_YEARS = 114
BLOCKS_PER_YEAR = 52594.88  # 365.2422 days * 144 blocks/day
HORIZON_END_BLOCK = int(TARGET_LAUNCH_BLOCK + HORIZON_YEARS * BLOCKS_PER_YEAR)

PROMISE_MANIFESTO = (
    "REGENERATIVE COMPUTE (regenerativecompute.io | regenerativecompute.org) — "
    "TIMECHAIN COVENANT: Sustaining Life on Earth and Beyond. "
    "New Civilizational KPI: Lift humanity starting from the most vulnerable populations—"
    "bringing sovereign food, clean atmospheric water, and Terra Preta soil regeneration "
    "to all Madagascans and Lemurians across a 114-year low-time-preference horizon "
    "(Block #1,000,000 Launch -> Block #6,995,816 / Year 2140), while flight-qualifying "
    "closed-loop life support for Mars. Every watt of compute warms life."
)

def fetch_tip_height():
    url = "https://mempool.space/api/blocks/tip/height"
    req = urllib.request.Request(url, headers={"User-Agent": "RegenerativeCompute-Anchor/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return int(resp.read().decode("utf-8").strip())
    except Exception as exc:
        print(f"[WARN] Could not reach mempool.space ({exc}); using fallback estimate.")
        return 971500

def main():
    tip = fetch_tip_height()
    blocks_remaining = max(0, TARGET_LAUNCH_BLOCK - tip)
    minutes_remaining = blocks_remaining * 10
    eta_utc = datetime.now(timezone.utc) + timedelta(minutes=minutes_remaining)

    sha256_digest = hashlib.sha256(PROMISE_MANIFESTO.encode("utf-8")).hexdigest()
    # 40-byte OP_RETURN payload: 'RC1M' prefix (4 bytes) + 32-byte SHA-256 hash = 36 bytes (<= 80 bytes standard)
    op_return_hex = "5243314d" + sha256_digest

    anchor_record = {
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "current_bitcoin_block": tip,
        "target_launch_block": TARGET_LAUNCH_BLOCK,
        "blocks_remaining": blocks_remaining,
        "estimated_launch_utc": eta_utc.strftime("%Y-%m-%d %H:%M UTC"),
        "horizon_years": HORIZON_YEARS,
        "horizon_end_block": HORIZON_END_BLOCK,
        "covenant_text": PROMISE_MANIFESTO,
        "covenant_sha256": sha256_digest,
        "op_return_hex": op_return_hex,
        "verification_instructions": (
            "Broadcast a 0-value OP_RETURN transaction containing op_return_hex on Bitcoin mainnet "
            "or stamp data/timechain_covenant.json via OpenTimestamps (ots stamp data/timechain_covenant.json)."
        )
    }

    with open("data/timechain_covenant.json", "w", encoding="utf-8") as f:
        json.dump(anchor_record, f, indent=2, ensure_ascii=False)

    print("=================================================================")
    print("  BITCOIN TIMECHAIN COVENANT — BLOCK #1,000,000 ANCHOR           ")
    print("=================================================================")
    print(f"Current Mainnet Height : #{tip:,}")
    print(f"Target Launch Height   : #{TARGET_LAUNCH_BLOCK:,}")
    print(f"Blocks Remaining       : {blocks_remaining:,} blocks (~{blocks_remaining/144:.1f} days)")
    print(f"Projected Launch ETA   : {anchor_record['estimated_launch_utc']}")
    print(f"114-Year Horizon Block : #{HORIZON_END_BLOCK:,} (Year 2140)")
    print(f"Covenant SHA-256       : {sha256_digest}")
    print(f"OP_RETURN Hex (36B)    : {op_return_hex}")
    print("[OK] Saved to data/timechain_covenant.json")

if __name__ == "__main__":
    main()
