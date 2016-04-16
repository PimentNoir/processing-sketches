/**
 Earth and Moon
 
 Shows how shapes can be combined to act
 as a single system.
 
 created by Peter Lager
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Ellipsoid earth, moon, stars;
Box orbiter;

boolean attached = true;

public void setup() {
  size(420, 380, P3D);  

  // Create the earth
  earth = new Ellipsoid(this, 16, 16);
  earth.setTexture("earth.jpg");
  earth.setRadius(90);
  earth.moveTo(new PVector(0, 0, 0));
  earth.strokeWeight(1.0f);
  earth.stroke(color(255, 255, 0));
  earth.moveTo(20, 40, -80);
  earth.tag = "Earth";
  earth.drawMode(Shape3D.TEXTURE);

  //    // Create the moon
  moon = new Ellipsoid(this, 15, 15);
  moon.setTexture("moon.jpg");
  moon.drawMode(Shape3D.TEXTURE);
  moon.setRadius(20);
  moon.moveTo(0, 0, 220);
  moon.tag = "Moon";

  orbiter = new Box(this, 6, 6, 10);
  orbiter.fill(color(32, 32, 200));
  orbiter.stroke(color(200, 200, 200));
  orbiter.strokeWeight(1.2f);
  orbiter.moveTo(0, 0, -30);
  orbiter.drawMode(Shape3D.SOLID);
  orbiter.tag = "orbiter";

  // Create the star background
  stars = new Ellipsoid(this, 10, 10);
  stars.setTexture("stars01.jpg", 5, 5);
  stars.drawMode(Shape3D.TEXTURE);
  stars.setRadius(500);

  // Add the moon to the earth this makes 
  // its position relative to the earth's
  earth.addShape(moon);
  // and the orbiter to the moon
  moon.addShape(orbiter);
}

public void draw() {
  pushStyle();
  // Change the rotations before drawing
  earth.rotateBy(0, radians(0.6f), 0);
  moon.rotateBy(radians(0.5f), radians(1.0f), 0);
  orbiter.rotateBy(0, radians(4.0f), 0);
  stars.rotateBy(0, 0, radians(0.02f));

  background(0);
  pushMatrix();
  camera(0, -190, 350, 0, 0, 0, 0, 1, 0);

  // Draw the earth (will cause all added shapes
  // to be drawn i.e. the moon)
  earth.draw();

  stars.draw();
  popMatrix();
  popStyle();
}
