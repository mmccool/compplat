use <threads.scad>;
 
eps = 0.0001;
tol = 0.1;
sm = 10;
th_sm = 20;

caster_thread_d = 10;
caster_thread_r = caster_thread_d/2;
caster_thread_p = 1.5;
caster_thread_c = 3;
caster_thread_h = 25 + caster_thread_c;
module caster_thread() {
  if (sm > th_sm) {
    metric_thread(
      diameter=caster_thread_d,
      pitch=caster_thread_p,
      length=caster_thread_h,
      internal=true);
  } else {
    color([1,0,0,1]) {
      cylinder(r=caster_thread_r,caster_thread_h,$fn=sm);
    }
  }
}

module rounded_rect(x,y,r,sm=sm) {
  hull() {
    translate([-x/2+r,-y/2+r]) circle(r=r,$fn=sm);
    translate([ x/2-r,-y/2+r]) circle(r=r,$fn=sm);
    translate([-x/2+r, y/2-r]) circle(r=r,$fn=sm);
    translate([ x/2-r, y/2-r]) circle(r=r,$fn=sm);
  }
}

foot_recess_h = 5;
foot_recess_x1 = 20;
foot_recess_y1 = 17;
foot_recess_r1 = 2;
foot_recess_x2 = 25;
foot_recess_y2 = 22;
foot_recess_r2 = 3;
foot_recess_ox = 30;
foot_recess_oy = 40;
module foot_recess() {
   hull() {
    translate([0,0,eps])
      linear_extrude(eps)
        rounded_rect(foot_recess_x2,foot_recess_y2,foot_recess_r2);
    translate([0,0,-foot_recess_h])
      linear_extrude(eps)
        rounded_rect(foot_recess_x1,foot_recess_y1,foot_recess_r1);

  }
}
 
bar_w = 15;
module bar(w=bar_w,h=500) {
  color([0.1,0.3,0.6,1.0])
    translate([0,-w/2,-w/2])
      cube([h,w,w]);
}

computer_x = 300;
computer_y = 500;
computer_z = 700;
module computer() {
  color([0.3,0.3,0.3,1.0]) {
    translate([-computer_x/2,0,0]) {
      cube([computer_x,computer_y,computer_z]);
      translate([foot_recess_ox,foot_recess_oy,0])
        foot_recess();
      translate([computer_x-foot_recess_ox,foot_recess_oy,0])
        foot_recess();
      translate([foot_recess_ox,computer_y-foot_recess_oy,0])
        foot_recess();
      translate([computer_x-foot_recess_ox,computer_y-foot_recess_oy,0])
        foot_recess();
    }
  }
}

assembly_ze = 5;
assembly_x = computer_x;
assembly_y = computer_y;
assembly_bar_ex = 5;
assembly_bar_ey = 10;
assembly_bar_sx = assembly_x;
assembly_bar_sy = assembly_y;
assembly_bar_w = 15;
assembly_thread_ox = assembly_bar_ex + bar_w/2;
assembly_thread_oy = 10;
assembly_thread_oz = -1.5*bar_w;

module hw() {
  // Bars
  translate([ assembly_bar_sx/2-assembly_bar_w/2-assembly_bar_ex,
             0,
             0]) 
    rotate(90)
      bar(h=assembly_bar_sy);
  translate([-assembly_bar_sx/2,
              assembly_bar_sy-assembly_bar_w/2-assembly_bar_ey,
             -assembly_bar_w]) 
      bar(h=assembly_bar_sx);

  // Caster post threads
  translate([ assembly_bar_sx/2-assembly_thread_ox,
              assembly_bar_sy+assembly_thread_oy,
              assembly_thread_oz-assembly_ze - tol]) 
    caster_thread();

  // Computer box
  translate([0,0,bar_w/2]) 
    computer();
}

unit_r = 5;
unit_ox = unit_r;
unit_x = 2*assembly_bar_ey
       + assembly_bar_w;
unit_oy = 15;
unit_y = 2*assembly_bar_ey
       + assembly_bar_w
       + assembly_thread_oy
       + unit_oy;
unit_z = 2*bar_w + 2*unit_r;
module unit_plate(sm=sm) {
  hull() {
    translate([unit_ox-unit_r,-unit_r,0])
      sphere(r=unit_r,$fn=sm);
    translate([-unit_x+unit_r,-unit_r,0])
      sphere(r=unit_r,$fn=sm);
    translate([unit_ox-unit_r,-unit_y+unit_r,0])
      sphere(r=unit_r,$fn=sm);
    translate([-unit_x+unit_r,-unit_y+unit_r,0])
      sphere(r=unit_r,$fn=sm);
  }
}
module unit(sm=sm) {
  hull() {
    translate([0,0,unit_r])
      unit_plate(sm=sm);
    translate([0,0,unit_z-unit_r])
      unit_plate(sm=sm);
  }
}

module mount() {
  difference() {
    translate([assembly_bar_sx/2,
               assembly_bar_sy+assembly_thread_oy + unit_oy,
               assembly_thread_oz-unit_r])
      unit();
    hw();
  }
}

module assembly() {
  // Bars
  translate([-assembly_bar_sx/2+assembly_bar_w/2+assembly_bar_ex,
             0,
             0]) 
    rotate(90)
      bar(h=assembly_bar_sy);
  translate([ assembly_bar_sx/2-assembly_bar_w/2-assembly_bar_ex,
             0,
             0]) 
    rotate(90)
      bar(h=assembly_bar_sy);
  translate([-assembly_bar_sx/2,
              assembly_bar_w/2+assembly_bar_ey,
             -assembly_bar_w]) 
      bar(h=assembly_bar_sx);
  translate([-assembly_bar_sx/2,
              assembly_bar_sy-assembly_bar_w/2-assembly_bar_ey,
             -assembly_bar_w]) 
      bar(h=assembly_bar_sx);

  // Caster post threads
  translate([-assembly_bar_sx/2+assembly_thread_ox,
             -assembly_thread_oy,
              assembly_thread_oz]) 
    caster_thread();
  translate([-assembly_bar_sx/2+assembly_thread_ox,
              assembly_bar_sy+assembly_thread_oy,
              assembly_thread_oz]) 
    caster_thread();
  translate([ assembly_bar_sx/2-assembly_thread_ox,
             -assembly_thread_oy,
              assembly_thread_oz]) 
    caster_thread();
  translate([ assembly_bar_sx/2-assembly_thread_ox,
              assembly_bar_sy+assembly_thread_oy,
              assembly_thread_oz]) 
    caster_thread();

  // Computer box
  translate([0,0,bar_w/2-eps]) 
    computer();
}

//---- TEST
//caster_thread();
//foot_recess();
//bar();
hw();
//unit();
mount();

//assembly();