//
// antenna feedthrough. car door over window
//
//

//Just for rendering
include <NopSCADlib/lib.scad>
//include <NopSCADlib/vitamins/antennas.scad>
include <NopSCADlib/core.scad>

// TODO: 

// taper the top part
// angle out a few degrees
//


// factor in  curvature
// factor side of window angle (look from front) ... for ext antenna mount.
// factor in top of window angle ( initial assumption... top of window level)
// add 1 perimeter of support. --- done ? 
// feet ( like brim... stay standing ) .. .maybe not prints fin for me
//

// Variations... / Notes...
// * Which SMA ( long bulkhead or ... female...  ( 2.4 vs 6mm )
// * Hook .. .check if hook fits ICOM
// * Hook size ... (control)
// * hook sides ( hull or not)
// * No-hook for remix? 
// * thin cable (sma to ipex... eg to a common  or popular heltec case?
//
// SMA flats... 
// * some connectors have them on 2 sides, some have on 1 side some don't have any.
// * if there is a hex on the connector it's orientation compared to the flat may vary.


window_thickness = 4; // window thickness in mm
perimeter_w = 0.45 ; // width of one perimeter
support_ratio = 0.35; // part of perimiter the slicer will recognize (above number is multiplied by this  to make supports as thin as practical

sma_dia = 6.6; // sma threaded part
//sma_flats = 6.2 ; // distance between flats
sma_flats = 6.3 ; // distance between flats !! 6.2 needed some trimming.

sma_mount_h = 6 ; //2.6 ; // threaded part in mount ( take into account nuts and threading an antenna on ( the height that is supported)
sma_hex_d = 9.4 ; // sma hex part  (8 mm face to face )...  find good number for $fn=6..
sma_hex_h = 2.6 ;//sma_mount_h ; // sma hex part  
sma_extra_h = 2; // extra height on outer

sma_offset_h = 60 ; // how high on the outside... and inside? the sma is offset 
sma_offset_z = 19.5; // how high on the outside... and inside? the sma is offset 
sma_offset_y = 5 ; // extra offset
sma_lower_cylinder_offset_y = 5 ; // maybe the PETG temp was a high and overhangs didn't turn out as well as expect with Prusament PETG vs being out with Refil PETG?
sma_z_rot = 23 ; // rotate connector match angle of the window looking from front of car.abs
sma_cutout_length = 13.5;
sma_cutout_d = sma_hex_d +2.5 ;

feedthrough_thickness_main = 3 ;   //
feedthrough_height_main = 65 ; // part that the weather_strip does not cover
feedthrough_height_main_outer_less = 35; //make outer main shorter
feedthrough_thickness_top = 2 ;  // check slicer result.. use something sensible... enough for 3-5 perimeters? 
feedthrough_height_top = 14 ; // part that the weather_strip_covers

feedthrough_width = 40 ; 

feedthrough_gap_offset_z = feedthrough_width/2;

coax_diameter = 3; 
coax_cut_angle = -25;

hook_h=10 +  feedthrough_thickness_main; 
hook_w=6 ;
hook_web_thick = 2;
hook_web_offset_y = -1;


$fn= 72;

module spherish_cylinder( d=1,h=1,center=false, flat_bottom=true, flat_top=true, z_rot=0)
{
    //flat_offset=0.707;
    //flat_offset=0.5*0.707;
    flat_offset= 0.35;
    rotate([0,0,z_rot])
    hull()
    {
        //bottom
        translate([0,0,d/2])
        sphere(d/2);
        if (flat_bottom)
        {
            translate([d*flat_offset,0,d/2])
            //cube(d,center=true);
            cylinder(d=d,h=d,center=true);
        }
        //top
        translate([0,0,h-d/2])
        sphere(d/2);
        if (flat_top)
        {
            translate([d*flat_offset,0,h-d/2])
            //cube(d,center=true);
            cylinder(d=d,h=d,center=true);
        }
    }  
}

