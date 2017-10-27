
class Sun extends DrawableSphere {
  static final int SCALE_SUN=3;
  TexturedSphere ts;
  
  public Sun(){
    location=new PVector(0, 0, 0);
   if (TEXTURED_SUN){
      ts=new TexturedSphere("Sun.jpg", SUN_SIZE/SCALE_SUN);
      ts.setRot(0.24);
   }
  }
  
  void draw(){
    
    translate(location.x, location.y, location.z);
    if (TEXTURED_SUN)
    {
      pushMatrix();
      //emissive(255, 170, 170);
      //lights();  
      ts.draw();
      popMatrix();
    }
    else 
    {
      fill(255, 255, 0);
      sphere(SUN_SIZE/SCALE_SUN);      
    }
  }
  
  public String toString(){
    return "Sun: x:"+location.x+", y:"+location.y;
  }
}