import org.openkinect.freenect.*;
import org.openkinect.processing.*;
Kinect kinect;

import gab.opencv.*;
OpenCV opencv;

import java.util.Arrays; 

PImage blank_img, depth_img, depth_art, canny_img;
int[] depth_data;

float deg;

boolean ir = true;
boolean colorDepth = false;
boolean mirror = true;

int event_1 = -9999;

float hue;

int bpm = 60;

void setup() {
  //P3D eats memory
  size(1920, 520);
  colorMode(HSB,360,100,100,100);
  
  kinect = new Kinect(this);
  kinect.initDepth();
  
  kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  kinect.enableMirror(mirror);

  deg = kinect.getTilt();
  // kinect.tilt(deg);
  
  depth_data = kinect.getRawDepth();
  
  depth_img = createImage(640,480,ARGB);
  depth_art = createImage(640,480,ARGB);
}


void draw() {
  int now = millis();
  
  if ((now-event_1)>(60000/bpm)){
    hue = random(360);
    event_1 = millis();}
  
  
  background(360-hue,80,70);

  depth_data = kinect.getRawDepth();
  
  print(Arrays.stream(depth_data).min().getAsInt());
  print("\n");
  print(Arrays.stream(depth_data).max().getAsInt());
  print("\n");

  int lastval = 0;
  int value = 0;
  

  depth_img.loadPixels();
  depth_art.loadPixels();
  
  for (int x = 0; x < blank_img.width; x++) {
    for (int y = 0; y < blank_img.height; y++ ) {
      int loc = x + y*blank_img.width;
      
      
      if (depth_data[loc]==2047){
        depth_img.pixels[loc] = color(0,0,0,0);
        value = lastval;}
      else{
        depth_img.pixels[loc] = color(depth_data[loc]/2048.0*360.0,80,70,100);
        value = depth_data[loc];}
        lastval = value;
      
      if (loc == 1000){
        print(value);
        print("\n");}
      
      //value 0 and 2047, 2048 means OOB
      //0 is near
      //depthInMeters = 1.0 / (rawDepth * -0.0030711016 + 3.3309495161);
      
      int steps = 50;
      
      float steps_mod = 2048.0/steps;
      float f_value = value/steps_mod/steps;

      if (loc == 1000){
      print(f_value);
      print("\n");}
      
      int alpha = 100;
      if (f_value > 0.4){
        alpha = 0;}
      
      depth_art.pixels[loc] = color(hue,80*f_value,70,alpha);
    }
  }
  
  depth_img.updatePixels();
  depth_art.updatePixels();
  
  image(depth_img, 0, 0);
  image(depth_art, 640, 0);
  
  opencv = new OpenCV(this, depth_img);
  opencv.findCannyEdges(5,10);
  canny_img = opencv.getSnapshot();
  image(canny_img, 1280, 0);
  
  
  forceCacheRemoval(depth_img);
  forceCacheRemoval(depth_art);
  forceCacheRemoval(canny_img);
  
  
  fill(255);
  text(
    "i: enable/disable between video image and IR image,  " +
    "Press 'c' to enable/disable between color depth and gray scale depth,  " +
    "Press 'm' to enable/diable mirror mode, "+
    "UP and DOWN to tilt camera   ", 10, 495);
    
  text("Framerate: " + int(frameRate), 10, 510);
  
}

void keyPressed() {
  if(key == 'm'){
    mirror = !mirror;
    kinect.enableMirror(mirror);
  } else if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg, 0, 30);
    kinect.setTilt(deg);
  }
}

void forceCacheRemoval(PGraphics pg) {
  for (PImage img: images) {
    Object cache = pg.getCache(img);
 
    if (cache instanceof Texture)
      ((Texture) cache).disposeSourceBuffer();
 
    pg.removeCache(img);
  }
}
