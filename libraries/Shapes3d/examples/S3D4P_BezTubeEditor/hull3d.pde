/**
 * Used to represent a 3D hull made from tubes and boxes.
 *
 */
public class Hull3D {
  Box[] hullCP;
  Tube[] hullLink;
  BezTube bt;
  PApplet app;

  Hull3D(PApplet papp, BezTube bezTube) {
    app = papp;
    bt = bezTube;
    PVector[] pts = bezTube.getBez().getCtrlPointArray();
    hullCP = new Box[pts.length];
    for (int i = 0; i < hullCP.length; i++)
      hullCP[i] = getNewControlPoint(papp, pts[i], i);
    hullLink = new Tube[pts.length - 1];
    for (int i = 0; i < hullLink.length; i++)
      hullLink[i] = getNewLink(papp, pts[i], pts[i+1], i);
  }

  void updateHullPoints(PVector[] cps) {
    if (hullCP.length == cps.length) {
      for (int i = 0; i < hullCP.length; i++)
        hullCP[i].moveTo(cps[i]);
      for (int i = 0; i < hullLink.length; i++)
        hullLink[i].setWorldPos(cps[i], cps[i+1]);
    }
    else
      println("Unmatched hull poits");
  }

  Tube getNewLink(PApplet papp, PVector from, PVector to, int nbr) {
    Tube tube = new Tube(papp, 4, 4);
    tube.setSize(1.2f, 1.2f, 1.2f, 1.2f);
    tube.fill(HULL3_LK);
    tube.drawMode(Shape3D.SOLID);
    tube.visible(false, Tube.BOTH_CAP);
    tube.setWorldPos(from, to);
    tube.tag = "L";
    tube.tagNo = nbr;
    return tube;
  }

  Box getNewControlPoint(PApplet papp, PVector pos, int nbr) {
    Box box = new Box(papp, 8);
    box.moveTo(pos);
    box.tag = "P";
    box.tagNo = nbr;
    box.fill(HULL3_LK);
    box.drawMode(Shape3D.SOLID);
    return box;
  }

  void update() {
    PVector np[] = bt.getBez().getCtrlPointArray();
    Box[] tempCP;
    Tube[] tempLink;
    int i;

    if (np.length < hullCP.length) {
      tempCP = new Box[np.length];
      tempLink = new Tube[np.length - 1];
      for (i = 0; i < tempCP.length; i++) {
        tempCP[i] = hullCP[i];
        tempCP[i].moveTo(np[i]);
      }
      for (; i< hullCP.length; i++) {
        hullCP[i].finishedWith();
      }
      for (i = 0; i < tempLink.length; i++) {
        tempLink[i] = hullLink[i];
        tempLink[i].setWorldPos(np[i], np[i+1]);
      }
      for (; i< hullLink.length; i++) {
        hullLink[i].finishedWith();
      }
      hullCP = tempCP;
      hullLink = tempLink;
    }
    else if (np.length > hullCP.length) {
      tempCP = new Box[np.length];
      tempLink = new Tube[np.length - 1];
      for (i = 0; i < hullCP.length; i++) {
        tempCP[i] = hullCP[i];
        tempCP[i].moveTo(np[i]);
      }
      for (; i< tempCP.length; i++) {
        tempCP[i] = getNewControlPoint(app, np[i], i) ;
      }
      for (i = 0; i < hullLink.length; i++) {
        tempLink[i] = hullLink[i];
        tempLink[i].setWorldPos(np[i], np[i+1]);
      }
      for (; i< tempLink.length; i++) {
        tempLink[i] = getNewLink(app, np[i], np[i+1], i);
      }
      hullCP = tempCP;
      hullLink = tempLink;
    }
    else { // update positions only
      for (i = 0; i < hullCP.length; i++)
        hullCP[i].moveTo(np[i]);				
      for (i = 0; i < hullLink.length; i++)
        hullLink[i].setWorldPos(np[i], np[i+1]);
    }
  }

  void destroy() {
    for (int i = 0; i < hullCP.length; i++)
      hullCP[i].finishedWith();
    for (int i = 0; i < hullLink.length; i++)
      hullLink[i].finishedWith();
  }

  void setVisible(boolean visible) {
    for (int i = 0; i < hullCP.length; i++)
      hullCP[i].visible(visible);
    for (int i = 0; i < hullLink.length; i++)
      hullLink[i].visible(visible);
  }

  void draw() {
    for (int i = 0; i < hullCP.length; i++) {
      if (i == selCP)
        hullCP[i].fill(HULL3_CP_SEL);
      else
        hullCP[i].fill(HULL3_CP);
      hullCP[i].draw();
    }
    for (int i = 0; i < hullLink.length; i++) {
      if (i == selLink)
        hullLink[i].fill(HULL3_LK_SEL);	
      else
        hullLink[i].fill(HULL3_LK);				
      hullLink[i].draw();
    }
  }
} // End Hull3D class

