import oscP5.*;
import foetus.*;
import processing.core.*;
import java.util.*;
import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;

/**
* Gradient Visual Synth example, for use with the Mother 1.0 library, both by Ilias Bergstrom.
* To see what this synth looks like when mixed with another synth, please run the MotherDelivery.pde example,
* and the MotherControllerExample, and then use the contols in the second to add synths and manipulate their parameters.
* For more info, read the included "Mother Documentation.pdf" file.
*/

// Messages:
// "/Gradient/TopColor" iii
// "/Gradient/BottomColor" iii

public Foetus f;

FoetusParameter m_TopR;
FoetusParameter m_TopG;
FoetusParameter m_TopB;
FoetusParameter m_BotR;
FoetusParameter m_BotG;
FoetusParameter m_BotB;
	
void setup()
{
  // When run as a synth, setup() is never called!
  // put the necessary initialization code in a method named initializeFoetus().
  // The necessary Processing initialization calls are called by Mother, and so should be left out from
  // initializeFoetus().
  // Finally, for the synth to work as a processing sketch within the PDE, call initializeFoetus() from within
  // setup().
  size(400, 300, OPENGL);
  frameRate(24);

  initializeFoetus();
}

void initializeFoetus()
{
  noStroke();

  // Instantiate foetus object here
  f = new Foetus(this);

  // Register messages that synth responds to (see OSC documentation)
  // This is here done automatically by the FoetusParameter constructors.
  m_TopR = new FoetusParameter(f, 0, "/TopRed", 	"f");
  m_TopG = new FoetusParameter(f, 1.0, "/TopGreen", 	"f");
  m_TopB = new FoetusParameter(f, 0, "/TopBlue",        "f");
  m_BotR = new FoetusParameter(f, 0, "/BotRed", 	"f");
  m_BotG = new FoetusParameter(f, 0, "/BotGreen", 	"f");
  m_BotB = new FoetusParameter(f, 0, "/BotBlue", 	"f");
}

void draw()
{
  pushMatrix();
		
  beginShape(QUADS);
			
  fill(m_TopR.getValue()*255, m_TopG.getValue()*255, m_TopB.getValue()*255);
  vertex(0, 0);
  vertex(width - 1, 0);
		
  fill(m_BotR.getValue()*255, m_BotG.getValue()*255, m_BotB.getValue()*255);
  vertex(width - 1, height - 1);
  vertex(0, height - 1);

  endShape();
			
  popMatrix();
}

/**
 * This method is called when an OSC message is received by the synth.
 */
void oscEvent(OscMessage theOscMessage)
{
  if (theOscMessage.checkAddrPattern("/TopRed") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_TopR.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  } 
  else if (theOscMessage.checkAddrPattern("/TopGreen") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_TopG.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  } 
  else if (theOscMessage.checkAddrPattern("/TopBlue") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_TopB.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  } 
  else if (theOscMessage.checkAddrPattern("/BotRed") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_BotR.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  }
  else if (theOscMessage.checkAddrPattern("/BotGreen") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_BotG.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  }
  else if (theOscMessage.checkAddrPattern("/BotBlue") == true)
  {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("f"))
    {
      m_BotB.setValue(theOscMessage.get(0).floatValue());
      return;
    }
  }
}