module feedthrough_outer( no_sma= false, no_hook=false )
{
    // draw inner and outer
    for( j = [-1, 1])  //-1 is inside, 1 is outside
    {
        // draw main part for side
        hull()
        for ( i = [0,1] )
        {
            translate([ i * feedthrough_height_main , j * (feedthrough_thickness_main/2 + window_thickness/2),0])
            // handle feedthrough_height_main_outer_less with extra translate
            if (j == 1 && i == 0)
            {
                translate([feedthrough_height_main_outer_less,0,0])
                spherish_cylinder(d=feedthrough_thickness_main , h = feedthrough_width, z_rot=180*i);
            }
            else
            {
                spherish_cylinder( d=feedthrough_thickness_main , h = feedthrough_width, z_rot=180*i);
            }
        }
        // draw top part for side
        hull()
        for ( i = [-0.5,1] )
        {
            translate([ feedthrough_height_main + i * feedthrough_height_top , j * (feedthrough_thickness_top/2 + window_thickness/2),0])
            spherish_cylinder(d=feedthrough_thickness_top , h = feedthrough_width, z_rot=180);
        }
        // draw the outer sma mount
        if ( j==1 && ! no_sma ) //outer only for now.
        {
            translate([ 0 , j * (feedthrough_thickness_main/2 + window_thickness/2  ),0])
            hull()
            {
                translate( [sma_offset_h-feedthrough_thickness_main-sma_cutout_length +feedthrough_thickness_main,0,0 ]) // ??
                spherish_cylinder(d=feedthrough_thickness_main , h = sma_offset_z+sma_dia/2 + window_thickness); // the lower cylinder
                
                translate( [sma_offset_h-feedthrough_thickness_main-sma_cutout_length +feedthrough_thickness_main,sma_lower_cylinder_offset_y,feedthrough_thickness_main/2 ]) // 
                //cylinder(d=feedthrough_thickness_main ); // the lower cylinder extra
                {
                    #sphere(d=feedthrough_thickness_main ); // the lower cylinder extra
                    rotate([0,0,sma_z_rot])
                    translate([sma_hex_h +  sma_mount_h + sma_extra_h,0,0])
                    #sphere(d=feedthrough_thickness_main  ); // the upper cylinder extra
                }
                translate( [sma_offset_h-feedthrough_thickness_main/2,0,0 ])
                spherish_cylinder(d=feedthrough_thickness_main , h = sma_offset_z +sma_dia/2 + window_thickness, z_rot=180); // the upper cylinder
                translate( [sma_offset_h-feedthrough_thickness_main/2,sma_lower_cylinder_offset_y,feedthrough_thickness_main/2 ])
                //cylinder(d=feedthrough_thickness_main  ); // the upper cylinder extra
                
                #sphere(d=feedthrough_thickness_main  ); // the upper cylinder extra
                
                translate( [sma_offset_h,j * (sma_dia + window_thickness+sma_offset_y) ,sma_offset_z ])
                
                rotate([0,-j*90,j*sma_z_rot])
                //rotate([0,0,j*sma_z_rot ])
                //rotate([0,0,-90])
                sma_mount(outer=true);
            }
        }
        if ( j==-1 && ! no_hook ) //inner only for now.
        {
            //lower hook
            hook( j=j,hook_height = hook_w, hook_d = feedthrough_thickness_main);
            // upper hook
            translate([0,0,feedthrough_width-hook_w])
            hook( j=j,hook_height = hook_w, hook_d = feedthrough_thickness_main);
            // hook web
            hull()
            {
                hook( j=j,hook_height = hook_w, hook_d = feedthrough_thickness_main, hook_web=true  );
                translate([0,hook_web_offset_y,hook_w ])
                hook( j=j,hook_height = hook_web_thick, hook_d = hook_web_thick, hook_web=true );
            }
            translate([0,hook_web_offset_y,hook_w ])
            hook( j=j,hook_height = feedthrough_width-hook_w*2 , hook_d = hook_web_thick, hook_web=true );
            hull()
            {
                translate([0,hook_web_offset_y,feedthrough_width-hook_w-hook_web_thick])
                hook( j=j,hook_height = hook_web_thick, hook_d = hook_web_thick, hook_web=true );
                translate([0,0,feedthrough_width-hook_w])
                hook( j=j,hook_height = hook_w, hook_d = feedthrough_thickness_main, hook_web=true);
            }
            
            
        }
    }
    // draw the very top part
    translate([ feedthrough_height_main + feedthrough_height_top ,0 ,0])
    difference()
    {
        cylinder(d= window_thickness + 2*  feedthrough_thickness_top , h = feedthrough_width);
        translate([ 0,0 ,-0.1])
        //cylinder(d= window_thickness + perimeter_w , h = feedthrough_width+0.2);
        hull()
        {
            cylinder(d= window_thickness + perimeter_w, h = feedthrough_width+0.2);
            translate([ -window_thickness  ,0 ,0])
            cylinder(d= window_thickness  , h = feedthrough_width+0.2);
        }
        
    }
    
}

