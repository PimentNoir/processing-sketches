/**
 * Create and edit the 3D BezTube shape
 * 
 * Apart from the Shapes3D library this example also uses
 * the  PeasyCam and G4P  libraries. <br>
 * Both of these libraries can be installed through the PDE <br>
 * 
 * The program is to enable the editing of BezTube shapes and 
 * not as an 'example' of how to use the Shapes3D library. It
 * is too complex for that although experienced programmers 
 * may use this to explore ways to use G4P to create multi-window
 * applets/applications.
 * 
 * @author Peter Lager
 * 
 */

import peasy.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import g4p_controls.*;

// Colors
final int PAPER = color(255);
final int PAPER3D = color(190);
final int GRIDLINE = color(160);
final int AXIS_X = color(160, 0, 0);
final int AXIS_Y = color(0, 160, 0);
final int AXIS_Z = color(0, 0, 160);
final int AXIS_X_HEAD = color(200, 0, 0);
final int AXIS_Y_HEAD = color(0, 200, 0);
final int AXIS_Z_HEAD = color(0, 0, 200);
final int PATH2D = color(200, 0, 200);

final int HULL2_CP = color(255, 255, 0, 192);
final int HULL2_CP_SEL = color(255, 255, 0);
final int HULL2_LK = color(160, 160, 160, 160);
final int HULL2_LK_SEL = color(255, 0, 0);

final int HULL3_CP = color(180, 180, 180, 180);
final int HULL3_CP_SEL = color(255, 255, 0, 180);
final int HULL3_LK = color(180, 180, 180, 180);
final int HULL3_LK_SEL = color(255, 0, 0, 180);

final int PRF_CP = color(255, 255, 0, 192);
final int PRF_CP_SEL = color(255, 255, 0);
final int PRF_LINE = color(0, 0, 128);
final int PRF_BACKGROUND = color(200, 200, 255);
final int PRF_TEXT = color(32, 32, 192);
final int PRF_GRIDY = 32;
final int PRF_BORDER = 10;
final int PRF_GWIDTH = 320;
final int PRF_GHEIGHT = 4 * PRF_GRIDY;

// Stroke weights
final int[] AXIS_WEIGHT = new int[] { 
  4, 3, 3, 2, 2, 2, 1, 1, 1
};
final float PATH_SW = 2.5f;
final float HULL_SW = 1.0f;
final float HULL_SW_SEL = 2.0f;
// Control point sizes
final int CP_SIZE = 4;
final int CP_SEL_SIZE = 8;

GWindow win3d, winProfile, winControl;
GWindow[] win2d = new GWindow[3];

GTextArea txfInfo;
// GButton btnUp, btnDown;

Axis3D axis3d;

GCustomSlider sdrScale2D;
int scale2d = 1;

GCustomSlider sdrPrfScaleY;
int scalePrfY = 5;
int[] scalePrfMaxY = new int[] {
  0, 4, 8, 16, 32, 64, 128
};

GCustomSlider sdrPrfRes;
int prfRes = 1;
int[] resPrf = new int[] {
  0, 1, 2, 4, 8, 16, 32
};

GButton[] btnCentre = new GButton[4];
GButton[] btnPlace = new GButton[3];
GToggleGroup optgPlace;
GOption optBelow, optAbove;

GButton[] btnHullPoints = new GButton[3];
GToggleGroup optgHull;
GOption optFlip, optSpread;

GButton btnCode, btnStart;
GButton btnAxisXpos, btnAxisZpos;
GButton btnAxisXneg, btnAxisYneg, btnAxisZneg;

GButton btnFlatten, btnTaper;
GButton btnStarter, btnKnot, btnBugle;
GButton btnFix;
GCheckbox cbxHull3D, cbxAxis3D, cbxTexture, cbxLights;

String[] btnLabel = new String[] { 
  "X", "Y", "Z", "O"
};

// Used for decoding button clicks
final int CENTER_COORDS = 1010;
final int SIT_COORDS = 1020;
final int HULL_CTRL_COORDS = 1030;
final int UPAXIS_CHANGE = 1040;
final int TUBE_SHAPE = 1050;
final int TUBE_PROFILE = 1060;

Hull3D hull;
BezTube btube;

int selCP = -1;
int selLink = -1;
int selPrfP = -1;

String appTitle = "3D Bezier Tube Editor";
int atw;

PeasyCam pcam;

public void settings() {
  size(580, 500);
}

public void setup() {
  G4P.messagesEnabled(false);

  appTitle = "3D Bezier Tube Editor";
  atw = (int) textWidth(appTitle);

  txfInfo = new GTextArea(this, 10, 10, width - 20, height - 60, G4P.SCROLLBARS_VERTICAL_ONLY, width - 80);
  String[] info = loadStrings("bte_guide.txt");
  txfInfo.setText(join(info, "\n"));
  txfInfo.setTextEditEnabled(false);

  btnStart = new GButton(this, 10, height - 39, width - 20, 30, "START PROGRAM");
  btnStart.tagNo = -1;
}

/**
 * Create the initial BezTube and the GUI
 * @param sheight 
 * @param swidth 
 */
