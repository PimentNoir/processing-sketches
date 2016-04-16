/**
 * Program to demonstrate the creation of a 3D shape based on the 360
 * degree rotation of a Bezier curve. 
 * 
 * Apart from the Shapes3D library this demo uses the GUI for
 * Processing library - G4P (V4.0).  
 * This libraries are available at www.lagers.org.uk
 *
 * The G4P library is used to create the 2D bezier editor window.
 * 
 * The program is to enable the editing of BezShape objects and 
 * not as an 'example' of how to use the Shapes3D library. It
 * is too complex for that although experienced programmers 
 * may use this to explore ways to use G4P to create multi-window
 * applets/applications.
 * 
 * @author Peter Lager
 * 
 */


import g4p_controls.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;


// Constants used in mouse event handling
final int M_FREE = 1;
final int M_DRAGGED = 2;

// From Shapes 3D library
BezShape bzshape;    // 3D
Bezier2D bz;              // 2D
PVector[] v;            // Control points for bz
float angleX, angleY, angleZ; // rotation of 3D shape

// G4P components
GWindow editor;
GButton btnShowControls;
GPanel pnlControls;
GButton btnNextTexture, btnPrevTexture;
GLabel lblTexture, lblZoom;
GSlider sdrZoom3D;

int camZ = 300;
int xOrigin, yOrigin;

int mx, my;
int overPoint = -1;
int dx, dy;
int mode = M_FREE;
int axisCol;

// List of image files for texture
String[] textures = new String[] {
  "grid01.png", "tartan.jpg", "rouge.jpg", 
  "globe.jpg", "sampler01.jpg"
};

int textureNo = 0;
boolean mainDraw = true;

public void setup() {
  size(400, 400, P3D);
  // Create the initial Bezier shape that can be edited
  v = new PVector[4];
  v[0] = new PVector(30, -80);
  v[1] = new PVector(120, -140);
  v[2] = new PVector(0, 20);
  v[3] = new PVector(80, 80);
  makeBezierShape();
  btnShowControls = new GButton(this, width-66, 6, 50, 50, "EDIT");
}

synchronized public void draw() {
  mainDraw = true;
  background(40);
  pushMatrix();
  // Set the camera and lights up for 3D stuff
  camera(0, 0, camZ, 0, 0, 0, 0, 1, 0);
  directionalLight(160, 160, 160, -100, 150, -100);
  directionalLight(160, 160, 160, 100, -150, -100);
  ambientLight(140, 140, 140);
  noStroke();
  fill(255);

  angleX += radians(0.913f);
  angleY += radians(0.799f);
  angleZ += radians(1.213f);
  bzshape.rotateTo(angleX, angleY, angleZ);
  bzshape.draw();
  popMatrix();
  mainDraw = false;
}

// Mouse event handler for editor window
public void editorMouseEventHandler(PApplet appc, GWinData data, MouseEvent event) {
  PVector vec;
  if (!pnlControls.isOver(event.getX(), event.getY())) {
    // Get current mouse position after offset for origin
    mx = event.getX() - xOrigin;
    my = event.getY() - yOrigin;

    switch(event.getAction()) {
    case MouseEvent.PRESS:
      if (overPoint >= 0) {
        mode = M_DRAGGED;
        vec = bz.getCtrlPoint(overPoint);
        dx = (int)(mx - vec.x);
        dy = (int)(my - vec.y);
      }
      break;
    case MouseEvent.RELEASE:
      mode = M_FREE;
      break;
    case MouseEvent.CLICK:
      if (overPoint >= 0 && bz.removeCtrlPoint(overPoint)) {
        v = bz.getCtrlPointArray();
        makeBezierShape();
      }
      else
        ifOverLineMakePoint(mx, my);
      break;
    case MouseEvent.DRAG:
      if (mode == M_DRAGGED) {
        vec = new PVector(mx + dx, my + dy);
        bz.updateCtrlPoint(vec, overPoint);
        v[overPoint].x = vec.x;
        v[overPoint].y = vec.y;
        makeBezierShape();
      }
      break;
    case MouseEvent.MOVE:
      overPoint = isOverPoint(mx, my);
      break;
    }
  }
}

