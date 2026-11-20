// ============================================================================
// PICO-BITAQUAPONICS v1.0 — ULTRA-COMPACT BITAXE AQUAPONIC ECOSYSTEM (1.35 L)
// Regenerative Compute (regenerativecompute.org | regenerativecompute.io)
// Author: Pascal Ranoroarijaona (Ranaora) — Sydney Tech Central (2026)
// License: CERN-OHL-P v2 / MIT Open Hardware Commons
// ============================================================================
// DIMENSIONS & THERMAL BUDGET:
// - Target Miner   : Bitaxe Gamma 601 (PCB 99.76 x 56.54 mm, 40x40mm fan, ~17W)
// - Footprint      : 124 mm x 124 mm x 265 mm total height (fits any desk)
// - Water Volume   : ~1.35 L freshwater (26.5°C +/- 1°C via adjustable baffle)
// - Biology        : 3-4 Neocaridina shrimp + 2 Planorbis snails + Terra Preta
//                    biochar biofilter + Wolffia arrhiza + watercress/mint
// ============================================================================

/* [Render Selector] */
// Options: "assembly", "base_cradle", "thermal_baffle", "hydro_basket", "airlift_tube", "cloche_ring"
PART_TO_RENDER = "assembly";

/* [Bitaxe Gamma 601 Exact PCB Parameters (mm)] */
pcb_len         = 99.76;   // Exact Bitaxe Gamma 601 length
pcb_wid         = 56.54;   // Exact Bitaxe Gamma 601 width
pcb_thick       = 1.60;    // FR4 thickness
pcb_clearance   = 0.35;    // Fit tolerance per side
fan_size        = 40.5;    // 40x40mm fan clearance
dc_jack_dia     = 9.5;     // 5.5x2.1mm barrel plug opening
oled_win_w      = 28.0;    // Front 0.91" OLED viewing window width
oled_win_h      = 14.0;    // Front 0.91" OLED viewing window height

/* [Vessel & Thermal Transfer Plate Parameters (mm)] */
// Fits standard 115mm OD borosilicate glass jar/beaker (~1.35L, 140mm tall)
vessel_od       = 115.0;
vessel_wall     = 2.5;
vessel_id       = vessel_od - 2 * vessel_wall; // 110.0 mm
vessel_h        = 135.0;
alu_plate_dia   = 112.0;   // Anodized aluminum thermal transfer disc
alu_plate_thick = 1.5;

/* [Print & Structural Settings] */
wall            = 2.4;
cradle_h        = 54.0;    // Height of Bitaxe hot-air plenum base
baffle_open_pct = 32;      // Default 32% heat coupling (~5.4 Wth into 1.35L water)
$fn             = 72;

// ============================================================================
// RENDER DISPATCHER
// ============================================================================
if (PART_TO_RENDER == "assembly") {
    full_assembly();
} else if (PART_TO_RENDER == "base_cradle") {
    part_base_cradle();
} else if (PART_TO_RENDER == "thermal_baffle") {
    part_thermal_baffle(baffle_open_pct);
} else if (PART_TO_RENDER == "hydro_basket") {
    part_hydro_basket();
} else if (PART_TO_RENDER == "airlift_tube") {
    part_airlift_tube();
} else if (PART_TO_RENDER == "cloche_ring") {
    part_cloche_ring();
}

// ============================================================================
// 1. PART A: BITAXE GAMMA 601 HORIZONTAL PLENUM CRADLE
// ============================================================================
module part_base_cradle() {
    outer_d = vessel_od + 2 * wall + 4.0; // 123.8 mm cylindrical shell

    difference() {
        union() {
            // Main cylindrical thermal chimney shell
            cylinder(d = outer_d, h = cradle_h);

            // Front angled OLED display visor bezel
            translate([0, -outer_d/2 + 2, 16])
                rotate([22, 0, 0])
                    cube([oled_win_w + 10, 10, oled_win_h + 8], center = true);

            // Anti-tip outrigger feet (4x)
            for (a = [45 : 90 : 315]) {
                rotate([0, 0, a])
                    translate([outer_d/2 - 2, 0, 0])
                        hull() {
                            cylinder(d = 12, h = 4);
                            translate([6, 0, 0]) cylinder(d = 8, h = 3);
                        }
            }
        }

        // Hollow internal plenum chamber
        translate([0, 0, wall])
            cylinder(d = outer_d - 2 * wall, h = cradle_h + 1);

        // Horizontal slide-in slot for Bitaxe Gamma 601 PCB (from rear Y+)
        slot_w = pcb_wid + 2 * pcb_clearance;
        slot_l = pcb_len + 2 * pcb_clearance;
        translate([-slot_w/2, -slot_l/2 + 4, 10])
            cube([slot_w, slot_l + 25, 34]);

        // PCB edge-rail grooves (locks board horizontally)
        translate([-(slot_w + 2.4)/2, -slot_l/2 + 4, 12])
            cube([slot_w + 2.4, slot_l + 25, pcb_thick + 0.5]);

        // Rear DC 5.5x2.1mm power barrel & USB/cable pass-through
        translate([0, outer_d/2, 17])
            rotate([90, 0, 0])
                cylinder(d = dc_jack_dia + 3, h = 25, center = true);

        // Front 0.91" OLED viewing cutout
        translate([0, -outer_d/2 + 1, 16])
            rotate([22, 0, 0])
                cube([oled_win_w, 22, oled_win_h], center = true);

        // Cool air intake vents (bottom perimeter, 8 slots)
        for (i = [0 : 7]) {
            rotate([0, 0, i * 45 + 22.5])
                translate([outer_d/2 - 4, 0, 7])
                    cube([12, 14, 6], center = true);
        }

        // Adjustable thermal bypass exhaust vents (upper perimeter)
        for (i = [0 : 5]) {
            rotate([0, 0, i * 60])
                translate([outer_d/2 - 4, 0, cradle_h - 11])
                    cube([12, 18, 7], center = true);
        }

        // Top rebate seat for Thermal Baffle & Aluminum Transfer Disc
        translate([0, 0, cradle_h - 4.0])
            cylinder(d = vessel_od + 2.4, h = 5.0);
    }