public void createApplet(int swidth, int sheight) {
  int[] pX = new int[] {
    swidth - 340, swidth - 680, swidth - 340, swidth - 680
  };
  int[] pY = new int[] {
    10, 350, 350, 10
  };

  // Create 3D window for BezTube
  win3d = GWindow.getWindow(this, "View BezTube in 3D", pX[3], pY[3], 300, 300, P3D);
  win3d.setActionOnClose(G4P.EXIT_APP);
  win3d.cursor(CROSS);
  // Create axis for 3D window
  axis3d = new Axis3D(win3d);
  // Make the initial tube and hull now 
  btube = makeBugle(win3d);
  hull = new Hull3D(win3d, btube);

  pcam = new PeasyCam(win3d, 300);
  pcam.setMinimumDistance(10);
  pcam.setMaximumDistance(2000);
  pcam.reset(1);

  // Create 3 windows for 2D views along axis
  String[] title = new String[] { 
    "View on X axis", 
    "View on Y axis", "View on Z axis"
  };
  String[] vAxis = new String[] { 
    "X", "Y", "Z"
  };
  for (int i = 0; i < 3; i++) {
    win2d[i] = GWindow.getWindow(this, title[i], pX[i], pY[i], 300, 300, JAVA2D);
    win2d[i].setActionOnClose(G4P.EXIT_APP);
    win2d[i].frameRate(15);
    win2d[i].cursor(CROSS);
    win2d[i].addDrawHandler(this, "draw_win2d_"+vAxis[i]);
    win2d[i].addMouseHandler(this, "mouse_handler_"+vAxis[i]);
    win2d[i].rectMode(CENTER);
  }

  // Create the Control window was 260 x 485
  winControl = GWindow.getWindow(this, "Bezier Tube controller", swidth - 1160, 10, 380, 485, JAVA2D);
  winControl.setActionOnClose(G4P.EXIT_APP);
  winControl.noLoop();
  sdrScale2D = new GCustomSlider(winControl, 20, 16, 160, 30);
  sdrScale2D.setNbrTicks(7); 
  sdrScale2D.tag = "Slider for 2D scale";
  sdrScale2D.setNumberFormat(GSlider.INTEGER);
  sdrScale2D.setStickToTicks(true);       //false by default 
  sdrScale2D.setLimits(scale2d, 1, 5);

  cbxHull3D = new GCheckbox(winControl, 20, 68, 100, 18, "3D Hull");
  cbxHull3D.setSelected(true);

  cbxAxis3D = new GCheckbox(winControl, 110, 68, 100, 18, "3D Axis");
  cbxAxis3D.setSelected(true);

  cbxTexture = new GCheckbox(winControl, 200, 68, 100, 18, "Texture");
  cbxTexture.setSelected(true);

  cbxLights = new GCheckbox(winControl, 300, 68, 100, 18, "Lights");
  cbxLights.setSelected(false);

  for (int i = 0; i < btnCentre.length; i++) {
    btnCentre[i] = new GButton(winControl, 165 + i*30, 105, 30, 20, btnLabel[i]);
    btnCentre[i].tag = "CENTRE";
    btnCentre[i].tagNo = CENTER_COORDS + i;
  }
  for (int i = 0; i < btnPlace.length; i++) {
    btnPlace[i] = new GButton(winControl, 250 + i*30, 145, 30, 20, btnLabel[i]);
    btnPlace[i].tag = "SIT";
    btnPlace[i].tagNo = SIT_COORDS + i;
  }
  optgPlace = new GToggleGroup();
  optBelow = new GOption(winControl, 110, 148, 70, 18, "below");
  optgPlace.addControl(optBelow);
  optAbove = new GOption(winControl, 180, 148, 70, 18, "above");
  optgPlace.addControl(optAbove);
  optAbove.setSelected(true);

  for (int i = 0; i < btnHullPoints.length; i++) {
    btnHullPoints[i] = new GButton(winControl, 250 + i*30, 185, 30, 20, btnLabel[i]);
    btnHullPoints[i].tag = "DISTRIBUTE";
    btnHullPoints[i].tagNo = HULL_CTRL_COORDS + i;
  }
  optgHull = new GToggleGroup();
  optFlip = new GOption(winControl, 110, 188, 70, 18, "mirror");
  optgHull.addControl(optFlip);
  optSpread = new GOption(winControl, 180, 188, 70, 18, "spread");
  optgHull.addControl(optSpread);
  optSpread.setSelected(true);

  btnAxisXneg = new GButton(winControl, 150, 225, 30, 20, "-X");
  btnAxisXneg.tag = "UPAXIS";
  btnAxisXneg.tagNo = UPAXIS_CHANGE;
  btnAxisXpos = new GButton(winControl, 180, 225, 30, 20, "+X");
  btnAxisXpos.tag = "UPAXIS";
  btnAxisXpos.tagNo = UPAXIS_CHANGE + 1;
  btnAxisYneg = new GButton(winControl, 210, 225, 30, 20, "-Y");
  btnAxisYneg.tag = "UPAXIS";
  btnAxisYneg.tagNo = UPAXIS_CHANGE + 2;
  btnAxisZneg = new GButton(winControl, 240, 225, 30, 20, "-Z");
  btnAxisZneg.tag = "UPAXIS";
  btnAxisZneg.tagNo = UPAXIS_CHANGE + 3;
  btnAxisZpos = new GButton(winControl, 270, 225, 30, 20, "+Z");
  btnAxisZpos.tag = "UPAXIS";
  btnAxisZpos.tagNo = UPAXIS_CHANGE + 4;

  btnStarter = new GButton(winControl, 30, 265, 60, 20, "Starter");
  btnStarter.tag = "SIMPLE STARTER";
  btnStarter.tagNo = TUBE_SHAPE;
  btnKnot = new GButton(winControl, 100, 265, 60, 20, "Knot");
  btnKnot.tag = "KNOT";
  btnKnot.tagNo = TUBE_SHAPE + 1;
  btnBugle = new GButton(winControl, 170, 265, 60, 20, "Bugle");
  btnBugle.tag = "BUGLE";
  btnBugle.tagNo = TUBE_SHAPE + 2;
  btnFix = new GButton(winControl, 328, 261, 20, 20, "Fix"); //, "bte_fix.png", 3
  btnFix.tag = "FIXSHAPE";
  btnFix.tagNo = TUBE_SHAPE + 9;

  // Profiler stuff
  sdrPrfScaleY = new GCustomSlider(winControl, 20, 304, 160, 30);
  sdrPrfScaleY.setNbrTicks(5); 
  sdrPrfScaleY.tag = "Slider for Profiler scale";
  sdrPrfScaleY.setNumberFormat(GSlider.INTEGER);
  //  sdrPrfScaleY.setRenderMaxMinLabel(false);
  //  sdrPrfScaleY.setRenderValueLabel(false);
  sdrPrfScaleY.setStickToTicks(true);       //false by default 
  sdrPrfScaleY.setLimits(scalePrfY, 1, 6);

  sdrPrfRes = new GCustomSlider(winControl, 20, 354, 160, 30);
  sdrPrfRes.setNbrTicks(5); 
  sdrPrfRes.tag = "Slider for Profiler resolution";
  sdrPrfRes.setNumberFormat(GSlider.INTEGER);
  sdrPrfRes.setStickToTicks(true);       //false by default 
  sdrPrfRes.setLimits(prfRes, 1, 6);

  btnFlatten = new GButton(winControl, 120, 405, 60, 20, "Flat");
  btnFlatten.tag = "PROFILE";
  btnFlatten.tagNo = TUBE_PROFILE + 1;  // DO NOT CHANGE

  btnTaper = new GButton(winControl, 180, 405, 60, 20, "Taper");
  btnTaper.tag = "PROFILE";
  btnTaper.tagNo = TUBE_PROFILE + 2; // DO NOT CHANGE

  btnCode = new GButton(this, 10, height - 39, width - 20, 30, "COPY CODE TO CLIPBOARD");

  winControl.addDrawHandler(this, "draw_control");
  winControl.loop();

  winControl.frameRate(20);

  winProfile = GWindow.getWindow(this, "Tube profile", swidth - 1160, 550, 380, 148, JAVA2D);
  winProfile.setActionOnClose(G4P.EXIT_APP);
  winProfile.frameRate(15);
  winProfile.cursor(CROSS);
  winProfile.addDrawHandler(this, "draw_profile");
  winProfile.addMouseHandler(this, "mouse_handler_profile");
  winProfile.rectMode(CENTER);

  win3d.addDrawHandler(this, "draw_win3d");
  win3d.addMouseHandler(this, "mouse_handler_3d");
}

