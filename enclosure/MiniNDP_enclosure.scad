/* 3d-printable enclosure for MiniNDP - github.com/bkw777/NODE_DATAPAC */
// version: 001

// print with no supports

// customizable options

//parts_height = 2; // thin card with CR2016 and short C1 cap
parts_height = 4.5; // thick card with CR2032

// arc smoothness - comment both out before importing into FreeCAD
$fs = 0.2;
$fa = 1;

fc = 0.2;  // fitment clearance

// for more solid case, make this 1
wall_thickness = 0.8;

pcb_thickness = 1.6;
pcb_length = 34;
pcb_width = 60;
pcb_corner_radius = 1;

// can go up to 1.5 for more solid grab
lip = 1; // height of wall above pcb, diameter of snap retainers

corner = 10; // size of pcb resting posts in corners

// export from KiCAD
pcb_stl = "pcb.stl";

// ---------------------------------------------------------------

fr = pcb_corner_radius + fc;  // fillet radius
inner_width = fc + pcb_width + fc;
inner_length = fc + pcb_length + fc;
inner_height = pcb_thickness + parts_height + fc;
outer_width = wall_thickness + inner_width + wall_thickness;
outer_length = wall_thickness + inner_length + wall_thickness;
outer_height = wall_thickness + inner_height + wall_thickness;
outer_corner = fr + wall_thickness;

include <handy.scad>;

module pcb_model () {
  import(pcb_stl);
}

module main_shell() {
 difference() {
  // add the main outer surface
  rounded_cube(w=outer_width,d=outer_length,h=outer_height*2,rh=outer_corner);

  union() {
   // cut outer rounded cube in half to leave a (solid) bathtub
   translate([0,0,-outer_height/2-lip])
    cube([1+outer_width+1,1+outer_length+1,outer_height],center=true);

   cz = inner_height + lip;
   // cut the pcb tray
   translate([0,0,-cz/2+pcb_thickness+fc]) rounded_cube(w=inner_width,d=inner_length,h=cz,rh=fr,rv=fc);
   // cut the main cavity
   hull() {
    rounded_cube(w=inner_width,d=inner_length-corner,h=inner_height*2,rh=fr);
    rounded_cube(w=inner_width-corner,d=inner_length,h=inner_height*2,rh=fr);
   }
  }
 }
 
 // add the snap retainer lips on the long wall edges
 mirror_copy([0,1,0]) translate([0,inner_length/2,-lip/2]) rotate([0,90,0]) cylinder(h=20,d=lip,center=true);
}

// orient & position for printing
translate([0,0,outer_height]) rotate([180,0,0]) {
 main_shell();
 %pcb_model();
}