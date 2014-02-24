
SimplexNoise simplexnoise;
INoise perlinnoise;

int i,w=500,h=w,x,y,s=3;
float k,m,r,j=0.01;

void setup(){
  size(w,h,P3D);
  colorMode(HSB,100,100,100);
  noStroke();
  int framerate = 24;
  frameRate(framerate);
}

static final int mult = 1<<16;

float perlinnoise(float i, float j, float k)
{
  return (1 + ((float)(perlinnoise.noise((int)(mult*i),(int)(mult*j),(int)(mult*k))) / mult)) / 2.0f;
}

float fractalperlinnoise(float x, float y, float z) {
int octave = 4; 
float rc = 0;
float amp = 1.0;
  for (int l=0;l<octave;l++) {
    rc += perlinnoise(x, y, z)*amp;
    amp /= octave;
    x /= 2;
    y /= 2;
    z /= 2;    
  }
  return rc;
}

float simplexnoise(float i, float j, float k) {
  return (1 + ((float)(simplexnoise.noise((double)(mult*i),(double)(mult*j),(double)(mult*k))) / mult)) / 2.0f;  
}

float fractalsimplexnoise(float x, float y, float z) {
int octave = 4; 
float rc = 0;
float amp = 1.0;
  for (int l=0;l<octave;l++) {
    rc += simplexnoise(x, y, z)*amp;
    amp /= octave;
    x /= 2;
    y /= 2;
    z /= 2;    
  }
  return rc;
}

float fractalNoise(float x, float y, float z) {
int octave = 4; 
float rc = 0;
float amp = 1.0;
  for (int l=0;l<octave;l++) {
    rc += noise(x, y, z)*amp;
    amp /= octave;
    x /= 2;
    y /= 2;
    z /= 2;    
  }
  return rc;
}

float n(float i){
  float xspeed = 0.1;
  float zspeed = 0.0125;
  float pulse = (sin(i*j/w)-0.75)*0.75;
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
  float rc = fractalsimplexnoise(lx + dist + pulse, ly + dist + pulse, lz + dist + pulse);
  //println(rc);
  return rc*s*10+h/2;
}

// Useless functions
float smoothnoise_cubic(float x, float y, float z) {
      return 3*pow(noise(x, y, z), 2) - 2*pow(noise(x, y, z), 3);
}

double smoothnoise_quintic(float x, float y, float z) {
      return simplexnoise(x,y,z)*simplexnoise(x,y,z)*simplexnoise(x,y,z)*(simplexnoise(x,y,z)*(simplexnoise(x,y,z)*6-15)+10);
}

void draw()
{
  background(0);
    
  if (mousePressed) {
    rotateX(TWO_PI * mouseY / height);
    rotateZ(TWO_PI * mouseX / width);  
  }
    
  lights();
  beginShape(TRIANGLE);
  for(i=0;i<w*h;i+=s)
  {
      x=i%w;y=i/w;     
      k=y+s;m=x+s;
      float hue = millis() * 0.001;
      float saturation = 100 * constrain(pow(1.05 * n(k*w+m)*0.0125, 2.5), 0, 1);
      color c = color(
         (n(k*w+m)*0.175+hue) % 100.0,
         saturation,
         100 * constrain(pow(1.00 * max(0, n(k*w+m) * 0.0125), 1.5), 0, 0.9)
         );
      fill(c);
      quadraticVertex(x,n(y*w+x),y,m,n(y*w+m),y);
      quadraticVertex(m,n(k*w+m),k,m,n(k*w+m),k);
      quadraticVertex(x,n(k*w+x),k,x,n(y*w+x),y);
      //rotateY(millis() * 0.001 * i * radians(0.01));
      i+=i%w==0?w*(s-2):0;
  }
  endShape();
  r-=j;
}


