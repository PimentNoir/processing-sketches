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
 * Pre-fabricated class that creates an I beam contour. <br>
 * 
 * There is a single constructor that allows you to specify the I beam geometry. <br>
 *  
 * @author Peter Lager
 *
 */
public class C_IBeam extends Contour {

	/**
	 * Create an I beam contour object. <br>
	 * 
	 * @param beamHeight The height of the beam including flanges. 
	 * @param flangeWidth the width of the flange from edge to edge
	 * @param webThickness the thickness of the web
	 * @param flangeThicknessAtWeb the thickness of the flange nearest the web
	 * @param flangeThicknessAtEdge the flange thickness at the edge - normally thinner that at the web.
	 */
	public C_IBeam(float beamHeight, float flangeWidth, float webThickness, float flangeThicknessAtWeb, float flangeThicknessAtEdge){
		 contour = new PVector[12];
		 contour[0] = new PVector(webThickness/2, beamHeight/2 - flangeThicknessAtWeb);
		 contour[1] = new PVector(flangeWidth/2, beamHeight/2 - flangeThicknessAtEdge);
		 contour[2] = new PVector(flangeWidth/2, beamHeight/2);

		 for(int i = 0; i <= 2; i++){
			 contour[5-i] = new PVector(-contour[i].x, contour[i].y);
			 contour[6+i] = new PVector(-contour[i].x, -contour[i].y);
			 contour[11-i] = new PVector(contour[i].x, -contour[i].y);
		 }
	}
	
}
