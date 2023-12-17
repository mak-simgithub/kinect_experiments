int last = -999;

void settings() { 
  System.setProperty("jogl.disable.openglcore", "false");
  size(1600, 800, P3D);
  smooth(2);
}

void setup() {
  //size(1800,900,P3D);
  colorMode(HSB,360,100,100,100);}
  
void draw() {
  int now = millis();
  if ((now-last)%3000<1500){
    directionalLight(12,80,70,0,1,0);}
  else{
    int i = 1;}
  background(0);
  stroke(360-142,80,70);
  translate(width/2, height/2,200);
  sphere(50);
  sphereDetail(5);
}
