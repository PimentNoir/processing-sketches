// Phenotype -- the external expression of the genotype
// can be evaluated
 
class Phenotype
{
  //float m_width;
  //float m_height;
  //float m_depth;
  int m_x;
  int m_y; 
  float m_rayon;
  int m_hue;
  int m_saturation;
  int m_brightness;
  Phenotype(Genotype g)
  {
    //m_width = g.m_genes[0] * width;
    //m_height = g.m_genes[1] * height;
    //m_depth = g.m_genes[2] * width;
   // m_rayon = g.m_genes[0] * width;
    //m_rayon = width/11;
    //m_x = (int)  floor(
    m_hue = (int) floor(g.m_genes[0] * random(0,255)); 
    m_saturation = (int) floor(g.m_genes[1] * random(0,255));
    m_brightness = (int) floor(g.m_genes[2] * random(0,255));
    //m_hue = (int) floor(g.m_genes[4]); 
    //m_saturation = (int) floor(g.m_genes[5]);
    //m_brightness = (int) floor(g.m_genes[6]);
  }
  void draw()
  {
    fill(m_hue, m_saturation,m_brightness);
    box(width,height,0);
    //sphere(width/2);
    
  }
  float evaluate()
  {
    float fitness = 0.0;
    //fitness += sq( m_width + m_height + m_depth + m_rayon + m_hue + m_saturation + m_brightness );
    fitness += sq( m_hue + m_saturation + m_brightness );
    //fitness -= m_width * m_height * m_depth * m_rayon * m_hue * m_saturation * m_brightness;
    fitness -= m_hue * m_saturation * m_brightness;
    return fitness;
  }
}


