/*
  Part of the Shapes 3D library for Processing 
  	http://www.lagers.org.uk

  Copyright (c) 2013 Peter Lager

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

import processing.core.PConstants;
import processing.core.PImage;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;
import shapes3d.utils.Contour;
import shapes3d.utils.ContourScale;
import shapes3d.utils.Path;

/**
 * This is the base class for all end cap classes.
 * 
 * @author Peter Lager
 *
 */
abstract class EndCapBase implements PConstants, SConstants {
	
	public Shape3D owner;
	
	public boolean visible = true;
	public PImage capSkin;
	public int col = WHITE;
	public int scol = WHITE;
	public float sweight = 1;
	public int capDrawMode = SOLID;

	public EndCapBase(Shape3D parent){
		owner = parent;
	}

	void calcShape(PVector[] edgeCoords, int steps, int uvDir){}
	void calcShape(Path path, Contour contour, ContourScale zoom, float t){}
	
	abstract void drawForPicker(PGraphicsOpenGL pickBuffer);
	
	abstract void draw();
	
	protected void drawWhat(){
		owner.useSolid = ((capDrawMode & SOLID) == SOLID);
		owner.useWire = ((capDrawMode & WIRE) == WIRE);
		owner.useTexture = ((capDrawMode & TEXTURE) == TEXTURE && capSkin != null);
	}

	public void drawMode(int mode){
		mode &= DRAWALL;
		boolean validMode = ((mode & WIRE) == WIRE);
		validMode |= ((mode & SOLID) == SOLID);
		validMode |= ((mode & TEXTURE) == TEXTURE && capSkin != null);
		if(!validMode)
			mode = SOLID;
		capDrawMode = mode;
	}


}
