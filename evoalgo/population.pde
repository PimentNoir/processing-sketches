
import java.util.Arrays;

class Population
{
  Individual [] m_pop; 
  Population()
  {
    m_pop = new Individual [100];
    for (int i = 0; i < m_pop.length; i++) {
      m_pop[i] = new Individual();
      m_pop[i].evaluate();
    }
    Arrays.sort(m_pop);
  }
  void evolve()
  {
    Individual a = select();
    Individual b = select();
    Individual x = breed(a,b);
    x.evaluate();
    m_pop[0] = x;
    Arrays.sort(m_pop);
  }
  Individual select()
  {
    // Selection requires some form of bias to fitter individuals,
    int which = (int) floor((100.0 - 1e-6) * (1.0 - sq(random(0,1))));
    return m_pop[which];
  }
}

