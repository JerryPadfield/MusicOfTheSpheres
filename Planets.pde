/*
 *
 *
 *
 */
static final float DAY_ROT=1;
static final float SCALE_GAIN=50;

class PlanetMercury extends Planet {
  /*
   * Mercury = the winged messenger
   * Algorithm for producing sound:
   * 
   */
  GranulateRandom chopper;
  float glmin=0.005, slmin=0.04, flmin=0.001, glmax=0.02, slmax=0.08, flmax=0.02;
  PlanetMercury(Sun a){
    super(a, 58, "Mercury");
    setSpeed(47.4);
    setSize(4879);
    setRotation(DAY_ROT/58);
    ugen=new Oscil(440, 0.5, Waves.SINE);
    moog = new MoogFilter(1200, 0.5);
    del=new Delay(0.4, 0.5, true, true);
    chopper = new GranulateRandom(glmin, slmin, flmin, glmax, slmax, flmax);
    ugen.patch(moog).patch(gain).patch(balance).patch(chopper).patch(del).patch(audioOutput);
  }
  void move(){
    super.move();
    ((Oscil)ugen).setFrequency(8*(location.x-earth.location.x));
    slmin=this.location.x/1000;
    slmax=slmin+0.02;
    chopper.setAllTimeParameters(glmin, slmin, flmin, glmax, slmax, flmax);
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN;
    gain.setValue(dB);
    //System.err.println("Mercury dB: "+dB);
    balance.setBalance(location.x/212);
     //System.err.println(""+earth.location.x);
     //moog.frequency.setLastValue(this.location.y*8f);
  }
}

class PlanetVenus extends Planet {
  /*
   * Venus = bringer of peace
   * Algorithm for producing sound:
   * 
   */
   Flanger flange;
   
  PlanetVenus(Sun a){
    super(a, 108, "Venus");
    setSpeed(35.0);
    setSize(12104);
    setRotation(-DAY_ROT/243);
    ugen=new Oscil(570, 0.3, Waves.TRIANGLE);
    //moog = new MoogFilter(1200, 0.5);
    del=new Delay(0.6, 0.6, true, false);
    flange = new Flanger( 1,     // delay length in milliseconds ( clamped to [0,100] )
                        0.2f,   // lfo rate in Hz ( clamped at low end to 0.001 )
                        1,     // delay depth in milliseconds ( minimum of 0 )
                        0.5f,   // amount of feedback ( clamped to [0,1] )
                        0.5f,   // amount of dry signal ( clamped to [0,1] )
                        0.5f    // amount of wet signal ( clamped to [0,1] )
                       );

    ugen.patch(gain).patch(balance).patch(del).patch(flange).patch(audioOutput);
  }
  void move(){
    super.move();
    ((Oscil)ugen).setFrequency(8*location.x);
    ((Oscil)ugen).setPhase(8*location.y);
    balance.setBalance(location.y/(_size/SCALE_ALL));
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN;
    gain.setValue(dB);
    //System.err.println("Venus dB: "+dB);

    //System.err.println("Venus, y: "+location.y);
    //moog.frequency.setLastValue(this.location.y*8f);
  }
}

class PlanetEarth extends Planet {
  /*
   * In Holst's suite the earth does not create any sound (nor the sun)
   */
   Planet moon;
   
  PlanetEarth(Sun a){
    super(a, 150, "Earth");
    setSize(12756);
    setSpeed(29.8);
    setRotation(1);
    //moon=new Moon(this, "Pluto", 3475, 350);
  }
  
  public void draw(){
    super.draw();
    //moon.draw();
  }
}

class PlanetMars extends Planet {
  /* 
   * Mars = bringer of war
   * Holst's peace centres around Gm with a G pedal note
   * Alogrithm:
   * 
   */

  PlanetMars(Sun a){
    super(a, 228, "Mars");
    setSpeed(24.1);
    setSize(6792);
    setRotation(1);
    ugen=new Oscil(Frequency.ofPitch("G2"), 0.2, Waves.SQUARE);
    //moog = new MoogFilter(1200, 0.5);
    del=new Delay(0.2, 0.2, false, true);
    //ugen.patch(gain).patch(balance).patch(del).patch(audioOutput);
  }
  
  void move(){
    super.move();
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN;
    gain.setValue(dB);
    //System.err.println("dB: "+dB);

    ((Oscil)ugen).setFrequency(Frequency.ofPitch("G2").asHz()+(location.x/rad));
    //moog.frequency.setLastValue(this.location.y*8f);
  }
}

