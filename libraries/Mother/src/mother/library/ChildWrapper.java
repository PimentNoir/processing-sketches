package mother.library;

import processing.core.*; 
import processing.opengl.*;

import javax.media.opengl.*;
import javax.media.opengl.glu.GLU;

import processing.opengl.*;

import foetus.Foetus;
import foetus.FoetusParameter;

import java.io.File;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;

/**
 *
 */
public class ChildWrapper
{
//	private Logger logger = null;
	
	PApplet m_Child; 
	Mother  r_Mother;
	
//	RenderSketchToTexture m_RenderToTexture;
		
	boolean m_RenderBillboard = true;
	
	// int m_Width;
	// int m_Height;
	
	int m_Blending_Source;
	int m_Blending_Destination;
	
	String m_Name;
	
	public PApplet Child()	{ return m_Child;	}
//	public PApplet Mother()	{ return r_Mother;	}
	
	public boolean GetRenderBillboard()							{ return m_RenderBillboard; }
	public void	   SetRenderBillboard(boolean renderBillboard)	{ m_RenderBillboard = renderBillboard; }
	
	public int 	GetBlending_Source()							{ return m_Blending_Source; }
	public void	SetBlending_Source(int source)					{ m_Blending_Source = source; }
	
	public int 	GetBlending_Destination()						{ return m_Blending_Destination; }
	public void	SetBlending_Destination(int dest)				{ m_Blending_Destination = dest; }
		
	public String GetName() { return m_Name; }
		
	Foetus foetusField;
		
	public Foetus 	getFoetusField()					{ return foetusField; }
	public void 	setFoetusField(Foetus foetusField)	{ this.foetusField = foetusField; }

	/**
	 *  ChildWrapper CONSTRUCTOR
	 */
	public ChildWrapper(PApplet child, String name, boolean billboard, Mother mother)
	{	
		r_Mother			= mother;
		m_Name 				= name;
		m_RenderBillboard 	= billboard;
		
		/*
	    File dir1 = new File (".");
	    try 
	    {
	      System.out.println ("Current dir : " + dir1.getCanonicalPath());
	    }
	    catch(Exception e)
	    {
	    	 
	    }
		*/
		
		m_Blending_Source 		= GL.GL_SRC_ALPHA;
		m_Blending_Destination 	= GL.GL_ONE_MINUS_SRC_ALPHA;
		
		m_Child = child;
	}
		
	/**
	 * METHODS
	 */
	
	public void draw(boolean stereo)
	{		
		if( (m_Child.g != null) /*&& (((PGraphicsOpenGL)m_Child.g).gl != null)*/ )	// Checking whether applet thread has been properly initialized
		{
			if(m_RenderBillboard)
			{
//				if( m_RenderToTexture == null)
//				{
//					m_RenderToTexture = new RenderSketchToTexture(	r_Mother.getChildWidth(), 
//																	r_Mother.getChildHeight(), 
//																	m_Child, 
//																	r_Mother,
//																	stereo);
//				}
//				
//				
//				m_RenderToTexture.draw();				
			}
			else
			{
//				logger.info("Before Draw: " + m_Name);
				
				m_Child.frameCount	= r_Mother.GetParent().frameCount;
				
				ArrayList<FoetusParameter> params = this.foetusField.getParameters();
				
				for(int pi = 0; pi < params.size(); pi++)
				{
					params.get(pi).tick();
				}
				
				PGraphicsOpenGL pgl = (PGraphicsOpenGL) m_Child.g;
				PGL opengl 			= pgl.beginPGL();
//				GLU glu 			= opengl.glu;
				
				opengl.gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
				
				m_Child.g.pushMatrix();
//				((PGraphicsOpenGL)m_Child.g).pushMatrix();				
				m_Child.draw();
				m_Child.g.popMatrix();
//				((PGraphicsOpenGL)m_Child.g).popMatrix();
				
				pgl.endPGL();
				
//				logger.info("After Draw: " + m_Name);
			}
		}
		else
		{
//			System.out.println("Applet thread not yet initialized, g == null");
			return;
		}
	}
	
	/*
	 * This worked but doesn't help much for the plugin handling: "-Djava.ext.dirs=C:\libraries"
	 */
}