/**
 * This is the main Processing draw window.
 */
public void draw() {
  background(80, 80, 142);
  fill(255, 0, 0);
  text(appTitle, (width - atw)/2, 8, atw, height);
}

/**
 * Draw method for the tube profile control window
 * @param wapp the papplet
 * @param windata not used
 */
public synchronized void draw_profile(PApplet wapp, GWinData windata) {
  wapp.background(PRF_BACKGROUND);
  wapp.rectMode(CORNER);
  wapp.noStroke();
  wapp.fill(PAPER);
  wapp.rect(PRF_BORDER, 0, PRF_GWIDTH, wapp.height - PRF_BORDER);
  // Draw graph grid lines and labels
  wapp.stroke(GRIDLINE);
  wapp.fill(PRF_TEXT);
  wapp.strokeWeight(1);
  int deltaReal =  scalePrfMaxY[scalePrfY]/4;
  int label = 0;
  int y = wapp.height - 10;
  while (y > 0) {
    wapp.line(PRF_BORDER, y, 320 + PRF_BORDER, y);
    wapp.text(label, PRF_GWIDTH + PRF_BORDER + 14, y + 6);
    y -= PRF_GRIDY;
    label += deltaReal;
  }
  // Prepare to draw profile
  float[] p = (float[]) btube.getRadiusProfiler().getController();
  world2profile(wapp, p);
  // Draw profile line
  wapp.stroke(PRF_LINE);
  float deltaX = (p.length == 1)? 1 : ((float)PRF_GWIDTH) / (p.length - 1);
  if (p.length == 1) {
    wapp.line(PRF_BORDER, p[0], PRF_BORDER + PRF_GWIDTH, p[0]);
  } else {
    for (int i = 1; i < p.length; i++) {
      wapp.line(PRF_BORDER + (i-1)*deltaX, p[i-1], PRF_BORDER+i*deltaX, p[i]);
    }
  }

  // Draw profile control points
  wapp.stroke(color(0, 0, 0));
  wapp.rectMode(CENTER);
  int s;
  for (int i = 0; i < p.length; i++) {
    if (i == selPrfP) {
      wapp.fill(PRF_CP_SEL);
      s = CP_SEL_SIZE;
    } else {
      wapp.fill(PRF_CP);
      s = CP_SIZE;
    }
    wapp.rect(PRF_BORDER + (i)*deltaX, p[i], s, s);
  }
}

/**
 * Draw method for the main control window. 
 * This simply draws the background, all the buttons, checkboxes,
 * sliders etc. are drawn into this window by G4P
 * @param wapp the papplet
 * @param windata not used
 */
public synchronized void draw_control(PApplet wapp, GWinData windata) {
  wapp.background(0, 0, 64);
  int bg = color(200);
  int bgw = wapp.width - 20;
  wapp.strokeWeight(2);
  wapp.stroke(0);
  wapp.fill(bg);

  wapp.rect(10, 10, bgw, 40);
  wapp.rect(10, 60, bgw, 30);
  wapp.rect(10, 100, bgw, 30);
  wapp.rect(10, 140, bgw, 30);
  wapp.rect(10, 180, bgw, 30);
  wapp.rect(10, 220, bgw, 30);
  wapp.rect(10, 260, bgw, 30);
  // Start profiler controls
  wapp.rect(10, 300, bgw, 40);
  wapp.rect(10, 350, bgw, 40);
  wapp.rect(10, 400, bgw, 30);
  wapp.rect(10, 440, bgw, 30);

  wapp.fill(0);
  wapp.text("2D Graph scale", 200, 34);
  wapp.text("Centre tube on", 20, 120);
  wapp.text("Place tube", 20, 160);
  wapp.text("Hull points", 20, 200);
  wapp.text("Change UP axis", 20, 240);
  wapp.text("Profile :  Y scale", 200, 324);
  wapp.text("Profile :  number of points", 200, 374);
  wapp.text("Coarse control", 20, 420);

  wapp.noFill();
  wapp.stroke(255);
  wapp.rect(5, 5, winControl.width - 10, 290);
  wapp.rect(5, 295, winControl.width - 10, 140);
  wapp.rect(5, 435, winControl.width - 10, 40);
}

/**
 * Draw method for View on X axis window.
 * @param wapp the papplet
 * @param windata not used
 */
public synchronized void draw_win2d_X(PApplet wapp, GWinData windata) {
  wapp.background(PAPER);
  draw2d_grid(wapp);
  draw2d_axis(wapp, 0);
  // Draw tube path
  PVector[] path = btube.getBez().points(60);
  world2screenX(wapp, path);
  draw2d_bezpath(wapp, path);
  // Draw hull and control points
  PVector[] hull2d = btube.getBez().getCtrlPointArray();
  world2screenX(wapp, hull2d);
  draw2d_bezhull(wapp, hull2d);
}

/**
 * Draw method for View on Y axis window.
 * @param wapp the papplet
 * @param windata not used
 */
public synchronized void draw_win2d_Y(PApplet wapp, GWinData windata) {
  wapp.background(PAPER);
  draw2d_grid(wapp);
  draw2d_axis(wapp, 1);
  // Draw tube path
  PVector[] path = btube.getBez().points(60);
  world2screenY(wapp, path);
  draw2d_bezpath(wapp, path);
  // Draw hull and control points
  PVector[] hull2d = btube.getBez().getCtrlPointArray();
  world2screenY(wapp, hull2d);
  draw2d_bezhull(wapp, hull2d);
}


/**
 * Draw method for View on Z axis window.
 * @param wapp the papplet
 * @param windata not used
 */
public synchronized void draw_win2d_Z(PApplet wapp, GWinData windata) {
  wapp.background(PAPER);
  draw2d_grid(wapp);
  draw2d_axis(wapp, 2);
  // Draw tube path
  PVector[] path = btube.getBez().points(60);
  world2screenZ(wapp, path);
  draw2d_bezpath(wapp, path);
  // Draw hull and control points
  PVector[] hull2d = btube.getBez().getCtrlPointArray();
  world2screenZ(wapp, hull2d);
  draw2d_bezhull(wapp, hull2d);
}

/**
 * Draw the control hull in the given 2d window.
 * @param wapp the window to draw in.
 * @param pts the window to draw in.
 */
