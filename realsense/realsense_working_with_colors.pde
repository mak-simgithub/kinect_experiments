import ch.bildspur.realsense.*;
import ch.bildspur.realsense.processing.*;
import ch.bildspur.realsense.stream.*;
import ch.bildspur.realsense.type.*;

import org.intel.rs.frame.Points;
import org.intel.rs.processing.PointCloud;
import org.intel.rs.processing.DecimationFilter;
import org.intel.rs.types.Vertex;
import org.intel.rs.frame.DepthFrame;
import org.intel.rs.types.Option;

import peasy.*;
PeasyCam cam;

import oscP5.*;
OscP5 oscP5;

RealSenseCamera camera = new RealSenseCamera(this);
PointCloud pointCloud = new PointCloud();
DecimationFilter decimationFilter = new DecimationFilter();

float scaleFactor = 500;  // Increased scale
int streamWidth = 424;
int streamHeight = 240;

float hue = random(360);
float sat = 80;
float lig = 70;
float point_size;

//camera related vars
int max_dist = 500;
int min_dist = 200;
float a = 0;
float b = 0;
int light_type = 4;
float[] pers_rand = new float[3];
float[] max_dims = new float[6]; // Define max_dims


//MIDI changeable vars
float shape_growing_speed = 0.5;
int shape_type = 1;
float shape_size = 0;
int movement_type = 1;
float movement_speed = 0.08;
float spread_points_x = 1;
float spread_points_y = 1;
int point_detail = 3;
int point_type = 1;
float angle_x = 3;
float angle_y = 3;
float loudness;
int spread_points = 100;

import java.io.File;
import processing.video.*;

Movie myVideo;
File[] videoFiles;
int currentVideoIndex = 0;
boolean goToNextVideo = true;


void setup() {
  System.setProperty("jogl.disable.openglcore", "false");
  //size(1920, 1680, P3D);
  size(640, 320, P3D);
  //fullScreen(P3D);
  smooth(2);
  colorMode(HSB, 360, 100, 100, 100);

  oscP5 = new OscP5(this, 3000);

  camera(0, 0, 800, 0, 0, 0, 0, 1, 0);

  cam = new PeasyCam(this, 400);

  camera.enableDepthStream(streamWidth, streamHeight);
  camera.start();

  // Initialize variables
  File videoFolder = new File("/home/luca/repos/kinect_experiments/realsense_working_with_colors/video");
  videoFiles = videoFolder.listFiles((dir, name) -> name.toLowerCase().endsWith(".mp4"));

}

void draw() {
  set_light();
  
  point_size = loudness/93;
  background(hue, 80, 70);

  // Read frames
  camera.readFrames();
  DepthFrame depthFrame = camera.getFrames().getDepthFrame();
  DepthFrame decimatedFrame = decimationFilter.process(depthFrame);

  Points points = pointCloud.calculate(decimatedFrame);
  Vertex[] vertices = points.getVertices();

  points.release();
  decimatedFrame.release();

  draw_world(vertices, (hue+180)%360, 80, 100, point_detail, point_type);
  
    showVideo();


  move_camera();

  surface.setTitle("FPS: " + nf(frameRate, 0, 2));
}

void move_camera() {
  switch (movement_type) {
    //rotate from random angle in random direction around center
  case 1:
    {
      camera(((max_dist-min_dist)*pers_rand[0]+min_dist)*pers_rand[0]*2-1, //eyeX
        ((max_dist-min_dist)*pers_rand[1]+min_dist)*pers_rand[1]*2-1, //eyeY
        ((max_dist-min_dist)*pers_rand[2]+min_dist)*pers_rand[2]*2-1, //eyeZ
        (max_dims[0]+max_dims[1])/2, //centerX
        (max_dims[2]+max_dims[3])/2, //centerY
        -(max_dims[4]+max_dims[5])/2, //centerZ
        cos(a), //upX
        sin(a), //upY
        0); //upZ

      a -= 0.1f*(round(pers_rand[0])*2-1)*movement_speed;
    }
    break;
  case 2:
    {
      camera((max_dims[0]+max_dims[1])/2+pers_rand[2]*(max_dims[1]-max_dims[0])*angle_x-(max_dims[1]-max_dims[0])/2*angle_x,
        (max_dims[2]+max_dims[3])/2+pers_rand[2]*(max_dims[3]-max_dims[2])*angle_y-(max_dims[3]-max_dims[2])/2*angle_y,
        ((max_dist-min_dist)*pers_rand[2]+min_dist)*(pers_rand[2]+a)*2-1,
        (max_dims[0]+max_dims[1])/2,
        (max_dims[2]+max_dims[3])/2,
        -(max_dims[4]+max_dims[5])/2,
        0,
        1,
        0);

      a -= 0.5f*movement_speed;
    }
    break;
  }
}

void set_light() {
  switch (light_type) {
  case 1:
    {
      directionalLight(360-hue+90, 80, 70, pers_rand[0], pers_rand[1], pers_rand[2]);
      //camera(width/2.0, height/2.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
      perspective();
    }
    break;
  case 2:
    {
      directionalLight(12, 80, 100, 0, 1, 0);
      //camera(width/4.0, height/2.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
    }
    break;
  case 3:
    {
      pointLight(360-hue+90, 80, 70, pers_rand[0], pers_rand[1], pers_rand[2]);
      //camera(width/2.0, height/4.0, 0, width/2.0, height/2.0, -100, 0, 1, 0);
    }
    break;
  case 4:
    {
      int i = 0;
    }
    break;
  }
}


