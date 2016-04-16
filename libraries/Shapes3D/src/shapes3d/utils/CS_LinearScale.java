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
 * Pre-fabricated class that creates a linear tapered scale control for the 
 * contour of a shape along its path. <br>
 * 
 * The constructor allow you to specify the amount of scaling to apply to the contour
 * each end of the extrusion path. <br>
 * 
 * if the scale is the same at both ends it is more efficient to use the ECS_ConstantScale class.
 * 
 * @author Peter Lager
 *
 */
public class CS_LinearScale implements ContourScale {

	
	private final float scaleStart;
	private final float scaleEnd;
	
	/**
	 * Create a linear scaling object
	 * @param scaleStart scale at one end
	 * @param scaleEnd scale at the other end
	 */
	public CS_LinearScale(float scaleStart, float scaleEnd) {
		this.scaleStart = scaleStart;
		this.scaleEnd = scaleEnd;
	}

	/**
	 * The method that calculates and returns the scale factor for a normalised position
	 * along the extrusion path.
	 * 
	 * @param t the normalised position must be >=0 and <=1
	 * @return the scale factor at position t
	 */
	public float scale(float t) {
		return scaleStart + t * (scaleEnd - scaleStart);
	}
	
	

}
