import ddf.minim.*;
import ddf.minim.ugens.*;
//import oscP5.*;
//import netP5.*;
import java.util.*;
/*
 * Music of the Spheres - Jerry Padfield 2017
 * MA Creative Media Practice - University of the West of Scotland - uws.ac.uk
 * TODO:
 * 
 *  ?
 */
// options & constants
static final int SCALE_ALL=3;        // scale all proportions down by this amount
static final int SUN_SIZE=(1391/SCALE_ALL);  // sun size
static final float CAMERA_MOVE=45*0.01f;     // amount the camera moves
static final boolean DEPTH_SORTING=true;      // use in-built depth sorting
static final int SPHERE_DETAIL=50;            // How detailed to draw the spheres
static final boolean TEXTURED_PLANETS=true;   // load textures on planets
static final boolean TEXTURED_SUN=true;        // load texture on sun
static final int NUM_PLANETS=8;
static final boolean USE_MINIM=true;      // use Minim for audio creation
//static final boolean USE_OSC=false;         // output Osc (for PD/MaxMSP)
static final boolean DRAW_ORBITS=true;    // Draw the planets' orbit paths - can't depth sort these properly unfortunately
//static final int OSC_CHANNEL=12000;        // OSC channel -> must match PD patch
static final boolean DRAW_WAVEFORMS=true;  // draw audio output waveforms
static final boolean MY_DEPTH_SORT=true;    // use depth sort algorithm: TODO remove this
static final int BUFFER_SCALE=6;          // how much to scale the audio buffer we sample to draw the audio waveform
static final boolean ENABLE_AUDIO_RECORDING=true; // whether to allow audio recording - this is to ensure not accidentally recording
//Stars theStars;  // starfield which twinkles - NOT USED

//static int idx=0;  // holds the planets index from the sun to identify to PD - not needed
Planet planets[]=new Planet[NUM_PLANETS];
Sun sun;
Planet starfield;    // draw the bg stars on a big textured sphere
Planet earth;        // hold a reference to earth so we can point the camera at it
CameraMover cameraMover;  // moves the camera around
// OSC broadcasting - NOT USED
//OscP5 osc;
//NetAddress na;
// Minim audio
Minim minim;
AudioOutput audioOutput;
AudioRecorder recorder; //to record the audio
final static String RECORDING_FILE="record.wav";

//used for the intro text
enum State {
  INTRO,
  LOADED
};
private State state=State.INTRO;
// timer to move camera around
private Timer t;

// Sin and Cosine look up tables for performance
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
 // probably a better way to do this
 // TODO: simply sort planets array each time rather than passing in an 
 // array - should be more efficient
 // distanceBetweenPoints = Math.sq(dx^2 + dy^2)
DrawableSphere[] bubble_sort(DrawableSphere array[]) {
  int n = NUM_PLANETS+1;
  int k;
  DrawableSphere [] retPlan=new DrawableSphere[NUM_PLANETS+1];
  //copy planets into the array
  arrayCopy(array, 0, retPlan, 0, NUM_PLANETS);
  //and the sun
  retPlan[NUM_PLANETS]=sun;
  //and sort relative to which is nearest the camera
  for (int m = n; m >= 0; m--) {
    for (int i = 0; i < n - 1; i++) {
      k = i + 1;
      //System.err.println("P: "+retPlan[i]);
      float dy=retPlan[i].location.y-cameraMover.getY();
      float dx=retPlan[i].location.x-cameraMover.getX();
      float dyk=retPlan[k].location.y-cameraMover.getY();
      float dxk=retPlan[k].location.x-cameraMover.getX();
      float dist = sqrt(pow(dy, 2)+pow(dx, 2));
      float distK = sqrt(pow(dyk, 2)+pow(dxk, 2));
      //System.err.println("dist: "+dist+", distK: "+distK);
      if (dist < distK)
        swapPlanets(i, k, retPlan);
    }
  }
  return retPlan;
}

void screenshot()  {  saveFrame("screenshots/MotS-######.png"); }

void swapPlanets(int i, int j, DrawableSphere[] array) {
  DrawableSphere temp;
  temp = array[i];
  array[i] = array[j];
  array[j] = temp;
}

