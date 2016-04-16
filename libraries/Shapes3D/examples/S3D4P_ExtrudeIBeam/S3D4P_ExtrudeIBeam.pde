/**
 Demonstration of using the Extrusion class to simulate 
 a structural I-beam.
 
 created by Peter Lager
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

float angleX, angleY, angleZ; // rotation of 3D shape
Extrusion e;

Path path;
Contour contour;
ContourScale conScale;

public void setup() {
  size(400, 400, P3D);
  cursor(CROSS);

  // create a striaght beam
  path = new P_LinearPath(new PVector(100, 100, 100), new PVector(-100, -100, -100));
  // Use pre-fabricated class to represent an I-beam
  contour = new C_IBeam(100, 40, 10, 12, 6);
  // Make the beam tapered
  conScale = new CS_LinearScale(3.5f, 0.8f);

  e = new Extrusion(this, path, 1, contour, conScale);
  e.fill(color(190, 255, 190));
  e.stroke(color(255));
  e.strokeWeight(1.2f);
  e.setTexture("sampler01.jpg", 2, 2.5f);
  e.drawMode(S3D.TEXTURE);

  // End caps
  e.stroke(color(0, 255, 255), S3D.BOTH_CAP);
  e.fill(color(0, 0, 255), S3D.BOTH_CAP);
  e.strokeWeight(3.5f, S3D.BOTH_CAP);
  e.drawMode(S3D.SOLID | S3D.WIRE, S3D.BOTH_CAP);
}

public void draw() {
  background(0, 0, 0);
  camera(0, 0, 600, 0, 0, 0, 0, 1, 0);
  lights();
  angleX += radians(0.913f);
  angleY += radians(0.799f);
  angleZ += radians(1.213f);
  e.rotateTo(angleX, angleY, angleZ);
  e.draw();
}
