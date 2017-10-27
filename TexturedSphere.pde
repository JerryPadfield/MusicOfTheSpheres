import processing.opengl.*;

class TexturedSphere {
  PImage texmap;
  PShape sphere;
  //TODO: load obj?
  // PShape should me more streamlined
  private boolean USE_PSHAPE=true;
  private PShape rings=null;
  int sDetail = SPHERE_DETAIL;  // Sphere detail setting
  float rotationX = 0;
  float rotationY = 0; float rotationZ=0;
  float velocityX = 0;
  float velocityY = 0; //random(-1,1);
  float velocityZ=0;
  float rotX=0.0, rotY=0;//random(-0.01, 0.01); // rotation speed
  float rotZ=0.0f;
  float globeRadius = 300;
  float pushBack = 0;
  int rad;
  boolean loaded=false;
  float[] cx, cz, sphereX,sphereY,sphereZ;
  private PShape ringsShape;
  
  void setSize(int s){
    globeRadius=(float)s;
    if (USE_PSHAPE){
      createSphere();
    }
  }
  private void createSphere() { createSphere(false); }
  private void createSphere(boolean rings){
      sphere=createShape(SPHERE, globeRadius);
      sphere.setFill(false);
      sphere.setStroke(false);
      //sphere.rotateX(radians(90));
      sphere.setTexture(texmap);
      if (rings){
        ringsShape=createShape();
        ringsShape.beginShape();
 
          ringsShape.rotateX(radians(90-27));
          // Exterior part of shape
          // Calculate the path as a sine wave
          ringsShape.setStroke(255);
          ringsShape.setFill(124);
          for (int a=0; a < 360; a += 1) {
            ringsShape.vertex(cos(a)*150,sin(a)*150);
          }

          // Interior part of shape
          ringsShape.beginContour();
          ringsShape.setFill(0);
          ringsShape.setStroke(0);
          for (int a=0; a < 360; a += 1) {
            ringsShape.vertex(cos(a)*100,sin(a)*100);
          }
          ringsShape.endContour();

        ringsShape.endShape();
      }
   }
  void setRot(float r) { velocityY=r; }
  TexturedSphere(String s, float r) { this(s, r, false); }
  TexturedSphere(String s, float r, boolean rings)
  {
    texmap = loadImage(s);
    if (texmap!=null)
      loaded=true;
    else System.out.println("Couldn't load image: "+s);
    globeRadius = r;
    
    //gl
    if (!USE_PSHAPE) {
      initializeSphere(sDetail);
    } else {
    //PShape
      createSphere(rings);
    }
  }

  void draw()
  {
    pushMatrix();
    noFill();
    noStroke();

    rotateX(radians(90));  // fixme
    rotateY(radians(rotationY));
    rotateZ(radians(180));
    if (!USE_PSHAPE){
      textureMode(IMAGE);
      //shininess(5.0);
      //ambient(255);
      //specular(255);
      texturedSphere(globeRadius, texmap);
    } else {
//    pushMatrix();
      if (ringsShape!=null){
        shape(ringsShape);
      }
      shape(sphere);
//    popMatrix();
    }
    popMatrix();
//    popMatrix();
    rotationX += velocityX;
    rotationY += velocityY;
    if (rotationY>=360)
      rotationY=rotationY-360;
    rotationZ += velocityZ;
    velocityX +=  rotX;
    velocityY -= rotY;
    velocityZ += rotZ;
  }

  void initializeSphere(int res)
  {
    float delta = (float)SINCOS_LENGTH/res;
    float[] cx = new float[res];
    float[] cz = new float[res];

    // Calc unit circle in XZ plane
    for (int i = 0; i < res; i++) {
      cx[i] = -cosLUT[(int) (i*delta) % SINCOS_LENGTH];
      cz[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
    }

    // Computing vertexlist vertexlist starts at south pole
    int vertCount = res * (res-1) + 2;
    int currVert = 0;

    // Re-init arrays to store vertices
    sphereX = new float[vertCount];
    sphereY = new float[vertCount];
    sphereZ = new float[vertCount];
    float angle_step = (SINCOS_LENGTH*0.5f)/res;
    float angle = angle_step;

    // Step along Y axis
    for (int i = 1; i < res; i++) {
      float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
      float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
      for (int j = 0; j < res; j++) {
        sphereX[currVert] = cx[j] * curradius;
        sphereY[currVert] = currY;
        sphereZ[currVert++] = cz[j] * curradius;
      }
      angle += angle_step;
    }
    sDetail = res;
  }

  // Generic routine to draw textured sphere
  void texturedSphere(float r, PImage t) 
  {
    if (!loaded) return;
    pushMatrix();

    int v1, v11, v2;
    r = (r + 40) * 0.33;
    beginShape(TRIANGLE_STRIP);
      texture(t);
      float iu=(float)(t.width-1)/(sDetail);
      float iv=(float)(t.height-1)/(sDetail);
      float u=0,v=iv;
      for (int i = 0; i < sDetail; i++) {
        vertex(0, -r, 0,u,0);
        vertex(sphereX[i]*r, sphereY[i]*r, sphereZ[i]*r, u, v);
        u+=iu;
      }
      vertex(0, -r, 0,u,0);
      vertex(sphereX[0]*r, sphereY[0]*r, sphereZ[0]*r, u, v);
    endShape();   
  
    // Middle rings
    int voff = 0;
    for (int i = 2; i < sDetail; i++) {
      v1=v11=voff;
      voff += sDetail;
      v2=voff;
      u=0;
      beginShape(TRIANGLE_STRIP);
      texture(t);
      for (int j = 0; j < sDetail; j++) {
        vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1++]*r, u, v);
        vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2++]*r, u, v+iv);
        u+=iu;
      }
  
      // Close each ring
      v1=v11;
      v2=voff;
      vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1]*r, u, v);
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v+iv);
      endShape();
      v+=iv;
    }
    u=0;
  
    // Add the northern cap
    beginShape(TRIANGLE_STRIP);
    texture(t);
    for (int i = 0; i < sDetail; i++) {
      v2 = voff + i;
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v);
      vertex(0, r, 0,u,v+iv);    
      u+=iu;
    }
    vertex(0, r, 0,u, v+iv);
    vertex(sphereX[voff]*r, sphereY[voff]*r, sphereZ[voff]*r, u, v);
    endShape();  
  popMatrix();
}
}