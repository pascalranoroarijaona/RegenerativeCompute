// ============================================================================
// BITPLANT v1.0 — CANAAN AVALON NANO 3S (140W) HYDROPONIC THERMAL MANIFOLD
// Regenerative Compute (regenerativecompute.org | regenerativecompute.io)
// Author: Pascal Ranoroarijaona (Ranaora) — Sydney Tech Central (2026)
// License: CERN-OHL-P v2 / MIT Open Hardware Commons
// ============================================================================
// EXACT HARDWARE SPECS:
// - Canaan Avalon Nano 3S: 205.0 x 115.0 x 58.5 mm, 6 TH/s, 140W, 33-40 dB
// - Outlet Exhaust Shroud -> Rotary Summer/Winter Damper -> 100mm Duct Spigot
// - Feeds warm air (42-48°C) under AC Infinity 72-Cell Dome / NFT Hydro Tray
//   or pre-dries agricultural biomass for Terra Preta Biochar!
// ============================================================================

PART_TO_RENDER = "assembly"; // "assembly", "exhaust_hood", "rotary_damper", "tray_diffuser"

nano_w        = 205.0;   // Exact Avalon Nano 3S width
nano_d        = 115.0;   // Exact Avalon Nano 3S depth
nano_h        = 58.5;    // Exact Avalon Nano 3S height
fit_tol       = 0.60;    // Slip-on gasket clearance
wall          = 2.6;
hood_depth    = 36.0;    // Overlap onto Nano 3S exhaust face
transition_l  = 95.0;    // Aerodynamic transition to 100mm round duct
duct_od       = 99.0;    // Fits standard 100mm (4") insulated flex duct
damper_angle  = 20;      // 0 deg = 100% to Hydroponics | 90 deg = Summer Bypass
$fn           = 72;

if (PART_TO_RENDER == "assembly") {
    bp_assembly();
} else if (PART_TO_RENDER == "exhaust_hood") {
    bp_exhaust_hood();
} else if (PART_TO_RENDER == "rotary_damper") {
    bp_rotary_damper();
} else if (PART_TO_RENDER == "tray_diffuser") {
    bp_tray_diffuser();
}

// Part A: Aerodynamic Collector Hood snapping onto Avalon Nano 3S exhaust
module bp_exhaust_hood() {
    in_w = nano_w + 2 * fit_tol;
    in_h = nano_h + 2 * fit_tol;
    out_w = in_w + 2 * wall;
    out_h = in_h + 2 * wall;

    difference() {
        union() {
            // Rectangular slip-on collar around Avalon Nano 3S
            translate([-out_w/2, -out_h/2, 0])
                cube([out_w, out_h, hood_depth]);

            // Smooth lofted transition from 205x58.5mm rectangle to 100mm circle
            hull() {
                translate([-out_w/2, -out_h/2, hood_depth - 1])
                    cube([out_w, out_h, 1]);
                translate([0, 0, hood_depth + transition_l])
                    cylinder(d = duct_od + 2*wall, h = 1);
            }

            // 100mm Duct Spigot Collar + Summer Bypass T-Branch
            translate([0, 0, hood_depth + transition_l])
                cylinder(d = duct_od, h = 42.0);

            // Lateral Summer Bypass Exhaust Port (Ø70mm)
            translate([0, 0, hood_depth + transition_l + 20])
                rotate([-90, 0, 0])
                    cylinder(d = 70.0, h = 62.0);

            // DS18B20 Temperature Sensor Boss (12mm port)
            translate([duct_od/2 - 2, 0, hood_depth + transition_l + 18])
                rotate([0, 90, 0])
                    cylinder(d = 14.0, h = 12.0);
        }

        // Hollow slip-on pocket for Nano 3S chassis
        translate([-in_w/2, -in_h/2, -1])
            cube([in_w, in_h, hood_depth + 1]);

        // Internal aerodynamic loft cavity
        hull() {
            translate([-(in_w - 4)/2, -(in_h - 4)/2, hood_depth - 0.5])
                cube([in_w - 4, in_h - 4, 1]);
            translate([0, 0, hood_depth + transition_l + 0.5])
                cylinder(d = duct_od - 2*wall, h = 1);
        }

        // Main 100mm duct bore
        translate([0, 0, hood_depth + transition_l - 1])
            cylinder(d = duct_od - 2*wall, h = 46.0);

        // Summer bypass bore
        translate([0, 0, hood_depth + transition_l + 20])
            rotate([-90, 0, 0])
                cylinder(d = 65.0, h = 66.0);

        // Damper axle shaft holes (6.2mm)
        translate([0, 0, hood_depth + transition_l + 20])
            rotate([0, 90, 0])
                cylinder(d = 6.2, h = duct_od + 20, center = true);

        // DS18B20 probe bore (6.5mm)
        translate([duct_od/2 - 8, 0, hood_depth + transition_l + 18])
            rotate([0, 90, 0])
                cylinder(d = 6.5, h = 24.0);
    }
}

