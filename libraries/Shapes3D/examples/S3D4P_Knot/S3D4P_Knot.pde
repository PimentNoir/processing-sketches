/**
 Knot in 3D
 Demonstrating the Shapes3D library.
 
 created by Peter Lager
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

private BezTube btube;
private Toroid toroid1;
private Rot rot1;
private float[] ang1;

// ###################################################
// TOROID SPEED CONTROL VARIABLES
private float speed = 0.003f;
private float t = 0, dt = speed;

// The greater segs the smoother the curve
int segs = 100, slices = 8;

float angleX, angleY, angleZ; // rotation of 3D shape

void setup() {
  size(400, 400, P3D);
  btube = makeBezTube();

  // ################################################
  // MAKE TOROID CODE
  toroid1 = new Toroid(this, 6, 20);
  toroid1.moveTo(btube.getPoint(0));
  toroid1.fill(color(255, 96, 96));
  toroid1.stroke(color(255, 255, 0));
  toroid1.strokeWeight(1.2f);
  toroid1.setRadius(5, 3, 11.0f);
  toroid1.drawMode(Shape3D.SOLID | Shape3D.WIRE);
  // ################################################
}

void draw() {
  background(0);
  angleX += radians(0.913f);
  angleY += radians(0.799f);
  angleZ += radians(1.213f);

  camera(0, 0, 250, 0, 0, 0, 0, 1, 0);
  rotateX(angleX);
  rotateY(angleY);
  rotateZ(angleZ);
  // ################################################
  // CODE TO MOVE TOROID ALONG TUBE
  // Calculate parametric position along tube
  t += dt;
  if (t >= 1.0f) {
    t = 0.99999f;
    dt = -speed;
  }
  else if ( t<0.0f) {
    t = 0.0f;
    dt = speed;
  }
  // Get position and rotation for torroid
  rot1 = new Rot(new PVector(0, 1, 0), btube.getTangent(t));
  ang1 = rot1.getAngles(RotOrder.XYZ);
  // Move toroid and orient to tube tangent
  toroid1.moveTo(btube.getPoint(t));
  toroid1.rotateTo(ang1);
  toroid1.draw();
  // END OF TOROID MOVE CODE
  // ################################################
  btube.draw();
}

public BezTube makeBezTube() {
  PVector[] p = new PVector[] {
    new PVector(-143.69f, 35.0f, -40.81f), 
    new PVector(-70.35f, 4.39f, -40.44f), 
    new PVector(-5.35f, -18.33f, -9.69f), 
    new PVector(26.15f, -77.13f, -3.69f), 
    new PVector(70.15f, -111.38f, 40.81f), 
    new PVector(107.15f, -97.88f, 39.81f), 
    new PVector(115.4f, -72.88f, 27.81f), 
    new PVector(124.15f, -54.33f, 6.81f), 
    new PVector(104.15f, 39.67f, -9.69f), 
    new PVector(66.4f, 77.62f, -61.19f), 
    new PVector(40.4f, 119.62f, -67.69f), 
    new PVector(18.15f, 125.52f, -29.69f), 
    new PVector(-1.6f, 118.62f, -14.94f), 
    new PVector(-23.6f, 110.52f, -0.19f), 
    new PVector(-54.69f, 62.25f, 23.19f), 
    new PVector(-131.48f, -25.83f, -11.29f), 
    new PVector(-133.69f, -67.61f, 16.81f), 
    new PVector(-117.69f, -108.61f, 42.81f), 
    new PVector(-85.69f, -125.61f, -23.81f), 
    new PVector(-36.69f, -119.61f, -71.19f), 
    new PVector(13.15f, -78.13f, -63.69f), 
    new PVector(17.03f, -10.14f, -51.69f), 
    new PVector(26.15f, -20.88f, -3.69f), 
    new PVector(37.65f, -3.33f, 11.31f), 
    new PVector(96.15f, 15.87f, 16.31f), 
    new PVector(143.69f, 35.39f, 40.81f)
    };

    BezTube bt = new BezTube(this, new P_Bezier3D(p, p.length), 5.0f, segs, slices);

  bt.fill(color(32, 32, 180));
  bt.stroke(color(64, 180, 180));
  bt.strokeWeight(1.50f);
  bt.drawMode(Shape3D.SOLID | Shape3D.WIRE);

  bt.fill(color(150, 255, 255), BezTube.BOTH_CAP);
  bt.drawMode(Shape3D.SOLID, BezTube.BOTH_CAP);

  return bt;
}
