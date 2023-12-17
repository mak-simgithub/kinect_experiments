import org.openkinect.freenect.*;
import org.openkinect.processing.*;
Kinect kinect;

import peasy.*;
PeasyCam cam;

import themidibus.*; //Import the library
MidiBus myBus; // The MidiBus

import http.requests.*;

//kinect related vars
float deg_kinect;
boolean ir = true;
boolean colorDepth = false;
boolean mirror = true;
int kinect_skip_points = 4;


//drawing related vars
float hue = random(360);
float sat = 80;
float lig = 70;
float point_size = 5;


//camera related vars
int max_dist = 500;
int min_dist = 200;
float a = 0;
float b = 0;
int light_type = 1;
float[] pers_rand = new float[3];


//MIDI changeable vars
float shape_growing_speed = 1;
int shape_type = 1;
float shape_size = 0;
int movement_type = 1;
float movement_speed = 0.5;
float spread_points_x = 1;
float spread_points_y = 1;
int point_detail = 3;
int point_type = 1;


//world related vars
float[] depthLookUp = new float[2048];
PVector[] world_points;
float[] max_dims;
int start_milis_filt;
float[] world_filter;
boolean filter_world = false;
boolean remeasure_world = false;
int filter_time = 3000;
float filter_tight = 0.8;


//GUI related vars
boolean show_overlay = false;


void settings() { 
  System.setProperty("jogl.disable.openglcore", "false");
  size(1600, 900, P3D);
}

void setup() {
  smooth(2);
  colorMode(HSB,360,100,100,100);
  
  //cam = new PeasyCam(this, -1000);
  //cam.lookAt(0,0,0);
  MidiBus.list(); 
  myBus = new MidiBus(this, 0, "VirMIDI [hw:3,0,0]");
  
  camera(0, 0, 800, 0, 0, 0, 0, 1, 0);

  kinect = new Kinect(this);
  kinect.initDepth();
  
  kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  kinect.enableMirror(mirror);

  deg_kinect = kinect.getTilt();
  
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);}
    
  world_points = get_world(kinect_skip_points);
  max_dims = measure_world(world_points);

}

void draw() {
  
  if (remeasure_world) {
    if ((millis()-start_milis_filt)<filter_time){
      background(0,0,0);
      world_points = get_world(kinect_skip_points);
      camera(0, 0, 600, 0, 0, 0, 0, 1, 0);
      draw_world(world_points,hue,80,100,point_detail,point_type);
      max_dims = measure_world(world_points);
      debug_overlay(max_dims);
      text(filter_time-(millis()-start_milis_filt), 300, -50, 0);
    }
    remeasure_world = false;
  }
  
  else if (show_overlay){
    
    set_light();
    
    background(0,0,0);
    world_points = get_world(kinect_skip_points);
    
    PVector[] world_points_filt = gate_world(world_points, max_dims, 0.2, 0, 0.5);
    
    draw_world(world_points_filt, (hue+180)%360,80,100,point_detail,point_type);

    draw_shape();
    camera(0, 0, 600, 0, 0, 0, 0, 1, 0);
    debug_overlay(max_dims);}
   
  else {
    
    set_light();
    
    point_size = int(3+random(1)*7);
    background(hue,80,70);
  
    world_points = get_world(kinect_skip_points);
    
    PVector[] world_points_filt = gate_world(world_points, max_dims, 0.2, 0, 0.5);
    
    draw_world(world_points_filt, (hue+180)%360,80,100,point_detail,point_type);

    draw_shape();
    
    move_camera();
    
}
}

