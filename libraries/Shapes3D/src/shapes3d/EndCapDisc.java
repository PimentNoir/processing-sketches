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

import processing.core.PApplet;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;
import shapes3d.utils.UV;

/**
 * This is the end cap class for all shapes that have open circular 
 * or oval ends e.g. Tube
 * 
 * @author Peter Lager
 *
 */
class EndCapDisc extends EndCapBase {
	
	public PVector n = new PVector();
	public PVector centre;
	public PVector[] edge;
	public UV[] uvLoc;

	public EndCapDisc(Shape3D parent) {
		super(parent);
	}

	protected void calcShape(PVector[] edgeCoords, int steps, int uvDir){
		edge = edgeCoords;
		// Calculate centre of end cap
		centre = new PVector();
		for(int i = 1; i < edge.length; i++)
			centre.add(edge[i]);
		centre.div(edge.length - 1);
		// Calculate UV coordinates
		float angle = 0, dAng = uvDir * TWO_PI / (steps - 1.0f);
		uvLoc = new UV[steps + 1];
		uvLoc[0] = new UV(0.5f, 0.5f);
		for(int i = 1; i < steps + 1; i++){
			uvLoc[i] = new UV(0.5f + 0.5f * (float)Math.cos(angle), 0.5f + 0.5f * (float)Math.sin(angle));
			angle += dAng;
		}
		// Calculate normal
		PVector v1 = PVector.sub(edge[0], centre);
		PVector v2 = PVector.sub(edge[1], centre);		
		PVector.cross(v1, v2, n);
		if(uvDir != 1)
			n.mult(uvDir);
		n.normalize();
	}
	
//	protected void drawWhat(){
//		owner.useSolid = ((capDrawMode & SOLID) == SOLID);
//		owner.useWire = ((capDrawMode & WIRE) == WIRE);
//		owner.useTexture = ((capDrawMode & TEXTURE) == TEXTURE && capSkin != null);
//	}
//
//	public void drawMode(int mode){
//		mode &= DRAWALL;
//		boolean validMode = ((mode & WIRE) == WIRE);
//		validMode |= ((mode & SOLID) == SOLID);
//		validMode |= ((mode & TEXTURE) == TEXTURE && capSkin != null);
//		if(!validMode)
//			mode = SOLID;
//		capDrawMode = mode;
//	}

	public void draw(){
		drawWhat();
		if(owner.useTexture)
			drawWithTexture();
		else
			drawWithoutTexture();
		// drawNormals();
	}

	public void drawNormals(){
		PVector c = centre;
		PVector n = PVector.mult(this.n, 20);
		owner.app.stroke(255,0,0);
		owner.app.line(c.x,c.y,c.z,c.x+n.x,c.y+n.y,c.z+n.z);
		for(int t = 0; t < edge.length; t++) {
			c = edge[t];
			owner.app.line(c.x,c.y,c.z,c.x+n.x,c.y+n.y,c.z+n.z);
		}
	}

	protected void drawWithoutTexture(){
		if(owner.useWire){
			owner.app.stroke(scol);
			owner.app.strokeWeight(sweight);
			owner.app.hint(Shape3D.OPTIMIZED_STROKE);
		}
		else {
			owner.app.noStroke();
		}
		if(owner.useSolid)
			owner.app.fill(col);
		else
			owner.app.noFill();
		
		PVector c = centre;
		owner.app.beginShape(TRIANGLE_FAN);
		owner.app.normal(n.x, n.y, n.z);
		owner.app.vertex(c.x, c.y, c.z);					
		for(int seg = 0; seg < edge.length; seg++) {
			c = edge[seg];
			owner.app.normal(n.x, n.y, n.z);
			owner.app.vertex(c.x, c.y, c.z);					
		}
		owner.app.endShape(PApplet.CLOSE);
		owner.app.hint(ENABLE_OPTIMIZED_STROKE);
	}

	/**
	 * Draw using texture
	 */
	protected void drawWithTexture(){
		PVector c = centre;
		UV uv = new UV(0.5f, 0.5f);

		if(owner.useSolid)
			owner.app.fill(owner.fillColor);
		if(owner.useWire){
			owner.app.stroke(scol);
			owner.app.strokeWeight(sweight);
			owner.app.hint(Shape3D.OPTIMIZED_STROKE);
		}
		else {
			owner.app.noStroke();
		}

		owner.app.textureMode(NORMAL);	
		owner.app.beginShape(TRIANGLE_FAN);
		owner.app.texture(capSkin);
		owner.app.normal(n.x, n.y, n.z);
		owner.app.vertex(c.x, c.y, c.z, uv.u, uv.v);
		for(int seg = 0; seg < edge.length; seg++) {
			c = edge[seg];
			uv = uvLoc[seg+1];	
			owner.app.normal(n.x, n.y, n.z);
			owner.app.vertex(c.x, c.y, c.z, uv.u, uv.v);
		}
		owner.app.endShape(PApplet.CLOSE);
		owner.app.hint(ENABLE_OPTIMIZED_STROKE);
	}

	protected void drawForPicker(PGraphicsOpenGL pickBuffer) {
		pickBuffer.pushMatrix();
		pickBuffer.translate(owner.pos.x, owner.pos.y, owner.pos.z);
		pickBuffer.rotateX(owner.rot.x);
		pickBuffer.rotateY(owner.rot.y);
		pickBuffer.rotateZ(owner.rot.z);
		pickBuffer.scale(owner.shapeScale);
		pickBuffer.noStroke();

		PVector c = centre;
		if(visible){
			pickBuffer.beginShape(TRIANGLE_FAN);
			pickBuffer.fill(owner.pickColor);
			pickBuffer.vertex(c.x, c.y, c.z);
			for(int seg = 0; seg < edge.length; seg++) {
				c = edge[seg];
				pickBuffer.vertex(c.x, c.y, c.z);					
			}
			pickBuffer.endShape(PApplet.CLOSE);
		}
		pickBuffer.popMatrix();
	}
}
