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

import processing.core.PVector;

/**
 * Pre-fabricated class that creates an rod (symmetrical) contour. <br>
 * 
 * There is a single constructor that allows you to specify the rod radius and the number
 * of faces (minimum 3). <br>
 * 
 * @author Peter Lager
 *
 */
public class C_Rod extends Contour {

	/**
	 * Create a rod contour. <br>
	 * 
	 * @param radius the rod radius
	 * @param nbrSegments the number of facets arround the circumference (must be >= 3)
	 */
	public C_Rod(float radius, int nbrSegments){
		contour = new PVector[nbrSegments];
		float deltaA = (float) (Math.PI * 2.0 / nbrSegments);
		for(int i = 0; i < nbrSegments; i++){
			contour[i] = new PVector((float)Math.cos(i*deltaA), (float)Math.sin(i*deltaA));
			contour[i].mult(radius);
		}		
	}
	
}
