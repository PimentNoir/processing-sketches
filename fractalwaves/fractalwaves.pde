
SimplexNoise simplexnoise;
INoise perlininoise = new INoise();
ImprovedNoise perlinnoise = new ImprovedNoise();


int i,w=500,h=w,x,y,s=3;
float k,m,r,j=0.01;

void setup(){
  size(w,h,P3D);
  colorMode(HSB,100,100,100);
  noStroke();
  int framerate = 24;
  frameRate(framerate);
}

float inoise(float i, float j , float k) {
  perlininoise.init();
  return (1 + (float)perlininoise.noise((int)i,(int)j,(int)k)) / 2.0f;
}

float perlininoise(float i, float j, float k)
{
  int octave = 4;
  float persistence = 0.5;
  float lacunarity = 2.0;
  float frequency = 1.0;
  
  float rc = 0;
  float amp = 1.0;
  for (int l = 0; l < octave; l++) { 
    rc += ((1 + (float)perlininoise.noise((int)(frequency*i),(int)(frequency*j),(int)(frequency*k))) / 2.0f) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  return rc * (1 - persistence)/(1 - amp);
}

float perlinnoise(float i, float j, float k)
{
  int octave = 4;
  float persistence = 0.5;
  float lacunarity = 2.0;
  float frequency = 1.0;
  
  float rc = 0;
  float amp = 1.0;
  for (int l = 0; l < octave; l++) { 
    rc += ((1 + (float)perlinnoise.noise((double)(frequency*i),(double)(frequency*j),(double)(frequency*k))) / 2.0f) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  return rc * (1 - persistence)/(1 - amp);
}

float fractalperlinnoise(float x, float y, float z) {
int octave = 4; 
float rc = 0;
float amp = 1.0;
  for (int l = 0; l < octave; l++) {
    rc += perlinnoise(x, y, z)*amp;
    amp /= octave;
    x /= 2;
    y /= 2;
    z /= 2;    
  }
  return rc;
}

float simplexnoise(float i, float j, float k) {
  int octave = 4;
  float persistence = 0.25;
  float lacunarity = 0.5;
  float frequency = 1.0;
  
  float rc = 0;
  float amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1]
    rc += (((float)simplexnoise.noise(frequency * i, frequency * j, frequency * k) + 1) / 2.0f) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  return rc * (1 - persistence)/(1 - amp);  
}

float fractalsimplexnoise(float x, float y, float z) {
int octave = 4; 
float rc = 0;
float amp = 1.0;
  for (int l = 0; l < octave; l++) {
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
  //float dist = dist(lx, ly, lz, lx_prev, ly_prev, lz_prev);
  float rc = simplexnoise(lx * 0.5 + abs(lx - lx_prev), ly * 0.5 + abs(ly - ly_prev), lz * 0.5 + abs(lz - lz_prev));
  //println(rc);
  return rc*s*6+h/2;
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
  fill(100);
  text(frameRate,22,22);
}


