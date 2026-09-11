/* Filler plate & connector guide for bus connector on Olivetti M-10
   https://github.com/bkw777/NODE_DATAPAC

   This has 2 purposes:
   * prevent off-by-one pin misalingment when installing MiniNDP
   * fill the opening to take the place of the open door

 */

plate_width = 61.3;              // 0.1
plate_depth = 30;                // 0.1
plate_thickness = 2;             // 0.1
plate_fitment_clearance = 0.2;   // 0.1

pc = plate_fitment_clearance;
pw = plate_width - pc*2;
pd = plate_depth - pc*2;
ph = plate_thickness;

bus_width = 51;                  // 0.1
bus_depth = 5.1;                 // 0.1
bus_height = 12;                 // 0.1
bus_wall_thickness = 2;          // 0.1
bus_fitment_clearance = 1.2;     // 0.1
bus_x = 3.8;                     // 0.1
bus_y = 0;                       // 0.1
bus_base_chamfer = 1.5;          // 0.1
bus_funnel = 1.5;                // 0.1

bc = bus_fitment_clearance;
bt = bus_wall_thickness;
bw = bus_width + bc*2;
bd = bus_depth + bc*2;
bh = bus_height;
bch = bt + bus_base_chamfer;

bx = pw/2-bw/2-bus_x+bc;
by = bus_y;

finger_pull_width = 19;         // 0.1
finger_pull_x = 7;              // 0.1
finger_pull_angle = 30;
finger_pull_height = 1.5;       // 0.1

inboard_retainer_x_adj = -0.4;  // 0.1

th = bh + ph; // total height

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

e = 0.01; // epsilon

// ---------------------------------------------------------------

module mirror_copy(v) {
  children();
  mirror(v) children();
}

module c4 (w,d,h,r,r1,r2) {
  ra = r ? r : r1;
  rb = r ? r : r2;
  hull()
    mirror_copy([0,1,0])
      translate([0,d/2,0])
        mirror_copy([1,0,0])
          translate([w/2,0,0])
            cylinder(h=h,r1=ra,r2=rb);
}

module M10_bus_filler_plate () {

  difference() {
    group() {

      // the main plate is rounded on the outboard edge
      // to snap under the lip on that side of the opening

      // plate
      hull() {
        // main plate
        translate([0,0,ph/2])
          cube([pw,pd,ph],center=true);
        // outboard retainer
        translate([-pw/2,0,ph/2])
          rotate([90,0,0])
            cylinder(h=pd,d=ph,center=true);
      }
      
      // inboard retainer
      translate([inboard_retainer_x_adj,0,0]) // nudge the whole thing in so the angled wall intersects the vertical at the bottm edge
      hull() {
        l = pd-5;
        translate([pw/2,0,-ph/2])
          rotate([90,0,0])
            cylinder(h=l,d=ph,center=true);
        translate([pw/2-ph,0,ph/2])
          rotate([90,0,0])
            cylinder(h=l,d=ph,center=true);
      }

      // tunnel
      translate([bx,by,0]) {
        translate([0,0,-bh+e])
        c4(w=bw,d=bd,h=bh,r=bt);

        // tunnel base chamfer
        difference() {
          // add chamfer
          translate([0,0,-bch+e])
            c4(w=bw,d=bd,h=bch,r1=0,r2=bch);
          // cut the edge off that pokes out the end
          translate([bch/2+1+bw/2+bt-e,0,0])
            cube([bch+2,bd+bch*2+2,bch+2],center=true);
       }
      }
     
    }

    group() {
      // tunnel
      translate([bx,by,-th/2+ph])
        cube([bw,bd,th+2],center=true);

      // funnel
      translate([bx,by,-bh-bt+bus_funnel])
        c4(w=bw,d=bd,h=bt,r1=bt+e,r2=0);

      // finger pull
      translate([finger_pull_width/2-pw/2+finger_pull_x,-pd/2,finger_pull_height])
        rotate([90-finger_pull_angle,0,0])
        translate([0,-ph,-3])
          hull()
            mirror_copy([1,0,0])
              translate([finger_pull_width/2,0,0])
                cylinder(h=8,r=ph,center=true);
    }
  }
    
}

// reorient for printing
ry = $preview ? 0 : 180 ;
tz = $preview ? 0 : ph ;
translate([0,0,tz]) rotate([0,ry,0]) M10_bus_filler_plate();