module hook( j=1, hook_height = 0, hook_d = 0 , hook_web = false)
{
    if (! hook_web)
    {
        hull()
        {
        //start at same location
        translate([ 0, j * (feedthrough_thickness_main/2 + window_thickness/2),0])
        cylinder(d=hook_d , h= hook_height );
        // outwards x 3
        translate([ 0 , j * (feedthrough_thickness_main*2.5 + window_thickness/2),0])
        cylinder(d=hook_d , h= hook_height );
        }
    }
    hull()
    {
        // outwards x 3
        translate([ 0 , j * (feedthrough_thickness_main*2.5 + window_thickness/2),0])
        cylinder(d=  hook_d , h= hook_height );
        // outwards and up
        translate([ hook_h , j * (feedthrough_thickness_main*2.5 + window_thickness/2),0])
        cylinder(d=  hook_d , h= hook_height );
        //cylinder(d= hook_web ? hook_web_thick : feedthrough_thickness_main , h= hook_height );
    }
}



module feedthrough_cutout()
{
    
    hull()
    for( j = [-1, 1]) //-1 is inside, 1 is outside
    {    
        translate([ window_thickness/2 + feedthrough_height_main + j *( feedthrough_height_top + coax_diameter) ,0 ,feedthrough_gap_offset_z])
        rotate([coax_cut_angle,0,0])
        cylinder(d= coax_diameter  , h = feedthrough_width, center=true);

    }
    
}

module feedthrough_cutout_support()
{
    difference()
    {
    feedthrough_outer(no_sma = true, no_hook= true);
    translate([perimeter_w,perimeter_w*support_ratio,0])
    feedthrough_outer(no_sma = true, no_hook= true);
    translate([-perimeter_w,perimeter_w*support_ratio,0])
    feedthrough_outer(no_sma = true, no_hook= true);

    }
}

module sma_cutout()
{
    for( j = [-1, 1]) //-1 is inside, 1 is outside 
    {
        // draw the outer sma mount
        if ( j==1 )
        {
            translate([ 0 , j * (feedthrough_thickness_main/2 + window_thickness/2 +sma_offset_y),0])
            /*hull()
            {
                cylinder(d=feedthrough_thickness_main , h = feedthrough_width); // the lower cylinder
                translate( [sma_offset_h-feedthrough_thickness_main/2,0,0 ])
                cylinder(d=feedthrough_thickness_main , h = feedthrough_width); // the lower cylinder */
            translate( [sma_offset_h,j * (sma_dia + window_thickness) ,sma_offset_z ])
            rotate([0,-j*90,j*sma_z_rot])
            sma_mount(outer=false);
        }
    }
}

