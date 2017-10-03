import ddf.minim.*;
import ddf.minim.ugens.*;
import oscP5.*;
import netP5.*;
/*
 * TODO:
 * animate camera movement
 * implement minim audio objects
 * 
 */
// options & constants
static final int SCALE_ALL=3;
static final int SUN_SIZE=(1391/SCALE_ALL);
static final float CAMERA_MOVE=45*0.01f;
static final float MAX_W=(45*12);
static final boolean DEPTH_SORTING=true;
static final int SPHERE_DETAIL=30;            // How detailed to draw the spheres
static final boolean TEXTURED_PLANETS=true;   // load textures on planets
static final boolean TEXTURED_SUN=true;
static final int NUM_PLANETS=8;
static final boolean USE_MINIM=true;      // use Minim for audio creation
static final boolean USE_OSC=false;         // output Osc (for PD)
static final boolean DRAW_ORBITS=false;    // Draw the planets' orbit paths 
static final int OSC_CHANNEL=12000;        // OSC channel -> must match PD patch

Stars theStars=new Stars();  // starfield which twinkles

static int idx=0;  // holds the planets index from the sun to identify to PD
Planet planets[]=new Planet[NUM_PLANETS];
Sun sun;
float h=45f, w=45f, z=0;  // camera co-ordinates
float cameraMoveX=0, cameraMoveY=0, cameraMoveZ=0; // camera movement
boolean cameraMoving=false;
//kludge FIXME
Planet starfield;
Planet earth;

// OSC broadcasting
OscP5 osc;
NetAddress na;
// Minim audio
Minim minim;
AudioOutput audioOutput;
AudioPlanet audioPlanet;
abstract class DrawableSphere {
  PVector location=new PVector(0,0,0);
  abstract void draw();
}
// Planet details
//static final String planet_names[] ={
//  "Mercury", "Venus", "Earth", "Mars",
//  "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"
//};
//static final int planet_orbit_distances[] = {
//  50, 150, 200, 275, 450, 550, 670, 850, 1250
//};
//static final int planet_sizes [] = {
//  5, 10, 16, 22, 30, 24, 22, 20, 3
//};
// Look up tables for performance
static float sinLUT[];
static float cosLUT[];
static final float SINCOS_PRECISION = 0.5f;
static final int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);
static {
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];

  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
  }
}

 // logic to sort the elements
DrawableSphere[] bubble_sort(DrawableSphere array[]) {
  int n = NUM_PLANETS+1;
  int k;
  DrawableSphere [] retPlan=new DrawableSphere[NUM_PLANETS+1];
  for (int i=0; i< NUM_PLANETS; i++){
    retPlan[i]=planets[i];
  }
  retPlan[NUM_PLANETS]=sun;
  for (int m = n; m >= 0; m--) {
    for (int i = 0; i < n - 1; i++) {
      k = i + 1;
      if (retPlan[i].location.y > retPlan[k].location.y) {
        swapPlanets(i, k, retPlan);
      }
    }
  }
  for (int i=0; i<NUM_PLANETS+1; i++)
      System.err.println(""+retPlan[i]);

  return retPlan;
}

void swapPlanets(int i, int j, DrawableSphere[] array) {
  DrawableSphere temp;
  temp = array[i];
  array[i] = array[j];
  array[j] = temp;
}
    
void setup(){
  size(800, 600, P3D);
  //fullScreen(P3D);
float fov = PI/3.0;
float cameraZ = (height/2.0) / tan(fov/2.0);
perspective(fov, float(width)/float(height), 
            cameraZ/10.0, cameraZ*30.0);
  if (DEPTH_SORTING)
    hint(ENABLE_DEPTH_SORT);  // This fixes depth sorting but makes things incredibly slow
  frameRate(25);
  sphereDetail(SPHERE_DETAIL);
  smooth();
  sun=new Sun();
//  for (int i=1; i<NUM_PLANETS+1; i++){
//    planets[i-1]=new Planet(sun, planet_orbit_distances[i-1], planet_names[i-1]);
//    planets[i-1].setColor(i*50, 250-(i*50), i*30);
//    planets[i-1].setSpeed(random(-1.5, 1.5));
//    planets[i-1].setSize(planet_sizes[i-1]);
//  }
  // Minim sound
  if (USE_MINIM){
    minim = new Minim(this);
    // get a line out from Minim, default sample rate is 44100, default bit depth is 16
    audioOutput = minim.getLineOut(Minim.STEREO, 2048);
  }
  // TODO:
   planets[0] = new PlanetMercury(sun); //... etc
   planets[1] = new PlanetVenus(sun);
   planets[2] = new PlanetEarth(sun);
   earth=planets[2];
   planets[3] = new PlanetMars(sun);
   planets[4] = new PlanetJupiter(sun);
   planets[5] = new PlanetSaturn(sun);
   planets[6] = new PlanetUranus(sun);
   planets[7] = new PlanetNeptune(sun);
   starfield = new Planet(sun, 0, "starfield");
   starfield.setRadius(150);
   starfield.setSize(30500000);
   starfield.ts.velocityY=0;
   
  if (USE_OSC){
    osc=new OscP5(this, OSC_CHANNEL);
    na=new NetAddress("127.0.0.1", OSC_CHANNEL);  // localhost
  }
  background(0);
}

