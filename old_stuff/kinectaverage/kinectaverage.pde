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
int[] depth_data_1, depth_data_2, depth_data_3, depth_data_4, depth_data_5, depth_data_avg;

float deg;

boolean ir = true;
boolean colorDepth = true;
boolean mirror = true;

void setup() {
  size(1280, 1000);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  
  kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  kinect.enableMirror(mirror);

  deg = kinect.getTilt();
  // kinect.tilt(deg);
  
  depth_img = kinect.getDepthImage();
  
  depth_data_avg = kinect.getRawDepth();
  depth_data_1 = depth_data_avg.clone();
  depth_data_2 = depth_data_avg.clone();
  depth_data_3 = depth_data_avg.clone();
  depth_data_4 = depth_data_avg.clone();
  depth_data_5 = depth_data_avg.clone();
}


void draw() {
  background(0);
  image(kinect.getVideoImage(), 0, 0);
  
  depth_data_5 = depth_data_4.clone();
  depth_data_4 = depth_data_3.clone();
  depth_data_3 = depth_data_2.clone();
  depth_data_2 = depth_data_1.clone();
  depth_data_1 = kinect.getRawDepth();
  
  print(Arrays.stream(depth_data_1).min().getAsInt());
  print("\n");
  print(Arrays.stream(depth_data_1).max().getAsInt());
  print("\n");
  /*
  delay(3000);*/
  
  
  depth_img = kinect.getDepthImage();
  depth_avg = depth_img.copy();
  
  image(depth_img, 640, 0);
  
  
  depth_avg.loadPixels();
  
  int acc = 0;
  int lastval = 0;
  
  float r_fact = random(1);
  float g_fact = random(1);
  float b_fact = random(1);
  
  float tot_lum = r_fact + g_fact + b_fact;
  
  float des_lum = 5;
  
  r_fact = r_fact/tot_lum*des_lum;
  g_fact = g_fact/tot_lum*des_lum;
  b_fact = b_fact/tot_lum*des_lum;
  
  /*float r_fact = 1;
  float g_fact = 1;
  float b_fact = 1;*/
  
  
  for (int x = 0; x < depth_img.width; x++) {
    for (int y = 0; y < depth_img.height; y++ ) {
      int loc = x + y*depth_img.width;
      float sum = 0;
      acc = 0;
      
      if (depth_data_1[loc]<2047) {
        acc = acc+1;
        sum = sum+depth_data_1[loc];}
      if (depth_data_2[loc]<2047) {
        acc = acc+1;
        sum = sum+depth_data_2[loc];}
      if (depth_data_3[loc]<2047) {
        acc = acc+1;
        sum = sum+depth_data_3[loc];}
      if (depth_data_4[loc]<2047) {
        acc = acc+1;
        sum = sum+depth_data_4[loc];}
      if (depth_data_5[loc]<2047) {
        acc = acc+1;
        sum = sum+depth_data_5[loc];}
      
      int value = 0;
      
      if (acc==0){
        value = lastval;}
      else{
      value = int(sum/acc);
      int steps = 50;
      int steps_mod = 2048/steps;
      int fullbright = 255;
      int brightcorr = fullbright/steps;
      value = value/steps_mod*brightcorr;}
      
      lastval = value;
      
      if (loc == 1000){
      print(value);
      print("\n");}
      
      depth_avg.pixels[loc] = color(r_fact*value,g_fact*value,b_fact*value);
    }
  }
  
  depth_avg.updatePixels();
  
  image(depth_avg, 0, 480);
  
  opencv = new OpenCV(this, depth_avg);
  opencv.findCannyEdges(5,10);
  canny = opencv.getSnapshot();
  image(canny, 640, 480);
  fill(255);
  text(
    "Press 'i' to enable/disable between video image and IR image,  " +
    "Press 'c' to enable/disable between color depth and gray scale depth,  " +
    "Press 'm' to enable/diable mirror mode, "+
    "UP and DOWN to tilt camera   ", 10, 980);
  text(
    "Framerate: " + int(frameRate), 10, 990);
    
    
  delay(1000);
  
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
