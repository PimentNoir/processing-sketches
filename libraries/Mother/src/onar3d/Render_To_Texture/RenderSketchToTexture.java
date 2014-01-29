///*
//Copyright 2008 Ilias Bergstrom.
//  
//This file is part of "Mother".
//
//Mother is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//Foobar is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with Mother.  If not, see <http://www.gnu.org/licenses/>.
// 
//www.onar3d.com
// 
//*/
//
//
//
//package onar3d.Render_To_Texture;
//
//import javax.media.opengl.GL;
//
////import codeanticode.glgraphics.*;
//
//import processing.core.*; 
//import processing.opengl.PGraphicsOpenGL;
//
///**
// * @author FugMom
// *
// */
//public class RenderSketchToTexture extends RenderToTexture
//{
//	protected PApplet m_Sketch;
//		
//	boolean m_Stereo;
//	
//	/**
//	 * @param w
//	 * @param h
//	 * @param pgl
//	 */
//	public RenderSketchToTexture(int w, int h, PApplet sketch, PApplet mother, boolean stereo)
//	{
//		super(w, h, (PGraphicsOpenGL)mother.g, mother);
//		
//		m_Sketch = sketch;
//		m_Stereo = stereo;
//		
//		r_Mother.noStroke();
//	}
//	
//	/* (non-Javadoc)
//	 * @see onar3d.Render_To_Texture.RenderToTexture#drawGeometry()
//	 */
//	protected void drawGeometry()
//	{
//		/*m_Gl.glPushMatrix();
//		m_Gl.glColor4f(0, 1.0f, 0, 1.0f);
//    	m_Gl.glTranslatef((m_Width/2.0f),(m_Height/2.0f) , 0f);
//    	m_Pgl.box(100);
//    	m_Gl.glPopMatrix();*/
//   	
//		if(!glinited)
//			initGL();
//
//	//	m_Sketch.pushMatrix();
//	//	m_Gl.glEnable(GL.GL_LIGHTING);
// 		
////		m_Gl.glPushMatrix();
////		m_Sketch.perspective(m_Sketch.PI/3.0f,1f,0.1f,1000f); //this is needed ot stop the images being squashed
////		m_Sketch.camera(m_Width/2.0f, m_Height/2.0f, (m_Height/2.0f) / m_Sketch.tan(m_Sketch.PI*60.0f / 360.0f), m_Width/2.0f, m_Height/2.0f, 0, 0, 1, 0);
////		m_Gl.glViewport(0, 0, m_Width/2, m_Height);
//	
//		m_Sketch.draw();
//		
////		m_Gl.glPopMatrix();
////		
////		m_Gl.glPushMatrix();
////		m_Sketch.perspective(m_Sketch.PI/3.0f,1f,0.1f,1000f); //this is needed ot stop the images being squashed
////		m_Sketch.camera(m_Width/2.0f, m_Height/2.0f, (m_Height/2.0f) / m_Sketch.tan(m_Sketch.PI*60.0f / 360.0f), m_Width/2.0f, m_Height/2.0f, 0, 0, 1, 0);
////		m_Gl.glViewport(m_Width/2, 0, m_Width/2, m_Height);
////	
////		m_Sketch.draw();
////		m_Gl.glPopMatrix();
//		
// 	//	m_Sketch.popMatrix();
//	}
//	
//	boolean glinited = false;
//	
//	/***
//	 * 
//	 */
//	void initGL()
//	{
//		
//		glinited = true; 
//	}
//}
//
