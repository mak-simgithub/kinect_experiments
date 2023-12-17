// Daniel Shiffman
// All features test

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

import java.util.Arrays; 
import java.util.Collections;

Kinect kinect;

import gab.opencv.*;
OpenCV opencv;
PImage depth_img, depth_avg, canny;
int[] depth_data;

float deg;

boolean ir = true;
boolean colorDepth = false;
boolean mirror = true;

float[] depthLookUp = new float[2048];

void setup() {
  size(1280, 480);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  
  kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  kinect.enableMirror(mirror);

  deg = kinect.getTilt();
  // kinect.tilt(deg);
  
  depth_img = kinect.getDepthImage();
  
  depth_data = kinect.getRawDepth();
  
  for (int i = 0; i < depthLookUp.length; i++) {
  depthLookUp[i] = rawDepthToMeters(i);
  
}
}


void draw() {
  background(0);

  depth_data = kinect.getRawDepth();
  
  print(Arrays.stream(depth_data).min().getAsInt());
  print("\n");
  print(Arrays.stream(depth_data).max().getAsInt());
  print("\n");
  /*
  delay(3000);*/
  
  
  depth_img = kinect.getDepthImage();
  depth_avg = depth_img.copy();
  
  image(depth_img, 640, 0);
  
  
  depth_avg.loadPixels();
  
  
  int centervalue = 0;
  
  for (int x = 0; x < depth_img.width; x++) {
    for (int y = 0; y < depth_img.height; y++ ) {
      int loc = x + y*depth_img.width;
      
      depth_avg.pixels[loc] = color(0,0,depth_data[loc]/2048.0*255.0);
      
      if (loc == (depth_img.width*depth_img.height/2-depth_img.width/2))
      {centervalue = depth_data[loc];
    depth_avg.pixels[loc] = color(0,255,0);}

      
    }
  }
  
  depth_avg.updatePixels();
  
  image(depth_avg, 0, 0);
  

  fill(255);

  textSize(220);
text(depthLookUp[centervalue], 330, 180); 
stroke(255);
strokeWeight(4);

line(310,240,330,240);
line(320,230,320,250);

line(640+310,240,640+330,240);
line(640+320,230,640+320,250);

  
}

void keyPressed() {
  if (key == 'i') {
    ir = !ir;
    kinect.enableIR(ir);
  } else if (key == 'c') {
    colorDepth = !colorDepth;
    kinect.enableColorDepth(colorDepth);
  }else if(key == 'm'){
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

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}
