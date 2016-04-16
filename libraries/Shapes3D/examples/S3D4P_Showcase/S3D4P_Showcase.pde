/**
 * Simple program that displays some the shapes 
 * and features available in the Shapes3D library.
 *
 * Press the space bar for the next shape. 
 * drag mouse to rotate.
 * 
 * Also requires PeasyCam library available from
 * http://www.processing.org/reference/libraries/#3d
 * 
 * created by Peter Lager
 */


import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Ellipsoid ellipsoid;
Toroid toroid;
Helix helix;
Cone cone;
Tube tube;
Box box;
Bezier2D bn;
P_Bezier3D bez;
BezShape bezierShape;
BezTube btube;
Extrusion extrude;

// Array to simplify the selection of the 
Shape3D[] shapes; 

Path path;
Contour contour;
ContourScale conScale;

int shapeNo = 2;

String footer = "Press any key for next shape";
int footerX;

float angleX, angleY, angleZ;

public void setup() {
  size(400, 400, P3D);
  // Use this to have fixed lighting
  cursor(CROSS);
  textFont(createFont("DIALOG", 16));
  // Needed to centre footer text
  footerX =  round((width - textWidth(footer))/2);
  // Makes shape selection easier
  shapes = new Shape3D[9];

  makeBezierForShape();
  bezierShape = new BezShape(this, bn, 40, 20);
  bezierShape.setTexture("rouge.jpg");
  bezierShape.drawMode(S3D.TEXTURE);
  shapes[0] = bezierShape;

  box = new Box(this);
  String[] faces = new String[] {
    "pd_9.jpg", "pd_a.jpg", "pd_10.jpg", 
    "pd_k.jpg", "pd_j.jpg", "pd_q.jpg"
  };
  box.setTextures(faces);
  box.fill(color(255));
  box.stroke(color(190));
  box.strokeWeight(1.2f);
  box.setSize(100, 100, 100);
  //    box.rotateTo(radians(45), radians(45), radians(45));
  box.drawMode(S3D.TEXTURE | S3D.WIRE);
  box.shapeOrientation(null, new PVector(20, 20, 20));
  shapes[1] = box;

  cone = new Cone(this, 40);
  cone.setSize(140, 140, 100);
  cone.moveTo(new PVector(0, 10, 0));
  cone.setTexture("stars03.jpg", S3D.CONE);
  cone.drawMode(S3D.TEXTURE, S3D.CONE);
  cone.fill(color(96, 0, 0), S3D.BASE);
  cone.stroke(color(180, 0, 0), S3D.BASE);
  cone.strokeWeight(0.8f, S3D.BASE);
  cone.drawMode(S3D.SOLID | S3D.WIRE, S3D.BASE);
  shapes[2] = cone;

  tube = new Tube(this, 4, 50);
  tube.setSize(100, 70, 40, 40, 240);
  tube.setTexture("sampler01.jpg", 2, 1);
  tube.setTexture("coinhead.jpg", S3D.S_CAP);
  tube.setTexture("cointail.jpg", S3D.E_CAP);
  tube.drawMode(S3D.TEXTURE);
  tube.drawMode(S3D.TEXTURE, S3D.BOTH_CAP);
  shapes[3] = tube;

  makeBezierForTube();
  btube = new BezTube(this, bez, 22, 30, 7);
  btube.setTexture("ukflag.jpg", 3, 10 );
  btube.drawMode(S3D.TEXTURE);
  btube.fill(color(255, 0, 0), S3D.S_CAP);
  btube.fill(color(0, 255, 0), S3D.E_CAP);
  shapes[4] = btube;

  ellipsoid = new Ellipsoid(this, 16, 24);
  ellipsoid.setTexture("globe.jpg");
  ellipsoid.setRadius(120, 80, 120);
  ellipsoid.drawMode(S3D.WIRE | S3D.TEXTURE);
  ellipsoid.stroke(color(160));
  ellipsoid.strokeWeight(0.6f);
  shapes[5] = ellipsoid;

  helix = new Helix(this, 20, 200);
  helix.setRadius(8, 14, 80);
  helix.setHelix(2.5f, 60);
  helix.moveTo(new PVector(0, 0, 0));
  helix.setTexture("wh_pic2.jpg", 40, 2);
  helix.drawMode(S3D.TEXTURE);
  helix.fill(color(20, 255, 20), S3D.S_CAP);
  helix.fill(color(255, 20, 20), S3D.E_CAP);
  helix.drawMode(S3D.SOLID, S3D.BOTH_CAP);
  shapes[6] = helix;

  toroid = new Toroid(this, 30, 60);
  toroid.setRadius(50, 40, 80);
  toroid.rotateToX(radians(-30));
  toroid.moveTo(new PVector(0, 0, 0));
  toroid.stroke(color(0, 0, 60));
  toroid.strokeWeight(0.8f);
  toroid.setTexture("sea.jpg", 6, 1);
  toroid.drawMode(S3D.TEXTURE | S3D.WIRE);
  shapes[7] = toroid;

  path = new P_LinearPath(new PVector(0, 140, 0), new PVector(0, 0, 0));
  contour = getBuildingContour();
  conScale = new CS_ConstantScale();
  contour.make_u_Coordinates();
  extrude = new Extrusion(this, path, 1, contour, conScale);
  extrude.moveTo(0, -40, 0);
  extrude.setTexture("wall.png", 1, 1);
  extrude.drawMode(S3D.TEXTURE );
  extrude.setTexture("tartan.jpg", S3D.BOTH_CAP);
  extrude.drawMode(S3D.TEXTURE, S3D.BOTH_CAP);
  shapes[8] = extrude;

  for (Shape3D shape : shapes) {
    shape.tag = "Created using the " + shape.getClass().getSimpleName() + " class";
    shape.tagNo = round((width - textWidth(shape.tag))/2);
  }
}

