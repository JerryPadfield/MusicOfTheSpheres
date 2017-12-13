/*
 * Planets:
 * Mercury: winged messenger - high pitched granulated
 * Venus: love - high pitch, flanged, phased
 * Mars: war - ominous G minor oscillators
 * Jupiter: jollity - bitcrushed
 * Saturn: noise (bleep when filter peaks)
 * Uranus: Sample of the planets played back at varying speed
 * Neptune: rhythm - TOD
 * 
 * Each planet has a generator, filter, delay, gain and balance
 */
static final float DAY_ROT=1;
static final float SCALE_GAIN=50;

class PlanetMercury extends Planet {
  /*
   * Mercury = the winged messenger
   * Algorithm for producing sound:
   * 
   * Granulated sine wave
   */
  GranulateRandom chopper;
  float glmin=0.005, slmin=0.04, flmin=0.001, glmax=0.02, slmax=0.08, flmax=0.02;
  PlanetMercury(Sun a){
    super(a, 58, "Mercury");
    setSpeed(47.4);
    setSize(4879);
    setRotation(DAY_ROT/58);
    ugen=new Oscil(4879, 0.3, Waves.SINE);
    moog = new MoogFilter(4879, 0.5);
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
    float f=map(location.x, -rad, rad, -1, 1);
    ///println("Mercury balance: "+f);
    balance.setBalance(location.x/212);
     //System.err.println(""+earth.location.x);
     //moog.frequency.setLastValue(this.location.y*8f);
  }
}

class PlanetVenus extends Planet {
  /*
   * Venus = bringer of peace
   * Algorithm for producing sound:
   * Flanger, phase shifted triangle wave
   * 
   */
   Flanger flange;
   
