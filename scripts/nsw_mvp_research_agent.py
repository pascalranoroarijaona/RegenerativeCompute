#!/usr/bin/env python3
"""
nsw_mvp_research_agent.py — NSW 1 MW Inverted Matrix MVP & Thermal Off-Taker Sizing Engine
Part of RegenerativeCompute (https://github.com/pascalranoroarijaona/RegenerativeCompute)

Purpose:
  1. Models exact winter & year-round thermal demand (kWth & MWh/yr) for NSW growers
     (floriculture, propagation nurseries, hydroponic vegetables, mushrooms, aquaculture).
  2. Computes LPG / Natural Gas fuel savings (AUD/yr) and sizes a Heat Purchase Agreement (Thermal PPA).
  3. Matches the off-taker load to the Inverted Matrix v2.0 Ultra-Lean 1 MW NSW Mine MVP.
  4. Optionally uses GEMINI_API_KEY to generate tailored B2B outreach & technical LOI briefs
     saved directly into `research/nsw_mvp/`.
"""

import os
import json
import argparse
from datetime import datetime, timezone

# NSW Reference Fuel Benchmarks (AUD, 2026)
LPG_PRICE_AUD_PER_L = 1.25          # Delivered bulk agricultural LPG in regional NSW
LPG_KWH_TH_PER_L = 6.12             # 25.9 MJ/L * 85% boiler efficiency = 6.12 kWh_th/L (~$0.204/kWh_th)
NAT_GAS_AUD_PER_GJ = 26.0           # Commercial piped gas (~$0.108/kWh_th at 88% efficiency)
THERMAL_PPA_RATE_AUD_KWH = 0.09     # Regenerative Compute 50%+ discount Heat PPA rate

CORRIDORS = {
    "lithgow": {"name": "Lithgow / Central Tablelands", "t_design_c": -2.0, "heating_hours_yr": 4800},
    "hunter":  {"name": "Upper Hunter (Muswellbrook / Singleton)", "t_design_c": 3.0, "heating_hours_yr": 3400},
    "macquarie": {"name": "Lake Macquarie / Central Coast Hinterland", "t_design_c": 5.5, "heating_hours_yr": 2850},
}

CROPS = {
    "flowers":   {"name": "Cut Flowers & Orchids (Roses, Phalaenopsis, Lilies)", "t_target_c": 22.0, "u_val": 5.2},
    "nursery":   {"name": "Propagation & Native Mine-Rehab Tree Nursery", "t_target_c": 25.0, "u_val": 4.2},
    "tomatoes":  {"name": "Protected Cropping Vegetables & Berries", "t_target_c": 20.0, "u_val": 5.6},
    "mushrooms": {"name": "Gourmet Mushrooms + Barramundi RAS (365-day load)", "t_target_c": 27.0, "u_val": 3.5},
}

def calculate_thermal_fit(corridor_key: str, crop_key: str, area_m2: float):
    cor = CORRIDORS[corridor_key]
    crop = CROPS[crop_key]

    delta_t_peak = max(5.0, crop["t_target_c"] - cor["t_design_c"])
    # Envelope surface-to-floor factor ~1.35 for multi-span greenhouse
    peak_kw_th = (crop["u_val"] * (area_m2 * 1.35) * delta_t_peak) / 1000.0

    # Average load factor across heating hours (or 0.78 year-round for mushrooms/RAS)
    load_factor = 0.75 if crop_key == "mushrooms" else 0.46
    hours = 8000 if crop_key == "mushrooms" else cor["heating_hours_yr"]
    annual_kwh_th = peak_kw_th * load_factor * hours

    lpg_liters_displaced = annual_kwh_th / LPG_KWH_TH_PER_L
    current_lpg_bill_aud = lpg_liters_displaced * LPG_PRICE_AUD_PER_L
    rc_ppa_bill_aud = annual_kwh_th * THERMAL_PPA_RATE_AUD_KWH
    grower_annual_savings_aud = current_lpg_bill_aud - rc_ppa_bill_aud
    co2_avoided_tons = (lpg_liters_displaced * 1.55) / 1000.0  # 1.55 kg CO2/L LPG

    # Size Immersion Compute Pod (at 95% hydraulic capture)
    recommended_it_kw = round(peak_kw_th / 0.95)

    return {
        "corridor": cor["name"],
        "crop_sector": crop["name"],
        "greenhouse_area_m2": area_m2,
        "design_delta_t_k": round(delta_t_peak, 1),
        "peak_thermal_demand_kw": round(peak_kw_th, 1),
        "annual_thermal_energy_mwh": round(annual_kwh_th / 1000.0, 1),
        "recommended_compute_pod_kw": recommended_it_kw,
        "lpg_displaced_liters_yr": round(lpg_liters_displaced),
        "baseline_lpg_cost_aud_yr": round(current_lpg_bill_aud),
        "thermal_ppa_revenue_aud_yr": round(rc_ppa_bill_aud),
        "grower_net_savings_aud_yr": round(grower_annual_savings_aud),
        "co2_avoided_tons_yr": round(co2_avoided_tons, 1),
    }

def maybe_generate_gemini_brief(result: dict):
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key:
        return None
    try:
        from google import genai
        client = genai.Client(api_key=api_key)
        prompt = (
            f"Write a concise, practical 1-page B2B Consulting & Thermal Off-Take LOI proposal "
            f"from Regenerative Compute (Sydney Tech Central) to a commercial grower in {result['corridor']} "
            f"operating {result['greenhouse_area_m2']} m² of {result['crop_sector']}. "
            f"Include these exact engineering numbers: peak demand {result['peak_thermal_demand_kw']} kWth, "
            f"{result['lpg_displaced_liters_yr']:,} L/yr of LPG displaced, "
            f"${result['grower_net_savings_aud_yr']:,} AUD/yr net fuel savings via a 65°C hydronic loop "
            f"powered by a {result['recommended_compute_pod_kw']} kW liquid-immersed compute pod."
        )
        resp = client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
        return resp.text
    except Exception as exc:
        print(f"[WARN] Gemini brief skipped: {exc}")
        return None

def main():
    parser = argparse.ArgumentParser(description="NSW 1 MW MVP Thermal Off-Taker Sizer")
    parser.add_argument("--corridor", choices=list(CORRIDORS.keys()), default="hunter")
    parser.add_argument("--crop", choices=list(CROPS.keys()), default="flowers")
    parser.add_argument("--area", type=float, default=6500.0, help="Protected cropping area in m2")
    args = parser.parse_args()

    res = calculate_thermal_fit(args.corridor, args.crop, args.area)
    os.makedirs("research/nsw_mvp", exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    out_json = f"research/nsw_mvp/{stamp}_{args.corridor}_{args.crop}.json"

    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=2)

    brief = maybe_generate_gemini_brief(res)
    if brief:
        out_md = f"research/nsw_mvp/{stamp}_{args.corridor}_{args.crop}_LOI_brief.md"
        with open(out_md, "w", encoding="utf-8") as f:
            f.write(brief)
        print(f"[OK] Generated AI B2B LOI Brief: {out_md}")

    print("======================================================================")
    print("  NSW 1 MW INVERTED MATRIX MVP — THERMAL OFF-TAKER SIZING REPORT      ")
    print("======================================================================")
    for k, v in res.items():
        print(f"  {k:30s}: {v}")
    print(f"[OK] Saved engineering report to {out_json}")

if __name__ == "__main__":
    main()
