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

import processing.core.PImage;
import shapes3d.utils.Textures;

/**
 * This class extends the Mesh2DCore class to enable the use of end caps
 * for the all 3D shapes that have open ends. This includes the Tube and
 * Extrusion classes. <br>
 * 
 * It also provides methods to control the draw mode and visibility of 
 * the end caps also this class includes methods to set the texture, fill 
 * color, stroke color and stroke weight for the end caps. <br>
 * 
 * All these parameters can be set independently for each end cap based on
 * the second parameter in the setter methods. <br>
 * 
 * The second parameter is <br>
 * Tube.S_CAP, Tube.E_CAP or Tube.BOTHCAP <br>
 * these <br>
 * Helix.S_CAP, Helix.E_CAP or Helix.BOTHCAP <br>
 * are also valid
 * 
 * @author Peter Lager
 *
 */
public class Mesh2DCoreWithCaps extends Mesh2DCore {

	protected EndCapBase startEC, endEC;

	@Override
	protected void calcShape() {}

	/**
	 * Change the visibility of end caps.
	 * Note if the body to invisible then the end caps will not be
	 * displayed.
	 * 
	 * @param vis visibility
	 * @param caps which cap(s) affected
	 */
	public void visible(boolean vis, int caps){
		if(isFlagSet(caps, S_CAP))
			startEC.visible = vis;
		if(isFlagSet(caps, E_CAP))
			endEC.visible = vis;
	}

	/**
	 * Sets the draw mode for the end caps shape. <br>
	 * The three constants Shape3D.SOILD, Shape3D.WIRE and Shape3D.TEXTURE are used 
	 * to determine how the shape is drawn. These can be ored together to get different
	 * drawing combinations e.g. Shape3D.SOLID | Shape3D.WIRE would be a coloured shape
	 * with edges. If the parameter is Shape3D.TEXTURE then and a texture has not
	 * been set then it will use SOLID.
	 * @param mode end-cap draw mode
	 * @param caps caps which cap(s) affected
	 */
	public void drawMode(int mode, int caps){
		if(isFlagSet(caps, S_CAP))
			startEC.drawMode(mode);
		if(isFlagSet(caps, E_CAP))
			endEC.drawMode(mode);
	}
	
	/**
	 * Sets the colours to be used for the end caps.
	 * 
	 * @param col tube(s) cap colour
	 * @param caps which cap(s) affected
	 */
	public void fill(int col, int caps){
		if(isFlagSet(caps, S_CAP))
			startEC.col = col;
		if(isFlagSet(caps, E_CAP))
			endEC.col = col;
	}
	
	/**
	 * Sets the stroke weights to be used for the end caps
	 * 
	 * @param weight start end-cap stroke weight
	 * @param caps end-cap(s) affected
	 */
	public void strokeWeight(float weight, int caps){
		if(isFlagSet(caps, S_CAP))
			startEC.sweight = weight;
		if(isFlagSet(caps, E_CAP))
			endEC.sweight = weight;
	}

	/**
	 * Sets the wire color to be used for the end caps.
	 * 
	 * @param col tube(s) cap wire colour
	 * @param caps which cap(s) affected
	 */
	public void stroke(int col, int caps){
		if(isFlagSet(caps, S_CAP))
			startEC.scol = col;
		if(isFlagSet(caps, E_CAP))
			endEC.scol = col;
	}

	/**
	 * Sets the texture to be used for the end cap(s)
	 * @param fname image filename
	 * @param caps which cap(s) affected
	 */
	public void setTexture(String fname, int caps){
		PImage img = Textures.loadImage(app, fname);
		setTexture(img, caps);
	}

	/**
	 * Sets the texture to be used for the end cap(s)
	 * @param img the image to be used
	 * @param caps which cap(s) affected
	 */
	public void setTexture(PImage img, int caps){
		if(img != null){
			if(isFlagSet(caps, S_CAP))
				startEC.capSkin = img;
			if(isFlagSet(caps, E_CAP))
				endEC.capSkin = img;
		}
	}

}
