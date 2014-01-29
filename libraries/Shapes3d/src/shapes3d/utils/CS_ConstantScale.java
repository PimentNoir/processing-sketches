/*
  Part of the Shapes 3D library for Processing 
  	http://www.lagers.org.uk

  Copyright (c) 2012 Peter Lager

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

package shapes3d.utils;

/**
 * Pre-fabricated class that creates a constant scale control for the 
 * contour of a shape along its path. <br>
 * 
 * The constructors allow you to specify the amount of scaling to apply to the 
 * contour along the extrusion path. <br>
 * 
 * @author Peter Lager
 *
 */
public class CS_ConstantScale implements ContourScale {

	private final float scale;
	
	/**
	 * Use for a constant scale factor of 1
	 */
	public CS_ConstantScale(){
		this.scale = 1;
	}
	
	/**
	 * Specify the constant scale factor to use.
	 * @param scale
	 */
	public CS_ConstantScale(float scale){
		this.scale = scale;
	}
	
	/**
	 * The method that calculates and returns the scale factor for a normalised position
	 * along the extrusion path.
	 * 
	 * @param t the normalised position must be >=0 and <=1
	 * @return the scale factor at position t
	 */
	public float scale(float t) {
		return scale;
	}

}