void draw2d_bezhull(PApplet wapp, PVector[] pts) {
  wapp.rectMode(CENTER);
  // Draw hull line
  for (int i = 1; i < pts.length; i++) {
    if (i == selLink + 1) {
      wapp.strokeWeight(HULL_SW_SEL);
      wapp.stroke(HULL2_LK_SEL);
    } else {
      wapp.strokeWeight(HULL_SW);
      wapp.stroke(HULL2_LK);
    }
    wapp.line(pts[i-1].x, pts[i-1].y, pts[i].x, pts[i].y);
  }
  // Draw hull links
  wapp.stroke(0);
  wapp.strokeWeight(HULL_SW);
  int size = CP_SIZE;
  for (int i = 0; i < pts.length; i++) {
    if (i == selCP) {
      size = CP_SEL_SIZE;
      wapp.fill(HULL2_CP_SEL);
    } else {
      size = CP_SIZE;
      wapp.fill(HULL2_CP);
    }
    wapp.rect(pts[i].x, pts[i].y, size, size);
  }
}

/**
 * Draw the bezier path in the given 2d window.
 * @param wapp the window to draw in.
 */
void draw2d_bezpath(PApplet wapp, PVector[] pathPts) {
  wapp.noFill();
  wapp.strokeWeight(PATH_SW);
  wapp.stroke(PATH2D);
  for (int i = 1; i < pathPts.length; i++) {
    wapp.line(pathPts[i-1].x, pathPts[i-1].y, pathPts[i].x, pathPts[i].y);
  }
}

/**
 * Draw the graph axis in the given 2d window.
 * @param wapp the window to draw in.
 */
void draw2d_axis(PApplet wapp, int axis) {
  wapp.strokeWeight(AXIS_WEIGHT[scale2d - 1]);
  int w = wapp.height;
  int h = wapp.height;
  int cx = w/2;
  int cy = h/2;
  switch(axis) {
  case 0:
    wapp.stroke(AXIS_Z);
    wapp.line(cx, cy, 0, cy);
    wapp.fill(AXIS_Z);
    wapp.text("Z", 10, cy - 10);
    wapp.stroke(AXIS_Y);
    wapp.line(cx, cy, cx, h);
    wapp.fill(AXIS_Y);
    wapp.text("Y", cx + 10, h - 10);
    break;
  case 1:
    wapp.stroke(AXIS_Z);
    wapp.line(cx, cy, cx, 0);
    wapp.fill(AXIS_Z);
    wapp.text("Z", cx - 14, 14);
    wapp.stroke(AXIS_X);
    wapp.line(cx, cy, w, cx);
    wapp.fill(AXIS_X);
    wapp.text("X", w - 14, cy + 14);
    break;
  case 2:
    wapp.stroke(AXIS_X);
    wapp.line(cx, cy, w, cx);
    wapp.fill(AXIS_X);
    wapp.text("X", w - 14, cy - 10);
    wapp.stroke(AXIS_Y);
    wapp.line(cx, cy, cx, h);
    wapp.fill(AXIS_Y);
    wapp.text("Y", cx - 14, h - 14);
    break;
  }
}

/**
 * Draw the graph paper grid in the given 2d window.
 * @param wapp the window to draw in.
 */
void draw2d_grid(PApplet wapp) {
  wapp.stroke(GRIDLINE);
  wapp.strokeWeight(1);
  int cx = wapp.width/2;
  int cy = wapp.height/2;
  int delta = 30 / scale2d;
  int d = 0;
  while (d < cy) {
    wapp.line(0, cy - d, wapp.width, cy - d);
    wapp.line(0, cy + d, wapp.width, cy + d);
    d += delta;
  }
  d = 0;
  while (cx - d > 0) {
    wapp.line(cx - d, 0, cx - d, wapp.height);
    wapp.line(cx + d, 0, cx + d, wapp.height);
    d += delta;
  }
}

/**
 * Draw the 3D view
 * @param wapp
 * @param windata
 */
public synchronized void draw_win3d(PApplet wapp, GWinData windata) {
  wapp.background(PAPER3D);
  if (cbxLights.isSelected()) {
    wapp.lights();
    wapp.ambientLight(60, 60, 60);
    wapp.directionalLight(200, 200, 200, -1, -1, -1);
  }
  btube.draw();
  axis3d.draw();
  hull.draw();
}

/**
 * Mouse handler for 3D window. Click on a control point to remove
 * it, click on hull link line to add new control point at its mid-point.
 * Rest is handled by PeasyCam
 * @param wapp papplet for the window
 * @param data not used
 * @param event mouse event
 */
public void mouse_handler_3d(PApplet wapp, GWinData data, MouseEvent event) {
  switch(event.getAction()) {
  case MouseEvent.MOVE:
    selCP = selLink = -1;
    Shape3D shape = Shape3D.pickShape(wapp, wapp.mouseX, wapp.mouseY);
    if (shape != null) {
      if (shape.tag == "P")
        selCP = shape.tagNo;
      else
        selLink = shape.tagNo;
    }
    break;
  case MouseEvent.CLICK:
    if (selCP > 0)
      removeControlPoint(selCP);
    else if (selLink >= 0)
      addNewControlPoint(selLink);    
    break;
  case MouseEvent.EXIT:
    selCP = selLink = -1;
    break;
  }
}

/**
 * Sees if the mouse is over a hull link in one of the 2D
 * view windows.
 * @param wapp a 2D view window
 * @param cp array of control points for curve
 * @return index to start of link line else -1
 */
public int isOverHullLink(PApplet wapp, PVector[] cp) {
  int link = -1;
  int mx = wapp.mouseX, my = wapp.mouseY;
  PVector vecStart = cp[0], vecEnd;
  float rx, ry;
  float xSM, ySM, xES, yES, denom, t, dist2 = 0.0f;

  for (int i = 1; i < cp.length; i++) {
    vecEnd = cp[i];
    xSM = vecStart.x - mx;
    ySM = vecStart.y - my;
    xES = vecEnd.x - vecStart.x;
    yES = vecEnd.y - vecStart.y;
    denom = xES*xES + yES*yES;
    if (denom > 1) {
      t = -(xSM*xES +ySM*yES)/denom;
      if (t > 0.1f && t < 0.9f) {
        rx = vecStart.x + t * xES;
        ry = vecStart.y + t * yES;
        dist2 = (mx - rx)*(mx - rx) +(my - ry)*(my - ry);
        if (dist2 < 4.1f) {
          link = i-1;
          break;
        }
      }
    }
    vecStart = vecEnd;
  }
  return link;
}

/**
 * See if mouse is over one of the profile control points in
 * the tube profile window.
 * @param mx screen mouse X position
 * @param my screen mouse Y position
 * @param pp screen coords for profile control points
 * @return index of control point mouse is over else -1
 */
