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

import java.util.Iterator;

import processing.core.PApplet;
import processing.core.PVector;
import shapes3d.utils.Contour;
import shapes3d.utils.ContourScale;
import shapes3d.utils.MeshSection;
import shapes3d.utils.Path;
import shapes3d.utils.Rot;


/**
 * This class represents all shapes that can be created from a 2D contour that
 * moves along a 3D path. <br>
 * 
 * It requires three pieces of information :- <br>
 * 1) the path the extrusion takes in 3D space <br>
 * 2) the shapes contour <br>
 * 3) the scaling factor to be applied to the contour depending on the distance along the path <br><br>
 * 
 * 
 * 
 * @author Peter Lager
 *
 */
public class Extrusion extends Mesh2DCoreWithCaps {

	protected Path path = null;
	protected Contour contour = null;
	protected ContourScale contourScale = null;

	protected float[] uContour;

	/**
	 * All extrusions are created using this constructor. <br>
	 * 
	 * The library provides some predefined classes that you can use as 
	 * parameters for this constructor. <br>
	 * They are <br>
	 * 
	 * 
	 * @param app the PApplet object used to draw the shape
	 * @param path the 3D path for the extrusion centre-line
	 * @param nbrSlices the number of slices along the path length
	 * @param contour the cross-sectional shape of the extrusion
	 * @param contourScale the scale to be applied to the contoru.
	 */
	public Extrusion(PApplet app, Path path, int nbrSlices, Contour contour, ContourScale contourScale){
		super();
		this.app = app;
		this.path = path;
		this.contour = contour;
		this.contourScale = contourScale;

		nsPieces = nbrSlices;
		ewPieces = this.contour.getNbrVertices();
		nsSteps = nsPieces + 1;
		ewSteps = ewPieces + 1;

		calcShape();
	}

	@Override
	protected void calcShape(){
		coord = new PVector[ewSteps][nsSteps];
		norm = new PVector[ewSteps][nsSteps];
		fullShape = new MeshSection(ewSteps, nsSteps);

		// Calculate the u texture coordinates for a contour of length 1
		// and store in uContour. This array will be used to calcuate
		// the actual texture coordinates u[] by multiplying by the max 
		// u coordinate required.
		float contourLength = 0;
		PVector[] contourVetices = contour.getVetices(false);
		uContour = new float[ewSteps];
		uContour[0] = 0;
		for(int i = 1; i < ewPieces; i++){
			contourLength += PVector.dist(contourVetices[i-1], contourVetices[i]);
			uContour[i] = contourLength;
		}
		contourLength += PVector.dist(contourVetices[ewPieces - 1], contourVetices[0]);
		uContour[ewPieces] = contourLength;
		for(int i = 0; i < ewSteps; i++)
			uContour[i] /= contourLength;
		
		// Create end caps for the extrusion
		startEC = new EndCapContour(this, path, contour, contourScale, 0.0f);
		endEC = new EndCapContour(this, path, contour, contourScale, 1.0f);

		calcXYZ();
		calcUV(ewRepeats, nsRepeats);
	}

	/**
	 * Used internally to perform interim calcs for uv texture coordinates based on
	 * number of repeats.
	 * @param ewRepeats nbr of times to repeat texture round extrusion
	 * @param nsRepeats nbr of times to repeat texture along extrusion
	 */
	protected void calcUV(float ewRepeats, float nsRepeats){
		u = new float[ewSteps];
		for(int i = 0; i < u.length; i++)
			u[i] = uContour[i] * ewRepeats;
		v = new float[nsSteps];
		float deltaV = nsRepeats / nsPieces;
		for(int i = 0; i < nsSteps; i++)
			v[i] = i * deltaV;
	}

	/**
	 * Used internally to calculate the shape.
	 */
	protected void calcXYZ(){
		final PVector FORWARD = new PVector(0,0,1);

		float deltaT = 1.0f / (nsSteps - 1), t = 0;
		float s;
		PVector[] c = contour.getVetices(true);
		PVector point, tangent, v;
		Rot rot;
		for(int ns = 0; ns < nsSteps; ns++){
			t = ns * deltaT;
			point = path.point(t);
			tangent = path.tangent(t);
			s = (contourScale == null) ? 1 : contourScale.scale(t);
			rot = new Rot(FORWARD, tangent);
			for(int ew = 0; ew < ewSteps ; ew++){
				if(ew == ewSteps - 1)
					// Close the contour by creating a 'last' vertex in the same
					// position as the first
					v = new PVector(c[0].x, c[0].y, c[0].z);
				else
					v = new PVector(c[ew].x, c[ew].y, c[ew].z);
				if(s != 1)
					v.mult(s);
				rot.applyTo(v);
				v.add(point);		
				coord[ew][ns] = v;
			}
		}
		calcNormals();
	}

	/**
	 * Will calculate the normals for any 2D mesh. <br>
	 * This is a heavy mathematical process so should be overridden in 
	 * child classes if there is a suitable alternative method.
	 */
	protected void calcNormals() {
		PVector c, nt, np;
		int ns, ew;
		for(ns = 0; ns < nsSteps; ns++) {
			for(ew = 0; ew < ewSteps - 1; ew++) {
				c = coord[ew][ns];
				np = coord[ew][(ns+1)%nsSteps];
				nt = coord[ew+1][ns];
				norm[ew][ns] = PVector.cross(PVector.sub(np, c, null), 
						PVector.sub(nt, c, null), 
						null);
				norm[ew][ns].normalize();
			}
		}
		for(ns = 0; ns < nsSteps ; ns++) 
			norm[ewSteps-1][ns] = norm[ewSteps-2][ns];
	}

	/**
	 * If visible draw the shape based on drawMode.
	 */
	@Override
	public void draw(){
		if(visible){
			super.draw();
			// Now draw the end caps
			app.pushStyle();
			app.pushMatrix();
			if(pickModeOn){
				if(visible && pickable){
					if(startEC.visible  && startEC.capDrawMode != WIRE)
						startEC.drawForPicker(pickBuffer);
					if(endEC.visible  && endEC.capDrawMode != WIRE)
						endEC.drawForPicker(pickBuffer);
				}
			}
			else {
				if(visible){
					app.translate(pos.x, pos.y, pos.z);
					app.rotateX(rot.x);
					app.rotateY(rot.y);
					app.rotateZ(rot.z);
					app.scale(shapeScale);
					app.fill(fillColor);

					if(startEC.visible)
						startEC.draw();
					if(endEC.visible)
						endEC.draw();

					if(children != null){
						Iterator<Shape3D> iter = children.iterator();
						while(iter.hasNext())
							iter.next().draw();
					}
				}
			}
			app.popMatrix();
			app.popStyle();
		}
	}

	/**
	 * Used for testing only
	 */
	protected void drawNormals(){
		PVector n, c;
		app.pushStyle();
		app.stroke(255,0,0);
		for(int p = 0; p < nsSteps-1; p++) {
			for(int t = 0; t < ewSteps-1; t++) {
				c = new PVector(coord[t][p].x, coord[t][p].y, coord[t][p].z);
				c.add(coord[t+1][p]);
				c.add(coord[t+1][p+1]);
				c.add(coord[t][p+1]);
				c.div(4);
				n = PVector.mult(norm[t][p],10);
				app.line(c.x,c.y,c.z,c.x+n.x,c.y+n.y,c.z+n.z);
			}
		}	
		app.noStroke();
		app.popStyle();
	}

}
