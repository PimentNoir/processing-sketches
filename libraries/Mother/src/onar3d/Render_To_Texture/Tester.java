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
//onar3d@hotmail.com, www.onar3d.com
// 
//*/
//
//package onar3d.Render_To_Texture;
//
//import processing.core.*;
//import processing.opengl.*;
//
//import javax.media.opengl.*;
//import javax.media.opengl.glu.*;
//
///**
// * For testing rendering to texture
// *
// */
//public class Tester extends PApplet
//{
//	RenderBlurredBox m_RenderBlurredBox;
//        
//	PGraphicsOpenGL m_Pgl;
//	GL m_Gl;
//	GLU m_Glu;
//	
//	boolean m_TexturesDone = false;
//	
//	static public void main(String args[]) 
//	{
//		PApplet.main(new String[] { "onar3d.Render_To_Texture.Tester"});	
//	}
//	
//	int m_Width = 640;
//	int m_Height = 480;
//	
//	public void setup() 
//	{
//		size(m_Width, m_Height, OPENGL);		
//				
//		noStroke();
//		
//		hint(ENABLE_OPENGL_4X_SMOOTH);
//		
//		m_Pgl 	= (PGraphicsOpenGL) g; 
//		m_Gl 	= m_Pgl.gl;
//		m_Glu 	= ((PGraphicsOpenGL)g).glu;
//	}
//	
//	public void draw() 
//	{
//		m_Gl.glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // Set The Clear Color To Black
//		m_Gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT); // Clear Screen And Depth Buffer
//		
//		if(!m_TexturesDone)
//		{
//			m_RenderBlurredBox = new RenderBlurredBox(m_Width, m_Height, m_Pgl, this);
//			m_TexturesDone = true;
//		}
//		m_RenderBlurredBox.draw();		
//	}
//}