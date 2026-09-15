// b.kenyon.w@gmail.com
// fillets and handy things made from fillets
// mirror, array

/*
   screw_post(h=10,od=6,id=3,fr=2,ch=0,o=0)

     cylindrical screw post with filleted base

     h = height
     od = main cylinder OD
     id = screw hole ID - default no hole
     fr = base fillet radius
     ch = screw hole chamfer depth - default no chamfer
     o = fillet ID shrink offset - usually unset

   rcube([w,d,h],rh=0,rv=0,t=0)

     draws a cube with rounded corners

     rh = horizontal radius
     rv = vertical radius
     t = wall thickness - if set, makes a hollow box

   fillet_polar(o=false,R=1,r=1,A=90,a=90,as=0)

     creates both internal and external radial fillets
     used to create screw_post() and rounded_cube()
  
     o = outside true/false - default false (inside/concave)
     R = big radius
     r = small radius
     A = big angle
     a = small angle
     as = small angle start angle

   fillet_linear(o=false,l=1,r=1,a=90)
   
     o = outside - true/false - default false (inside/concave)
     l = length
     r = radius
     a = angle

*/

//$fs = 0.5;
//$fa = 1;
//$fn = 96;
//$fn = 72;
//$fn = 36;
//$fn = 12;

// examples:
//translate([60,0,0]) screw_post(h=10,od=6,id=3,fr=2,ch=0.6);
//difference() { rcube([70,55,25],rh=3,rv=1,t=2); translate([0,-40,0]) cube([40,40,20]); }
//difference() { rcube([70,55,25],rh=3,rv=1); translate([0,-40,0]) cube([40,40,20]); }
//fillet_linear(l=40);
//fillet_polar(R=2,r=1);

module screw_post (h=10,od=6,id=0,fr=2,o=0,ch=0) {
 x = (o) ? o : ($fn>=3) ? 0 : 0.025;
 difference() {
  union(){
   translate([0,0,h/2]) cylinder(h=h,d=od,center=true);
   translate([0,0,fr+x]) fillet_polar(R=-od/2+x,r=fr+x,A=360,as=90);
  }
  if(id>0) {
   translate([0,0,h/2]) cylinder(h=h+0.1,d=id,center=true);
   if(ch) translate([0,0,h-id/2-ch]) cylinder(h=od/2,d1=0,d2=od);
  }
 }
}

module rcube (v,rh=0,rv=0,t=0) {
  vt = [v[0]+t*2,v[1]+t*2,v[2]+t*2];
  ve = (t>0)?vt:v;
  vi = (t>0)?v:vt;
  rhe = (t>0)?rh+t:rh;
  rhi = (t>0)?rh:rh+t;
  rve = (t>0)?rv+t:rv;
  rvi = (t>0)?rv:rv+t;

  if (rh==0&&rv==0) {
    // plain cube
    if(t) difference() {
      cube(ve,center=true);
      cube(vi,center=true);
    }
    else cube(ve,center=true);
  }
  else if (rv==0) {
    // rounded plate
    if(t) difference() {
      sqyl(w=ve[0],d=ve[1],h=ve[2],r=rhe);
      sqyl(w=vi[0],d=vi[1],h=vi[2],r=rhi);
    }
    else sqyl(w=ve[0],d=ve[1],h=ve[2],r=rhe);
  } else {
    // rounded cube
    if(t) difference() {
      _hbrc(w=ve[0],d=ve[1],h=ve[2],rh=rhe,rv=rve);
      _hbrc(w=vi[0],d=vi[1],h=vi[2],rh=rhi,rv=rvi);
    }
  else _hbrc(w=ve[0],d=ve[1],h=ve[2],rh=rhe,rv=rve);
  }
}

module _hbrc (w=60,d=40,h=20,rh=2,rv=1) { // rounded cube
 hull() {
  mirror_copy([0,0,1])
   mirror_copy([0,1,0])
    mirror_copy([1,0,0])
     translate([w/2-rh,d/2-rh,h/2-rv])
      fillet_polar(o=true,R=rh,r=rv);
 }
}

module fillet_polar (o=false,R=1,r=1,A=90,a=90,as=0) {
 rotate_extrude(angle=A)
  translate([R-r,0,0])
   rotate([0,0,-as])
    _hbf(o,r,a);
}

module fillet_linear (o=false,l=1,r=1,a=90) {
 linear_extrude(height=l)
  _hbf(o,r,a);
}

module _hbf (o=false,r=1,a=90) { // 2d fillet
 if(o) intersection() { circle(r=r); _hbw(r=r,a=a); }
 else difference() { _hbw(r=r,a=a); circle(r=r); }
}

module _hbw (r=1,a=90) { // 2d wedge polygon
  polygon([ [0,0], [0,r], [r*tan(a/2),r], [r*sin(a),r*cos(a)] ]);
}

module mirror_copy (v) {
 children();
 mirror(v) children();
}

module xy_array (xo=10,xc=4,yo=10,yc=2,center=false) {
 xe = (xc-1)*xo;
 ye = (yc-1)*yo;
 tx = center ? -xe/2 : 0;
 ty = center ? -ye/2 : 0;
 translate([tx,ty,0])
 for (i=[0:xo:xe]) {
  for (j=[0:yo:ye]) {
    translate([i,j,0])
     children();
  }
 }
}

// square cylinder
// with r = straight walls
// with r1 & r2 = sloped walls
module sqyl (w=0,d=0,h=0,r=0,r1=-1,r2=-1) {
 ra = (r1<0) ? r : r1 ;
 rb = (r2<0) ? r : r2 ;
 R = max(ra,rb);
 hull()
   mirror_copy([0,1,0])
     mirror_copy([1,0,0])
       translate([w/2-R,d/2-R,0])
         cylinder(h=h,r1=ra,r2=rb,center=true);
}

// modified from: https://gist.github.com/pschatzmann/1bf4617ff8543016333a3881d6522912
// od, coils, len, wire-diam, step
module spring (od=10, c=25, l=50, wd=1, s=18, $fn=12) {
    r = (od-wd)/2;    
    ld = (l-wd)/c/360;
    
    translate([0,0,wd/2]) for ( a = [s:s:360*c] ) {
        xa=r*cos(a-s);
        ya=r*sin(a-s);
        za=(a-s)*ld;

        xb=r*cos(a);
        yb=r*sin(a);
        zb=a*ld;

        hull() {
          translate([xa,ya,za]) sphere(d=wd);
          translate([xb,yb,zb]) sphere(d=wd);
        }
    }
}
