//package onar3d.Render_To_Texture;
//
//import java.awt.*;
//import java.awt.event.*;
//import javax.media.opengl.*;
//
//import com.sun.opengl.util.*;
//
///**
// * Gears.java <BR>
// * author: Brian Paul (converted to Java by Ron Cemer and Sven Goethel) <P>
// *
// * This version is equal to Brian Paul's version 1.2 1999/10/21
// */
//
//public class Gears implements GLEventListener, MouseListener, MouseMotionListener
//{	
//	protected static int[] mfbo = {0};
//	protected static int[] colorBuffer = {0};
//	protected static int[] depthBuffer = {0};
//	protected static int[] fbo = {0};
//	protected static int[] texture = {0};
//	
////	protected int m_OGL_PixelFormat = GL.GL_RGBA16F_ARB;
//	protected int m_multisamples = 4;
//
//	int m_Texture_Width = 640;
//	int m_Texture_Height = 640;
//	
//	public static void main(String[] args)
//	{
//		Frame frame = new Frame("Gear Demo");
//		GLCanvas canvas = new GLCanvas();
//
//		canvas.addGLEventListener(new Gears());
//		frame.add(canvas);
//		frame.setSize(640, 640);
//		final Animator animator = new Animator(canvas);
//		
//		frame.addWindowListener(new WindowAdapter()
//		{
//			public void windowClosing(WindowEvent e)
//			{
//				// Run this on another thread than the AWT event queue to
//				// make sure the call to Animator.stop() completes before
//				// exiting
//				new Thread(new Runnable()
//				{
//					public void run()
//					{
//						animator.stop();
//						System.exit(0);
//					}
//				}).start();
//			}
//		});
//		frame.show();
//		animator.start();
//	}
//
//	private float view_rotx = 20.0f, view_roty = 30.0f, view_rotz = 0.0f;
//
//	private int gear1, gear2, gear3;
//
//	private float angle = 0.0f;
//
//	private int prevMouseX, prevMouseY;
//
//	private boolean mouseRButtonDown = false;
//
//	public void init(GLAutoDrawable drawable)
//	{
//		// Use debug pipeline
//		//drawable.setGL(new DebugGL(drawable.getGL()));
//
//		GL gl = drawable.getGL();
//
//		System.err.println("INIT GL IS: " + gl.getClass().getName());
//
//		System.err.println("Chosen GLCapabilities: " + drawable.getChosenGLCapabilities());
//
//		gl.setSwapInterval(1);
//
//		float pos[] = { 5.0f, 5.0f, 10.0f, 0.0f };		
//		float green[] = { 0.0f, 0.8f, 0.2f, 1.0f };
//
//		gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, pos, 0);
//		gl.glEnable(GL.GL_CULL_FACE);
//		gl.glEnable(GL.GL_LIGHTING);
//		gl.glEnable(GL.GL_LIGHT0);
//		gl.glEnable(GL.GL_DEPTH_TEST);
//
//		/* make the gears */
//
//		gear2 = gl.glGenLists(1);
//		gl.glNewList(gear2, GL.GL_COMPILE);
//		gl.glMaterialfv(GL.GL_FRONT, GL.GL_AMBIENT_AND_DIFFUSE, green, 0);
//		gear(gl, 0.5f, 2.0f, 2.0f, 10, 0.7f);
//		gl.glEndList();
//
//		gl.glEnable(GL.GL_NORMALIZE);
//
//		drawable.addMouseListener(this);
//		drawable.addMouseMotionListener(this);
//		
//	//	gl.glEnable(GL.GL_TEXTURE_2D);
//	
//		gl.glGenRenderbuffersEXT(1, colorBuffer, 0);
//		gl.glBindRenderbufferEXT(GL.GL_RENDERBUFFER_EXT, colorBuffer[0]); // Binding render buffer		
//		gl.glRenderbufferStorageMultisampleEXT(GL.GL_RENDERBUFFER_EXT, m_multisamples, GL.GL_RGBA8, m_Texture_Width, m_Texture_Height);
//		
//		// Creating handle for depth buffer
//		gl.glGenRenderbuffersEXT(1, depthBuffer, 0);
//		gl.glBindRenderbufferEXT(GL.GL_RENDERBUFFER_EXT, depthBuffer[0]); // Binding depth buffer
//		// Allocating space for multisampled depth buffer
//		gl.glRenderbufferStorageMultisampleEXT(GL.GL_RENDERBUFFER_EXT, m_multisamples, GL.GL_DEPTH_COMPONENT, m_Texture_Width, m_Texture_Height);
//	
//		// Creating handle for FBO
//		gl.glGenFramebuffersEXT(1, mfbo, 0);
//		gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, mfbo[0]);		// Binding FBO
//		gl.glFramebufferRenderbufferEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_RENDERBUFFER_EXT, colorBuffer[0]);
//		gl.glFramebufferRenderbufferEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_DEPTH_ATTACHMENT_EXT, GL.GL_RENDERBUFFER_EXT, depthBuffer[0]);
//			
//		// Creating texture
//		gl.glGenTextures(1, texture, 0);
//		gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, texture[0]);
//		gl.glTexImage2D(GL.GL_TEXTURE_RECTANGLE_ARB, 0, GL.GL_RGBA, m_Texture_Width, m_Texture_Height, 0, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, null);
//		
//		// Creating actual resolution FBO
//		gl.glGenFramebuffersEXT(1, fbo, 0);
//		gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, fbo[0]);
//		// Attaching texture to FBO
//		gl.glFramebufferTexture2DEXT(GL.GL_FRAMEBUFFER_EXT, GL.GL_COLOR_ATTACHMENT0_EXT, GL.GL_TEXTURE_RECTANGLE_ARB, texture[0], 0);
//		
//		int status = gl.glCheckFramebufferStatusEXT(GL.GL_FRAMEBUFFER_EXT);
//		
//		if(status == GL.GL_FRAMEBUFFER_COMPLETE_EXT)
//		{
//			System.out.println("GL_FRAMEBUFFER_EXT Status Complete:" + status);
//		}
//		else
//		{
//			System.out.println("GL_FRAMEBUFFER_EXT Status Not complete... " + status);
//		}
//	}
//
//	public void reshape(GLAutoDrawable drawable, int x, int y, int width, int height)
//	{
//		GL gl = drawable.getGL();
//
//		float h = (float) height / (float) width;
//
//		gl.glMatrixMode(GL.GL_PROJECTION);
//
//		System.err.println("GL_VENDOR: " + gl.glGetString(GL.GL_VENDOR));
//		System.err.println("GL_RENDERER: " + gl.glGetString(GL.GL_RENDERER));
//		System.err.println("GL_VERSION: " + gl.glGetString(GL.GL_VERSION));
//		gl.glLoadIdentity();
//		gl.glFrustum(-1.0f, 1.0f, -h, h, 5.0f, 60.0f);
//		gl.glMatrixMode(GL.GL_MODELVIEW);
//		gl.glLoadIdentity();
//		gl.glTranslatef(0.0f, 0.0f, -40.0f);
//	}
//
//	public void display(GLAutoDrawable drawable)
//	{
//		
//		// Turn the gears' teeth
//		angle += 0.1f;
//
//		// Get the GL corresponding to the drawable we are animating
//		GL gl = drawable.getGL();
//	
//		// First draw the multisampled scene
//		gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, mfbo[0]);
//		
//		gl.glPushAttrib(GL.GL_VIEWPORT_BIT);
//		
//		gl.glViewport(0, 0, m_Texture_Width, m_Texture_Height);
//
//		gl.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
//		gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
//		
//		//-----------------------------
//	
//		drawGears(drawable);
//	
//		// ------------
//		
//		gl.glPopAttrib();
//
//		// Then downsample the multisampled to the normal buffer with a blit
//
//		gl.glBindFramebufferEXT(GL.GL_READ_FRAMEBUFFER_EXT, mfbo[0]); // source
//		gl.glBindFramebufferEXT(GL.GL_DRAW_FRAMEBUFFER_EXT, fbo[0]); // dest
//		gl.glBlitFramebufferEXT(0, 0, m_Texture_Width, m_Texture_Height, 0, 0, m_Texture_Width, m_Texture_Height, GL.GL_COLOR_BUFFER_BIT, GL.GL_NEAREST);
//	
//		gl.glBindFramebufferEXT(GL.GL_FRAMEBUFFER_EXT, 0);
//		
//		//gl.glActiveTexture(GL.GL_TEXTURE0);
//		
//		gl.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
//		gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);	
//		
//		drawBillboard(texture, m_Texture_Width, m_Texture_Height, drawable);
//		
//		drawGears(drawable);
//	}
//
//	private void drawGears(GLAutoDrawable drawable)
//	{	
//		// Get the GL corresponding to the drawable we are animating
//		GL gl = drawable.getGL();
//
//		float pos[] = { 5.0f, 5.0f, 10.0f, 0.0f };
//	
//		gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, pos, 0);
//		gl.glEnable(GL.GL_CULL_FACE);
//		gl.glEnable(GL.GL_LIGHTING);
//		gl.glEnable(GL.GL_LIGHT0);
//		gl.glEnable(GL.GL_DEPTH_TEST);
//		
//		// Rotate the entire assembly of gears based on how the user
//		// dragged the mouse around
//		gl.glPushMatrix();
//		
//			gl.glRotatef(view_rotx, 1.0f, 0.0f, 0.0f);
//			gl.glRotatef(view_roty, 0.0f, 1.0f, 0.0f);
//			gl.glRotatef(view_rotz, 0.0f, 0.0f, 1.0f);
//	
//			// Place the second gear and call its display list
//			gl.glPushMatrix();
//				gl.glTranslatef(3.1f, -2.0f, 0.0f);
//				gl.glRotatef(-2.0f * angle - 9.0f, 0.0f, 0.0f, 1.0f);
//				gl.glCallList(gear2);
//			gl.glPopMatrix();
//
//		gl.glPopMatrix();
//	}
//	
//	public void drawBillboard(int[] texture, int width, int height, GLAutoDrawable drawable)
//	{
//		//System.out.println("Drawing billboard");
//		
//		// Get the GL corresponding to the drawable we are animating
//		GL gl = drawable.getGL();
//		
//		// Disable AutoTexture Coordinates
//		gl.glDisable(GL.GL_TEXTURE_GEN_S);
//		gl.glDisable(GL.GL_TEXTURE_GEN_T);
//		
//		// Disable Depth Testing
//		gl.glDisable(GL.GL_DEPTH_TEST);
//		gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
//		 
//		gl.glEnable(GL.GL_BLEND);
//
//		gl.glDisable(GL.GL_LIGHTING);
//		
//		// Enable 2D Texture Mapping
//		gl.glEnable(GL.GL_TEXTURE_RECTANGLE_ARB);
//		
//		// Bind To The Texture
//		gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, texture[0]);
//				
//		// Switch To An Ortho View
//		viewOrtho(drawable);
//		
//		gl.glPushMatrix();
//		
//		gl.glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
//		
//		// Dislocating billboard so that i can see it behind gear. 
//		gl.glTranslatef(-width/4, -height/4, 0);
//		
//		gl.glBegin(GL.GL_QUADS);
//		
//		// Texture Coordinate ( 0, 1 )
//		gl.glTexCoord2f(0, m_Texture_Height);
//		// First Vertex ( 0, 0 )
//		gl.glVertex2f(0, 0);
//		// Texture Coordinate ( 0, 0 )
//		gl.glTexCoord2f(0, 0);
//		// Second Vertex ( 0, height )
//		gl.glVertex2f(0, height);
//		// Texture Coordinate ( 1, 0 )
//		gl.glTexCoord2f(m_Texture_Width, 0);
//		// Third Vertex ( width, height )
//		gl.glVertex2f(width, height);
//		// Texture Coordinate ( 1, 1 )
//		gl.glTexCoord2f(m_Texture_Width, m_Texture_Height);
//		// Fourth Vertex ( width, 0 )
//		gl.glVertex2f(width, 0);
//
//		gl.glEnd();
//		gl.glPopMatrix();
//		
//		gl.glDisable(GL.GL_BLEND);
//		
//		// Switch To A Perspective View
//		viewPerspective(drawable);
//    			
//		// Enable Depth Testing
//		gl.glEnable(GL.GL_DEPTH_TEST);
//		
//		// Disable 2D Texture Mapping
//		gl.glDisable(GL.GL_TEXTURE_RECTANGLE_ARB);
//
//		// Unbind The Blur Texture
//		gl.glBindTexture(GL.GL_TEXTURE_RECTANGLE_ARB, 0);
//	}
//	
//	// Set Up an Ortho View
//	protected void viewOrtho( GLAutoDrawable drawable)
//	{
//		// Get the GL corresponding to the drawable we are animating
//		GL gl = drawable.getGL();
//		
//		// Select Projection
//		gl.glMatrixMode(GL.GL_PROJECTION);
//		// Push The Matrix
//		gl.glPushMatrix();
//		// Reset The Matrix
//		gl.glLoadIdentity();
//		// Select Ortho Mode 
//		gl.glOrtho(0, m_Texture_Width, m_Texture_Height, 0, -1, 1);
//		// Select Modelview Matrix
//		gl.glMatrixMode(GL.GL_MODELVIEW);
//		// Push The Matrix
//		gl.glPushMatrix();
//		// Reset The Matrix
//		gl.glLoadIdentity();
//	}
//
//	// Set Up a Perspective View
//	protected void viewPerspective( GLAutoDrawable drawable)
//	{
//		// Get the GL corresponding to the drawable we are animating
//		GL gl = drawable.getGL();
//		
//		// Select Projection
//		gl.glMatrixMode(GL.GL_PROJECTION);
//		// Pop The Matrix
//		gl.glPopMatrix();
//		// Select Modelview
//		gl.glMatrixMode(GL.GL_MODELVIEW);
//		// Pop The Matrix
//		gl.glPopMatrix();
//	}
//	
//	public void displayChanged(GLAutoDrawable drawable, boolean modeChanged, boolean deviceChanged)
//	{
//	}
//
//	public static void gear(GL gl, float inner_radius, float outer_radius, float width, int teeth, float tooth_depth)
//	{
//		int i;
//		float r0, r1, r2;
//		float angle, da;
//		float u, v, len;
//
//		r0 = inner_radius;
//		r1 = outer_radius - tooth_depth / 2.0f;
//		r2 = outer_radius + tooth_depth / 2.0f;
//
//		da = 2.0f * (float) Math.PI / teeth / 4.0f;
//
//		gl.glShadeModel(GL.GL_FLAT);
//
//		gl.glNormal3f(0.0f, 0.0f, 1.0f);
//
//		/* draw front face */
//		gl.glBegin(GL.GL_QUAD_STRIP);
//		for (i = 0; i <= teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), width * 0.5f);
//			if (i < teeth)
//			{
//				gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), width * 0.5f);
//				gl.glVertex3f(r1 * (float) Math.cos(angle + 3.0f * da), r1 * (float) Math.sin(angle + 3.0f * da), width * 0.5f);
//			}
//		}
//		gl.glEnd();
//
//		/* draw front sides of teeth */
//		gl.glBegin(GL.GL_QUADS);
//		for (i = 0; i < teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + da), r2 * (float) Math.sin(angle + da), width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + 2.0f * da), r2 * (float) Math.sin(angle + 2.0f * da), width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle + 3.0f * da), r1 * (float) Math.sin(angle + 3.0f * da), width * 0.5f);
//		}
//		gl.glEnd();
//
//		/* draw back face */
//		gl.glBegin(GL.GL_QUAD_STRIP);
//		for (i = 0; i <= teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), -width * 0.5f);
//			gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), -width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle + 3 * da), r1 * (float) Math.sin(angle + 3 * da), -width * 0.5f);
//			gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), -width * 0.5f);
//		}
//		gl.glEnd();
//
//		/* draw back sides of teeth */
//		gl.glBegin(GL.GL_QUADS);
//		for (i = 0; i < teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glVertex3f(r1 * (float) Math.cos(angle + 3 * da), r1 * (float) Math.sin(angle + 3 * da), -width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + 2 * da), r2 * (float) Math.sin(angle + 2 * da), -width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + da), r2 * (float) Math.sin(angle + da), -width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), -width * 0.5f);
//		}
//		gl.glEnd();
//
//		/* draw outward faces of teeth */
//		gl.glBegin(GL.GL_QUAD_STRIP);
//		for (i = 0; i < teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle), r1 * (float) Math.sin(angle), -width * 0.5f);
//			u = r2 * (float) Math.cos(angle + da) - r1 * (float) Math.cos(angle);
//			v = r2 * (float) Math.sin(angle + da) - r1 * (float) Math.sin(angle);
//			len = (float) Math.sqrt(u * u + v * v);
//			u /= len;
//			v /= len;
//			gl.glNormal3f(v, -u, 0.0f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + da), r2 * (float) Math.sin(angle + da), width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + da), r2 * (float) Math.sin(angle + da), -width * 0.5f);
//			gl.glNormal3f((float) Math.cos(angle), (float) Math.sin(angle), 0.0f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + 2 * da), r2 * (float) Math.sin(angle + 2 * da), width * 0.5f);
//			gl.glVertex3f(r2 * (float) Math.cos(angle + 2 * da), r2 * (float) Math.sin(angle + 2 * da), -width * 0.5f);
//			u = r1 * (float) Math.cos(angle + 3 * da) - r2 * (float) Math.cos(angle + 2 * da);
//			v = r1 * (float) Math.sin(angle + 3 * da) - r2 * (float) Math.sin(angle + 2 * da);
//			gl.glNormal3f(v, -u, 0.0f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle + 3 * da), r1 * (float) Math.sin(angle + 3 * da), width * 0.5f);
//			gl.glVertex3f(r1 * (float) Math.cos(angle + 3 * da), r1 * (float) Math.sin(angle + 3 * da), -width * 0.5f);
//			gl.glNormal3f((float) Math.cos(angle), (float) Math.sin(angle), 0.0f);
//		}
//		gl.glVertex3f(r1 * (float) Math.cos(0), r1 * (float) Math.sin(0), width * 0.5f);
//		gl.glVertex3f(r1 * (float) Math.cos(0), r1 * (float) Math.sin(0), -width * 0.5f);
//		gl.glEnd();
//
//		gl.glShadeModel(GL.GL_SMOOTH);
//
//		/* draw inside radius cylinder */
//		gl.glBegin(GL.GL_QUAD_STRIP);
//		for (i = 0; i <= teeth; i++)
//		{
//			angle = i * 2.0f * (float) Math.PI / teeth;
//			gl.glNormal3f(-(float) Math.cos(angle), -(float) Math.sin(angle), 0.0f);
//			gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), -width * 0.5f);
//			gl.glVertex3f(r0 * (float) Math.cos(angle), r0 * (float) Math.sin(angle), width * 0.5f);
//		}
//		gl.glEnd();
//	}
//
//	// Methods required for the implementation of MouseListener
//	public void mouseEntered(MouseEvent e)
//	{
//	}
//
//	public void mouseExited(MouseEvent e)
//	{
//	}
//
//	public void mousePressed(MouseEvent e)
//	{
//		prevMouseX = e.getX();
//		prevMouseY = e.getY();
//		if ((e.getModifiers() & e.BUTTON3_MASK) != 0)
//		{
//			mouseRButtonDown = true;
//		}
//	}
//
//	public void mouseReleased(MouseEvent e)
//	{
//		if ((e.getModifiers() & e.BUTTON3_MASK) != 0)
//		{
//			mouseRButtonDown = false;
//		}
//	}
//
//	public void mouseClicked(MouseEvent e)
//	{
//	}
//
//	// Methods required for the implementation of MouseMotionListener
//	public void mouseDragged(MouseEvent e)
//	{
//		int x = e.getX();
//		int y = e.getY();
//		Dimension size = e.getComponent().getSize();
//
//		float thetaY = 360.0f * ((float) (x - prevMouseX) / (float) size.width);
//		float thetaX = 360.0f * ((float) (prevMouseY - y) / (float) size.height);
//
//		prevMouseX = x;
//		prevMouseY = y;
//
//		view_rotx += thetaX;
//		view_roty += thetaY;
//	}
//
//	public void mouseMoved(MouseEvent e)
//	{
//	}
//}
