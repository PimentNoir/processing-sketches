public class Axis3D {
  Box origin;
  Tube ax, ay, az;
  Cone cx, cy, cz;

  final float AXIS_LENGTH = 80;
  final float AXIS_RADIUS = 0.75f;

  Axis3D(PApplet papp) {
    origin = new Box(papp, 3);
    origin.fill(color(0));
    origin.drawMode(Shape3D.SOLID);
    origin.pickable(false);
    ax = new Tube(papp, 40, 8);
    ax.setSize(AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS);
    ax.setWorldPos(1.5f, 0, 0, AXIS_LENGTH, 0, 0);
    ax.fill(AXIS_X);
    ax.visible(false, Tube.BOTH_CAP);
    ax.drawMode(Shape3D.SOLID);
    ax.pickable(false);
    cx = new Cone(papp, 8, new PVector(-1, 0, 0), new PVector(AXIS_LENGTH, 0, 0));
    cx.setSize(2, 2, 5);
    cx.drawMode(Shape3D.SOLID, Cone.ALL);
    cx.fill(AXIS_X_HEAD, Cone.ALL);
    cx.pickable(false);

    ay = new Tube(papp, 40, 8);
    ay.setSize(AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS);
    ay.setWorldPos(0, 1.5f, 0, 0, AXIS_LENGTH, 0);
    ay.fill(AXIS_Y);
    ay.visible(false, Tube.BOTH_CAP);
    ay.drawMode(Shape3D.SOLID);
    ay.pickable(false);
    cy = new Cone(papp, 8, new PVector(0, -1, 0), new PVector(0, AXIS_LENGTH, 0));
    cy.setSize(2, 2, 5);
    cy.drawMode(Shape3D.SOLID, Cone.ALL);
    cy.fill(AXIS_Y_HEAD, Cone.ALL);
    cy.pickable(false);

    az = new Tube(papp, 40, 8);
    az.setSize(AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS, AXIS_RADIUS);
    az.setWorldPos(0, 0, 1.5f, 0, 0, AXIS_LENGTH);
    az.fill(AXIS_Z);
    az.visible(false, Tube.BOTH_CAP);
    az.drawMode(Shape3D.SOLID);
    az.pickable(false);
    cz = new Cone(papp, 8, new PVector(0, 0, -1), new PVector(0, 0, AXIS_LENGTH));
    cz.setSize(2, 2, 5);
    cz.drawMode(Shape3D.SOLID, Cone.ALL);
    cz.fill(AXIS_Z_HEAD, Cone.ALL);
    cz.pickable(false);
  }

  void setVisible(boolean visible) {
    origin.visible(visible);
    ax.visible(visible);
    cx.visible(visible);
    ay.visible(visible);
    cy.visible(visible);
    az.visible(visible);
    cz.visible(visible);
  }

  void draw() {
    origin.draw();
    ax.draw();
    cx.draw();
    ay.draw();
    cy.draw();
    az.draw();
    cz.draw();
  }
} // End Axis3D class


