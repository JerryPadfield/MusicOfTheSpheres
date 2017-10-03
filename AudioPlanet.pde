class AudioPlanet extends DrawableSphere // implements AudioSignal
{
//  float signal;
//  AudioOutput out;
  UGen ugen;  // SoundGenerator = Noise, Oscil, LiveInput, FilePlayer, Sampler, Vocoder
  MoogFilter moog;  //filter
  Delay del;
  void draw() {}
  Balance balance;
  //Pan pan;
  // Gain gain;
  BitCrush bitcrush;
  WaveShaper waveshaper;
  Flanger flanger;
  //GranulateRandom granrand; GranulateSteady chopper;
  
  AudioPlanet(){
    balance=new Balance(0);
  }
/*
  void generate(float[] samp)
  {
    float range = map(location.x, 0, width, 0, 1);
    float peaks = map(location.y, 0, height, 1, 20);
    float inter = float(samp.length) / peaks;
    for (int i = 0; i < samp.length; i += inter)
    {
      for (int j = 0; j < inter && (i+j) < samp.length; j++)
      {
        samp[i+j] = map(j, 0, inter, -range, range);
      }
    }
  }

  // this is a stricly mono signal
  void generate(float[] left, float[] right)
  {
    generate(left);
    generate(right);
  }
  */
}