    // Internal PCB support pillars (4 corners)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx * (pcb_wid/2 - 3), sy * (pcb_len/2 - 5) + 4, wall])
            cylinder(d = 5.5, h = 10 - wall);
    }
}

// ============================================================================
// 2. PART B: THERMAL BAFFLE & ALUMINUM DISC HOLDER (26.5°C WATER REGULATOR)
// ============================================================================
// Controls what fraction of the 17W ASIC plume hits the aluminum tank bottom
// vs. venting laterally. Default 32% open -> ~5.4 Wth -> steady 26.5°C water.
module part_thermal_baffle(open_pct = 32) {
    ring_od = vessel_od + 2.0;
    ring_h  = 9.0;

    difference() {
        union() {
            // Outer retaining collar that holds the borosilicate glass vessel
            cylinder(d = ring_od + 3.2, h = ring_h);
        }

        // Upper socket for glass vessel (4.5 mm deep)
        translate([0, 0, ring_h - 4.5])
            cylinder(d = vessel_od + 0.6, h = 5.5);

        // Seat for 112mm Anodized Aluminum Thermal Transfer Plate
        translate([0, 0, ring_h - 4.5 - alu_plate_thick])
            cylinder(d = alu_plate_dia + 0.5, h = alu_plate_thick + 0.5);

        // Central thermal aperture (scaled by open_pct)
        ap_dia = (alu_plate_dia - 14) * sqrt(open_pct / 100.0);
        translate([0, 0, -1])
            cylinder(d = max(18, ap_dia), h = ring_h + 2);

        // Radial warm-air bypass channels under the plate
        for (a = [0 : 60 : 300]) {
            rotate([0, 0, a])
                translate([alu_plate_dia/2 - 6, 0, 1.8])
                    cube([16, 12, 3.6], center = true);
        }
    }
}

// ============================================================================
// 3. PART C: ZERO-CLOG 3D-PRINTED AIR-LIFT WATER PUMP & OXYGENATOR
// ============================================================================
// Uses a tiny 1.2W 5V USB air pump to lift nitrate-rich water from the
// shrimp/biochar floor up into the top plant basket while oxygenating water.
module part_airlift_tube() {
    tube_od = 10.0;
    tube_id = 6.8;
    lift_h  = vessel_h - 14.0;

    difference() {
        union() {
            // Intake strainer foot resting in LECA/Biochar bed
            cylinder(d = 18.0, h = 10.0);
            // Vertical riser pipe
            cylinder(d = tube_od, h = lift_h);
            // Air-line barb inlet at z = 14 mm
            translate([tube_od/2 - 1, 0, 14])
                rotate([0, 90, 0])
                    cylinder(d1 = 5.2, d2 = 4.2, h = 8.0);
            // Top gooseneck spout discharging into Hydro Basket
            translate([0, 0, lift_h])
                rotate([0, -65, 0])
                    cylinder(d = tube_od, h = 24.0);
        }

        // Main internal water riser bore
        translate([0, 0, 2.0])
            cylinder(d = tube_id, h = lift_h + 2);

        // Gooseneck bore
        translate([0, 0, lift_h])
            rotate([0, -65, 0])
                cylinder(d = tube_id, h = 26.0);

        // Air injection nozzle bore
        translate([0, 0, 14])
            rotate([0, 90, 0])
                cylinder(d = 2.2, h = 16.0);

        // Bottom shrimp-safe intake slots (1.5 mm wide so baby shrimp stay safe!)
        for (a = [0 : 45 : 315]) {
            rotate([0, 0, a])
                translate([6.5, 0, 4.5])
                    cube([8, 1.5, 5.0], center = true);
        }
    }
}

// ============================================================================
// 4. PART D: UPPER HYDROPONIC + WOLFFIA BASKET (NITRATE BIO-FILTER)
// ============================================================================
module part_hydro_basket() {
    basket_od = vessel_id - 1.2; // 108.8 mm slips smoothly inside glass rim
    basket_h  = 34.0;
    lip_od    = vessel_od + 2.0;

