import java.util.TimerTask;

// base class for all 3d celestial bodies:
// sun, planets (moons)
// this allows depth-sorting
abstract class DrawableSphere {
  PVector location=new PVector(0,0,0);
  abstract void draw();
}

class AudioPlanet extends DrawableSphere
{
  UGen ugen;  // SoundGenerator = Noise, Oscil, LiveInput, FilePlayer, Sampler, Vocoder
  MoogFilter moog;  //filter
  Delay del;
  void draw() {}
  Balance balance;
  Gain gain;
  BitCrush bitcrush;
  WaveShaper waveshaper;
  Flanger flanger;
  //GranulateRandom granrand; GranulateSteady chopper;
  
  AudioPlanet(){
    balance=new Balance(0);
    gain=new Gain(0.0f);
  }
}

/* class to animate the movement of the camera
 * also handles moving the camera if a key is pressed
 * TODO: VR movements
 */
class CameraMover extends TimerTask {

  private float x, y, z=MAX_Z;
  private float offsetX, offsetY, offsetZ;
  private float moveX, moveY, moveZ;
  private boolean moving=false;
  static final float MAX_X=(45*12);
  static final float MAX_Y=(45*12);
  static final float MAX_Z=(45*12);
  private PVector towards;
  private Planet p;
  private boolean animating=true;
  private static final boolean DEBUG=false;
  
  public float getX() { return (x+offsetX); }
  public float getY() { return (10*(offsetY+y)); }
  public float getZ() { return (z+offsetZ)-125; }
  public CameraMover(){
    x=0; y=0; z=0;
    offsetX=0;offsetY=0;offsetZ=0;
    towards=new PVector(0, 0, 0);
    
  }
  public CameraMover(PVector t){
    towards=t;
  }
  public CameraMover(Planet pl){
    p=pl;
  }
  
  // animate following the path of an ellipse
  float ellipseRadX=150;
  float ellipseRadY=250;
  private float t=0;
  /* spirographic shapes formula
   * 
   * http://www.mathematische-basteleien.de/spirographs.htm#Formulas
   * 
   * x(t)=(R-r) * cos ((r/R)*t) + a*cos((1-(r/R)*t)
   */
  private void moveEllipse(){
    offsetX = ellipseRadX * (float)Math.cos(t);
    offsetY = ellipseRadY * (float)Math.sin(t);
    t+=0.001;
    debug("Camera: x: "+getX()+", y:"+getY());
  }
  private void debug(String s){ if (DEBUG) System.err.println(s); }
  public void animate(){ moving=true; debug("In animate"); }
  public void stopAnimating() { animating=false; }
  public void startAnimating() { animating=true; }
  public void startMoving() { moving=true;} 
  public void stopMoving() { moving=false; }
  public void reset(){
      debug("reset");
      x=0; y=0; z=10;
      moveX=0; moveY=0; moveZ=0;
      offsetX=0; offsetY=0; offsetZ=0;
      camera();
      moving=false;
      animating=false;
  }
  
  public void moveZ(float howMuch){
     //debug("moveZ: "+howMuch);
     moveZ=howMuch; moveX=0; moveY=0;
  }
    public void moveX(float howMuch){
      moveX=howMuch; moveZ=0; moveY=0;
  }
    public void moveY(float howMuch){
      moveY=howMuch; moveX=0; moveZ=0;
  }
  public void toggleAnimating(){
    if (animating)  animating=false;
    else animating =true;
  }
  private void move(){
    if (moving){
    debug("move: "+moveX);
    x+=moveX;
    y+=moveY;
    z+=moveZ;
    if (x>=MAX_X)   x=MAX_X;
    if (x<=-MAX_X)  x=-MAX_X;
    if (y<=-MAX_Y)  y=-MAX_Y;
    if (y>=MAX_Y)   y=MAX_Y;
    if (z<=-MAX_Z)  z=-MAX_Z;
    if (z>=MAX_Z)   z=MAX_Z;
    }
    if (animating){
      moveEllipse();
    }
  }

   public void setCamera(){
     if (p!=null)
       towards=p.location;
         camera(getX(), getY(), getZ(), towards.x, towards.y, towards.z, 0, 0, -1);
   }
  public void run(){
    while (true){
      move();
      try {
        Thread.sleep(10);
      } catch (InterruptedException e){
        System.err.println("Error: "+e);
      }
    }
  }
}