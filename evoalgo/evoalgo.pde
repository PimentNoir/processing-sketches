// Genetic algorithm
//
// Alasdair Turner 2009
//
// This is an example of evolutionary algorithm
// The test optimisation is to maximise the
// square of the side lengths while minimising
// the volume
 
Population pop;
 
void setup()
{
  int zoom = 4;
  size(220*zoom,220*zoom,P3D);
  //int framerate = int(random(80,120))
  int framerate = 4;
  frameRate(framerate);
  colorMode(RGB,100);
  pop = new Population();
  smooth();
   
}

int grid_size = 11;
float pop_number = sq(grid_size);
float evolve_rate = 1;

void draw()
{
  float scale = 0.0906;   
  long now = millis();
   
  // evolution is slow
  // make it easier to see and force evolve
  if (frameCount % evolve_rate == 0) {
    pop.evolve();
  }
  background(0);
  
  noStroke();
    
    
  lights();
  for (int i = 0; i < pop.m_pop.length; i++)
  {
    // this draws all the members of the population at
    // any one time step
    // fitter individuals appear to the top right
    pushMatrix();
    //println(scale); 
    scale(scale,scale,scale);
    //println((int)pop_number);
    int x = width * (i % (int)grid_size);
    //int y = height * (((int)grid_size-1) - (i / (int)grid_size));
    int y = height * (((int)grid_size-1) - (i / (int)grid_size));
    translate(x, y, 0);
    //translate(width/grid_size,height/grid_size,0);
    translate(width/2,height/2,0);
    rotateY(0.1 * frameCount);
    //lights();
    pop.m_pop[i].draw();
    popMatrix();
  }
}
 
void mousePressed()
{
  pop = new Population();
}

