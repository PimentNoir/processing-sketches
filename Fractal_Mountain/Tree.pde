class Tree
{
  Node root;
  float deltaH;
  Tree(PVector p_A, PVector p_B, PVector p_C, PVector p_D)
  {
    root = new Node(p_A, p_B, p_C, p_D, 0);
    addNodes(root);
  }
 
  void addNodes(Node p_node)
  {
    int depth = p_node.depth + 1;
    PVector A = p_node.A;
    PVector B = p_node.B;
    PVector C = p_node.C;
    PVector D = p_node.D;
    PVector H = new PVector((A.x + B.x + C.x + D.x)/4, (A.y + B.y + C.y + D.y)/4, (A.z + B.z + C.z + D.z)/4);
    //H.z = 150/(depth) + random(100/depth);// + random(50);// + 1.1 * max(A.z, max(B.z, C.z));//120;
    H.z += random(-HEIGHT_H/(depth*depth), HEIGHT_H/(depth*depth));
    if (lowestH > H.z)
    {
      lowestH = H.z;
    }
    else if (highestH < H.z)
    {
      highestH = H.z;
    }
    deltaH = (lowestH + highestH)/2;
 
    p_node.H = H;
//    p_node.colorNode = (int)min(abs(H.z), 255);
    p_node.colorNode = (int)map(min(abs(H.z), HEIGHT_H), 0, HEIGHT_H, 0, 255);
 
    if (depth <= MAX_DEPTH)
    {
      float u = random(.1, .9);//.5;//random(.1, .9);//
      float v = random(.1, .9);//.5;//random(.1, .9);//
 
      PVector AB = new PVector(A.x + u*(B.x-A.x), A.y + u*(B.y-A.y), A.z + u*(B.z-A.z));
      PVector BC = new PVector(B.x + u*(C.x-B.x), B.y + u*(C.y-B.y), B.z + u*(C.z-B.z));
      PVector CD = new PVector(C.x + u*(D.x-C.x), C.y + u*(D.y-C.y), C.z + u*(D.z-C.z));
      PVector DA = new PVector(D.x + u*(A.x-D.x), D.y + u*(A.y-D.y), D.z + u*(A.z-D.z));
 
      Node nodeA = new Node(A, AB, H, DA, depth);
      Node nodeB = new Node(B, BC, H, AB, depth);
      Node nodeC = new Node(C, CD, H, BC, depth);
      Node nodeD = new Node(D, DA, H, CD, depth);
      p_node.nodeA = nodeA;
      p_node.nodeB = nodeB;
      p_node.nodeC = nodeC;
      p_node.nodeD = nodeD;
 
      addNodes(nodeA);
      addNodes(nodeB);
      addNodes(nodeC);
      addNodes(nodeD);
    }
  }
}

