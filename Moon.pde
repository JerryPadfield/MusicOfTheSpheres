class Moon extends Planet {
//  TexturedSphere ts;
//  int radius=0;
  Planet orbiting;

  public Moon(Planet orbiting, String name, int size, int rad){
    super(null, rad, name);
    this.orbiting=orbiting;
    attractor=orbiting.location;
    location=orbiting.location.copy();

    setSize(size);
    setSpeed(10);
    setRotation(10);

  }
}