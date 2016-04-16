/**
 Simple program to demonstrate the shape picking feature
 of this library.
 
 Click on the slowly revolving cubes to change their colour.
 
 created by Peter Lager
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Box[] box = new Box[20];
Shape3D picked = null;
boolean clicked = false;

float bsize, a, d = 50, c = 120;

void setup() {
  size(400, 400, P3D);
  cursor(CROSS);
  for (int i = 0; i < box.length; i++) {
    bsize = 5 + (int)random(12);
    box[i] = new Box(this, bsize, bsize, bsize);
    box[i].moveTo(random(-d, d), random(-d, d), random(-d, d));
    box[i].fill(randomColor());
    box[i].stroke(color(64, 0, 64));
    box[i].strokeWeight(0.6);
    box[i].drawMode(S3D.SOLID | S3D.WIRE);
    box[i].tag = "Box " + i;
  }
}

void draw() {
  background(128);
  pushMatrix();
  camera(c * sin(a), 10, c * cos(a), 0, 0, 0, 0, 1, 0);
  if (clicked) {
    clicked = false;
    picked = Shape3D.pickShape(this, mouseX, mouseY);
    if (picked != null)
      picked.fill(randomColor());
  }
  for (int i = 0; i < box.length; i++)
    box[i].draw();
  popMatrix();
  a += 0.002;
}

void mouseClicked() {
  clicked = true;
}

int randomColor() {
  return color(random(100, 220), random(100, 220), random(100, 220));
}