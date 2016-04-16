/*
  Part of the Shapes 3D library for Processing 
  	http://www.lagers.org.uk

  Copyright (c) 2010 Peter Lager

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
 */

package shapes3d;

import java.util.Iterator;

import processing.core.PApplet;
import processing.core.PImage;
import shapes3d.utils.Textures;

/**
 * This is a simple way for users to add their own shapes so they work
 * as part of the Shapes3D library. <br>
 * To use this class create your shape class which must implement the IShape 
 * interface to work with this library). Then you create an object of your 
 * class and use setXShape to add it to an Xshape object. <br>
 * 
 * 
 * @author Peter Lager
 *
 */
public class Xshape extends Shape3D {

	private I_Shape shape = null;

	/**
	 * Need to use this constructor to initialise the PApplet 
	 * object responsible for drawing.
	 * 
	 * @param app
	 */
	public Xshape(PApplet app){
		super();
		this.app = app;
	}

	/**
	 * @return the xshape
	 */
	public I_Shape getXshape() {
		return shape;
	}

	/**
	 * @param xshape the shape renderer to use
	 */
	public void setXshape(I_Shape xshape) {
		this.shape = xshape;
	}

	/**
	 * Set the texture to be used for this Shape (no tiling) <br>
	 * If you have special requirements for your shape then provide the code
	 * in your renderer class. 
	 * @param fname
	 */
	public void setTexture(String fname){
		PImage img = Textures.loadImage(app, fname);
		skin = img;
	}

	/**
	 * Set the image to be used for this Shape (no tiling) <br>
	 * If you have special requirements for your shape then provide the code
	 * in your renderer class. 
	 * @param img if not null then the drawMode is changed to TEXTURE.
	 */
	public void setTexture(PImage img){
		skin = img;
	}

	@Override
	protected void calcShape() { }

	@Override
	public void draw() {
		if(visible && shape != null){
			app.pushStyle();
			app.pushMatrix();
			drawWhat();
			if(pickModeOn){
				pickBuffer.pushMatrix();
				pickBuffer.translate(pos.x, pos.y, pos.z);
				pickBuffer.rotateX(rot.x);
				pickBuffer.rotateY(rot.y);
				pickBuffer.rotateZ(rot.z);
				pickBuffer.scale(shapeScale);
				pickBuffer.noStroke();
				pickBuffer.fill(pickColor);
				if(visible && drawMode != WIRE){
					shape.drawForPicker(pickBuffer);
				}
				if(children != null){
					Iterator<Shape3D> iter = children.iterator();
					while(iter.hasNext())
						iter.next().drawForPicker(pickBuffer);
				}
				pickBuffer.popMatrix();
			}
			else { // normal display
				app.translate(pos.x, pos.y, pos.z);
				app.rotateX(rot.x);
				app.rotateY(rot.y);
				app.rotateZ(rot.z);
				app.scale(shapeScale);

				if(useTexture){
					if(useSolid)
						app.fill(fillColor);
					else
						app.noFill();
					if(useWire){
						app.stroke(strokeColor);
						app.strokeWeight(strokeWeight);
						app.hint(OPTIMIZED_STROKE);
					}
					else {
						app.noStroke();
					}
					shape.drawWithTexture(app, skin);
					app.hint(ENABLE_OPTIMIZED_STROKE);
				}
				else { // No texture
					if(useWire){
						app.stroke(strokeColor);
						app.strokeWeight(strokeWeight);
						app.hint(OPTIMIZED_STROKE);
					}
					else {
						app.noStroke();
					}
					if(useSolid)
						app.fill(fillColor);
					else
						app.noFill();
					shape.drawWithoutTexture(app);	
				}
				app.hint(ENABLE_OPTIMIZED_STROKE);
				// Draw any children
				if(children != null){
					Iterator<Shape3D> iter = children.iterator();
					while(iter.hasNext())
						iter.next().draw();
				}
			}
		}
		app.popMatrix();
		app.popStyle();
	}
}



