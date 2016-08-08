
float mute_rate = 0.05;

class Genotype
{
  float [] m_genes;
  Genotype()
  {
    // these genes use floating point numbers rather than
    // binary strings
    m_genes = new float [3];
    for (int i = 0; i < m_genes.length; i++) {
      m_genes[i] = random(0, 1);
    }
  }
  void mutate()
  {
    // 5% mutation rate
    for (int i = 0; i < m_genes.length; i++) {
      if (random(0, 1) < mute_rate) {
        m_genes[i] = random(0, 1);
      }
    }
  }
}

Genotype crossover(Genotype a, Genotype b)
{
  // uniform crossover switches at any location
  // between genes in the genotype
  Genotype c = new Genotype();
  for (int i = 0; i < c.m_genes.length; i++) {
    if (random(0, 1) < 0.5) {
      c.m_genes[i] = a.m_genes[i];
    } else {
      c.m_genes[i] = b.m_genes[i];
    }
  } 
  return c;
}