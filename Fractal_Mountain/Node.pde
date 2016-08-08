class Node
{
  PVector A, B, C, D;
  public PVector H;
  Node nodeA, nodeB, nodeC, nodeD;
  int depth;
  color colorNode;// = color((int)random(255), (int)random(255), (int)random(255));

  Node(PVector p_A, PVector p_B, PVector p_C, PVector p_D, int p_depth)
  {
    A = p_A;
    B = p_B;
    C = p_C;
    D = p_D;
    depth = p_depth;
  }
}