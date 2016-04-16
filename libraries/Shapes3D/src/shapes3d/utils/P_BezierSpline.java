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
 * This class defines a Bezier spline in 3D space that passes through a set of given 
 * points (called knots). It can also be used in 2D space by using z=0 when
 * creating the knots.<br>
 * The curve between each pair of points is a cubic Bezier curve and the controls 
 * points are calculated to give a smooth transition along the spline. <br>
 * 
 * The position along the spline can be found using a parametric variable in the 
 * range >=0 and <=1
 * 
 * 
 * @author Peter Lager
 *
 */
public class P_BezierSpline implements Path {
	
	protected P_Bezier3D[] bcurve;
	protected float[] tMax;
	protected float[] tLength;
	
	/**
	 * Create a Bezier spline that passes through the specified positions
	 * @param knots array of PVectors defining the spline.
	 */
	public P_BezierSpline(PVector[] knots){
		calculateSpline(knots);
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
		int bc = 0;
		while(bc < tMax.length-1 && t > tMax[bc])
			bc++;
		float nt = (bc == 0) ? t/tLength[0] : (t - tMax[bc-1])/tLength[bc];
		return bcurve[bc].point(nt);
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
		int bc = 0;
		while(bc < tMax.length-1 && t > tMax[bc])
			bc++;
		float nt = (bc == 0) ? t/tLength[0] : (t - tMax[bc-1])/tLength[bc];
		return bcurve[bc].tangent(nt);
	}
	
	/**
	 * Used internally to calculate the controls points.
	 * 
	 * @param knots
	 */
	private void calculateSpline(PVector[] knots){
		int nbrKnots = knots.length;
		int n = nbrKnots - 1;
		
		PVector[] p2, p1, r;
		float[] a, b, c;

		a = new float[n];
		b = new float[n];
		c = new float[n];
		p1 = new PVector[n];
		p2 = new PVector[n];
		r = new PVector[n];
		
		// Left segment
		a[0] = 0;
		b[0] = 2;
		c[0] = 1;
		r[0] = PVector.add(knots[0], PVector.mult(knots[1], 2));
		// Internal segments
		for(int i = 1; i < n-1; i++){
			a[i] = 1;
			b[i] = 4;
			c[i] = 1;
			r[i] = PVector.add(PVector.mult(knots[i], 4), PVector.mult(knots[i+1], 2));
		}
		// Right segment
		a[n-1] = 2;
		b[n-1] = 7;
		c[n-1] = 0;
		r[n-1] = PVector.add(PVector.mult(knots[n-1], 8), knots[n]);
		
		// Solves Ax = b with Thomas algorithm
		for(int i = 1; i < n; i++){
			float m = a[i]/b[i-1];
			b[i] = b[i] - m * c[i-1];
			r[i].sub(PVector.mult(r[i-1], m));
		}
		
		// Calculate p1 for elements  [0 .. n-1] element [n] required
		p1[n-1] = PVector.div(r[n-1], b[n-1]);
		for(int i = n - 2; i >= 0; --i){
			p1[i] = PVector.sub(r[i], PVector.mult(p1[i+1], c[i]));
			p1[i].div(b[i]);
		}
		
		// Calculate p2 for elements  [1 .. n] element [0] required
		for(int i = 0; i < n-1; i++){
			p2[i] = PVector.mult(knots[i+1], 2);
			p2[i].sub(p1[i+1]);
		}
		p2[n-1] = PVector.mult(PVector.add(knots[n], p1[n-1]), 0.5f);
		

		float splineLength = 0;
		bcurve = new P_Bezier3D[n];
		float[] bcurveLength = new float[n];
		
		for(int i = 0; i < n; i++){
			bcurve[i] = new P_Bezier3D( new PVector[] {knots[i], p1[i], p2[i], knots[i+1] } , 4);
			bcurveLength[i] = bcurve[i].length(100);
			splineLength += bcurveLength[i];
		}
	
		tMax = new float[n];
		tLength = new float[n];
		for(int i = 0; i < bcurve.length; i++){
			tLength[i] = bcurveLength[i] / splineLength;
			tMax[i] = tLength[i];
			if(i > 0)
				tMax[i] += tMax[i-1];
		}
	}
	
}
