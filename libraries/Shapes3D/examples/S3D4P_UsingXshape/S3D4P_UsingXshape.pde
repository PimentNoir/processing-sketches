/**
 * Demonstration showing how to use Xshape 
 * to create your own shapes. <br>
 * 
 * Also read the library references for more information.
 * 
 * @author Peter Lager
 *
 */

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;


Xshape myShape;
float angX, angY, angZ;
boolean testForHit = false;
Shape3D shapeHit = null;

void setup() {
  size(400, 400, P3D);
  cursor(CROSS);

  Saddle saddle = new Saddle(30);
  myShape = new Xshape(this);
  myShape.setXshape(saddle);

  myShape.fill(color(200, 0, 0));
  myShape.stroke(color(255, 255, 0));
  myShape.strokeWeight(2.0f);
  myShape.setTexture("ukflag.jpg");
  myShape.drawMode(S3D.SOLID | S3D.WIRE | S3D.TEXTURE );
}

void draw() {
  background(0);
  camera(0, 0, 150, 0, 0, 0, 0, 1, 0);
  rotateX(angX);
  rotateY(angY);
  rotateZ(angZ);
  angX += 0.017f;
  angY += 0.021f;
  angZ += 0.013f;
  if (testForHit) {
    shapeHit = Shape3D.pickShape(this, mouseX, mouseY);
    System.out.println(shapeHit);
    testForHit = false;
  }   
  myShape.draw();
}

void mouseClicked() {
  testForHit = true;
}