int isMouseOver(int mx, int my, float[] pp) {
  int sel = -1;
  float deltaX = (pp.length == 1)? 1 : ((float)PRF_GWIDTH) / (pp.length - 1);
  float indexF = (mx - PRF_BORDER) * (pp.length - 1) / ((float)PRF_GWIDTH);
  for (int i = 0; i < pp.length; i++) {
    if (Math.abs(indexF - i)*deltaX < CP_SIZE && Math.abs(my - pp[i]) < CP_SIZE) {
      sel = i;
      break;
    }
  }
  return sel;
}

/**
 * Mouse handler for tube profile window.
 * @param wapp papplet for the window
 * @param data not used
 * @param event mouse event
 */
public void mouse_handler_profile(PApplet wapp, GWinData data, MouseEvent event) {
  float[] pp = (float[]) btube.getRadiusProfiler().getController();
  float[] pps = new float[pp.length];
  System.arraycopy(pp, 0, pps, 0, pp.length);
  world2profile(wapp, pps);
  switch(event.getAction()) {
  case MouseEvent.PRESS:
    selPrfP = isMouseOver(event.getX(), event.getY(), pps);
    break;
  case MouseEvent.DRAG:
    if (selPrfP >= 0) {
      synchronized(this) {
        int my = wapp.height - PRF_BORDER - event.getY();
        my = Math.max(my, 0);
        my = Math.min(my, PRF_GHEIGHT);
        pp[selPrfP] = map(my, 0, PRF_GHEIGHT, 0, scalePrfMaxY[scalePrfY]);
        btube.setRadius(new TubeRadius(pp));
      }
    }
    break;
  case MouseEvent.MOVE:
    selPrfP = isMouseOver(event.getX(), event.getY(), pps);
    break;
  }
}

/**
 * Mouse handler for View on X axis window.
 * @param wapp papplet for the window
 * @param data not used
 * @param event mouse event
 */
public void mouse_handler_X(PApplet wapp, GWinData data, MouseEvent event) {
  PVector mousePos = new PVector();
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  mousePos.z = map((float) wapp.mouseX, 0, wapp.width, halfWidth, -halfWidth);
  mousePos.y = map((float) wapp.mouseY, 0, wapp.height, -halfHeight, halfHeight);
  PVector[] screenXY = btube.getBez().getCtrlPointArray();
  world2screenX(wapp, screenXY);

  switch(event.getAction()) {
  case MouseEvent.PRESS:
    selCP = isOverControlPoint(mousePos, new PVector(0, 1, 1));
    selLink = isOverHullLink(wapp, screenXY);
    break;
  case MouseEvent.CLICK:
    selCP = isOverControlPoint(mousePos, new PVector(0, 1, 1));
    selLink = isOverHullLink(wapp, screenXY);
    if (selCP > 0)
      removeControlPoint(selCP);
    else if (selLink >= 0)
      addNewControlPoint(selLink);
    break;
  case MouseEvent.RELEASE:
    selCP = -1;
    selLink = -1;
    break;
  case MouseEvent.DRAG:
    if (selCP >= 0)
      updateControlPoint(selCP, mousePos, new PVector(1, 0, 0));
    break;
  case MouseEvent.MOVE:
    selCP = isOverControlPoint(mousePos, new PVector(0, 1, 1));
    selLink = isOverHullLink(wapp, screenXY);
  }
}

/**
 * Mouse handler for View on Y axis window.
 * @param wapp papplet for the window
 * @param data not used
 * @param event mouse event
 */
public void mouse_handler_Y(PApplet wapp, GWinData data, MouseEvent event) {
  PVector mousePos = new PVector();
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  mousePos.x = map((float) wapp.mouseX, 0, wapp.height, -halfWidth, halfWidth);
  mousePos.z = map((float) wapp.mouseY, 0, wapp.width, halfHeight, -halfHeight);
  PVector[] screenXY = btube.getBez().getCtrlPointArray();
  world2screenY(wapp, screenXY);

  switch(event.getAction()) {
  case MouseEvent.PRESS:
    selCP = isOverControlPoint(mousePos, new PVector(1, 0, 1));
    selLink = isOverHullLink(wapp, screenXY);
    break;
  case MouseEvent.CLICK:
    selCP = isOverControlPoint(mousePos, new PVector(1, 0, 1));
    selLink = isOverHullLink(wapp, screenXY);
    if (selCP > 0)
      removeControlPoint(selCP);
    else if (selLink >= 0)
      addNewControlPoint(selLink);
    break;
  case MouseEvent.RELEASE:
    selCP = -1;
    selLink = -1;
    break;
  case MouseEvent.DRAG:
    if (selCP >= 0)
      updateControlPoint(selCP, mousePos, new PVector(0, 1, 0));
    break;
  case MouseEvent.MOVE:
    selCP = isOverControlPoint(mousePos, new PVector(1, 0, 1));
    selLink = isOverHullLink(wapp, screenXY);
  }
}

/**
 * Mouse handler for View on Z axis window.
 * @param wapp papplet for the window
 * @param data not used
 * @param event mouse event
 */
public void mouse_handler_Z(PApplet wapp, GWinData data, MouseEvent event) {
  PVector mousePos = new PVector();
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  mousePos.x = map((float) wapp.mouseX, 0, wapp.height, -halfWidth, halfWidth);
  mousePos.y = map((float) wapp.mouseY, 0, wapp.width, -halfHeight, halfHeight);
  PVector[] screenXY = btube.getBez().getCtrlPointArray();
  world2screenZ(wapp, screenXY);

  switch(event.getAction()) {
  case MouseEvent.PRESS:
    selCP = isOverControlPoint(mousePos, new PVector(1, 1, 0));
    selLink = isOverHullLink(wapp, screenXY);
    break;
  case MouseEvent.CLICK:
    selCP = isOverControlPoint(mousePos, new PVector(1, 1, 0));
    selLink = isOverHullLink(wapp, screenXY);
    if (selCP > 0)
      removeControlPoint(selCP);
    else if (selLink >= 0)
      addNewControlPoint(selLink);
    break;
  case MouseEvent.RELEASE:
    selCP = -1;
    selLink = -1;
    break;
  case MouseEvent.DRAG:
    if (selCP >= 0)
      updateControlPoint(selCP, mousePos, new PVector(0, 0, 1));
    break;
  case MouseEvent.MOVE:
    selCP = isOverControlPoint(mousePos, new PVector(1, 1, 0));
    selLink = isOverHullLink(wapp, screenXY);
  }
}

/**
 * Update control point position wher changed in the 2D view
 * windows.
 * @param point
 * @param newPos
 * @param axisMask
 */
void updateControlPoint(int point, PVector newPos, PVector axisMask) {
  synchronized(this) {
    PVector[] pt = btube.getBez().getCtrlPointArray();
    pt[point].x *= axisMask.x;
    pt[point].y *= axisMask.y;
    pt[point].z *= axisMask.z;
    pt[point].add(newPos);
    P_Bezier3D b = new P_Bezier3D(pt, pt.length);
    btube.setBez(b);
    hull.update();
  }
}