    difference() {
        union() {
            // Top resting rim on glass vessel edge
            translate([0, 0, basket_h - 3.0])
                cylinder(d = lip_od, h = 3.0);

            // Submerged root & Terra Preta cup body
            cylinder(d = basket_od, h = basket_h);

            // Central standpipe overflow weir (controls water level in basket)
            translate([-22, 0, 0])
                cylinder(d = 14.0, h = basket_h - 6.0);
        }

        // Hollow plant & Wolffia basin
        translate([0, 0, 2.2])
            cylinder(d = basket_od - 4.0, h = basket_h);

        // Overflow return drain bore
        translate([-22, 0, -1])
            cylinder(d = 9.5, h = basket_h);

        // Pass-through notch on rim for Air-Lift gooseneck & 5V LED cable
        translate([basket_od/2 - 4, 0, basket_h - 10])
            cylinder(d = 13.0, h = 14.0);

        // Root aeration & nutrient percolation slots on floor
        for (r = [14, 26, 38]) {
            n_holes = floor(r * 0.45);
            for (k = [0 : n_holes - 1]) {
                rotate([0, 0, k * (360 / n_holes)])
                    translate([r, 0, -1])
                        cylinder(d = 3.2, h = 5.0);
            }
        }
    }
}

// ============================================================================
// 5. PART E: TOP BIOSPHERE CLOCHE RING & LED HOLDER
// ============================================================================
module part_cloche_ring() {
    ring_od = vessel_od + 3.0;
    difference() {
        cylinder(d = ring_od, h = 14.0);
        // Bottom seat onto hydro basket lip
        translate([0, 0, -1])
            cylinder(d = vessel_od + 0.6, h = 7.0);
        // Top groove for borosilicate glass dome / cloche
        translate([0, 0, 8.0])
            cylinder(d = vessel_od + 0.8, h = 7.0);
        // Central light & gas-exchange aperture
        translate([0, 0, -1])
            cylinder(d = vessel_id - 6.0, h = 16.0);
        // 4 micro gas-exchange breathing ports (prevents CO2 starvation)
        for (a = [0 : 90 : 270]) {
            rotate([0, 0, a + 45])
                translate([ring_od/2, 0, 7.0])
                    rotate([0, 90, 0])
                        cylinder(d = 3.0, h = 10.0, center = true);
        }
    }
}

// ============================================================================
// FULL EXPLODED / ASSEMBLED VISUALIZATION
// ============================================================================
module full_assembly() {
    // 1. Bitaxe Cradle Base
    color("#2b211a") part_base_cradle();

    // 2. Simulated Bitaxe Gamma 601 PCB + Heatsink inside Cradle
    color("#111827")
        translate([0, 4, 12.5])
            cube([pcb_wid, pcb_len, pcb_thick], center = true);
    color("#f7931a")
        translate([0, 4, 24])
            cube([fan_size, fan_size, 20], center = true);

    // 3. Thermal Baffle + Aluminum Transfer Disc
    color("#475569")
        translate([0, 0, cradle_h - 3.5])
            part_thermal_baffle(baffle_open_pct);
    color("#cbd5e1")
        translate([0, 0, cradle_h + 0.5])
            cylinder(d = alu_plate_dia, h = alu_plate_thick);

    // 4. Transparent 1.35L Borosilicate Vessel + Water + Biochar Floor
    color("#1c1917")
        translate([0, 0, cradle_h + 2.5])
            cylinder(d = vessel_id - 1, h = 16); // Terra Preta + LECA biofilter
    color("#00ccff", 0.28)
        translate([0, 0, cradle_h + 18.5])
            cylinder(d = vessel_id - 1, h = vessel_h - 34); // 26.5°C Water
    color("#e0f2fe", 0.22)
        translate([0, 0, cradle_h + 2.0])
            difference() {
                cylinder(d = vessel_od, h = vessel_h);
                translate([0, 0, -1]) cylinder(d = vessel_id, h = vessel_h + 2);
            }

    // 5. Air-Lift Riser Tube
    color("#38bdf8")
        translate([vessel_id/2 - 11, 0, cradle_h + 4])
            part_airlift_tube();

    // 6. Upper Hydroponic + Wolffia Basket
    color("#1e293b")
        translate([0, 0, cradle_h + vessel_h - 31])
            part_hydro_basket();

    // 7. Living Greenery (Wolffia mat + emerging herbs)
    color("#44ee77")
        translate([0, 0, cradle_h + vessel_h - 2])
            cylinder(d = vessel_id - 8, h = 3.5);
    color("#22c55e")
        translate([12, 0, cradle_h + vessel_h + 15])
            sphere(d = 34);

    // 8. Top Cloche Ring & Dome
    color("#334155")
        translate([0, 0, cradle_h + vessel_h + 1])
            part_cloche_ring();
    color("#f8fafc", 0.18)
        translate([0, 0, cradle_h + vessel_h + 10])
            difference() {
                sphere(d = vessel_od);
                translate([0, 0, -vessel_od]) cube([vessel_od*2, vessel_od*2, vessel_od*2], center = true);
                sphere(d = vessel_id);
            }
}
