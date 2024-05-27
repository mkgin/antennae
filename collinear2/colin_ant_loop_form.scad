// colinear antenna form and parts
//
// Based on measurments here: 
// https://www.mobilefish.com/download/lora/lora_part46.pdf
//
// form and spacers intended to build the 868Mhz Colinear antenna above
// and hold the antenna elements spaced away from a insulated support
// in this case, a 8mm fiberglass rod.
//
// check the antenna design itelf for spacings, etc. 

// colinear antenna variables
// wire size

wire_dia=1.8; //1.8mm 2.5mm^2  1.4mm 1.5mm^2
wire_dia_tol_xy = 0 ; // add to wire dia to fit hole //TODO not used yet
wire_dia_tol_z = 0.2 ; // add to wire dia to fit wire stabilizer

// form variables for 868 Mhz

form_dia=26.8; // todo ... calculate it!
form_h= 20;
space_h= 4.5 ; // center or edges? TODO... 5mm after tuning mentioned in pdf
turn_h= (form_h-space_h)/2;

/* supports
// rod size... I support my antenna on a fiberglass rod originally intended for marking curbs or the side of the road for snowplows.
 so, support the main part of the antenna away from the pole 

- "loop supports" support at the 90 deg part of the loop.
  - option for a top of  rod mount. 
  - wire clips in vertically, otherwise, rests
- "straight element supports" as above
- base support
  - ground plane guide
    - wire diameter
    - level part
    - angle down.
  - connector
  - cable support / strain relief?
  
*/

support_offset = 30 ; // offset between centers of rod and wire
// support_transition 0-1  
// distance along offset where the support changes thickness 
support_transition1 = 0.4; 
support_transition2 = 0.7;

support_rod_dia = 7.9; // 8mm 
support_thickness_arm = 2; //mm
support_thickness_rod = 3; //mm extra radius
support_thickness_wire = 3; //mm extra radius 
support_height = 3; 
support_height_wire = 6; //extra height for wire to side for a cut to stabilize the loop (bottom of wire rests on support height)
support_cut_rod_gap=0.6; // width of a gap used to allow the opening for wire and rod to flex

$fn=64;

// The module renders a form to help make the loops in the antenna
module loop_form()
{
    //$fn=64; 
    // antenna loop form
    cylinder(d=form_dia, h=form_h);

    translate( [form_dia/2-3,0,0])
    {
        //translate( [0,wire_dia,turn_h/2])
        translate( [0,wire_dia/2,0])
       // rotate([90,0,0])
        cube([turn_h,turn_h/2,turn_h]);
        //translate( [0,-wire_dia,turn_h+space_h+turn_h/2 ])
        //rotate([90,0,0])
        //cylinder(d=4, h=turn_h, $fn=6);
       //translate( [0,-wire_dia/2,form_h])
        translate( [0,-wire_dia/2,turn_h])
       rotate([180,0,0])
       cube([turn_h,turn_h/2,turn_h]);
    }
}


// render the outer shell of the antenna support
module support_main( support_type= 0 )
{
    // rework this to make main shape first, then cuts after
   // $fn=64;
        
    // rod side- assume rod is the center
   hull()
    {
        cylinder(r=support_thickness_rod+support_rod_dia/2, h=support_height);
        translate([0,support_offset*support_transition1,0]) //1/4 y+
        cylinder(d=support_thickness_arm, h=support_height);
    }
    // offset to the wire y+
    hull()
    {
        translate([0,support_offset*support_transition1,0]) //1/4 y+
        cylinder(d=support_thickness_arm, h=support_height);
        translate([0,support_offset*support_transition2,0])
        cylinder(d=support_thickness_arm, h=support_height);
   
    } 
    // wire side 
    hull()
    {
        translate([0,support_offset*support_transition2,0]) //
        cylinder(d=support_thickness_arm, h=support_height);
        translate([0,support_offset,0])
        cylinder(r=support_thickness_wire+wire_dia/2, h=support_height_wire);
    }
}

module support_cuts( support_type= 0 )
{
    // rework this to make main shape first, then cuts after
    $fn=64;
    bevel_h=0.5;
    relief_offset_rod=1 ;
    relief_offset_wire=1.5 ;
    // rod side- assume rod is the center
    // space for rod
    cylinder(r=support_rod_dia/2, h=support_height);
    // space for rod elephant foot / slight bevel
    cylinder(r2=support_rod_dia/2, r1=support_rod_dia/2+bevel_h, h=bevel_h);
    // cut a gap for some flex with corner relief
    translate([0,-relief_offset_rod,0])
    {
        translate([-support_cut_rod_gap/2,-(support_thickness_rod+support_rod_dia/2),0])
        cube([support_cut_rod_gap,(support_thickness_rod+support_rod_dia/2)*2, support_height]);
        // corner relief
        translate([0,(support_thickness_rod+support_rod_dia/2),0])
        cylinder(d=support_cut_rod_gap*1.5, h=support_height);
    }
    // screw hole? tie wrap ? glue
    // offset to the wire y+
    translate([0,support_offset,0])
    // wire side 
    {
        cylinder(r=wire_dia/2, h=support_height_wire);
        // gap for flex
        translate([0,relief_offset_wire,0])
        {
            translate([-support_cut_rod_gap/2,-(support_thickness_wire+wire_dia/2),0])
            cube([support_cut_rod_gap,(support_thickness_rod+support_rod_dia/2)*2, support_height_wire]);
            // corner relief
            translate([0,-(support_thickness_wire+wire_dia/2),0])
            cylinder(d=support_cut_rod_gap*1.5, h=support_height_wire);
        }
        // also cut an arc so the wire can be snapped in instead of fed through
        hull()
        {
            cylinder(d=wire_dia/2, h=support_height_wire+1);
            translate([0,(support_thickness_wire+wire_dia/2),0])
            cylinder(d=wire_dia, h=support_height_wire+1);
            //cylinder(d=support_cut_rod_gap*1.5, h=support_height);
        }
        // wire stabilizer
        hull()
        {
            translate([0,0,support_height + wire_dia/2])
            rotate([0,90,0])
            cylinder(d=wire_dia+ wire_dia_tol_z, h=wire_dia+support_thickness_wire*2, center=true);
            translate([0,0,support_height_wire])
            rotate([0,90,0])
            cylinder(d=wire_dia+wire_dia_tol_z , h=wire_dia+support_thickness_wire*2, center=true);
        }
        //wire curve... 45deg cut
        //translate([0,0,support_height + wire_dia/2])
        hull()
        {
        translate([1,0,support_height])
        rotate([0,45,0])
        translate([0,0,-2])
        #cylinder(d=wire_dia+wire_dia_tol_z , h=wire_dia+support_thickness_wire*2);
        translate([-1,0,support_height])
        rotate([0,-45,0])
        translate([0,0,-2])
        #cylinder(d=wire_dia+wire_dia_tol_z , h=wire_dia+support_thickness_wire*2);    
        }
    }
}

module support( support_type= 0 )
{
    difference()
    {
        support_main( support_type= 0 );
        support_cuts( support_type= 0 );
    }
}


// how to do this ...
// support ground plane to bend? one cm past?
// ground_plane_radials();
// hold connector
// 
module base( )
{
    // use the support to attach to pole.
    // base outer
    // ground_plane_radials();
    // connector_space();
    
}


// uncomment to render
$fn=360;
//loop_form();
support();
//base();