/**
 * Remove the control point from the Bezier 3D object
 * @param pos
 */
void removeControlPoint(int pos) {
  synchronized(this) {
    PVector[] pt = btube.getBez().getCtrlPointArray();
    P_Bezier3D b  = new P_Bezier3D(pt, pt.length);
    b.removeCtrlPoint(pos);
    btube.setBez(b);
    hull.update();
  }
}

/**
 * Add a new control point to the centre point of one of the hull
 * lines.
 * @param onLink
 */
void addNewControlPoint(int onLink) {
  synchronized(this) {
    PVector[] pt = btube.getBez().getCtrlPointArray();
    P_Bezier3D b  = new P_Bezier3D(pt, pt.length);
    PVector mid = PVector.div(PVector.add(pt[onLink], pt[onLink + 1]), 2);
    b.insertCtrlPoint(mid, onLink + 1);
    btube.setBez(b);
    hull.update();
  }
}

/**
 * Map an array of tube profile points to fit the profile graph
 * window.
 * 
 * @param wapp tube profile graph window.
 * @param v array of floats representing radii
 */
void world2profile(PApplet wapp, float[] v) {
  float fullHeight = scalePrfMaxY[scalePrfY];
  for (int i = 0; i < v.length; i++) {
    v[i] = map(v[i], 0, fullHeight, wapp.height - PRF_BORDER, wapp.height - PRF_BORDER - 4*PRF_GRIDY);
  }
}

/**
 * Map an array of 3D real world coordinates to 2D graph positions
 * where we are looking down X axis. <br>
 */
void world2screenX(PApplet wapp, PVector[] v) {
  float x, y;
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  for (int i = 0; i < v.length; i++) {
    x = map(v[i].z, halfWidth, -halfWidth, 0, wapp.width);
    y = map(v[i].y, -halfHeight, halfHeight, 0, wapp.height);
    v[i].x = x;
    v[i].y = y;
    v[i].z = 0;
  }
}

/**
 * Map an array of 3D real world coordinates to 2D graph positions
 * where we are looking down Y axis. <br>
 */
void world2screenY(PApplet wapp, PVector[] v) {
  float x, y;
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  for (int i = 0; i < v.length; i++) {
    x = map(v[i].x, -halfWidth, halfWidth, 0, wapp.width);
    y = map(v[i].z, halfHeight, -halfHeight, 0, wapp.height);
    v[i].x = x;
    v[i].y = y;
    v[i].z = 0;
  }
}

/**
 * Map an array of 3D real world coordinates to 2D graph positions
 * where we are looking down the Z axis. <br>
 */
void world2screenZ(PApplet wapp, PVector[] v) {
  float x, y;
  float halfWidth = scale2d * wapp.width / 2;
  float halfHeight = scale2d * wapp.height / 2;
  for (int i = 0; i < v.length; i++) {
    x = map(v[i].x, -halfWidth, halfWidth, 0, wapp.width);
    y = map(v[i].y, -halfHeight, halfHeight, 0, wapp.height);
    v[i].x = x;
    v[i].y = y;
    v[i].z = 0;
  }
}

/**
 * See if the mouse if over a particular control point
 * 
 * @param mousePos in real world coordinates
 * @param mask defines axis we are looking down
 * @return index to control point mouse is over else -1
 */
public int isOverControlPoint(PVector mousePos, PVector mask) {
  int p = -1;
  float min_dist = Float.MAX_VALUE;
  float dist;
  PVector[] bpt = btube.getBez().getCtrlPointArray();
  for (int i = 0; i < bpt.length; i++) {
    bpt[i].x *= mask.x;
    bpt[i].y *= mask.y;
    bpt[i].z *= mask.z;
    dist = PVector.dist(mousePos, bpt[i]);
    if (dist < min_dist && 4 > dist / scale2d) {
      p = i;
      break;
    }
  }
  return p;
}

/**
 * Handle all GWSlider events 
 * @param slider
 */
public void handleSliderEvents(GValueControl slider, GEvent event) {
  if (slider == sdrScale2D) {
    scale2d = sdrScale2D.getValueI();
  } else if (slider == sdrPrfScaleY) {
    scalePrfY = sdrPrfScaleY.getValueI();
  } else if (slider == sdrPrfRes) {
    float[] currProfile = (float[]) btube.getRadiusProfiler().getController();
    float[] nextProfile;
    if (prfRes != sdrPrfRes.getValueI()) {
      I_RadiusGen currRad = btube.getRadiusProfiler();
      prfRes = sdrPrfRes.getValueI();
      if (prfRes == 1)
        nextProfile = new float[] { 
          currProfile[0]
        };
      else {
        nextProfile = new float[resPrf[prfRes]];
        float deltaT = 1.0f / (resPrf[prfRes] - 1);
        float t = 0;
        for (int i = 0; i < nextProfile.length; i++) {
          nextProfile[i] = currRad.radius(t);
          t += deltaT;
        }
      }
      btube.setRadius(new TubeRadius(nextProfile));
    }
  }
}

public void handleImageButtonEvents(GImageButton button) {
  //G4P.refresh();
}
/**
 * Handles all GButton events no matter which window has the button.
 * @param button
 */
public void handleButtonEvents(GButton button, GEvent event) {
  if (button.tagNo > 1000) {
    decodeButton(button.tagNo);
  } else if (button == btnCode) {
    makeSketchCode();
  } else if (button == btnStart) {
    createApplet(min(1280, displayWidth), displayHeight);
    btnStart.setVisible(false);
    frameRate(5);
  }
}

/**
 * Handle events created when clicking on a checkbox component.
 * @param checkbox
 */
public void handleCheckboxEvents(GCheckbox checkbox) {
  if (checkbox == cbxHull3D)
    hull.setVisible(cbxHull3D.isSelected());
  else if (checkbox == cbxAxis3D)
    axis3d.setVisible(cbxAxis3D.isSelected());
  else if (checkbox == cbxTexture) {
    if (cbxTexture.isSelected())
      btube.drawMode(Shape3D.TEXTURE);
    else
      btube.drawMode(Shape3D.SOLID | Shape3D.WIRE);
  }
}

/**
 * To simplify the processing of the buttons each button was given
 * a tag number comprising of a type (category) and an action (within
 * that category) This method gets the tag number and splits into 
 * type (category) and action then uses these values to work out
 * what needs to be done.
 * @param tn button tag number
 */
