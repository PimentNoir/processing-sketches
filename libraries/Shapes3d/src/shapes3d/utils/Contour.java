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
 * Extend this class to create your own contour shapes. In most cases all you have to do is provide
 * your own constructor that calculates and stores the contour vertices in the attribute 'contour' <br>
 * 
 * Note that the contour should be an open path - the library will automatically join the ends to get 
 * a continuous shape. The contour should define a 2D shape that has no holes or intersecting edges but
 * it can have concave sections. <br>
 * 
 * @author Peter Lager
 *
 */
public abstract class Contour {

	protected PVector[] contour = new PVector[0];
	protected float[] uContour;
	
	/**
	 * The number of vertices in the contour.
	 * @return the number of vertices / faces in the contour
	 */
	public int getNbrVertices(){
		return contour.length;
	}

	/**
	 * This will create and return an array of 2D points that represent the
	 * contour in the x/y plane. <br>
	 * Note in all cases the z coordinate will be zero. <br>
	 * In general the safe way is to return a copy of the array so that changes made
	 * do not affect the original.<br>
	 * 
	 * @param duplicate if true a copy of the contour array is returned else it returns the original.
	 * @return a duplicate array of contour vertices
	 */
	public PVector[] getVetices(boolean duplicate){
		if(duplicate){
			PVector[] n = new PVector[contour.length];
			for(int i = 0; i < contour.length; i++)
				n[i] = new PVector(contour[i].x, contour[i].y);
			return n;
		}
		else
			return contour;
	}

	/**
	 * Calculate the normalised coordinates for the u texture mapping point around 
	 * the contour.
	 * @return the normalised (0.0 - 1.0) contour corner u texture map coordinates.
	 */
	public float[] make_u_Coordinates(){
		return make_u_Coordinates(1);
	}

	/**
	 * Calculate the image pixel coordinates for the u texture mapping point around 
	 * the contour.
	 * 
	 * @param textureWidth the width of the image
	 * @return the image pixel positions for the contour corner u texture map coordinates.
	 */
	public float[] make_u_Coordinates(float textureWidth){
		float contourLength = 0;
		int i;
		uContour = new float[contour.length + 1];
		uContour[0] = 0;
		for(i = 1; i < contour.length; i++){
			contourLength += PVector.dist(contour[i-1], contour[i]);
			uContour[i] = contourLength;
		}
		contourLength += PVector.dist(contour[i-1], contour[0]);
		uContour[i] = contourLength;

		for( i = 0; i < uContour.length; i++){
			uContour[i] *= (textureWidth / contourLength);
		}
		return uContour;		
	}

}