// Part B: Butterfly / Rotary Thermal Damper Valve
module bp_rotary_damper() {
    disc_d = duct_od - 2*wall - 1.6;
    union() {
        cylinder(d = disc_d, h = 2.4, center = true);
        rotate([0, 90, 0])
            cylinder(d = 5.8, h = duct_od + 26, center = true);
        // External thumb dial lever
        translate([duct_od/2 + 12, 0, 0])
            cube([4, 24, 8], center = true);
    }
}

// Part C: Under-Tray Warm Air Diffuser Plenum (fits 540x280mm 72-cell Hydro Tray)
module bp_tray_diffuser() {
    plenum_w = 240.0; // Modular half-tray diffuser block (print 1 or 2)
    plenum_l = 240.0;
    plenum_h = 48.0;

    difference() {
        union() {
            translate([-plenum_w/2, -plenum_l/2, 0])
                cube([plenum_w, plenum_l, plenum_h]);
            // 100mm inlet collar on side
            translate([0, -plenum_l/2, plenum_h/2])
                rotate([90, 0, 0])
                    cylinder(d = duct_od, h = 28.0);
        }
        translate([-(plenum_w - 2*wall)/2, -(plenum_l - 2*wall)/2, wall])
            cube([plenum_w - 2*wall, plenum_l - 2*wall, plenum_h - 2*wall]);

        // Side inlet bore
        translate([0, -plenum_l/2 + 4, plenum_h/2])
            rotate([90, 0, 0])
                cylinder(d = duct_od - 2*wall, h = 36.0);

        // Top even-heat distribution matrix (keeps root zone uniform at 25°C)
        for (gx = [-85 : 34 : 85], gy = [-85 : 34 : 85]) {
            translate([gx, gy, plenum_h - wall - 1])
                cylinder(d = 12.0, h = wall + 3);
        }

        // Bottom 6mm condensate drain weep hole
        translate([plenum_w/2 - 15, plenum_l/2 - 15, -1])
            cylinder(d = 6.0, h = wall + 3);
    }
}

module bp_assembly() {
    // Simulated Avalon Nano 3S Miner Body
    color("#1e293b")
        translate([-nano_w/2, -nano_h/2, -nano_d + hood_depth - 5])
            cube([nano_w, nano_h, nano_d]);

    // Exhaust Manifold Hood
    color("#f7931a") bp_exhaust_hood();

    // Rotary Damper inside Manifold
    color("#44ee77")
        translate([0, 0, hood_depth + transition_l + 20])
            rotate([damper_angle, 0, 0])
                bp_rotary_damper();

    // Under-Tray Hydroponic Diffuser (shown offset above)
    color("#0ea5e9", 0.85)
        translate([0, 0, hood_depth + transition_l + 95])
            bp_tray_diffuser();
}
