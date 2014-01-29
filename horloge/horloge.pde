void setup() {
  //background(0);
  colorMode(RGB, 255, 255, 255);
  size(500,500,P2D);
  smooth();
  frameRate(60);
}

int lineweight = 4;
color s_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255));  
color m_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255)); 
color h_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255));

void draw() {
  background(0);
  int s = second();  // Values from 0 - 59
  int m = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
  
  // Randomize color every 60 frames
  if (frameCount % 60 == 0 && s_color == color(0,0,0) && m_color == color(0,0,0) && h_color == color(0,0,0)) {
    color s_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255));  
    color m_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255)); 
    color h_color = color((int)random(0,255), (int)random(0,255), (int)random(0,255));
  } 
  
  strokeWeight(lineweight);
  stroke(s_color);
  pushMatrix();
  line(lineweight+width*s/60, 0*height, lineweight+width*s/60, height/3);
  popMatrix();
  noStroke(); 
 
  strokeWeight(lineweight);
  stroke(m_color);
  pushMatrix(); 
  //translate(lineweight/2+width*m/120+width/120, 0);
  line(lineweight+width*m/60, height/3, lineweight+width*m/60, 2*height/3);
  popMatrix();
  noStroke();
  
  strokeWeight(lineweight);
  stroke(h_color);
  pushMatrix();
  //translate(lineweight/2+width*h/48+width/48, 0);
  line(lineweight+width*h/24, 2*height/3, lineweight+width*h/24, height);
  popMatrix();
  noStroke();
}


//void DrawLine (float
