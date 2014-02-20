
int i,w=500,h=w,x,y,s=3;
float k,m,r,j=0.01;

void setup(){
  size(w,h,P3D);
  colorMode(HSB,100,100,100);
  noStroke();
  inoise_setup();
  int framerate = 24;
  frameRate(framerate);
}

// Copyright 2002 Ken Perlin
// FIXED POINT VERSION OF IMPROVED NOISE:  1.0 IS REPRESENTED BY 2^16

   static int inoise(int x, int y, int z) {
      int X = x>>16 & 255, Y = y>>16 & 255, Z = z>>16 & 255, N = 1<<16;
      x &= N-1; y &= N-1; z &= N-1;
      int u=fade(x),v=fade(y),w=fade(z), A=p[X  ]+Y, AA=p[A]+Z, AB=p[A+1]+Z,
                                         B=p[X+1]+Y, BA=p[B]+Z, BB=p[B+1]+Z;
      return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x   , y   , z   ),  
                                     grad(p[BA  ], x-N , y   , z   )), 
                             lerp(u, grad(p[AB  ], x   , y-N , z   ),  
                                     grad(p[BB  ], x-N , y-N , z   ))),
                     lerp(v, lerp(u, grad(p[AA+1], x   , y   , z-N ),  
                                     grad(p[BA+1], x-N , y   , z-N )), 
                             lerp(u, grad(p[AB+1], x   , y-N , z-N ),
                                     grad(p[BB+1], x-N , y-N , z-N ))));
   }
   static int lerp(int t, int a, int b) { return a + (t * (b - a) >> 12); }
   static int grad(int hash, int x, int y, int z) {
      int h = hash&15, u = h<8?x:y, v = h<4?y:h==12||h==14?x:z;
      return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
   }
    static int fade(int t) {
      int t0 = fade[t >> 8], t1 = fade[Math.min(255, (t >> 8) + 1)];
      return t0 + ( (t & 255) * (t1 - t0) >> 8 );
   }
   static int fade[] = new int[256];
   static double f(double t) { return t * t * t * (t * (t * 6 - 15) + 10); }

static final int p[] = new int[512], permutation[] = { 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
   };

void inoise_setup()
{
  for (int i=0; i < 256 ; i++) p[256+i] = p[i] = permutation[i];
  for (int i=0; i < 256 ; i++) fade[i] = (int)((1<<12)*f(i/256.));
}

static final int mult = 1<<16;

float inoisef(float i, float j, float k)
{
  return (1 + ((float)(inoise((int)(mult*i),(int)(mult*j),(int)(mult*k))) / mult)) / 2.0f;
}

float n(float i){
  int octave = 4;
  float xspeed = 0.1;
  float zspeed = 0.1;
  float pulse = abs((sin(i*j/w)*0.75));
  float rv = 0;
  float lx_prev,ly_prev,lz_prev;
  if ( i <= 0 ) {
    lx_prev = 0;
    ly_prev = +r;
    lz_prev = r;
  } else {
    lx_prev = (i-s)%w*j;
    ly_prev = ((i-s)*j/w+r);
    lz_prev = ((i-s)*j/w-r); 
  }
  float lx = i%w*j;
  float ly = (i*j/w+r);
  float lz = (i*j/w-r);
  float dist = dist(lx, ly, lz, lx_prev, ly_prev, lz_prev);
  float amp = 1.0;
  for (int l=0;l<octave;l++) {
    rv += inoisef(lx + dist + pulse, ly + dist + pulse, lz + dist + pulse)*amp;
    amp /= 2;
    lx /= 2;
    ly /= 2;
    lz /= 2;
    dist /= 2;
    pulse /= 2;
  }
  return rv*s*8+h/2;
}

// Useless functions
float smoothnoise_cubic(float x, float y, float z) {
      return 3*pow(inoisef(x, y, z), 2) - 2*pow(inoisef(x, y, z), 3);
}

float smoothnoise_quintic(float x, float y, float z) {
      return pow(noise(x,y,z), 3)*(noise(x,y,z)*(noise(x,y,z)*6-15)+10) ;
}

void draw()
{
  background(0);
  lights();
  
  beginShape(TRIANGLE);
  for(i=0;i<w*h;i+=s)
  {
      x=i%w;y=i/w;     
      k=y+s;m=x+s;
      float hue = millis() * 0.001;
      float saturation = 100 * constrain(pow(1.05 * n(k*w+m)*0.0125, 2.5), 0, 1);
      color c = color(
         (n(k*w+m)*0.275%20+hue%80) % 100.0,
         saturation,
         100 * constrain(pow(1.00 * max(0, n(k*w+m) * 0.0125), 1.5), 0, 0.9)
         );
      fill(c);
      quadraticVertex(x,n(y*w+x),y,m,n(y*w+m),y);
      quadraticVertex(m,n(k*w+m),k,m,n(k*w+m),k);
      quadraticVertex(x,n(k*w+x),k,x,n(y*w+x),y);
      i+=i%w==0?w*(s-2):0;
  }
  endShape();
  r-=j;
}


