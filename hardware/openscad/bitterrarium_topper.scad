// ============================================================================
// BITTERRARIUM v1.0 — 17W BITAXE SNAP-ON DRY CLOCHE BIOSPHERE TOPPER
// Regenerative Compute (regenerativecompute.org | regenerativecompute.io)
// Author: Pascal Ranoroarijaona (Ranaora) — Sydney Tech Central (2026)
// License: CERN-OHL-P v2 / MIT Open Hardware Commons
// ============================================================================
// HARDWARE TARGET:
// - Bitaxe Gamma 601 (PCB: 99.76 x 56.54 x 1.6 mm, BM1370 ASIC, 17W, 40mm fan)
// - Dish: 150 mm anodized aluminum saucer (1.2 - 1.5 mm thick)
// - Dome: 150 mm OD borosilicate glass cloche bell jar
// - Thermal Split: ~35% (~6 Wth) warms Terra Preta moss bed to 27.5°C;
//   ~65% vents laterally so BM1370 ASIC stays < 54°C.
// ============================================================================

PART_TO_RENDER = "assembly"; // "assembly", "cradle", "gutter_ring", "led_crown"

pcb_len       = 99.76;
pcb_wid       = 56.54;
pcb_thick     = 1.60;
clearance     = 0.35;
saucer_od     = 150.0;
cloche_od     = 146.0;
wall          = 2.4;
cradle_h      = 50.0;
bypass_pct    = 65;   // Lateral hot-air bypass % (keeps ASIC cool & moss < 29°C)
$fn           = 80;

if (PART_TO_RENDER == "assembly") {
    bt_assembly();
} else if (PART_TO_RENDER == "cradle") {
    bt_cradle();
} else if (PART_TO_RENDER == "gutter_ring") {
    bt_condensation_gutter();
} else if (PART_TO_RENDER == "led_crown") {
    bt_led_crown();
}

module bt_cradle() {
    base_od = saucer_od + 6.0;
    difference() {
        union() {
            // Tapered architectural plinth (Shou-Sugi-Ban / fluted style)
            cylinder(d1 = base_od + 8, d2 = base_od, h = cradle_h);
            // Angled front visor for 0.91" Bitaxe OLED screen
            translate([0, -base_od/2 + 1, 16])
                rotate([24, 0, 0])
                    cube([36, 12, 20], center = true);
        }

        // Internal warm-air plenum
        translate([0, 0, wall])
            cylinder(d1 = base_od - 2*wall, d2 = saucer_od - 8, h = cradle_h + 2);

        // Slide-in Bitaxe Gamma 601 slot from rear (Y+)
        sw = pcb_wid + 2*clearance;
        sl = pcb_len + 2*clearance;
        translate([-sw/2, -sl/2 + 6, 10])
            cube([sw, sl + 35, 32]);
        translate([-(sw + 2.4)/2, -sl/2 + 6, 12])
            cube([sw + 2.4, sl + 35, pcb_thick + 0.5]);

        // Front 0.91" OLED window
        translate([0, -base_od/2 - 1, 16])
            rotate([24, 0, 0])
                cube([28, 22, 13], center = true);

        // Cool intake louvers (bottom)
        for (a = [30 : 45 : 330]) {
            rotate([0, 0, a])
                translate([base_od/2, 0, 7])
                    cube([16, 14, 6], center = true);
        }

        // Lateral thermal bypass exhaust slots (sized by bypass_pct)
        slot_h = 4.0 + (bypass_pct / 100.0) * 6.0;
        for (a = [0 : 45 : 315]) {
            rotate([0, 0, a + 22.5])
                translate([base_od/2 - 2, 0, cradle_h - 10])
                    cube([16, 18, slot_h], center = true);
        }

        // Top seat for 150 mm Anodized Aluminum Saucer
        translate([0, 0, cradle_h - 3.5])
            cylinder(d = saucer_od + 0.8, h = 5.0);
    }
}

// Internal condensation return ring: catches water droplets rolling down
// the inside of the glass cloche and channels them into the biochar bed.
module bt_condensation_gutter() {
    difference() {
        cylinder(d = saucer_od - 1.0, h = 12.0);
        translate([0, 0, -1])
            cylinder(d = cloche_od - 8.0, h = 15.0);
        // V-groove seat for 146mm borosilicate glass cloche rim
        translate([0, 0, 5.0])
            difference() {
                cylinder(d = cloche_od + 1.2, h = 8.0);
                cylinder(d = cloche_od - 4.2, h = 8.0);
            }
        // 8 inward weep channels directing condensed rain into moss
        for (a = [0 : 45 : 315]) {
            rotate([0, 0, a])
                translate([cloche_od/2 - 3, 0, 5.0])
                    rotate([0, -25, 0])
                        cube([10, 3.0, 4.0], center = true);
        }
    }
}

module bt_led_crown() {
    difference() {
        cylinder(d = 54.0, h = 8.0);
        translate([0, 0, 2.0]) cylinder(d = 48.0, h = 7.0);
        translate([0, 0, -1]) cylinder(d = 22.0, h = 10.0);
    }
}

module bt_assembly() {
    color("#d97706") bt_cradle();
    // Aluminum conduction dish
    color("#cbd5e1") translate([0, 0, cradle_h - 3.0]) cylinder(d = saucer_od, h = 2.0);
    // Condensation gutter
    color("#334155") translate([0, 0, cradle_h - 1.0]) bt_condensation_gutter();
    // Terra Preta Biochar + Moss hemisphere
    color("#1c1917") translate([0, 0, cradle_h]) cylinder(d = cloche_od - 10, h = 18);
    color("#22c55e") translate([0, 0, cradle_h + 18]) resize([120, 120, 45]) sphere(d = 100);
    // Borosilicate Cloche Dome
    color("#e0f2fe", 0.22)
        translate([0, 0, cradle_h + 4])
            difference() {
                union() {
                    cylinder(d = cloche_od, h = 75);
                    translate([0, 0, 75]) sphere(d = cloche_od);
                }
                translate([0, 0, -1]) cylinder(d = cloche_od - 4, h = 76);
                translate([0, 0, 75]) sphere(d = cloche_od - 4);
                translate([0, 0, -80]) cube([300, 300, 160], center = true);
            }
}
