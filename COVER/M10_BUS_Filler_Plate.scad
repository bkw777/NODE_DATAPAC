/* Filler plate & connector guide for bus connector on Olivetti M-10
   https://github.com/bkw777/NODE_DATAPAC

   This has 2 purposes:
   * prevent off-by-one pin misalingment when installing MiniNDP
   * fill the opening to take the place of the open door

 */

plate_width = 61.2;              // 0.1
plate_depth = 30;                // 0.1
plate_thickness = 2;             // 0.1
pt = plate_thickness;

fitment_clearance = 0.2;         // 0.1
fc = fitment_clearance;

pw = plate_width - fc*2;
pd = plate_depth - fc*2;

wt = pt;  // wall thickness

bus_width = 51;                  // 0.1
bus_depth = 5.1;                 // 0.1
// long as possible without touching the motherboard pcb, float 1mm away from pcb
bus_height = 12;                 // 0.1
// distance bus connector edge to door hinge
bus_x = 3.8;                     // 0.1

// large as possible without allowing the connector to be off by one pin, slightly less than 1/2 of 2.54mm pin pitch
bus_fitment_clearance = 1.2;     // 0.1
bfc = bus_fitment_clearance;

bus_base_chamfer = 1.5;          // 0.1  // intentionally not dynamic, not based on wall thickness etc
bus_funnel = wt*0.8;

bw = bus_width + bfc*2;
bd = bus_depth + bfc*2;
bh = bus_height;
bch = wt + bus_base_chamfer;

bx = pw/2-bw/2-bus_x+bfc;


include_finger_pull = false;
finger_pull_width = 19;         // 0.1
finger_pull_x = 7;              // 0.1
finger_pull_angle = 30;
finger_pull_height = pt*0.75;   // 0.1

// adjust the X position of the 45 deg plane so it meets the vertical plane near the bottom edge corner of the top plate
inboard_retainer_x_adj = -(pt*0.2);  // 0.1

th = bh + pt; // total height

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

e = 0.01; // epsilon

// ---------------------------------------------------------------

use <lib/handy.scad>;

module M10_bus_filler_plate () {

  difference() {
  
  // ADD
    group() {

      // the main plate is rounded on the outboard edge
      // to snap under the lip on that side of the opening

      // plate
      hull() {
        // main plate
        translate([0,0,pt/2])
          cube([pw,pd,pt],center=true);
        // outboard retainer
        translate([-pw/2,0,pt/2])
          rotate([90,0,0])
            cylinder(h=pd,d=pt,center=true);
      }
      
      // inboard retainer
      translate([inboard_retainer_x_adj,0,0]) // nudge the whole thing in so the angled wall intersects the vertical at the bottm edge
      hull() {
        translate([pw/2,0,-pt/2])
          rotate([90,0,0])
            cylinder(h=pd,d=pt,center=true);
        translate([pw/2-pt,0,pt/2])
          rotate([90,0,0])
            cylinder(h=pd,d=pt,center=true);
      }

      // tunnel
      translate([bx,0,0]) {
        translate([0,0,-bh/2+e])
        rcube([bw+wt*2,bd+wt*2,bh],rh=wt);

        // tunnel base chamfer
        difference() {
          // add chamfer
          translate([0,0,-bch/2+e])
            sqyl(w=bw+bch*2,d=bd+bch*2,h=bch,r1=0,r2=bch);
          // cut the edge off that pokes out the end
          translate([bch/2+1+pw/2-bx-e,0,0])
            cube([bch+2,bd+bch*2+2,bch+2],center=true);
       }
      }
     
    }

  // CUT
    group() {
      translate([bx,0,0]) {
        // tunnel
        translate([0,0,-th/2+pt])
          cube([bw,bd,th+2],center=true);

        // funnel
        translate([0,0,-bh-wt/2+bus_funnel])
          sqyl(w=bw+wt*2+e*2,d=bd+wt*2+e*2,h=wt,r1=wt+e,r2=0);
      }

      // finger pull
      if (include_finger_pull)
        translate([finger_pull_width/2-pw/2+finger_pull_x,-pd/2,finger_pull_height])
          rotate([90-finger_pull_angle,0,0])
            translate([0,-pt,-3])
              hull()
                mirror_copy([1,0,0])
                  translate([finger_pull_width/2,0,0])
                    cylinder(h=8,r=pt,center=true);
    }
  }
    
}

// reorient for printing
ry = $preview ? 0 : 180 ;
tz = $preview ? 0 : pt ;
translate([0,0,tz]) rotate([0,ry,0]) M10_bus_filler_plate();
