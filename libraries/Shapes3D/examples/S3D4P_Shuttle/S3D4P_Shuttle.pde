/**
 Demonstration of the PathTube class
 
 Keys 0 (stop) - 9 (fast) control the speed
 T key toggles tube style
 Keys < > change the tube shape
 
 @author Peter Lager 2013
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

// Path dependent variables
I_PathGen[] path;
int nbrPaths = 8;
int currPath = 0;
float[] speedFactor;
float[] carSpacing;

// The tubes
PathTube atube, ctube;
int tubeType = 0;
int nbrTubeTypes = 2;
final int SLICES = 300, SEGMENTS = 8;

// The shuttle
Toroid train;
Box[] bcar;
final int nbrBoxCars = 40;

// Used for train/car orientation to the tube
final PVector FORWARD_AXIS = new PVector(0, 1, 0);
final PVector LEFT_AXIS = new PVector(-1, 0, 0);
PVector normal, tangent, position ;
Rot rot;
float[] ang;

float angleX, angleY, angleZ;

// SHUTTLE SPEED CONTROL VARIABLES
float speed = 0.06f, pathFactor = 1, elapsed;
float paraT = 0.5f;	// starting position on curve
long st, ct;  		// keep track of running time

void setup() {
  size(500, 500, P3D);
  textFont(createFont("dialog", 16));

  // Create the path generator
  path = new I_PathGen[nbrPaths];
  path[0] = new Lissajous(1, 3, 2);
  path[1] = new Lissajous(3, 5, 2);
  path[2] = new Lissajous(3, 7, 2);
  path[3] = new Lissajous(3, 11, 2);
  path[4] = new Lissajous(5, 7, 2);
  path[5] = new Lissajous(5, 9, 2);
  path[6] = new Lissajous(5, 11, 2);
  path[7] = new Lissajous(7, 11, 2);
  speedFactor = new float[nbrPaths];
  carSpacing = new float[nbrPaths];
  // Create the tube
  atube = new PathTube(this, path[currPath], 6, SLICES, SEGMENTS, false);
  atube.fill(color(120, 120, 255));
  atube.drawMode(Shape3D.SOLID);
  atube.visible(false, Shape3D.BOTH_CAP);
  // Create path cage
  ctube = new PathTube(this, path[currPath], 22, SLICES, SEGMENTS - 2, true);
  ctube.stroke(color(192));
  ctube.stroke(color(120, 120, 255));
  ctube.strokeWeight(1.2f);
  ctube.drawMode(Shape3D.WIRE);
  ctube.visible(false, Shape3D.BOTH_CAP);
  // Initialise spacing and speed factors
  float l = atube.length(400);
  speedFactor[currPath] = 12000 / l;
  carSpacing[currPath] = 21 / l;

  // Create the train engine
  train = new Toroid(this, 4, 6);
  train.moveTo(atube.getPoint(paraT));
  train.fill(color(255, 255, 64));
  train.stroke(color(64, 0, 0));
  train.strokeWeight(0.5f);
  train.setRadius(8, 12, 11.0f);
  train.drawMode(Shape3D.SOLID | Shape3D.WIRE);
  // Create the box cars
  bcar = new Box[nbrBoxCars];
  for (int i = 0; i < nbrBoxCars; i++) {
    bcar[i] = new Box(this, 20);
  }
  // Initialise times
  st = ct = millis();
}

void draw() {
  background(16);
  pushMatrix();
  camera(0, 0, 800, 0, 0, 0, 0, 1, 0);
  angleX += radians(0.0913f);
  angleY += radians(0.0799f);
  angleZ += radians(0.1213f);
  rotateX(angleX);
  rotateY(angleY);
  rotateZ(angleZ);
  ct = millis();
  elapsed = (ct - st)/1000.0f;
  st = ct;
  paraT += elapsed * speed * speedFactor[currPath];
  paraT = (paraT > 1) ? paraT-1 : paraT;
  normal = atube.getNormal(paraT);
  tangent = atube.getTangent(paraT);
  position = atube.getPoint(paraT);
  // Get position and rotation for shuttle
  rot = new Rot(FORWARD_AXIS, LEFT_AXIS, tangent, normal);
  ang = rot.getAngles(RotOrder.XYZ);
  train.moveTo(position);
  train.rotateTo(ang);
  train.draw();
  float bparaT = paraT;

  for (int i = 0; i < nbrBoxCars; i++) {
    bparaT -= carSpacing[currPath];
    bparaT = (bparaT < 0) ? bparaT + 1 : bparaT;
    normal = atube.getNormal(bparaT);
    tangent = atube.getTangent(bparaT);
    position = atube.getPoint(bparaT);
    rot = new Rot(FORWARD_AXIS, LEFT_AXIS, tangent, normal);
    ang = rot.getAngles(RotOrder.XYZ);
    bcar[i].moveTo(position);
    bcar[i].rotateTo(ang);
    bcar[i].draw();
  }
  // Display one of the tubes
  switch(tubeType) {
  case 0:
    atube.draw();
    break;
  case 1:
    ctube.draw();
    break;
  }
  popMatrix();
  noStroke();
  fill(0, 0, 96);
  rect(0, 0, width, 36);
  rect(0, height-36, width, 36);
  fill(255);
  text("SHUTTLE KEYS:  stop  [0]     [1]  speed  [9]", 4, 20);
  text("TUBE KEYS:  style  [T]     shape  [<]  change  [>]", 4, height - 10);
}

void keyReleased() {
  // Adjust speed
  if (key >= '0' && key <= '9') {
    speed = (key - 48) / 50.0f;
  }
  // Change tube style
  if (key == 'T' || key == 't') {
    tubeType++;
    tubeType %= nbrTubeTypes;
  }
  // Change tube path
  if (key == '<' || key == ',')
    currPath += (nbrPaths - 1);
  else if (key == '>' || key == '.')
    currPath++;
  currPath %= nbrPaths;
  atube.setPath(path[currPath]);
  ctube.setPath(path[currPath]);	
  if (speedFactor[currPath] <= 0) {
    float l = atube.length(400);
    speedFactor[currPath] = 12000 / l;
    carSpacing[currPath] = 21 / l;
  }
}
