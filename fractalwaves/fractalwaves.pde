
SimplexNoise simplexnoise = new SimplexNoise();
INoise perlininoise = new INoise();
ImprovedNoise perlinnoise = new ImprovedNoise();

int i,w=500,h=w,x,y,s=6;
float k,m,r,j=0.01;

void setup(){
  size(500,500,P3D);
  colorMode(HSB,100,100,100);
  noStroke();
  int framerate = 24;
  frameRate(framerate);
}

float inoise(float i, float j , float k) {
  final int mult = 1<<16;
  //Keep the same behaviour as the processing perlin noise() function, return values in [0,1] range
  return (1 + ((float)(perlininoise.noise((int)(i*mult),(int)(j*mult),(int)(k*mult))) / mult)) / 2.0f;
}

float perlininoise(float i, float j, float k)
{
  int octave = 4;
  float persistence = 0.25;
  float lacunarity = 0.5;
  float frequency = 1.0;
  
  float rc = 0;
  float amp = 1.0;
  for (int l = 0; l < octave; l++) { 
    rc += inoise(frequency*i, frequency*j, frequency*k) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  return rc * (1 - persistence)/(1 - amp);
}

// Mimic the processing FBM in noise() and off by one the FBM amplification
float perlinnoise(float i, float j, float k)
{
  int octave = 8;
  float persistence = 0.65;
  float lacunarity = 2.0;
  float frequency = 1.0;
  
  float rc = 0;
  float maxamp = 0;
  float amp = 0.5;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function: return values in [0,1] range. 
    rc += ((1 + (float)perlinnoise.noise((double)(frequency*i),(double)(frequency*j),(double)(frequency*k))) / 2.0f) * amp;
    maxamp += amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
    return rc / maxamp;
}

float simplexnoise(float i, float j, float k) {
  int octave = 4;
  float persistence = 0.25;
  float lacunarity = 0.5;
  float frequency = 1.0;
  
  float rc = 0;
  float amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1] range.
    rc += (((float)simplexnoise.noise((double)(frequency * i), (double)(frequency * j), (double)(frequency * k)) + 1) / 2.0f) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  return rc * (1 - persistence)/(1 - amp);  
}

float Noise(float x, float y, float z) {
  int octave = 8; 
  float persistence = 0.65;
  float lacunarity = 2.0;
  float frequency = 1.0;

  float rc = 0;
  float amp = 0.5;
  float maxamp = 0;
  //FBM with frequency = 1.0, lacunarity = 2.0 and persistence = 0.5 on 4 octaves with initial amp = 0.5.
  //Take only the first octave with persistence = 0.0.
  noiseDetail(1,0);
  for (int l = 0; l < octave; l++) {
    //println(rc);
    // The processing FBM for noise() is specific: persistence = 0.5 but they have introduced an off by one in the math common formula: initial amp = 0.5,
    // which should mean that the perlin noise() return value for the first octave should be half the processing perlin noise raw source. frequency = 1.0, lacunarity = 2.0 but the lacunarity is applied to 
    // noise() function arguments and is not an internal variable. There seem also to have some reseeding between octave in the FBM. libnoise do something that look similar in the idea but without the off by one.
    // The normalization in processing noise() function is still a mystery, libnoise do not normalize but the reseeding or something elsewhere might normalize between [-1,1]. 
    rc += noise(x*frequency, y*frequency, z*frequency) * amp;
    maxamp += amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  //return rc * (1 - persistence)/(1 - amp);
  //return rc / maxamp;
  //No need for normalization with the processing raw perlin noise implementation?
  return rc; 
}

float rawnoise(float x, float y, float z) {
  //FBM with frequency = 1.0, lacunarity = 2.0 and persistence = 0.5 on 4 octaves with initial amp = 0.5. 
  //Take 8 octaves with persistence = 0.65.
  noiseDetail(8, 0.65);
  return noise(x,y,z);
}

float n(float i){
  float xspeed = 0.1;
  float zspeed = 0.0125;
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
  float pulsey = sin(ly) * 1.25 + cos(ly) * 1.25;
  float noise_scale = 0.5125;
  float rc = simplexnoise(lx_prev * noise_scale + abs(lx - lx_prev), ly_prev * noise_scale + abs(ly - ly_prev) + pulsey, lz_prev * noise_scale + abs(lz - lz_prev));
  //println(rc);
  return rc*s*12+h/2;
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
  beginShape(TRIANGLES);
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
      //beginShape(TRIANGLES);
      vertex(x,n(y*w+x),y);
      vertex(m,n(y*w+m),y);
      vertex(m,n(k*w+m),k);
      vertex(m,n(k*w+m),k);
      vertex(x,n(k*w+x),k);
      vertex(x,n(y*w+x),y);
      //endShape();
      i+=i%w==0?w*(s-2):0;
  }
  endShape();
  r-=j;
  fill(100);
  text(frameRate,22,22);
}