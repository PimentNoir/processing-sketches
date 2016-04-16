
import processing.core.*;
import processing.opengl.*;
import shapes3d.I_Shape;

/**
 * Demonstration of how to create your own shape renderer. <br>
 * 
 * Notice that it implements I_Shape which is essential.
 * 
 * 
 * @author Peter Lager
 *
 */
public class Saddle implements I_Shape {

  // This class must create and manage its own vertex data
  PVector[] coord;
  int fcol, scol;

  /**
   * Will ned a constructor to create the objects 
   * vertex data and initialise any other data required.
   * 
   * @param saddleSize
   */
  public Saddle(int saddleSize) {
    coord = new PVector[4];
    coord[0] = new PVector(-saddleSize, -saddleSize, saddleSize);
    coord[1] = new PVector( saddleSize, -saddleSize, -saddleSize);
    coord[2] = new PVector(-saddleSize, saddleSize, -saddleSize);
    coord[3] = new PVector( saddleSize, saddleSize, saddleSize);
  }

  /*
 * Other methods can be added as needed.
   */

  /**
   * This method is specified in the I_Shape interface so 
   * must exist in your class. <br>
   * 
   */
  public void drawForPicker(PGraphicsOpenGL pickBuffer) {
    pickBuffer.beginShape(PApplet.TRIANGLE_STRIP);
    pickBuffer.vertex(coord[0].x, coord[0].y, coord[0].z);
    pickBuffer.vertex(coord[1].x, coord[1].y, coord[1].z);
    pickBuffer.vertex(coord[2].x, coord[2].y, coord[2].z);
    pickBuffer.vertex(coord[3].x, coord[3].y, coord[3].z);
    pickBuffer.endShape();
  }

  /**
   * This method is specified in the I_Shape interface so 
   * must exist in your class. <br>
   * 
   */
  public void drawWithTexture(PApplet app, PImage skin) {
    app.textureMode(PApplet.NORMAL);
    app.beginShape(PApplet.TRIANGLE_STRIP);
    app.texture(skin);
    app.vertex(coord[0].x, coord[0].y, coord[0].z, 0, 0);
    app.vertex(coord[1].x, coord[1].y, coord[1].z, 0, 1);
    app.vertex(coord[2].x, coord[2].y, coord[2].z, 1, 1);
    app.vertex(coord[3].x, coord[3].y, coord[3].z, 1, 0);
    app.endShape();
  }

  /**
   * This method is specified in the I_Shape interface so 
   * must exist in your class. <br>
   * 
   */
  public void drawWithoutTexture(PApplet app) {
    app.beginShape(PApplet.TRIANGLE_STRIP);
    app.vertex(coord[0].x, coord[0].y, coord[0].z);
    app.vertex(coord[1].x, coord[1].y, coord[1].z);
    app.vertex(coord[2].x, coord[2].y, coord[2].z);
    app.vertex(coord[3].x, coord[3].y, coord[3].z);
    app.endShape();
  }
}

