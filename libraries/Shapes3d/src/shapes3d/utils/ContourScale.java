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
 * This interface provides the method required to define the scale factor to be 
 * applied to the contour at various points along the extrusion's length.
 * 
 * @author Peter Lager
 *
 */
public interface ContourScale {

	/**
	 * A parametric method that returns a scale factor for the normalised position
	 * along the extrusion path.
	 * 
	 * @param t the normalied position must be >=0 and <=1
	 * @return the scale factor at position t
	 */
	public float scale(float t);
	
}