module sma_mount( outer = true, sma_flats = false)
{
    // outer... not to be confused with outside...  
    // outer is the outer shell, 
    // !outer is the space for the SMA  connector
    //
    //cylinder( d = sma_dia + ( outer ? 2*window_thickness : 0 ) , h = sma_hex_h +  sma_mount_h + ( outer ? 0 : 10 ) );
    if ( !outer)
    {
        // sma outer with flats
        intersection()
        {
            translate([0,0,-0.01])
            cylinder( d = sma_dia  , h = sma_mount_h+0.02  );
            if (sma_flats)
            {
                translate([0,0,sma_mount_h/2-0.01])
                cube([sma_flats,sma_dia,sma_mount_h+0.02],center=true);
            }
        }
        
        
        // hex
        translate([0,0,sma_mount_h-0.01])
        //rotate([180,0,0])
        rotate([0,0,30])
        cylinder( d = sma_hex_d,  h = sma_hex_h+0.02 ,$fn=6);
        // cable  + connector space?
        translate([0,0,sma_mount_h+ sma_hex_h-0.01])
        cylinder( d = sma_cutout_d,  h = sma_cutout_length +0.02 );
    }
    else
    {
        cylinder( d = sma_dia + 2*window_thickness , h = sma_hex_h +  sma_mount_h + sma_extra_h );
    }
}


module draw_all( own_supports = true, no_hook=false )
{
    if ( own_supports )
        feedthrough_cutout_support();
    difference()
    {
        feedthrough_outer(no_hook=no_hook);
        feedthrough_cutout();
        sma_cutout();
    }
    
    
}
module draw_glass()
{
    j=0;
    hull()
    for ( i = [-1,1] )
    {
        translate([ i * (feedthrough_height_main+ feedthrough_height_top) , j * (feedthrough_thickness_main/2 + window_thickness/2),-feedthrough_width])
        cylinder(d= window_thickness, h=feedthrough_width*3, $fn=16);
    }
}
module draw_sma()
{
    j=-1;
    rotate([180,0,0])
    translate([ 0 , j * (feedthrough_thickness_main/2 + window_thickness/2  ),0])
    translate([sma_offset_h,j * (sma_dia + window_thickness+sma_offset_y) ,-sma_offset_z ])
    rotate([0,-j*90,j*sma_z_rot])
    antenna(ESP201_antenna);
}
module draw_wire()
{
    // really ugly but works...
    j= 1; $fn = 24;
    //
    path = [
    [sma_offset_h,  2*window_thickness+2.5*sma_offset_y-2 ,sma_offset_z ],
    [ sma_offset_h/2 , 1*window_thickness+2.5*sma_offset_y -2 ,sma_offset_z],
    [ sma_offset_h/2 , 1*window_thickness+2.5*sma_offset_y -2 ,sma_offset_z+15],
     [ sma_offset_h , 1*window_thickness +2 ,sma_offset_z+15],
    [ sma_offset_h*1.2 , 1*window_thickness + 2 ,sma_offset_z+15],
    [ sma_offset_h*1.2 , 1*window_thickness - 1 ,sma_offset_z+8],
    [ sma_offset_h*1.6 , 1*window_thickness - 1 ,sma_offset_z+8],
     [ sma_offset_h*1.65 , 0 ,sma_offset_z],
    [ sma_offset_h*1.6 , -window_thickness+1 ,sma_offset_z-8],
    [ sma_offset_h*1.2 , -window_thickness+1 ,sma_offset_z-8]
    ];
   
   for (i = [1:len(path)-1])
   {
       hull()
       for(j = [0:1])
       {
           translate(path[(i-j)])
           sphere(1.5);
       }
   }
   
}

module render_example()
{
    color("grey", 0.8)
    render(convexity = 2) draw_all( own_supports = false );
    color("lightblue", 0.5)
    render(convexity = 2) draw_glass();
    draw_sma();
    color("red", 0.9)
    render(convexity = 2)
    draw_wire();
}

draw_all(own_supports = true, no_hook = true ); // draw for printing
//draw_all(own_supports = true ); 
//draw_all(own_supports = false); // draw for printing
//rotate([0,-90,0]) rotate([0,0,-20]) render_example();