void draw_world(Vertex[] vertices, float hue, float sat, float lig, int detail, int shape) {

  // Create the shape dynamically
  beginShape();
  
  for (Vertex v : vertices) {
    float this_point_size = point_size * (0.9+0.2*random(1));

    stroke(hue+this_point_size*10, lig, sat);

    pushMatrix();
    translate(v.getX() * spread_points_x *spread_points, v.getY() * spread_points_y*spread_points, -v.getZ()*spread_points);

    if (v.getX()*spread_points < max_dims[0]) {
      max_dims[0] = v.getX()*spread_points;
    }
    if (v.getX()*spread_points > max_dims[1]) {
      max_dims[1] = v.getX()*spread_points;
    }
    if (v.getY()*spread_points < max_dims[2]) {
      max_dims[2] = v.getY()*spread_points;
    }
    if (v.getY()*spread_points > max_dims[3]) {
      max_dims[3] = v.getY()*spread_points;
    }
    if (v.getZ()*spread_points < max_dims[4]) {
      max_dims[4] = v.getZ()*spread_points;
    }
    if (v.getZ()*spread_points > max_dims[5]) {
      max_dims[5] = v.getZ()*spread_points;
    }
    
    // Draw a shape
    switch (shape_type) {
    case 1:
      {
        sphereDetail(3);
        sphere(this_point_size);
      }
      break;
    case 2:
      {
        sphereDetail(2);
        sphere(this_point_size);
      }
      break;
    case 3:
      {
        box(this_point_size);
      }
      break;
    case 4:
      {
        tetrahedron(this_point_size);
      }
    }

    popMatrix();
  }
}

void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/loudness")==true) {


    loudness = theOscMessage.get(0).floatValue();
    //println("loudness: "+string_value);
    return;
  }

  if (theOscMessage.checkAddrPattern("/bonk")==true) {

    hue = random(360);

    pers_rand[0] = random(1);
    pers_rand[1] = random(1);
    pers_rand[2] = random(1);

    a = random(PI);
    b = random(1);

    //randomize some stuff
    movement_type = int(1+random(2));
    shape_type = int(1+random(4));
    light_type = int(4);

    println("movement_type:"+movement_type);
    println("shape_type:"+shape_type);
    println("light_type:"+light_type);

    shape_size = 0;

    float string_value = theOscMessage.get(0).floatValue();
    println("bonk: "+string_value);
    return;
  }
}

void controllerChange(int channel, int number, int value) {

  println("controller change");

  float value_norm = value/127.0f;

  switch(number) {
    //movement speed
  case 1:
    {
      movement_speed = value_norm;
      println("movement_speed: "+movement_speed);
    }
    break;
    //movement type
  case 2:
    {
      int number_of_types = 2;
      movement_type = round(1+value_norm*(number_of_types-1));
      println("movement_type: "+movement_type);
    }
    break;
    //shape type
  case 4:
    {//int number_of_shape = 4;
      //shape_type = round(1+value_norm*(number_of_shape-1));
      angle_x = value_norm/127.0*3;
      println("angle_x: "+angle_x);
    }
    break;
    //shape growing speed
  case 5:
    {//shape_growing_speed = value_norm;
      angle_y = value_norm/127.0*3;
      println("angle_y: "+angle_y);
    }
    break;
    //shape points spreading in x dir
  case 6:
    {
      spread_points_x = value_norm;
      println("spread_points_x: "+spread_points_x);
    }
    break;
    //shape points spreading in y dir
  case 7:
    {
      spread_points_y = value_norm;
      println("spread_points_y: "+spread_points_y);
    }
    break;
    //light type
  case 8:
    {
      int number_of_light_type = 4;
      light_type = round(1+value_norm*(number_of_light_type-1));
      println("light_type: "+light_type);
    }
    break;
  }
}

void tetrahedron(float size) {
  beginShape(TRIANGLE_STRIP);
  fill(255);

  vertex(-size, -size, -size);   //1
  vertex( 0, 0, -size);          //2
  vertex(   0, -size, 0);    //3
  vertex( -size, 0, 0);         //4
  vertex(-size, -size, -size);   //1
  vertex( 0, 0, -size);          //2

  endShape(CLOSE);
}

void showVideo() {
  if(goToNextVideo){
    loadNextVideo();}

  beginShape();
  texture(myVideo); // Apply the video as a texture
  vertex(-240, 135, -250, 0, myVideo.height); // Bottom left
  vertex(240, 135, -250, myVideo.width, myVideo.height); // Bottom right
  vertex(240, -135, -250, myVideo.width, 0); // Top right
  vertex(-240, -135, -250, 0, 0); // Top left
endShape(CLOSE);
  
}


void loadNextVideo() {
  

  if (videoFiles != null && videoFiles.length > 0) {
    String videoPath = videoFiles[currentVideoIndex].getAbsolutePath();
    myVideo = new Movie(this, videoPath);
    myVideo.loop();

    // Update the current video index
    currentVideoIndex = (currentVideoIndex + 1) % videoFiles.length;
  }
  goToNextVideo = false;
}

void movieEvent(Movie m) {
  m.read(); // Read the video file on each frame

  // Load the next video when the current one finishes
  if (m.time() >= m.duration() - 1) {
    goToNextVideo = true;
  }
}
