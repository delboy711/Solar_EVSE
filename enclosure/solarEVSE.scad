//
// Arduino Uno
//
// Based on a design by Egil Kvaleberg, 8 Aug 2015
// Remixed by delboy711 21/08/2016

//
// notes:
// design origin is middle of PCB
//



// Set part = "all" to see both top and bottom parts
// Set part = "top" to see just the top part
// Set part = "bottom" to see just the bottom part
// Set part = "demo" to see both parts fitted together
part = "all"; // [ top, bottom, all, demo ]
// Is the Arduino a Uno (USB, and power socket), or a Xino (bare bones no usb or power socket)
// See https://www.wirelessthings.net/xino-basic-for-atmel-atmega-avr-arduino-compatible-kit
device = "Xino";  // [ Uno. Xino ]
// Select feature options
have_emontx_shield =0 ; //Is fitted with an emontx shield card
have_text = 1; //  Writing on side
text_="Solar EVSE";   // Text to write on side
font_size= 7;  // Text font size
have_pcb_fixings = 0; // 
have_snaplock = 1;   // snaplocks on edges
have_bottom_vents = 0;  // Ventilation slots on bottom
have_top_vents = 0;  // Ventilation slots on top
have_cable_outlet= 1; // Has hole for cable outlet
have_screwblock=1;    //Opening for screwblock in lid


/* [Hidden] */
mil2mm = 0.0254;
pcb = [69, 53.5, 1.5]; // main board 
extra_width = 0;   
extra_depth = 0;   // extra space below pcb
extra_length = (have_emontx_shield ? 26 : 0); // extra length Longer with emontx shield fitted
extra_height = (have_emontx_shield ? 9 : 0);   // extra space above pcb taller with emontx shield 
pcb2floor = 4.0 + extra_depth; //  
pcb2roof = 14 + extra_height; //   

pcbmntdia = 2.3; // mounting holes
pcbmntdx= [pcb[0]/2 - 2.5, (device == "Uno" ? 14.5 : 2.8)-pcb[0]/2, pcb[0]/2 - 2.3, pcb[0]/2 - 53.3];  //location of mount holes
pcbmntdy= [7.6 - pcb[1]/2, (device == "Uno" ? 2.8 : 13)-pcb[1]/2, 9.1, pcb[1]/2 - 2.5];

breakaway = 0.3; // have hidden hole for screw, 0 for no extra pegs 
usbsy = 10.5; // core
usbframe = 1.0; // frame
usbsz = 10 + 0.5;
usb1dy = pcb[1]/2 - 15.0;
powerpsx = 9; // power plug width 
powerpsz = 14.0; // plug height
powerssx = 9.9; // power socket width 
powerssz = 10.0; // socket height
powerdz = -1.7; // for plug 
powerdy = 8.8- pcb[1]/2; // 
emonacdz = -3;   // AC power socket of emontx shield
emonacdx = pcb[0]/2 -1.5;
frame_w = 2.5; // width of lip for frame 
snap_dia = 1.8; // snap lock ridge diameter
snapedges = false; // snap lock on all edges or just long ones
//snap_len = 40.0; // snap lock length - no longer used DJ
tol = 0.5; // general tolerance

wall = 2; // general wall thickness  was 1.2 dj
thinwall = 1;   // was 0.4 dj
corner_r = wall; // casing corner radius
corner2_r = wall+tol+wall; // corners of top casing
d = 0.01;
 

module c_cube(x, y, z) {
	translate([-x/2, -y/2, 0]) cube([x, y, z]);
}

module cr_cube(x, y, z, r) {
	hull() {
		for (dx=[-1,1]) for (dy=[-1,1]) translate([dx*(x/2-r), dy*(y/2-r), 0]) cylinder(r=r, h=z, $fn=20);
	}
}

module cr2_cube(x, y, z, r1, r2) {
	hull() {
		for (dx=[-1,1]) for (dy=[-1,1]) translate([dx*(x/2-r1), dy*(y/2-r1), 0]) cylinder(r1=r1, r2=r2, h=z, $fn=20);
	}
}

module bottom() {
	module snap2(ex, both) {
		if (both) translate([pcb[0]/2+tol+wall+ex+extra_length, -(pcb[1]+extra_width-10)/2, wall+pcb2floor+pcb[2]-frame_w/2]) rotate([-90, 0, 0]) cylinder(r=snap_dia/2, h=pcb[1]+extra_width-10, $fs=0.3);
		translate([-(pcb[0]-10)/2, -(pcb[1]/2+tol+wall+extra_width/2), wall+pcb2floor+pcb[2]-frame_w/2]) rotate([0, 90, 0]) cylinder(r=snap_dia/2, h=pcb[0]+extra_length-10, $fs=0.3);
	}
    module plugs(extra) { 
        z0 = wall+pcb2floor+pcb[2];
    }
    module plugs_add() { 
        z0 = wall+pcb2floor+pcb[2];
    }

