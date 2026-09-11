/* 3d-printable enclosure for MiniNDP - github.com/bkw777/NODE_DATAPAC */
// version: 003

// ------------------------------------------------------------------------------
// options

Customizer_Note = "";

// ------------------------------------------------------------------------------

plate_width = 61;                // 0.1
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
bus_fitment_clearance = 1.5;     // 0.1
bus_x = 4;                       // 0.1
bus_y = 0;                       // 0.1

bc = bus_fitment_clearance;
bt = bus_wall_thickness;
bw = bus_width + bc*2;
bd = bus_depth + bc*2;
bh = bus_height;

//bx = bus_x;
bx = pw/2-bw/2-bus_x+bc;
by = bus_y;

finger_pull_width = 19;         // 0.1

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

e = 0.01; // epsilon

// ---------------------------------------------------------------

module mirror_copy(v) {
 children();
 mirror(v) children();
}

module M10_bus_filler_plate () {

  th = bh + ph;

  difference() {
    group() {
      
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
      hull() {
        l = pd-5;
        translate([pw/2-0.3,0,-ph/2])
          rotate([90,0,0])
            cylinder(h=l,d=ph,center=true);
        translate([pw/2-3,0,ph/2])
          rotate([90,0,0])
            cylinder(h=l,d=ph,center=true);
      }

      // tunnel
      translate([bx,by,-bh+e])
        hull()
          mirror_copy([0,1,0])
            translate([0,bd/2,0])
              mirror_copy([1,0,0])
                translate([bw/2,0,0])
                  cylinder(h=bh,r=bt);

    }

    group() {
      // tunnel
      translate([bx,by,-th/2+ph])
        cube([bw,bd,th+2],center=true);

      // funnel
      translate([bx,by,-bh-bt/4])
        hull()
          mirror_copy([0,1,0])
            translate([0,bd/2-e,0])
              mirror_copy([1,0,0])
                translate([bw/2-e,0,0])
                  cylinder(h=bt,r1=bt,r2=0);

      // finger pull
      translate([finger_pull_width/2-pw/2+7,-pd/2,-ph/2])
        rotate([60,0,0])
          hull()
            mirror_copy([1,0,0])
              translate([finger_pull_width/2,0,0])
                cylinder(h=10,r=ph,center=true);
    }
  }
    
}

ry = $preview ? 0 : 180 ;
tz = $preview ? 0 : ph ;
translate([0,0,tz]) rotate([0,ry,0]) M10_bus_filler_plate();