class PlanetJupiter extends Planet {
  /*
   * The bringer of Jollity
   * 
   */
  PlanetJupiter(Sun a){
    super(a, 779, "Jupiter");
    setSpeed(13.1);
    setSize(142984);
    setRotation(DAY_ROT/0.4);
    ugen=new Oscil(340, 0.5, Waves.SAW);
    moog = new MoogFilter(1200, 0.5);
    del=new Delay(0.3, 0.3, true, true);
   // ugen.patch(moog).patch(balance).patch(del).patch(gain).patch(audioOutput);
  }
  void move(){
    super.move();
    ((Oscil)ugen).setPhase(8*location.x);
    //moog.frequency.setLastValue(this.location.y*8f);
    balance.setBalance(location.y/(_size/SCALE_ALL));
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN;
    gain.setValue(dB/100);
   // System.err.println("dB: "+dB);

  }
}

class PlanetSaturn extends Planet {
  /*
   * The bringer of old age
   * Algorithm:
   *
   */
  PlanetSaturn(Sun a){
    super(a, 1433, "Saturn");
    ugen=new Noise();
    ((Noise)ugen).setTint(Noise.Tint.PINK);
    ((Noise)ugen).amplitude.setLastValue(0.1);
    moog = new MoogFilter(1000, 0.5, MoogFilter.Type.BP);
    del=new Delay(0.4, 0.4, true, true);
    ugen.patch(moog).patch(del).patch(gain).patch(balance).patch(audioOutput);
    setRotation(DAY_ROT/0.44);
    setSpeed(9.7);
    setSize(120536);
  }
  void move(){
    super.move();
    balance.setBalance(-location.y/(rad/SCALE_ALL));
    float fr=abs(location.y*10);
    //System.err.println("Saturn rotation: "+getRotation());
    if (fr >=20000) fr=20000;
    moog.frequency.setLastValue(fr);
    moog.resonance.setLastValue(1/getRotation());
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN/2;
    gain.setValue(dB);
    System.err.println("dB: "+dB);

 //   System.out.println("Saturn: moog: "+location.y*50);
  }
  // override draw to draw rings
  void draw(){
    super.draw();
    //stroke(255, 155, 0);
    pushMatrix();
    fill(0, 0);
    translate(location.x, location.y, 0);
    rotateZ(radians(ts.rotationY));
    rotateX(radians(26.7));
    for (int i=0; i<50; i++){
      stroke(255-(i*2), 155+i, random(0, 100), 5);
      ellipse(0, 0, 2*_size+i, 2*_size+i);
      
    }
    noStroke();
    popMatrix();
  }
}
class PlanetUranus extends Planet {
  /*
   * The magician
   * Algorithm:
   * 
   */
  PlanetUranus(Sun a){
    super(a, 2872, "Uranus");
    setSpeed(6.8);
    setSize(51118);
    setRotation(-DAY_ROT/0.7);
    ugen = new FilePlayer( minim.loadFileStream("test.wav"));
  // and then we'll tell the file player to loop indefinitely
    ((FilePlayer)ugen).loop();
    del=new Delay(0.8, 0.1, false, true);
//    ugen.patch(del).patch(audioOutput);
  }
  void move(){
    super.move();
    //((Oscil)ugen).setPhase(8*location.x);
    //moog.frequency.setLastValue(this.location.y*8f);
  }
}
class PlanetNeptune extends Planet {
  /*
   * The mystic
   * Algorithm:
   * 
   */
  PlanetNeptune(Sun a){
    super(a, 4495, "Neptune");
    setSpeed(5.4);
    setSize(49528);
    setRotation(DAY_ROT/0.67);
  }
String notes[] = {
  "C5", "D5", "E5", "G5", "A5", "C6"
};
  void move(){
    super.move();
    if ((int)random(0, 20)==9){
 //     audioOutput.playNote(notes[(int)random(0, notes.length)]);
  //    System.out.println("Neptune: C3");
    }
//    audioOutput.playNote( 3.0, 1.9, "E3" );
//    audioOutput.playNote( 4.0, 0.9, "G3" );
    
    //((Oscil)ugen).setPhase(8*location.x);
    //moog.frequency.setLastValue(this.location.y*8f);
  }
}