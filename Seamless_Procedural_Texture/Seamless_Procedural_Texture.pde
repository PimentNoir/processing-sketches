/*
 
generate seamless tile using perlin noise
 
*/
double ns = 0.015;  //increase this to get higher density
double tt = 1;
ImprovedNoise perlinnoise = new ImprovedNoise();
INoise perlininoise = new INoise();
SimplexNoise simplexnoise = new SimplexNoise();

double inoise(double x, double y , double z) {
  final int mult = 1<<16;
  //Keep the same behaviour as the processing perlin noise() function, return values in [0,1]
  return (1 + ((double)(perlininoise.noise((int)(x*mult),(int)(y*mult),(int)(z*mult))) / mult)) / 2.0d;
}

double Noise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 1.0;
  
  double rc = 0; 
  double amp = 1.0;
  //Standard frequency ?
  noiseDetail(1,0);
  for (int l = 0; l < octave; l++) {
    rc += (double)noise((float)(frequency * x), (float)(frequency * y), (float)(frequency * z));
    amp *= persistence;
    frequency *= lacunarity;
  }
  //println(rc * (1 - persistence)/(1 - amp));
  return rc * (1 - persistence)/(1 - amp);  
}

double INoise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 8.0;
  
  double rc = 0; 
  double amp = 1.0;
  for (int l = 0; l < octave; l++) {
    rc += inoise(frequency * x, frequency * y, frequency * z) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  //println(rc * (1 - persistence)/(1 - amp));
  return rc * (1 - persistence)/(1 - amp);  
}

double NoiseImproved (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 1.0;
  
  double rc = 0; 
  double amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1]
    rc += ((1 + perlinnoise.noise(frequency * x, frequency * y, frequency * z))/2)*amp;
    amp *= persistence;
    frequency *= lacunarity; 
  }
  //println(rc * (1 - persistence)/(1 - amp));
  return rc * (1 - persistence)/(1 - amp);  
}

double SimplexNoise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 1.0;
  
  double rc = 0; 
  double amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1]
    rc += ((1 + simplexnoise.noise(frequency * x, frequency * y, frequency * z))/2)*amp;
    amp *= persistence;
    frequency *= lacunarity; 
  }
  //println(rc * (1 - persistence)/(1 - amp));
  return rc * (1 - persistence)/(1 - amp);  
}
 
void setup () {
  size(512,512);
  colorMode(RGB, 255);
//  frameRate(16);
//  noLoop();
}
 
void draw () { 
  loadPixels();
  int w = width; 
  int h = height; 
  int offset = 0;
  int value = 0;
  for (int y = 0; y < h; y++) { 
  double v = (double) y / h;
  double nv = 1.0 - v; 
  for (int x = 0; x < w; x++) {
    double u = (double) x / w; 
    double noise00 = INoise(x*ns, y*ns, tt); 
    double noise01 = INoise(x*ns, (y+h)*ns, tt); 
    double noise10 = INoise((x+w)*ns, y*ns, tt); 
    double noise11 = INoise((x+w)*ns, (y+h)*ns, tt); 
    double noisea = u*v*noise00 + u*nv*noise01 + (1-u)*v*noise10 + (1-u)*nv*noise11;
    //println(noisea); 
    value = (int) (256 * noisea) + 50; 
    pixels[offset] = color(constrain((int)noise00,0,255)
                          ,constrain(value,0,255)
                          ,constrain(value +50,0,255)); 
    offset++;
   } 
  } 
  updatePixels();
  tt += (float) 1/16; 
  text(frameRate,22,22); 
}
