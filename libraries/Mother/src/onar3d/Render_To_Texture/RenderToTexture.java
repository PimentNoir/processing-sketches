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
//
//package onar3d.Render_To_Texture;
//
//import com.sun.opengl.util.BufferUtil;
//
//import javax.media.opengl.*;
//import javax.media.opengl.glu.*;
//import javax.swing.JOptionPane;
//
//import processing.opengl.PGraphicsOpenGL;
//
//import java.nio.ByteBuffer;
//import java.nio.IntBuffer;
//import java.util.ArrayList;
//
//import processing.core.*;
//
//
//import foetus.*;
//
//public abstract class RenderToTexture
//{
//	protected int m_Texture_Width  = 640;
//	protected int m_Texture_Height = 480;
//	
//	private int m_Texture_Coordinate_W;
//	private int m_Texture_Coordinate_H;
//	private boolean m_Texture_Rectangle_Available;
//
//	protected FoetusParameter m_R;
//	protected FoetusParameter m_G;
//	protected FoetusParameter m_B;
//	protected FoetusParameter m_A;
//	
//	public float GetR() { return m_R.getValue(); }
//	public float GetG() { return m_G.getValue(); }
//	public float GetB() { return m_B.getValue(); }
//	public float GetA() { return m_A.getValue(); }
//	
//	public void SetR(float r) { m_R.setValue(r); }
//	public void SetG(float g) { m_G.setValue(g); }
//	public void SetB(float b) { m_B.setValue(b); }
//	public void SetA(float a) { m_A.setValue(a); }
//	
//	// An Unsigned Int To Store The Texture Number
//	protected static int m_Texture;
//
//	private static int m_FrameBufferObject = -1;
//
//	private static boolean m_TextureCreated 	= false;
//	private static boolean m_FrameBufferCreated = false;
//	
//	PGraphicsOpenGL m_Pgl;
//
//	GL m_Gl;
//
//	GLU m_Glu;
//
//	int m_Width;
//	int m_Height;
//	
//	
//	GLPbuffer pbuffer;
//	
//	protected PApplet r_Mother;
//	
//	public RenderToTexture(int w, int h, PGraphicsOpenGL pgl, PApplet mother)
//	{
//		r_Mother = mother;
//		m_Width  = w;
//		m_Height = h;
//		m_Texture_Width 	= w;
//		m_Texture_Height 	= h;
//		
//		m_Pgl 	= (PGraphicsOpenGL) pgl;
//		m_Gl 	= m_Pgl.gl;
//		m_Glu 	= ((PGraphicsOpenGL) pgl).glu;
//
//		// Create Our Empty Texture
//		if(!m_TextureCreated)
//		{
//			m_Texture 			= createTexture(m_Gl);
//			m_TextureCreated 	= true;
//		}
//
//		// Commented so that offcreen rendering is performed using backbuffer instead.
//		 
//		if (m_Gl.isExtensionAvailable("GL_EXT_framebuffer_object") && !m_FrameBufferCreated)
//	    {
//			m_FrameBufferObject = createFrameBufferObject();
//			m_FrameBufferCreated = true;
//		}
//		
//		if (!GLDrawableFactory.getFactory().canCreateGLPbuffer())
//		{
//			System.out.println("Requires pbuffer support");
//			System.exit(1);
//		}
//		
//		if (m_Gl.isExtensionAvailable("GL_ARB_texture_rectangle"))
//		{
//			// Query the maximum texture size available
//			IntBuffer val = BufferUtil.newIntBuffer(1);
//			m_Gl.glGetIntegerv(GL.GL_MAX_RECTANGLE_TEXTURE_SIZE_ARB, val);			
//			System.out.println("Max rectangle texture size: " + val.get(0));
//		}
//		else
//		{
//			m_Texture_Height = m_Texture_Width;
//		}
//	}
//	/**
//	 * CONSTRUCTOR
//	 * 
//	 * @param w
//	 * @param h
//	 * @param pgl
//	 */
//	public RenderToTexture(int w, int h, PGraphicsOpenGL pgl)
//	{
//		m_Width  = w;
//		m_Height = h;
//		m_Texture_Width 	= (int)(w); // TEST
//		m_Texture_Height 	= (int)(h); // TEST
//		
//		m_Pgl 	= (PGraphicsOpenGL) pgl;
//		m_Gl 	= m_Pgl.gl;
//		m_Glu 	= ((PGraphicsOpenGL) pgl).glu;
//
//		m_R = new FoetusParameter(null, 1.0f, "", "f");
//		m_G = new FoetusParameter(null, 1.0f, "", "f");
//		m_B = new FoetusParameter(null, 1.0f, "", "f");
//		m_A = new FoetusParameter(null, 1.0f, "", "f");
//		
//		// Create Our Empty Texture
//		if(!m_TextureCreated)
//		{
//			m_Texture 			= createTexture(m_Gl);
//			m_TextureCreated 	= true;
//			System.out.println("created!");
//		}
//
//		// Commented so that offcreen rendering is performed using backbuffer instead.
//		 
//		if (m_Gl.isExtensionAvailable("GL_EXT_framebuffer_object") && !m_FrameBufferCreated)
//	    {
//			m_FrameBufferObject = createFrameBufferObject();
//			m_FrameBufferCreated = true;
//		}
//
//		if (!GLDrawableFactory.getFactory().canCreateGLPbuffer())
//		{
//			System.out.println("Requires pbuffer support");
//			System.exit(1);
//		}
//		// Use a pbuffer for rendering
//		GLCapabilities caps = new GLCapabilities();
//		caps.setDoubleBuffered(false);
//		caps.setAlphaBits(8);
//		pbuffer = GLDrawableFactory.getFactory().createGLPbuffer(caps, null, 640, 480, null);
//
//		if (m_FrameBufferObject != -1)
//		{
//			System.out.println(" using frame buffer object");
//		} 
//		else
//		{
//			System.out.println(" using default frame buffer");
//		}
//	
//		if (m_Gl.isExtensionAvailable("GL_ARB_texture_rectangle"))
//		{
//			// Query the maximum texture size available
//			IntBuffer val = BufferUtil.newIntBuffer(1);
//			m_Gl.glGetIntegerv(GL.GL_MAX_RECTANGLE_TEXTURE_SIZE_ARB, val);			
//			System.out.println("Max rectangle texture size: " + val.get(0));
//			
//			m_Texture_Coordinate_W 			= m_Texture_Width;
//			m_Texture_Coordinate_H 			= m_Texture_Height;
//			m_Texture_Rectangle_Available 	= true;
//		}
//		else
//		{
//			m_Texture_Coordinate_W 			= 1;
//			m_Texture_Coordinate_H 			= 1;
//			m_Texture_Rectangle_Available 	= false;
//			m_Texture_Height 				= m_Texture_Width;
//		}
//	}
//
//	// Create An Empty Texture
//	private int createTexture(GL gl)
//	{
//		ByteBuffer data = BufferUtil.newByteBuffer(m_Texture_Width * m_Texture_Height * 4); // Create Storage Space For
//		// Texture
//		// Data (128x128x4)
//		data.limit(data.capacity());
//
//		int[] txtnumber = new int[1];
//
//		gl.glGenTextures(1, txtnumber, 0); // Create 1 Texture
//		gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, txtnumber[0]); // Bind The Texture
//
//		// Build Texture Using Information In data
//		gl.glTexImage2D(GL.GL_TEXTURE_RECTANGLE_ARB, 0, GL.GL_RGBA, m_Texture_Width, m_Texture_Height, 0, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, data);
//		gl.glTexParameteri(GL.GL_TEXTURE_RECTANGLE_ARB, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR );
//		gl.glTexParameteri(GL.GL_TEXTURE_RECTANGLE_ARB, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR );
//
//		return txtnumber[0]; // Return The Texture ID
//	}
//
//	// Set Up an Ortho View
//	protected void viewOrtho()
//	{
//		// Select Projection
//		m_Gl.glMatrixMode(GL.GL_PROJECTION);
//		// Push The Matrix
//		m_Gl.glPushMatrix();
//		// Reset The Matrix
//		m_Gl.glLoadIdentity();
//		// Select Ortho Mode (640x480)
//		m_Gl.glOrtho(0, m_Width, m_Height, 0, -1, 1);
//		// Select Modelview Matrix
//		m_Gl.glMatrixMode(GL.GL_MODELVIEW);
//		// Push The Matrix
//		m_Gl.glPushMatrix();
//		// Reset The Matrix
//		m_Gl.glLoadIdentity();
//	}
//
//	// Set Up a Perspective View
//	protected void viewPerspective()
//	{
//		// Select Projection
//		m_Gl.glMatrixMode(GL.GL_PROJECTION);
//		// Pop The Matrix
//		m_Gl.glPopMatrix();
//		// Select Modelview
//		m_Gl.glMatrixMode(GL.GL_MODELVIEW);
//		// Pop The Matrix
//		m_Gl.glPopMatrix();
//	}
//
//	public void draw()
//	{
//		m_Pgl.pushMatrix();
//
//		// If I uncomment this, the y axis is inverted
//		// m_Gl.glLoadIdentity(); // Reset The View
//		renderToTexture(); // Render To A Texture
//
//		m_Pgl.popMatrix();
//	
//		// Checking whether processing creates an Alpha channel. It doesn't.
//		// I have now subclassed the processing OGL renderer and made it
//		// to create an Alpha channel in the rendering buffers.
////		IntBuffer val = BufferUtil.newIntBuffer(1);
////		m_Gl.glGetIntegerv(GL.GL_ALPHA_BITS, val);
////		System.out.println(val.get(0));
//		
//		drawBillboard();
//		
//		// Flush The GL Rendering Pipeline
//		m_Gl.glFlush();
//	}
//
//	protected abstract void drawGeometry();
//	
//	/**
//	 * Renders To A Texture
//	 */
//	private void renderToTexture()
//	{
//		if (m_FrameBufferObject != -1)
//		{
//			// Bind the fbo
//			m_Gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, m_FrameBufferObject);
//		}
//		
//		// Set Our Viewport (Match Texture Size)
//		m_Gl.glViewport(0, 0, m_Texture_Width, m_Texture_Height);
//
//    	drawGeometry();
//
//		// Copy Our ViewPort To The Blur Texture (From 0,0 To 128,128... No Border)
//		m_Gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, m_Texture);
//		m_Gl.glCopyTexImage2D(GL.GL_TEXTURE_RECTANGLE_ARB, 0, GL.GL_RGBA, 0, 0, m_Texture_Width, m_Texture_Height, 0);
//		
//		// Clear the frame buffer (either the default frame buffer or the fbo)
//		m_Gl.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
//		m_Gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
//		
//		// Restore the viewport (0,0 to 640x480)
//		m_Gl.glViewport(0, 0, m_Width, m_Height);
//		
//		if (m_FrameBufferObject != -1)
//		{
//			// If we used the fbo, restore the default frame buffer
//			m_Gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, 0);
//		}
//	}
//
//	// Draw The Image
//	public void drawBillboard()
//	{
//		// Disable AutoTexture Coordinates
//		m_Gl.glDisable(GL.GL_TEXTURE_GEN_S);
//		m_Gl.glDisable(GL.GL_TEXTURE_GEN_T);
//
//		/*if(i==1)
//		{
//			m_Pgl.pushMatrix();
//			m_Pgl.color(1.0f, 1.0f, 1.0f, 1.0f);
//			m_Gl.glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
//	    	m_Gl.glTranslatef((m_Width/2.0f),(m_Height/2.0f) , 0f);
//	    	m_Pgl.box(100);
//	    	m_Pgl.popMatrix();
//		}*/
//		
//		// Disable Depth Testing
//		m_Gl.glDisable(GL.GL_DEPTH_TEST);
//		m_Gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
//		 
//		m_Gl.glEnable(GL.GL_BLEND);
//			
//		// Enable 2D Texture Mapping
//		m_Gl.glEnable(GL.GL_TEXTURE_RECTANGLE_ARB);
//
//		// Bind To The Texture
//		m_Gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, m_Texture);
//			
//		// Switch To An Ortho View
//		viewOrtho();
//		
//		m_Gl.glPushMatrix();
//
//		m_Gl.glColor4f(1, 1, 1, 1);
//		
////		m_Gl.glColor4f(m_R.getValue(), m_G.getValue(), m_B.getValue(), m_A.getValue());
//		
//		m_Gl.glBegin(GL.GL_QUADS);
//		
//		// Texture Coordinate ( 0, 1 )
//		m_Gl.glTexCoord2f(0, m_Texture_Height);
//		// First Vertex ( 0, 0 )
//		m_Gl.glVertex2f(0, 0);
//		// Texture Coordinate ( 0, 0 )
//		m_Gl.glTexCoord2f(0, 0);
//		// Second Vertex ( 0, height )
//		m_Gl.glVertex2f(0, m_Height);
//		// Texture Coordinate ( 1, 0 )
//		m_Gl.glTexCoord2f(m_Texture_Width, 0);
//		// Third Vertex ( width, height )
//		m_Gl.glVertex2f(m_Width, m_Height);
//		// Texture Coordinate ( 1, 1 )
//		m_Gl.glTexCoord2f(m_Texture_Width, m_Texture_Height);
//		// Fourth Vertex ( width, 0 )
//		m_Gl.glVertex2f(m_Width, 0);
//
//		m_Gl.glEnd();
//		m_Gl.glPopMatrix();
//
//		m_Gl.glColor4f(1, 1, 1, 1);
//		
//		m_Gl.glDisable(GL.GL_BLEND);
//		
//		// Switch To A Perspective View
//		viewPerspective();
//    	
//		// Enable Depth Testing
//		m_Gl.glEnable(GL.GL_DEPTH_TEST);
//		
//		// Disable 2D Texture Mapping
//		m_Gl.glDisable(GL.GL_TEXTURE_RECTANGLE_ARB);
//
//		// Unbind The Blur Texture
//		m_Gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, 0);
//	}
//
//	/**
//	 * Creates a frame buffer object.
//	 * 
//	 * @return the newly created frame buffer object is or -1 if a frame buffer object could not be created
//	 */
//	private int createFrameBufferObject()
//	{
//		// Create the FBO
//		int[] frameBuffer = new int[1];
//
//		m_Gl.glGenFramebuffersEXT(1, frameBuffer, 0);
//		m_Gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, frameBuffer[0]);
//
//		// Create a TEXTURE_SIZE x TEXTURE_SIZE RGBA texture that will be used as color attachment
//		// for the fbo.
//		int[] colorBuffer = new int[1];
//
//		// Create 1 Texture
//		m_Gl.glGenTextures(1, colorBuffer, 0);
//
//		// Bind The Texture
//		m_Gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, colorBuffer[0]);
//		
//		// Build Texture Using Information In data
//		m_Gl.glTexImage2D(
//				GL.GL_TEXTURE_RECTANGLE_ARB, 
//				0, 
//				GL.GL_RGBA, 
//				m_Texture_Width, 
//				m_Texture_Height, 
//				0, 
//				GL.GL_RGBA, 
//				GL.GL_UNSIGNED_BYTE, 
//				BufferUtil.newByteBuffer(m_Texture_Width * m_Texture_Height * 4));
//		
//		// Attach the texture to the frame buffer as the color attachment. This
//		// will cause the results of rendering to the FBO to be written in the blur texture.
//		m_Gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_TEXTURE_RECTANGLE_ARB, colorBuffer[0], 0);
//
//		m_Gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, 0);
//		
//		// Create a 24-bit TEXTURE_SIZE x TEXTURE_SIZE depth buffer for the FBO.
//		// We need this to get correct rendering results.
//		int[] depthBuffer = new int[1];
//		m_Gl.glGenRenderbuffersEXT(1, depthBuffer, 0);
//		m_Gl.glBindRenderbufferEXT(GL.GL_RENDERBUFFER_EXT, depthBuffer[0]);
//		m_Gl.glRenderbufferStorageEXT(GL.GL_RENDERBUFFER_EXT, GL.GL_DEPTH_COMPONENT24, m_Texture_Width, m_Texture_Height);
//
//		// Attach the newly created depth buffer to the FBO.
//		m_Gl.glFramebufferRenderbufferEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_DEPTH_ATTACHMENT_EXT, GL.GL_RENDERBUFFER_EXT, depthBuffer[0]);
//
//		// Make sure the framebuffer object is complete (i.e. set up correctly)
//		int status = m_Gl.glCheckFramebufferStatusEXT(GL.GL_FRAMEBUFFER_EXT);
//
//		if (status == GL.GL_FRAMEBUFFER_COMPLETE_EXT)
//		{
//			return frameBuffer[0];
//		} else
//		{
//			// No matter what goes wrong, we simply delete the frame buffer object
//			// This switch statement simply serves to list all possible error codes
//			switch (status)
//			{
//			// case GL.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
//			// One of the attachments is incomplete
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
//				// Not all attachments have the same size
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
//				// The desired read buffer has no attachment
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
//				// The desired draw buffer has no attachment
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
//				// Not all color attachments have the same internal format
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
//				// No attachments have been attached
//			case GL.GL_FRAMEBUFFER_UNSUPPORTED_EXT:
//				// The combination of internal formats is not supported
//			case GL.GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT:
//				// This value is no longer in the EXT_framebuffer_object specification
//			default:
//				// Delete the color buffer texture
//				m_Gl.glDeleteTextures(1, colorBuffer, 0);
//				// Delete the depth buffer
//				m_Gl.glDeleteRenderbuffersEXT(1, depthBuffer, 0);
//				// Delete the FBO
//				m_Gl.glDeleteFramebuffersEXT(1, frameBuffer, 0);
//				return -1;
//			}
//		}
//	}
//
//}
