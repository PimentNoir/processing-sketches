// An individual has both a genotype and a phenotype
 
class Individual implements Comparable
{
  Genotype m_genotype;
  Phenotype m_phenotype; 
  float m_fitness;
  Individual()
  {
    m_genotype = new Genotype();
    m_phenotype = new Phenotype(m_genotype);
    m_fitness = 0.0;
  }
  int compareTo(Object obj_b)
  {
    Individual b = (Individual) obj_b;
    if (m_fitness > b.m_fitness) {
      return 1;
    }
    else if (m_fitness < b.m_fitness) {
      return -1;
    }
    return 0;
  }
  void draw()
  {
    m_phenotype.draw();
  }
  void evaluate()
  {
    m_fitness = m_phenotype.evaluate();
  }
}
 
Individual breed(Individual a, Individual b)
{
  Individual c = new Individual();
  c.m_genotype = crossover(a.m_genotype,b.m_genotype);
  c.m_genotype.mutate();
  c.m_phenotype = new Phenotype(c.m_genotype);
  return c;
}