	module add() {
		hull () for (x = [-1, 1]) for (y = [-1, 1])
			translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_length : 0), y*(pcb[1]/2+tol+wall+extra_width/2-corner_r), corner_r]) {
				sphere(r = corner_r, $fs=0.3);
				cylinder(r = corner_r, h = wall+pcb2floor+pcb[2]-corner_r, $fs=0.3);
		}
		if (have_snaplock) {
            snap2(0, snapedges);
            rotate([0, 0, 180]) translate([-extra_length,0,0]) snap2(0, snapedges);
        }
	}
	module sub() {
        module pedestal(x, hg, dia) {
            translate([pcbmntdx[x], pcbmntdy[x], wall]) {
				cylinder(r = dia/2+wall, h = hg, $fs=0.2);
                // pegs through pcb mount holes
                if (breakaway > 0) translate([0, 0, hg]) 
                        cylinder(r = dia/2 , h = pcb[2]+d, $fs=0.2);
            }
        }
		difference () {
			// pcb itself
			translate([-(pcb[0]/2+tol), -(pcb[1]/2+tol)-extra_width/2, wall])
				cube([2*tol+pcb[0]+extra_length, 2*tol+pcb[1]+extra_width, pcb2floor+pcb[2]+d]);
			// less pcb mount pedestals 
            for (x = (device=="Xino" ? [0,1,3] :[0:3]))  // leave out one pedestal if xino
                pedestal(x, pcb2floor, pcbmntdia);
            
            // Stop card moving
            if (extra_length > 0 ) translate([pcb[0]/2+0.7,-13,-pcb2floor+3]) cube([3,16,10]);
		}
        
        
        plugs(tol);
        
        
        // DJ Add bottom vents
        if ( have_bottom_vents ) 
            for ( dx=[-4 : 4] ) for ( dy=[-1, 1] ) translate([dx*7, dy*(pcb[1]/2-14), 0]) cube([2, pcb[1]/2-6, 2*wall], center=true);

        
	}
	difference () {
		add();
		sub();
	}
    plugs_add();

    if (part=="all" || part=="demo")  {
       if (device == "Uno") color("LightPink", 0.6) translate([-34,-26.5,6+extra_depth]) scale([10,10,10]) rotate([90,0,0])  import(file="arduino_pcb.stl");
       if (have_emontx_shield) color("LightBlue", 0.6) translate([-12,-26.5,18.5+extra_depth]) scale([0.001,0.001,0.001]) import("emontxshield.stl");
    }
 
}

// Z base is top of pcb
module top() {
	module snap2(ex, both) {
		if (both) translate([pcb[0]/2+tol+wall+ex+extra_length, -(pcb[1]+extra_width-10)/2-tol, -frame_w/2]) rotate([-90, 0, 0]) cylinder(r=snap_dia/2, h=pcb[1]+extra_width-10+2*tol, $fs=0.3);
		translate([-(pcb[0]-10)/2-tol, pcb[1]/2+tol+wall+extra_width/2, -frame_w/2]) rotate([0, 90, 0]) cylinder(r=snap_dia/2, h=pcb[0]+extra_length-10+2*tol, $fs=0.3);
	}
    module plugs(extra) { 
        module usb_plug(dy) {
            translate([-pcb[0]/2, dy, -extra-frame_w]) 
				c_cube(19.9, usbsy+2*extra, usbsz+2*extra+frame_w);
            translate([-pcb[0]/2 -19.9/2, dy, -extra-frame_w]) 
				c_cube(19.9, usbsy+2*usbframe+2*extra, usbsz+2*extra+frame_w+2*usbframe/2);
        }

       // usb plug
       usb_plug(usb1dy);

       translate([-pcb[0]/2 -19.9/2, powerdy , -extra-frame_w]) 
				c_cube(19.9, powerpsx+2*extra, powerpsz+2*extra);
                
    }

