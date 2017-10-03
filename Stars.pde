class Stars {
  final static int R=2000;
  float[][] stars;
  PVector fills[];
  final static int NUM_STARS=1500;
  final static int STAR_DETAIL=10;
  final static int STAR_SIZE=5;
  
  public Stars()
  {
    stars=new float[NUM_STARS][3];
    fills=new PVector[NUM_STARS];
    for (int i=0; i<stars.length; i++)
    {
      float p=random(-PI, PI);
      float t=asin(random(-1, 1));
      stars[i]=new float[] {
        R * cos(t) * cos(p),
        R * cos(t) * sin(p),
        R * sin(t)
        };
       fills[i]=new PVector(random(0, 255), random(0, 255), random(0, 255));
      }
    }

    void draw()
    {
      noStroke();
      sphereDetail(STAR_DETAIL);
      for (int i = 0; i < stars.length; i++)
      {
        pushMatrix();

        translate(stars[i][0], stars[i][1], stars[i][2]);
        fill(fills[i].x, fills[i].y, fills[i].z);
        fills[i].x++; if (fills[i].x>255) fills[i].x=0;
        fills[i].y++; if (fills[i].y>255) fills[i].y=0;
        fills[i].z++; if (fills[i].z>255) fills[i].z=0;
        sphere(STAR_SIZE);
        popMatrix();
      }
      sphereDetail(SPHERE_DETAIL);
    }
}