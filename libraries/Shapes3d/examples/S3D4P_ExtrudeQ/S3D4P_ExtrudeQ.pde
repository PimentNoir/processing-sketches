/**
 Demonstration of using the Extrusion class to create an
 extruded object from a custom (concave) contour. In
 this case the letter Q
 
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
  // The vertices to be used for the Bezier spline
  PVector[] knots = new PVector[] {
    new PVector(240, 0, 50), 
    new PVector(120, 0, 0), 
    new PVector(0, 0, -100), 
    new PVector(-80, 0, 0), 
    new PVector(-40, 50, 0), 
    new PVector(60, 80, 50),
  };

  // Use a BezierSpline to define the extrusion path
  path = new P_BezierSpline(knots);
  // Custom contour object
  contour = new Qcontour();
  // Custom scale object
  conScale = new Qscale();

  e = new Extrusion(this, path, 100, contour, conScale);
  e.setTexture("ukflag.jpg", 4, 7);
  e.drawMode(S3D.TEXTURE );

  // End caps
  e.stroke(color(255, 255, 255), S3D.BOTH_CAP);
  e.fill(color(255, 255, 0), S3D.BOTH_CAP);
  e.strokeWeight(2.2f, S3D.BOTH_CAP);
  e.setTexture("ukflag.jpg", S3D.BOTH_CAP);
  e.drawMode(S3D.SOLID | S3D.WIRE, S3D.BOTH_CAP);
}

public void draw() {
  background(0, 0, 0);
  camera(0, 0, 480, 0, 0, 0, 0, 1, 0);
  lights();
  angleX += radians(0.913f);
  angleY += radians(0.799f);
  angleZ += radians(1.213f);
  e.rotateTo(angleX, angleY, angleZ);
  e.draw();
}

// Simple class to generate a scaling factor to apply 
// to the contour along its length
class Qscale implements ContourScale {
  // Parametric t in range 0.0 to 1.0 inclusive
  public float scale(float t) {
    float s = t - 0.5f;
    s = s * s * 2.2f + 0.2f;
    return s;
  }
}

/**
 Another class that defines the contour to be used
 */
class Qcontour extends Contour {
  public Qcontour() {
    contour = new PVector[] {
      new PVector(13, 6.5f), 
      new PVector(13, -6.5f), 
      new PVector(6.5f, -13), 
      new PVector(-6.5f, -13), 
      new PVector(-13, -6.5f), 
      new PVector(-13, 6.5f), 
      new PVector(-6.5f, 13), 
      new PVector(5.3f, 13), 
      new PVector(11.5f, 18.5f), 
      new PVector(10, 20), 
      new PVector(-10, 20), 
      new PVector(-20, 10), 
      new PVector(-20, -10), 
      new PVector(-10, -20), 
      new PVector(10, -20), 
      new PVector(20, -10), 
      new PVector(20, 10), 
      new PVector(17.5f, 13), 
      new PVector(20, 15.5f), 
      new PVector(15.5f, 20), 
      new PVector(5.5f, 11), 
      new PVector(10, 5.5f), 
      new PVector(12, 7.7f)
      };
      for (PVector c : contour)
        c.mult(2);
  }
}
