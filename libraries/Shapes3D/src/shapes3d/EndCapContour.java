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

import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;
import shapes3d.utils.Contour;
import shapes3d.utils.ContourScale;
import shapes3d.utils.Path;
import shapes3d.utils.Rot;
import shapes3d.utils.Triangulator;
import shapes3d.utils.UV;

/**
 * This is the end cap class for all shapes that have open irregular
 * shaped ends e.g. Extrusion 
 * 
 * @author Peter Lager
 *
 */
public class EndCapContour extends EndCapBase {

	public PVector n = new PVector();
	public PVector centre;
	public PVector[] edge;
	public UV[] uvLoc;

	private Integer[] triangles;

	public int capDrawMode = SOLID;

	public EndCapContour(Shape3D parent, Path path, Contour contour, ContourScale zoom, float t){
		super(parent);
		calcShape(path,contour,zoom,t);
	}

	protected void calcShape(Path path, Contour contour, ContourScale zoom, float t){
		final PVector FORWARD = new PVector(0,0,1);
		// Get copy of contour
		edge = contour.getVetices(true);
		// Calculate uv coordinates.
		float minX, maxX, minY, maxY;
		minX = maxX = edge[0].x;
		minY = maxY = edge[0].y;
		for(int i = 1; i < edge.length; i++){
			minX = (edge[i].x < minX) ? edge[i].x : minX;
			maxX = (edge[i].x > maxX) ? edge[i].x : maxX;
			minY = (edge[i].y < minY) ? edge[i].y : minY;
			maxY = (edge[i].y > maxY) ? edge[i].y : maxY;
		}
		// Calculate the uv texture coordinates. Assume that the entire image is
		// to be used which means both u and v will have values in the range 0 to 1 
		// inclusive
		uvLoc = new UV[edge.length];
		float maxWidth = maxX - minX;
		float maxHeight = maxY - minY;
		for(int i = 0; i < edge.length; i++)
			uvLoc[i] = new UV( (edge[i].x - minX)/maxWidth, (edge[i].y - minY)/maxHeight);
		// Calculate triangles for drawing the end cap
		triangles = Triangulator.triangulate(edge);
		// Transform end cap to correct position and size
		PVector pathTangent = path.tangent(t);
		PVector point = path.point(t);
		Rot rot = new Rot(FORWARD, pathTangent);
		float s = (zoom == null) ? 1 : zoom.scale(t);
		for(int i = 0; i < edge.length; i++){
			edge[i].mult(s);
			rot.applyTo(edge[i]);
			edge[i].add(point);
		}
		// Calculate end cap normal
		n.set(pathTangent);
		if(t > 0.5f)
			n.mult(-1);
		n.normalize();
	}

	/**
	 * Draw the end cap based on the draw mode
	 */
	public void draw(){
		if(visible){
			drawWhat();
			if(owner.useTexture)
				drawWithTexture();
			else
				drawWithoutTexture();
		}
	}

	public void drawNormals(){
		PVector c = centre;
		PVector en = PVector.mult(this.n, 20);
		owner.app.stroke(255,0,0);
		for(int t = 0; t < edge.length; t++) {
			c = edge[t];
			owner.app.line(c.x,c.y,c.z,c.x+en.x,c.y+en.y,c.z+en.z);
		}
	}

	/**
	 * Draw the end cap without a texture
	 */
	protected void drawWithoutTexture(){
		int v0, v1, v2;
		if(owner.useSolid){
			owner.app.fill(col);
			owner.app.noStroke();
			owner.app.beginShape(TRIANGLES);
			for(int tri = 0; tri < triangles.length; tri += 3) {
				v0 = triangles[tri];
				v1 = triangles[tri+1];
				v2 = triangles[tri+2];

				owner.app.fill(col);
				owner.app.normal(n.x, n.y, n.z);
				owner.app.vertex(edge[v0].x, edge[v0].y ,edge[v0].z);					
				owner.app.vertex(edge[v1].x, edge[v1].y ,edge[v1].z);					
				owner.app.vertex(edge[v2].x, edge[v2].y ,edge[v2].z);					
			}
			owner.app.endShape();
		}
		if(owner.useWire){
			owner.app.stroke(scol);
			owner.app.strokeWeight(sweight);
			owner.app.hint(Shape3D.OPTIMIZED_STROKE);

			owner.app.beginShape(LINE_STRIP);
			for(int i = 0; i < edge.length; i++)
				owner.app.vertex(edge[i].x, edge[i].y, edge[i].z);
			owner.app.vertex(edge[0].x, edge[0].y, edge[0].z);
			owner.app.endShape();
			
			owner.app.hint(ENABLE_OPTIMIZED_STROKE);
		}
	}

	/**
	 * Draw end cap using texture
	 */
	protected void drawWithTexture(){
		int v0, v1, v2;
		owner.app.noStroke();
		owner.app.textureMode(NORMAL);
		owner.app.hint(Shape3D.OPTIMIZED_STROKE);

		owner.app.beginShape(TRIANGLES);
		owner.app.texture(capSkin);
		for(int tri = 0; tri < triangles.length; tri += 3) {
			v0 = triangles[tri];
			v1 = triangles[tri+1];
			v2 = triangles[tri+2];

			owner.app.fill(col);
			owner.app.normal(n.x, n.y, n.z);
			owner.app.vertex(edge[v0].x, edge[v0].y ,edge[v0].z, uvLoc[v0].u, uvLoc[v0].v);					
			owner.app.vertex(edge[v1].x, edge[v1].y ,edge[v1].z, uvLoc[v1].u, uvLoc[v1].v);
			owner.app.vertex(edge[v2].x, edge[v2].y ,edge[v2].z, uvLoc[v2].u, uvLoc[v2].v);
		}
		owner.app.endShape();

		if(owner.useWire){
			owner.app.stroke(scol);
			owner.app.strokeWeight(sweight);
			owner.app.hint(Shape3D.OPTIMIZED_STROKE);
			owner.app.beginShape(LINE_STRIP);
			for(int i = 0; i < edge.length; i++)
				owner.app.vertex(edge[i].x, edge[i].y, edge[i].z);
			owner.app.vertex(edge[0].x, edge[0].y, edge[0].z);
			owner.app.endShape();
			owner.app.hint(ENABLE_OPTIMIZED_STROKE);
		}
	}

	/**
	 * Draw end cap for picker
	 * @param pickBuffer
	 */
	protected void drawForPicker(PGraphicsOpenGL pickBuffer) {
		int v0, v1, v2;
		pickBuffer.pushMatrix();
		pickBuffer.translate(owner.pos.x, owner.pos.y, owner.pos.z);
		pickBuffer.rotateX(owner.rot.x);
		pickBuffer.rotateY(owner.rot.y);
		pickBuffer.rotateZ(owner.rot.z);
		pickBuffer.scale(owner.shapeScale);
		pickBuffer.noStroke();

		if(visible){
			pickBuffer.beginShape(TRIANGLES);
			for(int tri = 0; tri < triangles.length; tri += 3) {
				v0 = triangles[tri];
				v1 = triangles[tri+1];
				v2 = triangles[tri+2];
				pickBuffer.fill(owner.pickColor);
				pickBuffer.vertex(edge[v0].x, edge[v0].y ,edge[v0].z);					
				pickBuffer.vertex(edge[v1].x, edge[v1].y ,edge[v1].z);					
				pickBuffer.vertex(edge[v2].x, edge[v2].y ,edge[v2].z);					
			}
			pickBuffer.endShape();
			pickBuffer.popMatrix();
		}
	}

}
