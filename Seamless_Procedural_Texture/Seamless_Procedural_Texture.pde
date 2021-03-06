/*
 
 generate seamless tile using differents perlin's noises implementation
 
 */
ImprovedNoise perlinnoise = new ImprovedNoise();
INoise perlininoise = new INoise();
SimplexNoise simplexnoise = new SimplexNoise();

double ns = 0.015;  //increase this to get higher density
double tt = 1;

double inoise(double x, double y, double z) {
  final int mult = 1<<16;
  //Keep the same behaviour as the processing perlin noise() function, return values in [0,1] range. 
  return (1 + ((double)(INoise.noise((int)(x*mult), (int)(y*mult), (int)(z*mult))) / mult)) / 2.0d;
}

// Mimic the processing FBM in noise() and off by one the FBM amplification
double Noise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 8.0;

  double rc = 0; 
  //off by one the amplification
  double amp = 0.5;
  //FBM with frequency = 1.0, lacunarity = 2.0 and persistence = 0.5 on 4 octaves with initial amp = 0.5, take only the first octave with persistence = 0.0.
  noiseDetail(1, 0);
  for (int l = 0; l < octave; l++) {
    rc += (double)noise((float)(frequency * x), (float)(frequency * y), (float)(frequency * z))*amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  //println(rc * (1 - persistence)/(1 - amp));
  //return rc * (1 - persistence)/(1 - amp);
  //println(rc);
  //The processing noise() perlin noise implementation do not seem to need normalization.
  //This implementation make a little more tiles.
  return rc;
}

// Mimic the processing FBM in noise() and off by one the FBM amplification
double INoise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 8.0;

  double rc = 0;
  //off by one the amplification 
  double amp = 0.5;
  for (int l = 0; l < octave; l++) {
    rc += inoise(frequency * x, frequency * y, frequency * z) * amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  //println(rc * (1 - persistence)/(1 - amp));
  //The Perlin reference implementation need normalization.
  return rc * (1 - persistence)/(1 - amp); 
  //println(rc);
  //return rc;
}

double ImprovedNoise (double x, double y, double z) {
  int octave = 8;
  double persistence = 0.5;
  double lacunarity = 2.0;
  double frequency = 8.0;

  double rc = 0; 
  double amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1] range.
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
  double frequency = 8.0;

  double rc = 0; 
  double amp = 1.0;
  for (int l = 0; l < octave; l++) {
    //Keep the same behaviour as the processing perlin noise() function, return values in [0,1] range. 
    rc += ((1 + SimplexNoise.noise(frequency * x, frequency * y, frequency * z))/2)*amp;
    amp *= persistence;
    frequency *= lacunarity;
  }
  //println(rc * (1 - persistence)/(1 - amp));
  return rc * (1 - persistence)/(1 - amp);
}

double RawNoise(double x, double y, double z) {
  float frequency = 8.0;
  //FBM with frequency = 1.0, lacunarity = 2.0 and persistence = 0.5 on 4 octaves with initial amp = 0.5. 
  //Take 8 octaves with persistence = 0.5.
  noiseDetail(8, 0.5);
  return (double)noise(frequency*(float)x, frequency*(float)y, frequency*(float)z);
}

void setup () {
  size(512, 512);
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
      double noise00 = RawNoise(x*ns, y*ns, tt); 
      double noise01 = RawNoise(x*ns, (y+h)*ns, tt); 
      double noise10 = RawNoise((x+w)*ns, y*ns, tt); 
      double noise11 = RawNoise((x+w)*ns, (y+h)*ns, tt); 
      double noisea = u*v*noise00 + u*nv*noise01 + (1-u)*v*noise10 + (1-u)*nv*noise11;
      //println(noisea); 
      value = (int) (256 * noisea) + 50; 
      pixels[offset] = color(constrain((int)noise00, 0, 255)
        , constrain(value, 0, 255)
        , constrain(value +50, 0, 255)); 
      offset++;
    }
  } 
  updatePixels();
  tt += (float) 1/16; 
  text(frameRate, 22, 22);
}