// See if mouse is over a line linking control points
public void ifOverLineMakePoint(int mx, int my) {
  PVector result = new PVector();

  PVector vecStart = bz.getCtrlPoint(0);
  PVector vecEnd;
  float xSM, ySM, xES, yES, denom, t;
  float dist2 = 0.0f;

  for (int i = 1; i < bz.getNbrCtrlPoints(); i++) {
    vecEnd = bz.getCtrlPoint(i);
    xSM = vecStart.x - mx;
    ySM = vecStart.y - my;
    xES = vecEnd.x - vecStart.x;
    yES = vecEnd.y - vecStart.y;
    denom = xES*xES + yES*yES;
    if (denom > 1) {
      t = -(xSM*xES +ySM*yES)/denom;
      if (t > 0.05f && t < 0.95f) {
        result.x = vecStart.x + t * xES;
        result.y = vecStart.y + t * yES;
        dist2 = (mx - result.x)*(mx - result.x) +(my - result.y)*(my - result.y);
        if (dist2 < 4.1f) {
          bz.insertCtrlPoint(result, i);
          v = bz.getCtrlPointArray();
          makeBezierShape();
          break;
        }
      }
    }
    vecStart = vecEnd;
  }
}

// See if mouse is over a control point
public int isOverPoint(int mx, int my) {
  PVector vec;
  overPoint = -1;
  for (int i = 0; i < bz.getNbrCtrlPoints(); i++) {
    vec = bz.getCtrlPoint(i);          
    if (Math.abs(mx - vec.x) < 4 && Math.abs(my - vec.y) < 4) {
      overPoint = i;
      break;
    }
  }
  return overPoint;
}

// Draw method for editor window.
synchronized public void drawEditor(PApplet wapp, GWinData windata) {
  while (mainDraw); 
  wapp.background(255);
  drawEdPaper(wapp);
  drawBezier(wapp);
}

// Draw editor background stuff
public void drawEdPaper(PApplet wapp) {
  int axisCol = color(100, 100, 100);
  int insideCol = color(230);
  int textCol = color(128);
  wapp.fill(insideCol);
  wapp.noStroke();
  wapp.rect(0, 0, xOrigin, wapp.height);
  wapp.stroke(axisCol);
  wapp.strokeWeight(1);
  wapp.line(xOrigin, 0, xOrigin, wapp.height);
  wapp.line(xOrigin, yOrigin, wapp.width, yOrigin);
  wapp.fill(axisCol);
  wapp.beginShape(TRIANGLES);
  wapp.vertex(xOrigin, 0);
  wapp.vertex(xOrigin - 3, 6);
  wapp.vertex(xOrigin + 3, 6);
  wapp.endShape();
  wapp.beginShape(TRIANGLES);
  wapp.vertex(wapp.width, yOrigin);
  wapp.vertex(wapp.width - 6, yOrigin - 3);
  wapp.vertex(wapp.width -6, yOrigin +3);
  wapp.endShape();
  wapp.fill(textCol);
  wapp.text("Rotation axis >", xOrigin - 88, wapp.height - 6);
  wapp.text("Y", xOrigin-12, 14);
  wapp.text("X", wapp.width-16, yOrigin - 6);
  wapp.text("Drag a control point to alter the 3D shape.", xOrigin + 40, height - 34);
  wapp.text("Click on a control point to remove it.", xOrigin + 40, height - 20);
  wapp.text("Click on a line (yellow) to add a new control point", xOrigin + 40, height - 6);
}