float fov = PI/3.0;
float cameraZ;
// can play with this for different perspectives
void defaultPerspective(){
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*30.0);
}

void setup(){
  //size(800, 600, P3D);
  fullScreen(P3D); noCursor();
  cameraZ = (height/2.0) / tan(fov/2.0);
  defaultPerspective();
  theFont=createFont("Calibri", FONT_SIZE_BIG);
  theOtherFont=createFont("Calibri", FONT_SIZE);
  if (DEPTH_SORTING){
 //   hint(ENABLE_DEPTH_SORT);  // This fixes depth sorting but makes things incredibly slow
  }
  frameRate(25);
  sphereDetail(SPHERE_DETAIL);
  smooth(32);
  sun=new Sun();
//  if (!DEPTH_SORTING){
//    theStars=new Stars();
//  }

  // Minim sound
  if (USE_MINIM){
    minim = new Minim(this);
    // get a line out from Minim, default sample rate is 44100, default bit depth is 16
    audioOutput = minim.getLineOut(Minim.STEREO, 2048);
    audioOutput.shiftGain(-120, 0, 10000); //fade sound in
    recorder=minim.createRecorder(audioOutput, RECORDING_FILE);
    //recorder.beginRecord();
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
   if (DEPTH_SORTING){
     starfield = new Planet(sun, 0, "starfield");
     starfield.setRadius(150);
     starfield.setSize(4000000);
     starfield.ts.velocityY=0;
   }
    
  cameraMover=new CameraMover(earth);
  t=new Timer(true);
  t.scheduleAtFixedRate((TimerTask)cameraMover, 100, 100);

//  if (USE_OSC){
//    osc=new OscP5(this, OSC_CHANNEL);
//    na=new NetAddress("127.0.0.1", OSC_CHANNEL);  // localhost
//  }
  background(0);
}
// animate text out via alpha channel at intro
private int alpha=255;
private PFont theFont, theOtherFont;
private static final int FONT_SIZE_BIG=48;
private static final int FONT_SIZE=32;
private static final int FONT_SIZE_SMALL=16;
private void drawIntro(){
  pushMatrix();
  hint(DISABLE_DEPTH_TEST);
  camera();
  perspective();
  noLights();
 
  fill(0, 0, 0, alpha);
  stroke(0, 0, 0, alpha);
  rect(0, 0, width, height);
  fill(255, 255, 255, alpha);
  stroke(255, 255, 255, alpha);
  alpha--;
  textSize(FONT_SIZE_BIG);
  textFont(theFont);
  int textCounter=0;
  text("Music of the Spheres", width/2, height/2);
  textSize(FONT_SIZE);
  textFont(theOtherFont);
  textCounter+=36;
  text("By Jerry Padfield", width/2, height/2+textCounter);
  textCounter+=28;
  textSize(FONT_SIZE_SMALL);
  text("University of the West of Scotland", width/2, height/2+textCounter);
  textCounter+=FONT_SIZE_SMALL;
  text("MA Creative Media Practice", width/2, height/2+textCounter);
  textCounter+=(FONT_SIZE_SMALL*3);
  text("CMPG11006 Creative Media Practice Assignment 2017", width/2, height/2+textCounter);
  textCounter +=FONT_SIZE_SMALL;
  text("jerrypadfield.co.uk", width/2, height/2+textCounter);
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
  if (alpha==0) { state=State.LOADED; } // stop drawing text
}
float light=0.0025f;
float LIGHT_DELTA=0.001f;
void defaultLighting(){
  // lighting slows things down
  lightFalloff(1, 0, 0);   
  pointLight(255, 255, 255, 0, 0, 0);
  lightFalloff(0.1, light, 0.00001); //light falls off right behind the surface of the sun
  ambientLight(255, 255, 180, 0, 0, 0); //ambientLight in the center of the sun
  //lightSpecular(204, 204, 154);
}

void draw(){
  surface.setTitle("Music of the Spheres, FPS: "+frameRate);
  background(0);
  noStroke();
  noFill();
  defaultLighting();
  translate(width/2, height/2);
  cameraMover.setCamera();

//  if (!DEPTH_SORTING){
//      theStars.draw();
//  } else {
    starfield.move();
    starfield.draw();
//  }
  noStroke();
  fill(255);
  for (int i=0; i<NUM_PLANETS; i++){
    planets[i].move();
    //planets[i].broadcast(osc, na);
  }
  if (!MY_DEPTH_SORT){
    sun.draw();
    for (int i=0; i<NUM_PLANETS; i++)
      planets[i].draw();
  } else {
    DrawableSphere [] drawPlanets=bubble_sort(planets);
    for (int i=0; i<NUM_PLANETS+1; i++){
      drawPlanets[i].draw();
    }
  }
  // draw the Minim waveforms
  if (DRAW_WAVEFORMS){
    stroke(255, 255, 255, 80);
    hint(DISABLE_DEPTH_TEST);
//      translate(0, 0, -10);
    strokeWeight(2);
    pushMatrix();
    camera();
    perspective();
    for (int i = 0; i < audioOutput.bufferSize()/BUFFER_SCALE-1; i++)
    {
      float x1 = map(i, 0, audioOutput.bufferSize()/BUFFER_SCALE, 0, width);
      float x2 = map(i+1, 0, audioOutput.bufferSize()/BUFFER_SCALE, 0, width);
      line(x1, height-150 + audioOutput.left.get(i)*50, x2, height-150 + audioOutput.left.get(i+1)*50);
      line(x1, height-50 + audioOutput.right.get(i)*50, x2, height-50 + audioOutput.right.get(i+1)*50);
    }
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }
   if (state == State.INTRO){
      drawIntro();
      defaultPerspective();
  }
}

public void keyReleased(){
  cameraMover.stopMoving();
}

public void keyPressed(){
  if (keyPressed){
    if (key=='R'||key=='r'){  // reset the camera
      cameraMover.reset();
    } else if (key=='Q' || key == 'q'){ // increase Z
        cameraMover.startMoving();;
        cameraMover.moveZ(CAMERA_MOVE);
    }
    else if (key=='W' || key == 'w'){  // decrease Z
      cameraMover.startMoving();;
      cameraMover.moveZ(-CAMERA_MOVE);
    }
//    else if (key == 'l' || key=='L'){    // for testing lighting values
//      light+=LIGHT_DELTA;
 //     System.err.println("light: "+light);
//    }
//    else if (key=='k' || key == 'K'){
//      light-=LIGHT_DELTA;
//      System.err.println("light: "+light);
//    }
  else if (key == 's' || key == 'S'){
    screenshot();
  }
    else if (key=='P' || key == 'p'){
      if (recorder.isRecording()){
        System.err.println("Saving file: "+RECORDING_FILE);
        recorder.endRecord();
        recorder.save();
      } else { 
        if (ENABLE_AUDIO_RECORDING){
          System.err.println("Recording to: "+RECORDING_FILE);
          recorder.beginRecord();
        }
      }
    }
    else if (key == CODED){
      if (keyCode==DOWN){
    cameraMover.startMoving();;
        cameraMover.moveY(CAMERA_MOVE);
      } 
      else if (keyCode == UP){
    cameraMover.startMoving();;
        cameraMover.moveY(-CAMERA_MOVE);
      } 
      else if (keyCode == RIGHT){
    cameraMover.startMoving();;
        cameraMover.moveX(CAMERA_MOVE);
      } 
      else if (keyCode == LEFT){
    cameraMover.startMoving();;
        cameraMover.moveX(-CAMERA_MOVE);
      }
    } else if (key == 'A' || key =='a'){
        cameraMover.toggleAnimating();
    }
    else cameraMover.stopMoving();
  }
}

/* incoming osc message are forwarded to the oscEvent method.
void oscEvent(OscMessage theOscMessage) {
  // print the address pattern and the typetag of the received OscMessage
  //  print("### received an osc message.");
  //  print(" addrpattern: "+theOscMessage.addrPattern());
  //  println(" typetag: "+theOscMessage.typetag());
} */
void stop(){
  if (USE_MINIM){
    if (recorder.isRecording()){
      recorder.endRecord();
      recorder.save();
    }
    audioOutput.close();
    minim.stop();
  }
  super.stop();
}