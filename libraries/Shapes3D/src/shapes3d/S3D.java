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

/**
 * This class is provided to simplify the use of library 
 * constants e.g. S3D.TEXTURE <br>
 * 
 * @author Peter Lager
 *
 */
public class S3D implements SConstants {
	
	/**
	 * return the pretty version of the library.
	 */
	public static String getPrettyVersion() {
		return "2.2";
	}

	/**
	 * return the version of the library used by Processing
	 */
	public static String getVersion() {
		return "11";
	}

}
