import oscP5.*;
import netP5.*;
//import java.util.*;

class Planet extends AudioPlanet implements Comparable {
  final static int SCALE_SIZE=1000;
  final static float SCALE_SPEED=30;
  int index;
  float speed;
  int r=0xc0, g=0xc0, b=0xc0;
  int _size=int(random(10, 20));
  float shine=5.0f;
  PVector attractor;
  int rad=100+SUN_SIZE;
  float angle;
  TexturedSphere ts=null;
  String name;

  public Planet(Sun att, String n){
    attractor=att.location;
    location=att.location.copy();
    name=n;
    if (TEXTURED_PLANETS){
      ts=new TexturedSphere(n+".jpg", _size);
    }
    index=idx++;
  }
  
  public Planet(Sun att, int radius, String n){
    this(att, n);
    rad=(radius+(SUN_SIZE/SCALE_ALL));
  }

  void setSize(int s)  { _size=(s/SCALE_SIZE); if (ts!=null) ts.setSize(s/SCALE_SIZE); }
  void setSpeed(float s){ speed=s/SCALE_SPEED; }
  void setRadius(int r) { rad=r/SCALE_ALL; }
  void setColor(int i, int j, int k){ r=i; g=j; b=k; }
  void setRotation(float f)  { ts.setRot(f); }
  float getRotation() { return ts.rotationY; }
  
  void move(){
    angle+= (2.0/rad)*speed;
    location=attractor.copy();
    location.x+=rad*cos(angle);
    location.y+=rad*sin(angle);
  }

  void draw(){

    pushMatrix();

    translate(location.x, location.y, location.z);
    
    if (!TEXTURED_PLANETS){
      fill(r, g, b);
      shininess(shine);
      sphere(_size);
    } 
    else { 
      ts.draw();
    }
      popMatrix();
      if (DRAW_ORBITS){
        stroke(300-(rad/SCALE_ALL), 0, rad);
        fill(0, 0);
        ellipse(sun.location.x, sun.location.y, 2*rad, 2*rad);
        noStroke();
      }
  }

  void broadcast(OscP5 oscP5, NetAddress na){
if (USE_OSC){
    OscMessage myMessage = new OscMessage("/planet_loc");

    myMessage.add(location.x);
    myMessage.add(location.y);
    myMessage.add(index);
    /* send the message */
    oscP5.send(myMessage, na);
}
  }
  // for depth sorting
  public int compareTo(Object j) {
    return int(abs(location.y)-abs((((Planet)j).location.y)));
  }
  public String toString(){
    return name+"["+index+"]"+" "+location.x+" "+location.y;
  }
}