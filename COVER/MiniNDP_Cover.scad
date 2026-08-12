/* 3d-printable enclosure for MiniNDP - github.com/bkw777/NODE_DATAPAC */
// version: 002

// ------------------------------------------------------------------------------
// options

Customizer_Note = "";
PCB = "EZ1M"; // [EZ1M,EZ512,SL1M,OG,T512,M10,M10c]
loose_fit = false; // set true if FDM print is too tight

DEBUG_X = false;
debug_cut_x = 0;
DEBUG_Y = false;
debug_cut_y = 0;

// ------------------------------------------------------------------------------

low_profile =  // true for CR2016 , false for CR2032
        PCB=="M10" ? true :
        PCB=="M10c" ? true :
        PCB=="SL1M" ? true :
        PCB=="T512" ? true :
        PCB=="OG" ? true :
        false;

pcb_stl =
        PCB=="EZ512" ? "lib/pcb_EZ512.stl" :
        PCB=="M10" ? "lib/pcb_M10.stl" :
        PCB=="M10c" ? "lib/pcb_M10c.stl" :
        PCB=="T512" ? "lib/pcb_T512.stl" :
        PCB=="OG" ? "lib/pcb_OG.stl" :
        low_profile ? "lib/pcb_SL1M.stl" :
        "lib/pcb_EZ1M.stl";

// 0=auto
components_height = 0; // 0.1

ch = components_height ? components_height :
        low_profile ? 1.7 :
        4.1;

// PCB dimensions from KiCAD
pcb_thickness = 1.6;
pcb_corner_radius = 2;

pcblw = 
        PCB=="M10c" ? [31,56] :
        [34,60];

pcb_length = pcblw[0];
pcb_width = pcblw[1];

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

wall_thickness = 0.8;

// this is both the height of the wall above the pcb surface on the computer side,
// and the diameter of the cylinders that form the pcb retainer bumps
lip =
  PCB=="M10c" ? 0.9 :
  1.2;

// width of pcb tray ledge
ledge = 0.8;

// -1 = auto
fitment_clearance = -1 ; // 0.1
fc =
  fitment_clearance > -0.01 ? fitment_clearance :
  PCB=="M10c" ? 0.05 :
  loose_fit ? 0.2 :
  0.1;

o = 0.01; // overlap/overcut/overhang

// secondary/smaller fillet radius
sr = 1;   // 0.1

short_retainer_len = 10;
long_retainer_len = pcb_width/2;

finger_pull_length = 10;
finger_pull_height = 0.4;

// ---------------------------------------------------------------

assert(lip<=wall_thickness*2);
assert(finger_pull_height<=wall_thickness+fc+ledge);

inner_width = fc + pcb_width + fc;
inner_length = fc + pcb_length + fc;
inner_height = pcb_thickness + ch + fc;
outer_width = wall_thickness + inner_width + wall_thickness;
outer_length = wall_thickness + inner_length + wall_thickness;
outer_height = inner_height + wall_thickness;
outer_corner = pcb_corner_radius + fc;

// 0 = auto
outer_secondary_radius = 0 ; // 0.1
osr =
  outer_secondary_radius>0.01 ? outer_secondary_radius :
  PCB=="M10c" ? sr+wall_thickness+ledge :
  sr;

include <lib/handy.scad>;

module pcb_model () {
  import(pcb_stl);
}

module main_shell() {
 difference() {
  // add the main outer surface
  rounded_cube(w=outer_width,d=outer_length,h=outer_height*2,rh=pcb_corner_radius+fc+wall_thickness,rv=osr);

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
    translate([0,inner_length/2,-lip/2]) {
     rotate([0,90,0])
       cylinder(h=long_retainer_len,d=lip,center=true);
     //translate([0,lip/2-ledge,0]) rotate([0,90,0])
     //  cylinder(h=long_retainer_len,d=lip,center=true);
     //translate([0,lip-ledge,0]) cube([long_retainer_len,lip,lip],center=true);
     }
   if (PCB!="M10c") translate([0,-inner_length/2+1,-0.5])
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
 et = 0.2; // emboss thickness
 if (PCB=="M10c") {
  // Olivetti M-10 compact version
  w = 20*2.54;
  l = 2*2.54;
  translate([-w/2,-pcb_length/2+0.5,inner_height-et+o])
    cube([w,l,et]);
 } else {
  // normal version
   translate([0,-pcb_length/2+5,inner_height+o]) {
    rotate([0,180,0]) {
     linear_extrude(et) {
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
 }

 // add finger pulls
 translate([0,finger_pull_length/2-pcb_length/2+pcb_corner_radius,outer_height-finger_pull_height-osr])
  mirror_copy([1,0,0])
   translate([outer_width/2,0,0])
    hull() {
     mirror_copy([0,1,0])
      translate([0,finger_pull_length/2-finger_pull_height,0])
       sphere(finger_pull_height);
    }

}

difference() {
  dcw = outer_width+2;
  dcd = outer_length+2;
  dch = outer_height*2+2;
  main_shell();
  if ($preview) {
    if (DEBUG_X) translate([debug_cut_x,-dcd/2,-dch/2]) cube([dcw/2-debug_cut_x,dcd,dch]);
    if (DEBUG_Y) translate([-dcw/2,debug_cut_y,-dch/2]) cube([dcw,dcd/2-debug_cut_y,dch]);
  }
}

%pcb_model();