  PlanetVenus(Sun a){
    super(a, 108, "Venus");
    setSpeed(35.0);
    setSize(12104);
    setRotation(-DAY_ROT/243);
    ugen=new Oscil(12104, 0.2, Waves.TRIANGLE);
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
 //  Planet moon;
   
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
   * Algorithm: 3 oscillators 
   * 
   */
  Oscil oscil2;
  Oscil oscil3;
  
  PlanetMars(Sun a){
    super(a, 228, "Mars");
    setSpeed(24.1);
    setSize(6792);
    setRotation(1);
    ugen=new Oscil(Frequency.ofPitch("G2"), 0.5, Waves.SQUARE);
    oscil2=new Oscil(Frequency.ofPitch("Bb2"), 0.2, Waves.SQUARE);
    oscil3=new Oscil(Frequency.ofPitch("D2"), 0.1, Waves.SQUARE);
    // add a low pass filter at the frequency which matches Mars' size
    moog = new MoogFilter(200, 0.5, MoogFilter.Type.LP);
    del=new Delay(0.2, 0.2, false, true);
    ugen.patch(oscil2).patch(oscil3).patch(moog).patch(gain).patch(balance).patch(del).patch(audioOutput);
  }
  
  void move(){
    super.move();
    float dB=distanceFrom(earth);
    dB=0-dB/(SCALE_GAIN/2);
    gain.setValue(dB);
    //System.err.println("dB: "+dB);

    ((Oscil)ugen).setFrequency(Frequency.ofPitch("G1").asHz()+(location.x/rad));
    oscil2.setFrequency(Frequency.ofPitch("Bb1").asHz()+sin(ts.rotationY));
    oscil3.setFrequency(Frequency.ofPitch("D1").asHz()+location.x/rad);
    //moog.frequency.setLastValue(this.location.y*8f);
  }
}

class PlanetJupiter extends Planet {
  /*
   * The bringer of Jollity
   * Algorithm:
   * Bitcrushed saw wave
   * 
   */
   BitCrush bc;
  PlanetJupiter(Sun a){
    super(a, 779, "Jupiter");
    setSpeed(13.1);
    setSize(142984);
    setRotation(DAY_ROT/0.4);
    ugen=new Oscil(779, 0.2, Waves.SAW);
    moog = new MoogFilter(1200, 0.5);
    bc=new BitCrush();
    del=new Delay(0.3, 0.3, true, true);
    ugen.patch(moog).patch(balance).patch(del).patch(gain).patch(audioOutput);
  }
  void move(){
    super.move();
    ((Oscil)ugen).setPhase(8*location.x);
    ((Oscil)ugen).setFrequency(770+distanceFrom(earth));
    //moog.frequency.setLastValue(this.location.y*8f);
    balance.setBalance(location.y/(_size/SCALE_ALL));
    float f=map(location.x, -400, 400, 0, 16);
    bc.setBitRes(f);
    //println("f: "+f);
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
   * Filtered noise
   *
   */
   private static final int SATURN_RINGS_ALPHA=5;
  PlanetSaturn(Sun a){
    super(a, 1433, "Saturn");
    ugen=new Noise();
    ((Noise)ugen).setTint(Noise.Tint.PINK);
    ((Noise)ugen).amplitude.setLastValue(0.2);
    moog = new MoogFilter(1000, 0.5, MoogFilter.Type.BP);
    del=new Delay(0.4, 0.4, true, true);
    ugen.patch(moog).patch(del).patch(gain).patch(balance).patch(audioOutput);
    setRotation(DAY_ROT/0.44);
    setSpeed(9.7);
    setSize(120536);
  }
  void move(){
    super.move();
    float f=map(location.y, -rad, rad, -1, 1);
    balance.setBalance(f);//-location.y/(rad/SCALE_ALL));
    float fr=abs(location.y*10);
    //System.err.println("Saturn rotation: "+getRotation());
    if (fr >=20000) fr=20000;
    moog.frequency.setLastValue(fr);
    moog.resonance.setLastValue(1/getRotation());
    float dB=distanceFrom(earth);
    dB=0-dB/SCALE_GAIN/2;
    gain.setValue(dB-3);
    //println("dB: "+dB);

 //   println("Saturn: moog: "+location.y*50);
  }
  // override draw to draw rings
  void draw(){
    super.draw();
    //stroke(255, 155, 0);
    //strokeWeight(10);
    pushMatrix();
      translate(location.x, location.y, location.z);
      rotateZ(radians(ts.rotationY));
      // rotateY(radians(ts.rotationZ));
      rotateX(radians(26.7));
      strokeWeight(5);
      noFill();
      //blendMode(SCREEN);
      for (int i=0; i<50; i++){
        stroke(155-(i*2), 155+i, random(0, 150), SATURN_RINGS_ALPHA);
        ellipse(0, 0, 2.5*_size+i, 2.5*_size+i); 
      }
      //blendMode(BLEND);
      noStroke();
    popMatrix();
  }
}

class PlanetUranus extends Planet {
  /*
   * The magician
   * Algorithm:
   *  Plays and manipulates a recording (sample)
   */
   TickRate tr;
  PlanetUranus(Sun a){
    super(a, 2872, "Uranus");
    setSpeed(6.8);
    setSize(51118);
    setRotation(-DAY_ROT/0.7);
    ugen = new FilePlayer(minim.loadFileStream("data/test.wav"));
  // and then we'll tell the file player to loop indefinitely
    ((FilePlayer)ugen).loop();
    tr=new TickRate(1.f);
    tr.setInterpolation(true);
    del=new Delay(0.8, 0.1, false, true);
    gain.setValue(-0.3);
    ugen.patch(tr).patch(gain).patch(balance).patch(del).patch(audioOutput);
  }
  void move(){
    super.move();
//    float dB=distanceFrom(earth);
//    dB=0-dB/SCALE_GAIN/2;
    gain.setValue(-6);
    float f=map(location.x, -500, 500, 0.001, 3);
    //println("Uranus speed: " +f);
    tr.value.setLastValue(abs(f));
    // map location.y between -1 1 for bal
    f=map(location.y, -rad, rad, -1, 1);
    //println("Uranus bal: "+f);
    balance.setBalance(f);

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
   //NeptuneInstrument inst;
  PlanetNeptune(Sun a){
    super(a, 4495, "Neptune");
    setSpeed(5.4);
    setSize(49528);
    setRotation(DAY_ROT/0.67);
   // inst=new NeptuneInstrument(4495);
  }
String notes[] = {
  "C2", "D2", "E2", "G2", "A2", "C3"
};
  void move(){
    super.move();
  //  System.out.println("Neptune: play note: "+ts.rotationY);
    if ((int)ts.rotationY==1){
      audioOutput.playNote(1, 0.6, new NeptuneInstrument(270));
    //System.gc();

    }
  }
  class NeptuneInstrument implements Instrument
{
  Oscil wave;
  Line ampEnv;
  MoogFilter moog;
  ADSR adsr;
  Delay del;
  NeptuneInstrument(float frequency)
  {
    // make a sine wave oscillator
    // the amplitude is zero because 
    // we are going to patch a Line to it anyway
    wave   = new Oscil( frequency, 0.5, Waves.SINE );
    moog = new MoogFilter(200, 0.5, MoogFilter.Type.LP);
    del=new Delay(0.6, 0.95, true, true);
    wave.patch(moog).patch(del);
    ampEnv = new Line(0.1);
    adsr=new ADSR(1.0, 0.001, //attack time
                      0.001,  // dec time
                      0.5,    //sus level
                      0.001   // release time
                      );
  //  ampEnv.patch(wave.amplitude);
  wave.patch(adsr);
  }
  
  // this is called by the sequencer when this instrument
  // should start making sound. the duration is expressed in seconds.
  void noteOn(float duration)
  {
    // start the amplitude envelope
   // ampEnv.activate(duration, 0.5f, 0);
    // attach the oscil to the output so it makes sound
    //wave.patch(audioOutput);
    adsr.noteOn();
    adsr.patch(moog).patch(del).patch(audioOutput);
  }
  
  // this is called by the sequencer when the instrument should
  // stop making sound
  void noteOff()
  {
    //wave.unpatch(audioOutput);
    adsr.unpatchAfterRelease(audioOutput);
    adsr.noteOff();
  }
}
}