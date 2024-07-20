/* 3d-printable enclosure for MiniNDP - github.com/bkw777/NODE_DATAPAC */
// version: 002

// ------------------------------------------------------------------------------
// options

old_pcb_shape = false; // first few versions of PCB had 1mm corner radius
low_profile = false; // true for CR2016 , false for CR2032
loose_fit = false; // true if FDM print is too tight

// ------------------------------------------------------------------------------

//pcb_stl = "pcb_1M.stl"; assert(!low_profile);
//pcb_stl = "pcb_512_B.stl"; assert(!low_profile);
pcb_stl = low_profile ? "pcb_CR2016.stl" : "pcb_CR2032.stl";

parts_height = low_profile ? 1.8 : 4.2;

// PCB dimensions from KiCAD
pcb_thickness = 1.6;
pcb_length = 34;
pcb_width = 60;
pcb_corner_radius = old_pcb_shape ? 1 : 2;

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

wall_thickness = 0.8;

// this is both the height of the wall above the pcb surface on the computer side,
// and the diameter of the cylinders that form the pcb retainer bumps
lip = 1.2;

// width of pcb tray ledge
ledge = 0.8;

fc = loose_fit ? 0.2 : 0.1; // fitment clearance
o = 0.01; // overlap/overcut/overhang

sr = 1;   // secondary/smaller fillet radius

short_retainer_len = 10;
long_retainer_len = pcb_width/2;

finger_pull_length = 10;
finger_pull_height = 0.4;

// ---------------------------------------------------------------

assert(lip<=wall_thickness*2);
assert(finger_pull_height<=wall_thickness+fc+ledge);

inner_width = fc + pcb_width + fc;
inner_length = fc + pcb_length + fc;
inner_height = pcb_thickness + parts_height + fc;
outer_width = wall_thickness + inner_width + wall_thickness;
outer_length = wall_thickness + inner_length + wall_thickness;
outer_height = inner_height + wall_thickness;
outer_corner = pcb_corner_radius + fc;

include <handy.scad>;

module pcb_model () {
  import(pcb_stl);
}

module main_shell() {
 difference() {
  // add the main outer surface
  // not using the thickness param on purpose because
  // we want different thickness for the walls vs the face
  // and smaller exterior corner radius than would be possible with the full wall thickness
  rounded_cube(w=outer_width,d=outer_length,h=outer_height*2,rh=pcb_corner_radius+fc+wall_thickness,rv=sr);

  union() {
   // cut outer shell in half to leave a (solid) bathtub
   translate([0,0,-outer_height/2-lip])
    cube([1+outer_width+1,1+outer_length+1,outer_height],center=true);

   // cut the main cavity
   rh = (pcb_corner_radius-ledge<sr) ? sr : pcb_corner_radius-ledge ;
   rounded_cube(w=pcb_width-ledge*2,d=pcb_length-ledge*2,h=inner_height*2,rh=rh,rv=sr);

   // cut the pcb tray
   cz = inner_height + lip;
   translate([0,0,-cz/2+pcb_thickness+fc])
    rounded_cube(w=inner_width,d=inner_length,h=cz,rh=pcb_corner_radius+fc,rv=fc);
  }
 }
 
 // add the top & bottom PCB grabbers
  difference () {
   mirror_copy([0,1,0])
    translate([0,inner_length/2,-lip/2])
     rotate([0,90,0])
      cylinder(h=long_retainer_len,d=lip,center=true);
   translate([0,-inner_length/2+1,-0.5])
    cylinder(h=2,r=1,center=true);
  }

 // add the short PCB grabbers on the bottom left & right
 mirror_copy([1,0,0])
  translate([inner_width/2,-inner_length/2-wall_thickness/2+short_retainer_len/2,-lip/2])
   difference() {
    rotate([90,0,0])
     cylinder(h=short_retainer_len,d=lip,center=true);
    translate([lip/2+0.1,-short_retainer_len/2,0])
     rotate([0,0,45])
      cube(lip*2,center=true);
   }
  
 // add embossed graphic of the 2x20 IDC connector
 // to the inside face to show install orientation
 translate([0,-pcb_length/2+5,inner_height+o]) {
  h = 0.2; // emboss height
  rotate([0,180,0]) {
   linear_extrude(h) {
    xy_array(xo=2.54,xc=20,yo=2.54,yc=2,center=true)
     square(0.64,true); // circle(0.32);
    difference() {
     square([58.5,8.7],true);
     group () {
      translate([0,4,0])
       square([4.5,8],true);
      square([56.3,6.4],true);
     }
    }
   }
  }
 }

 // add finger pulls
 translate([0,finger_pull_length/2-pcb_length/2+pcb_corner_radius,outer_height-finger_pull_height-sr])
  mirror_copy([1,0,0])
   translate([outer_width/2,0,0])
    hull() {
     mirror_copy([0,1,0])
      translate([0,finger_pull_length/2-finger_pull_height,0])
       sphere(finger_pull_height);
    }

}

// orient & position for printing
translate([0,0,outer_height]) rotate([180,0,0]) {
 main_shell();
 %pcb_model();
}