public void decodeButton(int tn) {
  int type = (tn / 10) * 10;
  int action = tn%10;
  PVector low = new PVector();
  PVector high = new PVector();
  PVector offset = new PVector();
  PVector mask = new PVector();
  PVector[] p = btube.getBez().getCtrlPointArray();
  PVector[] pps = btube.getBez().points(50);

  switch(type) {
  case TUBE_SHAPE:
    switch(action) {
    case 0:
      btube = makeStarter(win3d);
      break;
    case 1:
      btube = makeKnot(win3d);
      break;
    case 2:
      btube = makeBugle(win3d);
      break;
    case 9:
      btube.restoreShape();
      break;
    }
    hull.destroy();
    hull = new Hull3D(win3d, btube);
    pcam.reset();
    if (!cbxHull3D.isSelected())
      hull.setVisible(false);
    if (!cbxTexture.isSelected())
      btube.drawMode(Shape3D.SOLID | Shape3D.WIRE);        
    sdrPrfRes.setValue(prfRes);
    sdrPrfScaleY.setValue(scalePrfY);
    break;
  case TUBE_PROFILE:
    float[] prf = (float[]) btube.getRadiusProfiler().getController();
    I_RadiusGen btr = null;
    switch(action) {
    case 1:
      float sum = prf[0], avg;
      for (int i = 1; i < prf.length; i++)
        sum += prf[i];
      avg = sum / prf.length;
      for (int i = 0; i < prf.length; i++)
        prf[i] = avg;
      btr = new TubeRadius(prf);
      break;
    case 2:
      if (prf.length > 1) {
        float delta = (prf[prf.length-1] - prf[0])/(prf.length - 1);
        for (int i = 0; i < prf.length; i++)
          prf[i] = prf[0] + i * delta;
        btr = new TubeRadius(prf);
      }
    } // end switch
    btube.setRadius(btr);
    break;
  case CENTER_COORDS:
    findLimits(pps, low, high);
    offset = PVector.sub(high, low);
    offset.mult(0.5f);
    offset.add(low);
    if (action == 0 || action == 3)
      mask.x = 1.0f;
    if (action == 1 || action == 3)
      mask.y = 1.0f;
    if (action == 2 || action == 3)
      mask.z = 1.0f;
    offset.x *= mask.x;
    offset.y *= mask.y;
    offset.z *= mask.z;
    for (int i = 0; i < p.length; i++)
      p[i].sub(offset);
    btube.setBez(new P_Bezier3D(p, p.length));    
    hull.updateHullPoints(btube.getBez().getCtrlPointArray());
    break;
  case SIT_COORDS:
    findLimits(pps, low, high);
    if (optBelow.isSelected())
      offset.set(high);
    else
      offset.set(low);
    if (action == 0)
      mask.x = 1.0f;
    else if (action == 1)
      mask.y = 1.0f;
    else if (action == 2)
      mask.z = 1.0f;
    offset.x *= mask.x;
    offset.y *= mask.y;
    offset.z *= mask.z;
    for (int i = 0; i < p.length; i++)
      p[i].sub(offset);
    btube.setBez(new P_Bezier3D(p, p.length));          
    hull.updateHullPoints(btube.getBez().getCtrlPointArray());
    break;
  case HULL_CTRL_COORDS:
    if (optSpread.isSelected()) {
      findLimits(pps, low, high);
      offset = PVector.sub(high, low);
      offset.div(p.length-1);
      for (int i = 0; i < p.length; i++) {
        if (action == 0)
          p[i].x = low.x + i * offset.x;
        else if (action == 1)
          p[i].y = low.y + i * offset.y;
        else if (action == 2)
          p[i].z = low.z + i * offset.z;
      }
    } else {
      if (action == 0)
        mask.x = 1.0f;
      else if (action == 1)
        mask.y = 1.0f;
      else if (action == 2)
        mask.z = 1.0f;
      mask.mult(-2);
      mask.add(1, 1, 1);
      for (int i = 0; i < p.length; i++) {
        p[i].x *= mask.x;
        p[i].y *= mask.y;
        p[i].z *= mask.z;
      }
    }
    // Either spread or mirrord so now create tube
    btube.setBez(new P_Bezier3D(p, p.length));
    hull.updateHullPoints(btube.getBez().getCtrlPointArray());
    break;
  case UPAXIS_CHANGE:
    switch(action) {
    case 0:
      btube.shapeOrientation(new PVector(-1, 0, 0), null);
      break;
    case 1:
      btube.shapeOrientation(new PVector(1, 0, 0), null);
      break;
    case 2:
      btube.shapeOrientation(new PVector(0, -1, 0), null);
      break;
    case 3:
      btube.shapeOrientation(new PVector(0, 0, -1), null);
      break;
    case 4:
      btube.shapeOrientation(new PVector(0, 0, 1), null);
      break;
    }
  }
}

/**
 * Loop through path points finding min and max vales for x, y an z.
 * The results will be stored in the vectors low and high. This method
 * is called by several others.
 * @param p
 * @param low
 * @param high
 */
public void findLimits(PVector[] p, PVector low, PVector high) {
  low.set(p[0]);
  high.set(p[0]);
  for (int i = 1; i < p.length; i++) {
    if (p[i].x < low.x)
      low.x = p[i].x;
    else if (p[i].x > high.x)
      high.x = p[i].x;    
    if (p[i].y < low.y)
      low.y = p[i].y;
    else if (p[i].y > high.y)
      high.y = p[i].y;
    if (p[i].z < low.z)
      low.z = p[i].z;
    else if (p[i].z > high.z)
      high.z = p[i].z;
  }
}

/**
 * Create suitable code (on the clipboard) which can be pasted into
 * the Processing IDE to display the shape in 3D.
 */
void makeSketchCode() {
  String[] s1 = loadStrings("bte_sketch_1.txt");
  StringBuilder ss = new StringBuilder("");
  PVector[] cpts = btube.getBez().getCtrlPointArray();
  for (int i = 0; i < cpts.length; i++) {
    cpts[i].x = (Math.round(cpts[i].x * 10))/10.0f;
    cpts[i].y = (Math.round(cpts[i].y * 10))/10.0f;
    cpts[i].z = (Math.round(cpts[i].z * 10))/10.0f;
  }
  float[] profile = (float[]) btube.getRadiusProfiler().getController();
  for (int i = 0; i < profile.length; i++)
    profile[i] = Math.round(profile[i]*10)/10.0f;

  int p = 0;
  while (p < s1.length) {
    if (s1[p].contains("//CPOINTS")) {
      for (int i = 0; i < cpts.length; i++) {
        ss.append(Messages.build("    new PVector({0}f, {1}f, {2}f)", cpts[i].x, cpts[i].y, cpts[i].z));
        ss.append((i < cpts.length - 1) ? ", \n" : "\n");
      }
    } else if (s1[p].contains("//PRFPOINTS")) {
      ss.append("    ");
      for (int i = 0; i < profile.length; i++) {
        if (i > 0 && i%8 == 0)
          ss.append("\n");
        ss.append(Messages.build("{0}f", profile[i]));
        ss.append((i < profile.length - 1) ? ", " : "\n");
      }
    } else {
      ss.append(s1[p]);
      ss.append("\n");
    }
    p++;
  }
  GClip.copy(ss.toString());
}

