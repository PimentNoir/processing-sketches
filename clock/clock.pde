void setup() {
  size(220, 220);
  smooth();
}

void draw() {
  background(255);

  translate(width / 2, height / 2);
  
  // clock circle
  strokeWeight(2);
  ellipse(0, 0, 200, 200);
  
  // seconds
  strokeWeight(1);
  // degrees divided by number of second marks per round
  float radSec = 360 / 60 * second();
  pushMatrix();
  rotate(radians(radSec));
  line(0, 0, 0, -95);
  popMatrix();
  
  // minutes
  strokeWeight(2);
  float radMin = 360 / 60 * minute();
  pushMatrix();
  rotate(radians(radMin));
  line(0, 0, 0, -90);
  popMatrix();
  
  // hours
  strokeWeight(4);
  float radHour = 360 / 12 * hour();
  pushMatrix();
  rotate(radians(radHour));
  line(0, 0, 0, -50);
  popMatrix();
}