void move_camera(){
  switch (movement_type) {
        //rotate from random angle in random direction around center
        case 1: { camera(((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[0]*2-1, //eyeX
                        ((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[1]*2-1, //eyeY
                        ((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[2]*2-1, //eyeZ
                        (max_dims[0]+max_dims[1])/2, //centerX
                        (max_dims[2]+max_dims[3])/2, //centerY
                        -(max_dims[4]+max_dims[5])/2, //centerZ
                        cos(a), //upX
                        sin(a), //upY
                        0); //upZ
                        
                  a -= 0.1f*(round(pers_rand[0])*2-1)*movement_speed;}
        break;
        case 2: { camera(((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[0]*2-1,
                        ((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[1]*2-1,
                        ((max_dist-min_dist)*pers_rand[0]+min_dist)*(pers_rand[2]+a)*2-1,
                        (max_dims[0]+max_dims[1])/2,
                        (max_dims[2]+max_dims[3])/2,
                        -(max_dims[4]+max_dims[5])/2,
                        0,
                        1,
                        0);
                        
                  a -= 0.5f*movement_speed;}
        break;
      }
}

void set_light(){
  switch (light_type) {
      case 1: {directionalLight(360-hue+90,80,70,pers_rand[0],pers_rand[1],pers_rand[2]);
              //camera(width/2.0, height/2.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
              perspective();
            }
      break;
      case 2: {directionalLight(12,80,100,0,1,0);
              //camera(width/4.0, height/2.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
            }
      break;
      case 3: {pointLight(360-hue+90,80,70,pers_rand[0],pers_rand[1],pers_rand[2]);
              //camera(width/2.0, height/4.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
            }
      break;
      case 4: {int i = 0;}
      break;
    }}


//gets world coordinates, only taking every skipth point from kinect
PVector[] get_world(int skip) {
  int[]  depth = kinect.getRawDepth();
  PVector[] world = new PVector[kinect.width*kinect.height/skip/skip];
  int counter = 0;
  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      int offset = x + y*kinect.width;
      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);
      world[counter] = v.mult(1000); // to mm
      counter++;
      }
    }
    return world;}
        
//get minimum bounding box for all measured points
float[] measure_world(PVector[] world) {
  float[] max_dims = new float[6];
  max_dims[0] =-999999;
  max_dims[1] =999999;
  max_dims[2] =-999999;
  max_dims[3] =999999;
  max_dims[4] =-999999;
  max_dims[5] =999999;
  for (int x = 0; x<world.length; x++) {
    if (world[x].x>max_dims[0]){
            max_dims[0] = world[x].x;}
    
    if (world[x].x<max_dims[1]){
            max_dims[1] = world[x].x;}
            
    if (world[x].y>max_dims[2]){
            max_dims[2] = world[x].y;}
            
    if (world[x].y<max_dims[3]){
            max_dims[3] = world[x].y;}
            
    if (world[x].z>max_dims[4]){
            max_dims[4] = world[x].z;}
            
    if (world[x].z<max_dims[5] && world[x].z != 0){
            max_dims[5] = world[x].z;}
  }
  return max_dims;}


void draw_world(PVector[] world, float hue, float sat, float lig, int detail, int shape) {
  for (int i = 0; i<world.length; i++) {
    if (world[i].x+world[i].y+world[i].z != 0){
      
      sphereDetail(detail);
      stroke(hue, lig, sat);
      
      pushMatrix();
      translate(world[i].x*spread_points_x, world[i].y*spread_points_y, -world[i].z);
      
      // Draw a shape
      switch (shape) {
        case 1: {sphere(point_size);}
        break;
        }
        
      popMatrix();
    }
  }
}


PVector[] gate_world(PVector[] world, float[] max_dims, float cut_x, float cut_y, float cut_z){
  PVector[] filtered_world = new PVector[world.length];
  int counter = 0;
  for (int i = 0; i<world.length; i++) {
    if ((world[i].x < max_dims[0]*(1-cut_x) && world[i].x > max_dims[1]*(1-cut_x)) && (world[i].y < max_dims[2]*(1-cut_y) && world[i].y > max_dims[3]*(1-cut_y)) && world[i].z < max_dims[4]*(1-cut_z)) {
      filtered_world[counter] = world[i];
    counter++;}
  }
  PVector[] filtered_world_cut = new PVector[counter];
  for (int i = 0; i<counter; i++) {
    filtered_world_cut[i] = filtered_world[i];}
      return filtered_world_cut;
}


void draw_shape(){
  pushMatrix();
  translate(-1000, 0, -0.5*max_dims[4]);
  stroke(360-hue,80,70);
  sphereDetail(20);
  sphere(shape_size);
  shape_size += shape_growing_speed*10;
  popMatrix();
}

void debug_overlay(float[] max_dims) {
  //hlights();
  
  fill(255);
  textSize(32);
  
  text("FPS:\n" + int(frameRate), -300, 100, 0);
  text("light:\n" + int(light_type), 0, 100, 0);
  text("max/min:\n" + 
  String.format("X: %.1f", max_dims[0]) + "/" + String.format("%.1f", max_dims[1]) + "\n"
  + String.format("Y: %.1f", max_dims[2]) + "/" + String.format("%.1f", max_dims[3]) + "\n"
  + String.format("Z: %.1f", max_dims[4]) + "/" + String.format("%.1f", max_dims[5]) + "\n",
  300, 100, 0);
  
  stroke(255);
  strokeWeight(4);
  
  int crosshair_len = 30;
  line(-crosshair_len,0,0,0);
  line(0,-crosshair_len,0,0);
  line(0,0,-crosshair_len,0,0,0);
  
  line(max_dims[0], max_dims[2], max_dims[4], max_dims[1], max_dims[3], max_dims[5]);
  
  stroke(0,80,100);
  fill(0,80,100);
  line(0,0,crosshair_len,0);
  text("X", -50, 50, 0);
  
  stroke(120,80,100);
  fill(120,80,100);
  line(0,0,0,crosshair_len);
  text("Y", 0, 50, 0);
  
  stroke(240,80,100);
  fill(240,80,100);
  line(0,0,0,0,0,crosshair_len);
  text("Z", 50, 50, 0);
}


// handle key inputs
void keyPressed() {
  if(key == 'm'){
    mirror = !mirror;
    kinect.enableMirror(mirror);}
    
  else if (key == 'h') {show_overlay = !show_overlay;}
  
  else if (key == 'f') {
    if (filter_world == true){filter_world = false;}
    else{
      start_milis_filt = millis();
      remeasure_world = true;}
    }
  
  else if (key == CODED) {
    if (keyCode == UP) {
      deg_kinect++;
    } else if (keyCode == DOWN) {
      deg_kinect--;
    }
    deg_kinect = constrain(deg_kinect, 0, 30);
    kinect.setTilt(deg_kinect);
  }
}


void noteOn(int channel, int pitch, int velocity) {
  
  println("Note on pitch:"+pitch);

  hue = random(360);
  
  pers_rand[0] = random(1);
  pers_rand[1] = random(1);
  pers_rand[2] = random(1);
  
  a = random(PI);
  b = random(1);
  
  int rgb[] = hsl_to_rgb(hue, sat, lig);
  
  //turn light on
  GetRequest get_on = new GetRequest("http://192.168.0.47/win&A=255");
  get_on.send();
  
  GetRequest get_r = new GetRequest("http://192.168.0.47/win&R="+rgb[0]);
  get_r.send();
  GetRequest get_g = new GetRequest("http://192.168.0.47/win&G="+rgb[1]);
  get_g.send();
  GetRequest get_b = new GetRequest("http://192.168.0.47/win&B="+rgb[2]);
  get_b.send();
}


void controllerChange(int channel, int number, int value) {
  
  float value_norm = value/127.0f;
  
  switch(number){
    //movement speed
    case 1:{movement_speed = value_norm;
            println("movement_speed: "+movement_speed);}
    break;
    //movement type
    case 2:{int number_of_types = 2;
            movement_type = round(1+value_norm*(number_of_types-1));
            println("movement_type: "+movement_type);}
    break;
    //point detail
    case 3:{int number_of_details = 10;
            point_detail = round(1+value_norm*(number_of_details-1));
            println("point_detail: "+point_detail);}
    break;
    //shape type
    case 4:{int number_of_shape = 1;
            shape_type = round(1+value_norm*(number_of_shape-1));
            println("shape_type: "+shape_type);}
    break;
    //shape growing speed
    case 5:{shape_growing_speed = value_norm;
            println("shape_growing_speed: "+shape_growing_speed);}
    break;
    //shape points spreading in x dir
    case 6:{spread_points_x = value_norm;
            println("spread_points_x: "+spread_points_x);}
    break;
    //shape points spreading in y dir
    case 7:{spread_points_y = value_norm;
            println("spread_points_y: "+spread_points_y);}
    break;
    //light type
    case 8:{int number_of_light_type = 4;
            light_type = round(1+value_norm*(number_of_light_type-1));
            println("light_type: "+light_type);}
    break;
  }
  
}

int[] hsl_to_rgb(float h,float s,float l){
  float r;
  float g;
  float b;
  
  h = h/360.0;
  s = s/100.0;
  l = l/100.0;
  
  if (s == 0) {
    r = 1;
    g = 1;
    b = 1;}
  else{
    float q = l < 0.5 ? l * (1+s) : l+s-l*s;
    float p = 2*l-q;
    r = hue2rgb(p, q, h+1/3.0);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h-1/3.0);}
  
  int rgb[] = new int[3];
  
  rgb[0] = int(r*255);
  rgb[1] = int(g*255);
  rgb[2] = int(b*255);
  
  return rgb;
}

float hue2rgb(float p, float q, float t){
  if (t < 0){t = t+1;}
  if (t > 1){t = t-1;} 
  if (t < 1/6.0){return p+(q-p)*6*t;}
  if (t < 1/2.0){return q;}
  if (t < 2/3.0){return p+(q-p)*(2/3-t)*6;}
  return p;}
  
// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {
  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}
