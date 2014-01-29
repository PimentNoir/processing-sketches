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
 * Pre- fabricated class that creates an linear path between two points for the shape. <br>
 * 
 * There is a single constructor that allows you to specify the start and end positions. <br>
 *  
 * @author Peter Lager
 *
 */
public class P_LinearPath implements Path {

	private final PVector s;
	private final PVector e;
	private final PVector delta;
	private final PVector tangent;
	
	/**
	 * Create the linear path extrusion control
	 * @param start vector defining start position
	 * @param end vector defining end position
	 */
	public P_LinearPath(PVector start, PVector end){
		s = new PVector(start.x, start.y, start.z);
		e = new PVector(end.x, end.y, end.z);
		delta = PVector.sub(e, s);
		tangent = delta.normalize(null);
	}
	
	/**
	 * Method defines the function V = pos(t) where t is in the range >=0 and <=1.
	 * When you implement this method there is no need to constrain the value
	 * of t to this range as this is done in the PathTube class.
	 * 
	 * @param t >=0 and <= 1.0
	 * @return a PVector giving the x,y,z coordinates at a position t
	 */
	public PVector point(float t) {
		return PVector.add(s, PVector.mult(delta, t));
	}

	/**
	 * Method defines the function V = tangent(t) where t is in the range >=0 and <=1.
	 * When you implement this method there you must constrain the value
	 * of t to this range.
	 * 
	 * @param t >=0 and <= 1.0
	 * @return a PVector giving the x,y,z coordinates of the tangent at position t
	 */
	public PVector tangent(float t) {
		return tangent;
	}

}