public void draw() {
  background(240, 220, 240);
  // 3D draw first
  pushMatrix();
  camera(0, 0, 300, 0, 0, 0, 0, 1, 0);
  angleX += radians(0.913f);
  angleY += radians(0.799f);
  angleZ += radians(1.213f);
  rotateX(angleX);
  rotateY(angleY);
  rotateZ(angleZ);
  // Draw selected shape
  shapes[shapeNo].draw();
  popMatrix();
  // draw HUD
  fill(30, 30, 200);
  rect(0, 0, width, 40);
  rect(0, height - 40, width, 40);
  fill(255);
  text(shapes[shapeNo].tag, shapes[shapeNo].tagNo, 24);
  text(footer, footerX, height - 12);
} 

public void keyPressed() {
  shapes[shapeNo].visible(false);
  shapeNo = (shapeNo + 1)%9;
  shapes[shapeNo].visible(true);
}

public void makeBezierForShape() {
  int degree = 4;
  PVector[] v;
  float[][] d = new float[degree][2];    
  d[0][0] = 60;    
  d[0][1] = -80;
  d[1][0] = -10;    
  d[1][1] = -40;
  d[2][0] = -20;    
  d[2][1] = 20;
  d[3][0] = 80;    
  d[3][1] = 80;

  v = new PVector[degree];
  for (int i = 0; i < degree; i++) {
    v[i] = new PVector(d[i][0], d[i][1]);
  }
  bn = new Bezier2D(v, v.length);
}

public void makeBezierForTube() {
  PVector[] p = new PVector[] {
    new PVector(-100, -60, 10), 
    new PVector(-80, 50, -20), 
    new PVector(0, 140, -30), 
    new PVector(50, 160, -40), 
    new PVector(200, 100, -60), 
    new PVector(80, 40, -40), 
    new PVector(50, -30, -30), 
    new PVector(0, -80, -20),
  };
  bez = new P_Bezier3D(p, p.length);
}

public Contour getBuildingContour() {
  PVector[] c = new PVector[] {
    new PVector(-30, 30), 
    new PVector(30, 30), 
    new PVector(50, 10), 
    new PVector(10, -30), 
    new PVector(-10, -30), 
    new PVector(-50, 10)
    };
    return new Building(c);
}

/**
 * Very basic class to represent a building 
 * contour for the extrude shape
 *
 */
public class Building extends Contour {

  public Building(PVector[] c) {
    this.contour = c;
  }
}