void draw(){
  background(0);
  smooth();
  noStroke();
  //  lights();
  translate(width/2, height/2);
  moveCamera();
//  camera(0.0+(45*w), 45.0*(10*h), 175.0+(45*z), 50.0, 50.0, 0.0, 0.0, 1.0, 0.0);
  camera(w, (10*h), 175+z, earth.location.x, earth.location.y, 0, 0, 1, 0);
  spotLight(175, 175, 40, 0, 0, 1, 0, 0, 1, PI, 0.05); 
  ambientLight(150, 150, 100);
  /*
   * TODO:
   * depth sort here!!!
   */
  theStars.draw();
  //starfield.move();
  //starfield.draw();
  sun.draw();
  for (int i=0; i<NUM_PLANETS; i++){
    planets[i].move();
    planets[i].broadcast(osc, na);
    planets[i].draw();
  }
//    DrawableSphere [] drawPlanets=bubble_sort(planets);
//  for (int i=0; i<NUM_PLANETS+1; i++){
//    drawPlanets[i].draw();
//  }
 // Object [] depthsort = new Object[NUM_PLANETS+1];
 // for (int i=0;i<NUM_PLANETS+1; i++){
 //   if (planets[i] < planets[i+1])
 // }

  // draw the Minim waveforms
  /*
  stroke(255);
  for (int i = 0; i < audioOutput.bufferSize()-1; i++)
  {
    pushMatrix();
     float x1 = map(i, 0, audioOutput.bufferSize(), 0, width);
     float x2 = map(i+1, 0, audioOutput.bufferSize(), 0, width);
     line(x1, 50 + audioOutput.left.get(i)*50, x2, 50 + audioOutput.left.get(i+1)*50);
     line(x1, 150 + audioOutput.right.get(i)*50, x2, 150 + audioOutput.right.get(i+1)*50);
     popMatrix();
  }
  */
}

// move camera if keypressed or being animated
void moveCamera(){
  if (!cameraMoving)  return;
  h+=cameraMoveX;
  w+=cameraMoveY;
  z+=cameraMoveZ;
  if (h>=MAX_W) h=MAX_W;
  if (h<=-MAX_W) h=-MAX_W;
  if (w<=0) w=0;
  if (w>=MAX_W) w=MAX_W;
  if (z<=-MAX_W) z=MAX_W;
  if (z>=MAX_W) z=MAX_W;
}

public void keyReleased(){
  cameraMoving=false;
}
public void keyPressed(){
  if (keyPressed){
    cameraMoving=true;
    if (key=='R'||key=='r'){
      h=0.35*45; w=0.35*45; z=0.35*45;
      cameraMoveX=0; cameraMoveY=0; cameraMoveZ=0;
      camera();
      cameraMoving=false;
    } else if (key=='Q' || key == 'q'){
      cameraMoveZ=CAMERA_MOVE; cameraMoveX=0;cameraMoveY=0;
    }
    else if (key=='W' || key == 'w'){
      cameraMoveZ=-CAMERA_MOVE; cameraMoveX=0; cameraMoveY=0;
    }
    else if (key == CODED){
      if (keyCode==DOWN){
        cameraMoveX = CAMERA_MOVE; cameraMoveY=0; cameraMoveZ=0;
      } 
      else if (keyCode == UP){
        cameraMoveX= -CAMERA_MOVE; cameraMoveY=0; cameraMoveZ=0;
      } 
      else if (keyCode == RIGHT){
        cameraMoveY=CAMERA_MOVE; cameraMoveX=0; cameraMoveZ=0;
      } 
      else if (keyCode == LEFT){
        cameraMoveY=-CAMERA_MOVE; cameraMoveX=0; cameraMoveZ=0;
      }
    } else cameraMoving=false;
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //  print("### received an osc message.");
  //  print(" addrpattern: "+theOscMessage.addrPattern());
  //  println(" typetag: "+theOscMessage.typetag());
}
void stop(){
  if (USE_MINIM){
    audioOutput.close();
    minim.stop();
  }
  super.stop();
}