// Draw the 2D bezier and control points etc.
public void drawBezier(PApplet wapp) {
  int nsteps = 20;
  int handleSize = 4;
  int hullLineCol = color(200, 200, 0);
  int hullFillCol = color(255, 255, 0);
  int lineCol = color(255, 0, 0);

  wapp.noFill();
  wapp.stroke(hullLineCol);
  wapp.strokeWeight(1);
  for (int i = 1; i < v.length; i++) {
    wapp.line(v[i-1].x + xOrigin, v[i-1].y + yOrigin, v[i].x + xOrigin, v[i].y + yOrigin);
  }
  PVector[] pts = bz.points(nsteps);
  wapp.stroke(lineCol);
  wapp.strokeWeight(2);
  for (int i = 1; i < pts.length; i++) {
    wapp.line(pts[i-1].x + xOrigin, pts[i-1].y + yOrigin, 
    pts[i].x + xOrigin, pts[i].y + yOrigin);
  }
  wapp.rectMode(CENTER);
  wapp.stroke(hullLineCol);
  wapp.fill(hullFillCol);
  wapp.strokeWeight(1);
  for (int i = 0; i < v.length; i++) {
    if (i == overPoint) {
      wapp.fill(color(0, 255, 0));
      wapp.stroke(color(0, 128, 0));
      handleSize = 6;
    }
    else {
      wapp.fill(hullFillCol);
      wapp.stroke(hullLineCol);
    }      
    wapp.rect(v[i].x + xOrigin, v[i].y + yOrigin, handleSize, handleSize);
  }
  wapp.rectMode(CORNER);
}

// Create a BezierShape (3D) object based on array of PVector
public void makeBezierShape() {
  // Create a Bezier object based on array of PVector
  bz = new Bezier2D(v, v.length);
  // Create a new BezierShape (3D) based on Bezier object
  // with 36 slices (along Bezier curve length), 20 segmnts
  // (round 360 circumference and will use normals to enable
  // shading. 
  bzshape = new BezShape(this, bz, 36, 20);
  bzshape.setTexture(textures[textureNo]);
  bzshape.drawMode(Shape3D.TEXTURE);
}

// Handle the zoom slider events
public void handleSliderEvents(GValueControl slider, GEvent event) {
  if (slider == sdrZoom3D) {
    camZ = slider.getValueI();
  }
}

// Handle button events
public void handleButtonEvents(GButton button, GEvent event) {
  if (button == btnNextTexture && event == GEvent.CLICKED) {
    textureNo = (++textureNo)%textures.length;
    bzshape.setTexture(textures[textureNo]);
  }
  if (button == btnPrevTexture && event == GEvent.CLICKED) {
    textureNo = (--textureNo + textures.length)%textures.length;
    bzshape.setTexture(textures[textureNo]);
  }
  // Create the editor window
  if (button == btnShowControls && event == GEvent.CLICKED && editor == null) {
    makeControlWindow();
  }
}

public void makeControlWindow() {
  editor = GWindow.getWindow(this, "Shape Editor", 600, 200, 500, 400, JAVA2D);
  editor.addDrawHandler(this, "drawEditor");
  editor.addMouseHandler(this, "editorMouseEventHandler");
  editor.setActionOnClose(G4P.KEEP_OPEN);
  editor.cursor(CROSS);

  pnlControls = new GPanel(editor, 280, 20, 180, 80, "Controls");
  int h = 26;
  lblTexture = new GLabel(editor, 3, h, (int)pnlControls.getWidth() - 6, 14, "Texture");
  lblTexture.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  pnlControls.addControl(lblTexture);

  btnPrevTexture = new GButton(editor, 10, h, 36, 16, "<<");
  pnlControls.addControl(btnPrevTexture);

  btnNextTexture = new GButton(editor, (int)pnlControls.getWidth() - 46, h, 36, 16, ">>");
  pnlControls.addControl(btnNextTexture);

  h = 42;
  lblZoom = new GLabel(editor, 3, h, (int)pnlControls.getWidth() - 6, 14, "Zoom 3D");
  lblZoom.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  pnlControls.addControl(lblZoom);

  sdrZoom3D = new GSlider(editor, 10, h+12, (int)pnlControls.getWidth() - 20, 20, 12);
  sdrZoom3D.setLimits(300, 200, 800);
  pnlControls.addControl(sdrZoom3D);

  btnShowControls.setVisible(false);
  pnlControls.setCollapsed(false);

  xOrigin = editor.width / 5;
  yOrigin = editor.height / 2;
}