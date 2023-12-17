import themidibus.*; //Import the library
import http.requests.*;


MidiBus myBus; // The MidiBus

float h_rand = random(360);
float s_rand = random(100);
float l_rand = random(100);

float circle_size = 1;
float circle_size2 = 1;
float circle_size_old = 1;

int time_old = 0;
int time_d = 0;

void setup() {
  size(1600, 1200);
  background(random(360),random(100),random(100));

  //MidiBus.list(); 
  
  myBus = new MidiBus(this, 1, "VirMIDI [hw:3,0,0]");
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  
  int time_d_n = millis()-time_old;
  float circle_size_interp = circle_size;//time_d_n/time_d*(circle_size-circle_size_old)+circle_size;
  
  background(h_rand,s_rand,l_rand);
  fill((h_rand+180)%360, s_rand, l_rand);
  stroke((h_rand+180)%360, s_rand, l_rand);
  circle(width/4,height/2,circle_size);
  circle(3*width/4,height/2,circle_size2);
  text(int(frameRate),20,60);
  delay(1);
}

void noteOn(int channel, int pitch, int velocity) {
  h_rand = random(360);
  s_rand = random(60,100);
  l_rand = random(40,90);
  
  int rgb[] = hsl_to_rgb(h_rand, s_rand, l_rand);
  
  String payload1 = String.valueOf(rgb[0]) +','+ String.valueOf(rgb[1]) +','+ String.valueOf(rgb[2]);
  String payload2 = String.format(','+ "%.1f", h_rand/360.0) +','+ String.format("%.1f", s_rand/100.0) +','+ String.format("%.1f", l_rand/100.0);
  
  GetRequest get = new GetRequest("http://192.168.40.19/save-to-log.php?message="+payload1+payload2);
  get.send();
}


void controllerChange(int channel, int number, int value) {
  float sane_value = value*0.07;
  //circle_size_old = circle_size;
  
  if (number>0){
  circle_size2 = sane_value*sane_value*sane_value;}
  else{
  circle_size = sane_value*sane_value*sane_value;}

  //time_d = millis()-time_old;
  //time_old = millis();
}

int[] hsl_to_rgb(float h,float s,float l){
  float r;
  float g;
  float b;
  
  h = h/360.0;
  s = s/100.0;
  l = l/100.0;
  
  if (s == 0)
  {r = 1;
  g = 1;
  b = 1;}
  else{
  float q = l < 0.5 ? l * (1+s) : l+s-l*s;
    float p = 2*l-q;
    r = hue2rgb(p, q, h+1/3.0);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h-1/3.0);
  }
  int rgb[] = new int[3];
  
  rgb[0] = int(r*1023);
  rgb[1] = int(g*1023);
  rgb[2] = int(b*1023);
  
  return rgb;
}

float hue2rgb(float p, float q, float t){
  if (t < 0){t = t+1;}
  if (t > 1){t = t-1;} 
  if (t < 1/6.0){return p+(q-p)*6*t;}
  if (t < 1/2.0){return q;}
  if (t < 2/3.0){return p+(q-p)*(2/3-t)*6;}
  return p;
};
