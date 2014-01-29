// Phenotype -- the external expression of the genotype
// can be evaluated
 
class Phenotype
{
  float m_width;
  float m_height;
  float m_depth;
  Phenotype(Genotype g)
  {
    m_width = g.m_genes[0] * width;
    m_height = g.m_genes[1] * height;
    m_depth = g.m_genes[2] * height;
  }
  void draw()
  {
    box(m_width,m_height,m_depth);
  }
  float evaluate()
  {
    float fitness = 0.0;
    fitness += sq(m_width + m_height + m_depth);
    fitness -= m_width * m_height * m_depth;
    return fitness;
  }
}


