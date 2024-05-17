/* 3d-printable enclosure for MiniNDP - github.com/bkw777/NODE_DATAPAC */
// version: 002


// ------------------------------------------------------------------------------
// customizable options

onemeg = false; // 1M board
lowprofile = false; // CR2016 instead of CR2032

parts_height = lowprofile ? 1.8 : 4.2;

pcb_stl = 
        onemeg ? "MiniNDP_1M.PCB.stl" :
        lowprofile ? "pcb_CR2016.stl" :
        "pcb_CR2032.stl";

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

wall_thickness = 0.8;

// This is both the height of the wall above the pcb surface on the computer side,
// and the diameter of the long thin cylinder that forms the grabber clip.
// Max is 1.5
lip = 1.2;
ledge = 0.8; // width of pcb rest ledge

fc = 0.2;  // fitment clearance
o = 0.01;  // overlap/overcut/overhang

// PCB dimensions from KiCAD
pcb_thickness = 1.6;
pcb_length = 34;
pcb_width = 60;
pcb_corner_radius = 2;

short_grabbers = 10;
long_grabbers = pcb_width/2;

// ---------------------------------------------------------------

fr = pcb_corner_radius + fc;  // fillet radius
inner_width = fc + pcb_width + fc;
inner_length = fc + pcb_length + fc;
inner_height = pcb_thickness + parts_height + fc;
outer_width = wall_thickness + inner_width + wall_thickness;
outer_length = wall_thickness + inner_length + wall_thickness;
outer_height = inner_height + wall_thickness;
outer_corner = fr + wall_thickness;

include <handy.scad>;

module pcb_model () {
  import(pcb_stl);
}

module main_shell() {
 difference() {
  // add the main outer surface
  rounded_cube(w=outer_width,d=outer_length,h=outer_height*2,rh=outer_corner,rv=outer_corner*0.75);

  union() {
   // cut outer rounded cube in half to leave a (solid) bathtub
   translate([0,0,-outer_height/2-lip])
    cube([1+outer_width+1,1+outer_length+1,outer_height],center=true);

   cz = inner_height + lip;
   // cut the pcb rest
   translate([0,0,-cz/2+pcb_thickness+fc]) rounded_cube(w=inner_width,d=inner_length,h=cz,rh=fr,rv=fc);
   // cut the main cavity
   // ledge
   rounded_cube(w=inner_width-ledge*2,d=inner_length-ledge*2,h=inner_height*2,rh=fr);
  }
 }
 
 // add the snap retainer lips on the long wall edges
  translate([0,inner_length/2,-lip/2]) rotate([0,90,0]) cylinder(h=long_grabbers,d=lip,center=true);

 // add the short grabbers on the bottom
 mirror_copy([1,0,0]) translate([inner_width/2,-inner_length/2-wall_thickness/2+short_grabbers/2,-lip/2])
  difference() {
   rotate([90,0,0]) cylinder(h=short_grabbers,d=lip,center=true);
   translate([lip/2+0.1,-short_grabbers/2,0]) rotate([0,0,45]) cube(lip*2,center=true);
  }
  
 // add graphic to show install orientation
 translate([0,-pcb_length/2+5,inner_height+o]) {
  h = 0.2;
  rotate([0,180,0]) {
   linear_extrude(h) {
    xy_array(xo=2.54,xc=20,yo=2.54,yc=2,center=true)
     circle(r=0.5);
    difference() {
     square([58.5,8.7],true);
      group () {
       translate([0,4,0]) square([4.5,8],true);
       square([56.3,6.4],true);
      }
    }
   }
  }
 }

}

// orient & position for printing
translate([0,0,outer_height]) rotate([180,0,0]) {
 main_shell();
 %pcb_model();
}