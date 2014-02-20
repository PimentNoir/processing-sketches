//import processing.opengl.*;
 
final int START_SIZE = 500;
final int STEP = 200;
 
Box mother;
 
void setup() {
  size(600, 600, P3D);
   
  mother = new Box(START_SIZE);
  stroke(255, 50);
  fill(255, 20);
  frameRate(25);
}
 
void draw() {
  background(0);
  resetMatrix();
  translate(0,0,-1000);
 
   
  if(frameCount % STEP == 0 && frameRate >= 25) {
    mother.tick();
    println(frameRate);
  }
 
  mother.draw();
}
 
void mousePressed() {
  mother.tick();
}

 