	module add() {
		hull () for (x = [-1, 1]) for (y = [-1, 1]) {
			translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_length : 0), y*(pcb[1]/2+tol+wall+extra_width/2-corner_r), -frame_w]) 
				cylinder(r = corner_r+tol+wall, h = d, $fs=0.3); // include frame
			translate([x*(pcb[0]/2+tol+wall-corner2_r) + (x>0 ? extra_length : 0), y*(pcb[1]/2+tol+wall+extra_width/2-corner2_r), pcb2roof+wall-corner2_r]) 
					sphere(r = corner2_r, $fs=0.3);	
		}
        // Text on side
        if (have_text) {
            translate([extra_length/2, (pcb[1]/2+tol+wall+extra_width/2+0.4),pcb2roof/2 ]) rotate([-100,180,0]) linear_extrude(height = 1.0)  text(text_, font = "Adventure" , size=font_size, halign="center", valign="center");
        }
	}

	module sub() { 

		// room for bottom case within frame 
		hull () for (x = [-1, 1]) for (y = [-1, 1])
			translate([x*(pcb[0]/2+tol+wall-corner_r) + (x>0 ? extra_length : 0), y*(pcb[1]/2+tol+wall+extra_width/2-corner_r), -frame_w-d]) 
                cylinder(r = corner_r+tol, h = d+frame_w, $fs=0.3); 
		// snap lock
        if (have_snaplock) {
            snap2(0, snapedges);
            rotate([0, 0, 180]) translate([-extra_length,0,0]) snap2(0, snapedges);
        }
		difference() { 
			// room for pcb
			translate([0+extra_length/2, 0, -d]) cr_cube(2*tol+pcb[0]+extra_length, 2*tol+pcb[1]+extra_width, d+pcb2roof, 1.0);
			union () { // subtract from pcb:

                // pegs
                if (have_pcb_fixings) for (x = [0:3])  translate([pcbmntdx[x], pcbmntdy[x], 0]) {
                    cylinder(r1 = pcbmntdia/2 +wall, r2 = pcbmntdia/2 +1.5*1.2, h = pcb2roof, $fs=0.2);
                }
                // Screwblock
                if (have_screwblock) translate([-pcb[0]/2+4, -pcb[1]/2+12.5,0]) c_cube(18,21,16);
                       
			}

		}

        // DJ Add top vents
        if ( have_top_vents ) 
            for ( dx=[-4 : 4] ) for ( dy=[-1, 1] ) translate([dx*7, dy*(pcb[1]/2-16), pcb2roof]) cube([2, pcb[1]/2-10, 2*wall], center=true);
        // Screwblock text
        if (have_screwblock) {
            translate([-pcb[0]/2+20, -pcb[1]/2+7.5,pcb2roof+wall-0.4]) linear_extrude(height = 10.0) text("0V", font = "Adventure" , size=5, halign="center", valign="center"); 
            translate([-pcb[0]/2+20, -pcb[1]/2+12.5,pcb2roof+wall-0.4]) linear_extrude(height = 10.0) text("5V", font = "Adventure" , size=5, halign="center", valign="center");
          translate([-pcb[0]/2+20, -pcb[1]/2+17.5,pcb2roof+wall-0.4]) linear_extrude(height = 10.0) text("IC", font = "Adventure" , size=5, halign="center", valign="center");  
     
        }
        // hole for usb, ether and power
        if (device=="Uno") plugs(tol);
        // AC Power socket for emon shield
        if (have_emontx_shield) {
            translate([emonacdx, pcb[1]/2 + 22.9/2+extra_width/2, emonacdz])rotate([0,90,0]) {
                rotate([90, -90, 0]) cube([11,14,22]);
                translate([-17,-9,5])  rotate([0,90,90]) linear_extrude(height = 4.0)  text("9V AC", font = "Adventure" , size=4, halign="center", valign="center");
            }

        // Jacks for current sensors on emon shield
            for (x=[1:4]) translate([pcb[0]/2+ extra_length, 32.5 -x*13, 7.4]) rotate([0, 90, 0])
            { hull() { cylinder(h=5,r=4.3,$fn=24);
                    translate([10,0,0]) cylinder(h=5,r=4.3);
                     }
               translate([-7,0,2.2])  rotate([-5,0,90]) linear_extrude(height = 20.0)  text(str(x), font = "Adventure" , size=5, halign="center", valign="center");
            }
        }
        //  hole for antenna cable
        if (have_cable_outlet)    translate([-pcb[0]/2, 22, -2.3]) rotate([0, -90, 0]) 
                hull() { cylinder(h=7,r=1);  
                         translate([5,0,0]) cylinder(h=7,r=1);
                }
            
        // hole for reset switch if Xino
            if (device=="Xino") translate([21 -pcb[0]/2, -5-pcb[1]/2, 4]) rotate([-90,0,0]) cylinder(h=5,r=3.2);

        // peg holes
         if (have_pcb_fixings)for (x = [0:3]) translate([pcbmntdx[x], pcbmntdy[x], 0]) {
            translate([0, 0, -d]) cylinder(r = pcbmntthreads/2, h = pcb2roof, $fs=0.2); // hole
        }
        // Screwblock
         if (have_screwblock) translate([-pcb[0]/2+4.3, -pcb[1]/2+12.5,-4]) c_cube(19,18,27);
	}
	difference () {
		add();
		sub();
	}
    
} 


//

if (part=="demo") { bottom(); translate([0, 0, wall+pcb2floor+pcb[2]]) top(); }
if (part=="bottom" || part=="all") translate([0, -45, 0]) bottom();
if (part=="top" || part=="all") translate([-0, 45, pcb2roof+wall]) rotate([180,0,0]) top();
	