/**
 * Make a Knot shape.
 * @param papp the 3D window to draw it
 * @return a new BezTube reference
 */
BezTube makeKnot(PApplet papp) {
  BezTube bt = null;
  prfRes = 1;
  scalePrfY = 1;
  TubeRadius r = new TubeRadius(3.75f);

  PVector[] v = new PVector[] {
    new PVector(-141.3f, 35.9f, -52.9f), 
    new PVector(-72.7f, 5.3f, -28.3f), 
    new PVector(5.7f, -17.5f, 15.1f), 
    new PVector(23.8f, -76.3f, 8.4f), 
    new PVector(67.8f, -110.5f, 52.9f), 
    new PVector(104.8f, -97f, 51.9f), 
    new PVector(113.1f, -72f, 39.9f), 
    new PVector(121.8f, -53.5f, 18.9f), 
    new PVector(98.7f, 40.5f, -47.9f), 
    new PVector(67.7f, 78.5f, -60.9f), 
    new PVector(38.1f, 120.5f, -55.6f), 
    new PVector(15.8f, 126.4f, -17.6f), 
    new PVector(-6.3f, 109.6f, 40.1f), 
    new PVector(-25.9f, 84.6f, 66.1f), 
    new PVector(-60.3f, 63.1f, 53.1f), 
    new PVector(-133.8f, -25f, 0.8f), 
    new PVector(-136f, -66.7f, 28.9f), 
    new PVector(-120f, -107.7f, 54.9f), 
    new PVector(-88f, -124.7f, -11.7f), 
    new PVector(-39f, -118.7f, -59.1f), 
    new PVector(-6.3f, -54.1f, -61.9f), 
    new PVector(14.7f, -9.3f, -47.9f), 
    new PVector(23.8f, -20f, 8.4f), 
    new PVector(35.3f, -2.5f, 23.4f), 
    new PVector(93.8f, 16.7f, 28.4f), 
    new PVector(141.4f, 36.3f, 52.9f)
  };
  bt = new BezTube(papp, new P_Bezier3D(v, v.length), r, 100, 16);

  bt.fill(color(32, 32, 160));
  bt.stroke(color(255));
  bt.strokeWeight(2.0f);  
  bt.setTexture("bte_stripes.jpg", 1, 8);
  // Set initially to texture
  bt.drawMode(Shape3D.TEXTURE);
  // Caps
  bt.fill(color(255, 0, 0), BezTube.S_CAP);
  bt.fill(color(0, 255, 0), BezTube.E_CAP);
  bt.drawMode(Shape3D.SOLID, BezTube.BOTH_CAP);
  bt.pickable(false);

  return bt;
}

/**
 * Make a Simple starting shape.
 * @param papp the 3D window to draw it
 * @return a new BezTube reference
 */
BezTube makeStarter(PApplet papp) {
  BezTube bt = null;
  prfRes = 2;
  scalePrfY = 4;
  float[] prf = new float[] {
    8f, 24f
  };

  TubeRadius r = new TubeRadius(prf);

  PVector[] v = new PVector[] {        
    new PVector(-48.6f, -83.6f, -61.3f), 
    new PVector(-7.6f, -117.6f, -54.3f), 
    new PVector(66f, -79f, 3f), 
    new PVector(86f, -21f, 58f), 
    new PVector(53f, 55f, 87f), 
    new PVector(-16.6f, 82f, 80f), 
    new PVector(-66.6f, 100.4f, -25.3f)
  };
  bt = new BezTube(papp, new P_Bezier3D(v, v.length), r, 100, 8);

  bt.fill(color(32, 32, 160));
  bt.stroke(color(255));
  bt.strokeWeight(2.0f);  
  bt.setTexture("bte_stripes.jpg", 1, 8);
  // Set initially to texture
  bt.drawMode(Shape3D.TEXTURE);
  // Caps
  bt.fill(color(255, 0, 0), BezTube.S_CAP);
  bt.fill(color(0, 255, 0), BezTube.E_CAP);
  bt.drawMode(Shape3D.SOLID, BezTube.BOTH_CAP);
  bt.pickable(false);

  return bt;
}

/**
 * Make a Bugle shape.
 * @param papp the 3D window to draw it
 * @return a new BezTube reference
 */
BezTube makeBugle(PApplet papp) {
  BezTube btube = null;
  prfRes = 6;
  scalePrfY = 6;
  float[] prf = new float[] {
    88f, 52f, 30.1f, 21.9f, 14.3f, 13f, 12.8f, 12.8f, 
    12.8f, 12.5f, 12.1f, 12.1f, 12.2f, 12.1f, 11.9f, 11.7f, 
    11.6f, 11.6f, 11.7f, 11.8f, 11.9f, 12f, 11.8f, 11.7f, 
    11.4f, 11.3f, 11.7f, 12.1f, 12.5f, 12f, 12.5f, 19.5f
  };

  TubeRadius r = new TubeRadius(prf);

  PVector[] v = new PVector[] {
    new PVector(113f, -31f, -24f), 
    new PVector(82.2f, -31.5f, -21.2f), 
    new PVector(51.5f, -32f, -18.5f), 
    new PVector(-6.5f, -33f, -15.7f), 
    new PVector(-62f, -50f, -13f), 
    new PVector(-81.5f, -44f, -10.2f), 
    new PVector(-91f, -24f, -7.5f), 
    new PVector(-95f, 5f, -4.7f), 
    new PVector(-86f, 44f, -1.9f), 
    new PVector(-51f, 52f, 0.8f), 
    new PVector(1.5f, 65f, 3.5f), 
    new PVector(68f, 59f, 6.3f), 
    new PVector(93f, 9f, 9f), 
    new PVector(87.5f, -48f, 11.8f), 
    new PVector(43f, -44f, 14.5f), 
    new PVector(-108f, -35f, 17.3f)
  };
  btube = new BezTube(papp, new P_Bezier3D(v, v.length), r, 100, 16);

  btube.fill(color(32, 32, 160));
  btube.stroke(color(255));
  btube.strokeWeight(2.0f);  
  btube.setTexture("bte_stripes.jpg", 1, 8);
  // Set initially to texture
  btube.drawMode(Shape3D.TEXTURE);
  // Caps
  btube.fill(color(255, 0, 0), BezTube.S_CAP);
  btube.fill(color(0, 255, 0), BezTube.E_CAP);
  btube.drawMode(Shape3D.SOLID, BezTube.BOTH_CAP);
  btube.pickable(false);

  return btube;
}
