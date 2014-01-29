package shapes3d.utils;

import java.util.ArrayList;
import java.util.List;

import processing.core.PVector;

public class Triangulator {

	static final double EPSILON = 1E-30;

	/**
	 * Create a set of triangles from a concave/convex polygon with no holes and no intersecting sides.
	 * @param contour an open list of vertices that make up a 2D polygon 
	 * @param result list of vertex indices (to contour list) in groups of three for the render triangles
	 * @return true if succeeded else false
	 */
	public static boolean triangulate(List<PVector> contour, List<Integer> result){
		result.clear();
		Integer[] r = triangulate(contour);
		for(Integer i : r)
			result.add(i);
		return (result.isEmpty()) ? false : true;
	}
	
	/**
	 * Create a set of triangles from a concave/convex polygon with no holes and no intersecting sides.
	 * @param contour an open list of vertices that make up a 2D polygon 
	 * @return list of vertex indices (to contour list) in groups of three for the render triangles
	 */
	public static Integer[] triangulate(List<PVector> contour){
		PVector[] contourArray = contour.toArray(new PVector[contour.size()]);
		return triangulate(contourArray);

	}

	/**
	 * Create a set of triangles from a concave/convex polygon with no holes and no intersecting sides.
	 * @param contour an array of vertices that make up an open 2D polygon 
	 * @return list of vertex indices (to contour list) in groups of three for the render triangles
	 */
	public static Integer[] triangulate(PVector[] contour){
		int n = contour.length;
		if ( n < 3 ) 
			return null;

		 List<Integer> result = new ArrayList<Integer>();
		 
		int[] vList = new int[n];

		/* we want a counter-clockwise polygon in V based on computer screen coordinates */
		if ( 0.0f < area(contour) )
			for (int v = 0; v < n; v++) vList[v] = v;
		else
			for(int v = 0; v < n; v++) vList[v] = (n-1)-v;

		int nv = n;

		/*  remove nv-2 Vertices, creating 1 triangle every time */
		int count = 2 * nv;   /* error detection */

		for(int m = 0, v = nv - 1; nv > 2; ){
			/* if we loop, it is probably a non-simple polygon */
			if (0 >= (count--)){
				return null; // Triangulation: ERROR - probable bad polygon!
			}

			/* three consecutive vertices in current polygon, <u,v,w> */
			int u = v;		if (nv <= u) u = 0;		/* previous */
			v = u+1; 		if (nv <= v) v = 0;		/* new v    */
			int w = v+1; 	if (nv <= w) w = 0;		/* next     */

			if (snip(contour, u, v, w, nv, vList)){
				int a,b,c,s,t;

				/* true names of the vertices */
				a = vList[u]; b = vList[v]; c = vList[w];

				/* output Triangle */
				result.add(a);
				result.add(b);
				result.add(c);

				m++;

				/* remove v from remaining polygon */
				for(s = v, t = v+1; t < nv; s++, t++) 
					vList[s] = vList[t]; 
				nv--;

				/* reset error detection counter */
				count = 2 * nv;
			}
		}
		return result.toArray(new Integer[result.size()]);
	}

	/**
	 * Calculate the area of the polygon.
	 * 
	 * @param contour an array of vertices that make up an open 2D polygon 
	 * @return the area of the polygon
	 */
	public static double area(PVector[] contour){
		int n = contour.length;
		double areaX2 = 0.0;
		for(int p = n-1, q = 0; q < n; p = q++)
			areaX2 += contour[p].x * contour[q].y - contour[q].x * contour[p].y;
		return areaX2 * 0.5;
	}

	/**
	 * Decide if point pX/pY is inside triangle defined by triangle ABC
	 * @param aX
	 * @param aY
	 * @param bX
	 * @param bY
	 * @param cX
	 * @param cY
	 * @param pX
	 * @param pY
	 * @return true if inside else false
	 */
	public static boolean isInsideTriangle(double aX, double aY,
			double bX, double bY,
			double cX, double cY,
			double pX, double pY){
		double ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
		double cCROSSap, bCROSScp, aCROSSbp;

		ax = cX - bX;  ay = cY - bY;
		bx = aX - cX;  by = aY - cY;
		cx = bX - aX;  cy = bY - aY;
		apx= pX - aX;  apy= pY - aY;
		bpx= pX - bX;  bpy= pY - bY;
		cpx= pX - cX;  cpy= pY - cY;

		aCROSSbp = ax*bpy - ay*bpx;
		cCROSSap = cx*apy - cy*apx;
		bCROSScp = bx*cpy - by*cpx;

		return ((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
	}

	/**
	 * Decide if point p is inside triangle defined by triangle ABC
	 * @param a triangle vertex
	 * @param b triangle vertex
	 * @param c triangle vertex
	 * @param p the point to test
	 * @return true if inside else false
	 */
	public static boolean isInsideTriangle(PVector a, PVector b, PVector c, PVector p){
		return isInsideTriangle(a.x, a.y, b.x, b.y, c.x, c.y, p.x, p.y);
	}
			
	/**
	 * Decide if point pX/pY is inside triangle defined by triangle ABC
	 * @param a triangle vertex
	 * @param b triangle vertex
	 * @param c triangle vertex
	 * @param pX
	 * @param pY
	 * @return true if inside else false
	 */
	public static boolean isInsideTriangle(PVector a, PVector b, PVector c, double pX, double pY){
		return isInsideTriangle(a.x, a.y, b.x, b.y, c.x, c.y, pX, pY);
	}
			
	private static boolean snip(PVector[] contour, int u, int v, int w, int n, int[] vList){
		int p;
		double Ax, Ay, Bx, By, Cx, Cy, Px, Py;

		Ax = contour[vList[u]].x;
		Ay = contour[vList[u]].y;

		Bx = contour[vList[v]].x;
		By = contour[vList[v]].y;

		Cx = contour[vList[w]].x;
		Cy = contour[vList[w]].y;

		if ( EPSILON > (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) ) 
			return false;

		for (p = 0; p < n; p++){
			if( (p == u) || (p == v) || (p == w) ) continue;
			Px = contour[vList[p]].x;
			Py = contour[vList[p]].y;
			if (isInsideTriangle(Ax, Ay, Bx, By, Cx, Cy, Px, Py)) 
				return false;
		}
		return true;
	}
}
