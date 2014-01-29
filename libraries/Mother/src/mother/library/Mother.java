/**
 * Mother
 * A library for live visuals performance with Processing sketches
 * http://www.onar3d.com/mother
 *
 * Copyright (c) 2008-2013 Ilias Bergstrom http://www.onar3d.com
 *
 * Mother is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * Foobar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Mother.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * 
 * @author      Ilias Bergstrom http://www.onar3d.com
 * @modified    08/08/2013
 * @version     1.0.0 (1)
 */

package mother.library;

import processing.core.*;
import processing.opengl.*;
import oscP5.*;
import mpe.config.FileParser;

import javax.media.opengl.*;
import javax.media.opengl.glu.*;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;
import com.illposed.osc.OSCPortOut;

import java.text.NumberFormat;
import java.util.*;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Rectangle;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.*;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

import foetus.*;

public class Mother
{
	public final static String VERSION = "1.0.0";
	
	private int 			m_osc_send_port;
	private int 			m_osc_receive_port;
	private String 			m_IP;
	private SynthContainer 	m_SynthContainer;
	private String 			m_Synth_Folder;
	private int 			m_Width;
	private int 			m_Height;
	private FileParser 		fp;
	private PrintWriter 	output;
	private boolean 		m_FullScreen;
	private boolean 		m_WriteImage = false;
	private float 			m_FrameRate = 30f;
	private String 			m_ImageFolder;
	private float 			m_SpeedFraction;
	private boolean 		firstProfiledFrame; // Frames-per-second computation
	private int 			profiledFrameCount;
	private long 			startTimeMillis;
	private boolean 		m_Stereo;
	private boolean 		m_Billboard;
		
	static boolean 			first_run = true; 	// For debugging crash with registered methods.
	
	ArrayList<Message> m_MessageStack;

	public float 	getSpeedFraction()	{	return m_SpeedFraction;	}
	public boolean	getBillboardFlag()	{	return m_Billboard; }

	PApplet r_Parent;
	
	PApplet GetParent() { return r_Parent; }
	
	public Mother(PApplet parent)
	{
		r_Parent = parent;
	}
	
	public int getChildWidth()
	{
		if(m_Stereo)
			return m_Width/2;
		else
			return m_Width;
	}
	
	public int getChildHeight()
	{
		return m_Height;
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * @see processing.core.PApplet#setup()
	 */
	public void setup()
	{
		if(first_run)
		{
			r_Parent.registerMethod("dispose", this);
			r_Parent.registerMethod("pre", this);
			r_Parent.registerMethod("post", this);
			first_run=false;
		}

		r_Parent.size(m_Width, m_Height, r_Parent.P3D);
		
		r_Parent.frameRate(m_FrameRate / m_SpeedFraction);

		m_SynthContainer = new SynthContainer(m_Synth_Folder);

		m_MessageStack = new ArrayList<Message>();

		listenToOSC();

		PGraphicsOpenGL pgl = (PGraphicsOpenGL) r_Parent.g;
		PGL 			gl 	= pgl.beginPGL();
		GL2 			gl2	= gl.gl.getGL2();
				
		gl2.setSwapInterval(1); // set vertical sync on
		
		pgl.endPGL();
	}

	public void pre() 	
	{
		
	}

	public void post()	
	{
		
	}

	public void dispose()	
	{
		System.out.println("Disposed of."); 
	}

	/*
	 * 
	 */
	private void PreDrawChildUpdate(PApplet child)
	{
		child.mouseX 		= r_Parent.mouseX;
		child.mouseY 		= r_Parent.mouseY;
		child.mousePressed 	= r_Parent.mousePressed;
		child.keyPressed 	= r_Parent.keyPressed;
		child.key 			= r_Parent.key;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see processing.core.PApplet#draw()
	 */
	public void draw()
	{		
		ChildWrapper current;
	
		dealWithMessageStack(); // Dealing with message stack

		PGraphicsOpenGL pgl = (PGraphicsOpenGL) r_Parent.g;
		PGL 			gl 	= pgl.beginPGL();
		GL2 			gl2 = gl.gl.getGL2();
		
		gl2.glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // Set The Clear Color To Black
		gl2.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

		synchronized (m_SynthContainer)
		{
			for (int i = 0; i < m_SynthContainer.Synths().size(); i++)
			{
				current = (ChildWrapper) m_SynthContainer.Synths().get(i);

				PreDrawChildUpdate(current.Child());

				callRegisteredMethod(current, "pre");

				gl2.glEnable(GL.GL_BLEND);
				// opengl.glDisable(GL.GL_DEPTH_TEST); // Disables Depth Testing

				// //For testing (getting opengl state)
				// IntBuffer arg1 = IntBuffer.allocate(1);
				// opengl.glGetIntegerv(GL.GL_BLEND_DST, arg1);
				// println(arg1.get(0));

				pgl.colorMode(r_Parent.RGB, 255);

				r_Parent.pushMatrix();

				gl2.glBlendFunc(current.GetBlending_Source(), current.GetBlending_Destination());

				r_Parent.pushStyle();
					
				gl2.glPushAttrib(GL2.GL_ALL_ATTRIB_BITS);
					
				current.draw(m_Stereo);

				callRegisteredMethod(current, "draw");

				gl2.glPopAttrib();
					
				r_Parent.popStyle();

				r_Parent.popMatrix();

				gl2.glDisable(GL.GL_BLEND);

				callRegisteredMethod(current, "post");
			}
		}

		// float m = millis(); // For timing image recording
		handleImageRecording();
		// System.out.println(millis()-m);

		pgl.endPGL();
		
		printFrameRate();
	}

	protected void finalize()
	{
		System.out.println("FINALIZING");
		output.flush(); // Write the remaining data
		output.close(); // Finish the file
	}

	public void keyPressed()
	{
		PApplet child;
		Method keyMethod;

		switch (r_Parent.key)
		{
		case 'r':
			m_WriteImage = !m_WriteImage;
			break;
		}

		// For forwarding keyPressed messages to synths. Not really necessary though as all
		// communication is supposed to be over OSC.

		for (int i = 0; i < m_SynthContainer.Synths().size(); i++)
		{
			child = ((ChildWrapper) m_SynthContainer.Synths().get(i)).Child();

			// Handling messages to synths
			try
			{
				child.keyEvent 	= r_Parent.keyEvent;
				child.key 		= r_Parent.key;
				child.keyCode 	= r_Parent.keyCode;

				keyMethod = child.getClass().getMethod("keyPressed", new Class[] {});
				keyMethod.invoke(child, new Object[] {});
			}
			catch (Exception e)
			{
				r_Parent.println("CRASH keyPressed" + e.getMessage());
			}
		}
	}

	public void motherAcceptMessage(Date time, OSCMessage message)
	{
		Message m;

		synchronized (m_MessageStack)
		{
			m 			= new Message();
			m.time 		= time;
			m.message 	= message;

			m_MessageStack.add(m);

			if (m_MessageStack.size() > 5000)
			{
				System.out.println("Clearing message stack");
				m_MessageStack.clear();
			}
		}
	}

	/*
	 * incoming osc message are forwarded to the oscEvent method.
	 */
	public void oscEvent(OscMessage theOscMessage)
	{
		PApplet child;
		Method oscEventMethod;

		String addrPattern 	= theOscMessage.addrPattern();
//		String typetag 		= theOscMessage.typetag();
		String[] splits 	= addrPattern.split("/");

		/* check if theOscMessage has the address pattern we are looking for. */
		if (splits.length >= 2 && (splits[1].compareTo("Mother") == 0))
		{
			synchronized (m_SynthContainer)
			{
				if (splits[2].compareTo("Get_synth_names") == 0)
				{
					OSCPortOut sender;
					try
					{
						InetAddress ip = InetAddress.getByName(m_IP);
						sender = new OSCPortOut(ip, m_osc_send_port);

						ArrayList<String> list = new ArrayList<String>();
						for (Enumeration<String> e = m_SynthContainer.get_Synth_Names().keys(); e.hasMoreElements();)
						{
							list.add(e.nextElement());
						}

						Object args[] = new Object[list.size()];

						for (int i = 0; i < list.size(); i++)
						{
							args[i] = list.get(i);
						}

						OSCMessage msg = new OSCMessage("/Synth_names", args);

						sender.send(msg);
					}
					catch (UnknownHostException e1)
					{
						e1.printStackTrace();
					}
					catch (SocketException e1)
					{
						e1.printStackTrace();
					}
					catch (IOException e)
					{
						e.printStackTrace();
					}
				}
				else if (splits[2].compareTo("Add_synth") == 0)
				{
					if (theOscMessage.checkTypetag("ss"))
					{
						if (!m_SynthContainer.contains(theOscMessage.get(1).stringValue()))
						{
							r_Parent.println("redraw no longer set to false!");
//							r_Parent.redraw = false;
							r_Parent.noLoop();

							ChildWrapper wrapper = m_SynthContainer.Add(	theOscMessage.get(1).stringValue(), 
																			theOscMessage.get(0).stringValue(), 
																			this);

							if(wrapper!=null) {
								sendSupportedMessages(wrapper);
							}

							r_Parent.loop();
//							this.redraw = true;
							r_Parent.println("redraw no longer set to true!");							
						}
					}
				}
				else if (splits[2].compareTo("Reset") == 0)
				{
					m_SynthContainer.reset();
				}
				else if (splits[2].compareTo("Remove_synth") == 0)
				{
					if (theOscMessage.checkTypetag("s"))
					{
						ChildWrapper w = m_SynthContainer.Remove(theOscMessage.get(0).stringValue());

						callRegisteredMethod(w, "dispose");
					}
				}
				else if (splits[2].compareTo("Move_synth") == 0)
				{
					if (theOscMessage.checkTypetag("si"))
					{
						m_SynthContainer.Move(theOscMessage.get(0).stringValue(), theOscMessage.get(1).intValue());
					}
				}
				else if (splits[2].compareTo("Set_synth_blending") == 0)
				{
					if (theOscMessage.checkTypetag("sii"))
					{
						m_SynthContainer.Set_Synth_Blending(theOscMessage.get(0).stringValue(), theOscMessage.get(1)
								.intValue(), theOscMessage.get(2).intValue());
					}
				}
				else if (splits[2].compareTo("Child") == 0 && splits.length >= 4)
				{
					StringBuffer newAddrPattern = new StringBuffer();
					String childName;

					for (int pos = 4; pos < splits.length; pos++)
					{
						newAddrPattern.append("/" + splits[pos]);
					}

					for (int i = 0; i < m_SynthContainer.Synths().size(); i++)
					{
						child = ((ChildWrapper) m_SynthContainer.Synths().get(i)).Child();
						childName = ((ChildWrapper) m_SynthContainer.Synths().get(i)).GetName();

						if (childName.compareTo(splits[3]) == 0)
						{
							if (splits[4].compareTo("Get_Supported_Messages") == 0)
							{
								sendSupportedMessages((ChildWrapper) m_SynthContainer.Synths().get(i));
							}
							else
							// Handling messages to synths
							{
								try
								{
									// removing "/Mother/Child/Synth_Name" from address pattern
									theOscMessage.setAddrPattern(newAddrPattern.toString());

									oscEventMethod = child.getClass().getDeclaredMethod("oscEvent",
											new Class[] { OscMessage.class });

									oscEventMethod.invoke(child, new Object[] { theOscMessage });
								}
								catch (Exception e)
								{
									r_Parent.println("CRASH Child oscEvent" + childName + e.getStackTrace());
									r_Parent.println(e.getStackTrace());
								}
							}

							break;
						}
					}
				}
				else if (splits[2].compareTo("Record") == 0)
				{
					if (theOscMessage.checkTypetag("i"))
					{
						int in = theOscMessage.get(0).intValue();

						if (in == 1)
						{
							m_WriteImage = true;
							System.out.println("Recording!");
						}
						else if (in == 0)
						{
							m_WriteImage = false;
							System.out.println("Stopped Recording!");
							// loop();
						}
					}
				}

			}
		}
		else
		// Message not for mother
		{
			// println("Unhandled OSC message: " + theOscMessage.addrPattern());
		}
	}

	protected void sendPicWritingStartedMessage()
	{
		OSCPortOut sender;
		try
		{
			// (m_IP, m_osc_send_port)
			InetAddress ip = InetAddress.getByName(m_IP);
			sender = new OSCPortOut(ip, m_osc_send_port);

			ArrayList<Float> list = new ArrayList<Float>();

			list.add(m_FrameRate);

			Object args[] = new Object[list.size()];

			for (int i = 0; i < list.size(); i++)
			{
				args[i] = list.get(i);
			}

			OSCMessage msg = new OSCMessage("/Mother_Pic_Writing_Started/", args);

			sender.send(msg);
		}
		catch (UnknownHostException e1)
		{
			e1.printStackTrace();
		}
		catch (SocketException e1)
		{
			e1.printStackTrace();
		}
		catch (IOException ex)
		{
			ex.printStackTrace();
		}

		r_Parent.redraw();
	}

	protected void sendNextFrameMessage()
	{
		OSCPortOut sender;
		try
		{
			// (m_IP, m_osc_send_port)
			InetAddress ip = InetAddress.getByName(m_IP);
			sender = new OSCPortOut(ip, m_osc_send_port);

			ArrayList<Float> list = new ArrayList<Float>();

			list.add(m_FrameRate);

			Object args[] = new Object[list.size()];

			for (int i = 0; i < list.size(); i++)
			{
				args[i] = list.get(i);
			}

			OSCMessage msg = new OSCMessage("/Mother_Next_Frame/", args);

			sender.send(msg);
		}
		catch (UnknownHostException e1)
		{
			e1.printStackTrace();
		}
		catch (SocketException e1)
		{
			e1.printStackTrace();
		}
		catch (IOException ex)
		{
			ex.printStackTrace();
		}

		r_Parent.redraw();
	}

	protected void sendSupportedMessages(ChildWrapper wrapper)
	{
		PApplet child = wrapper.Child();
		String childName = wrapper.GetName();

		Foetus f = null;

		try
		{
			f = (Foetus) child.getClass().getField("f").get(child);
		}
		catch (Exception e)
		{
			r_Parent.println("CRASH: Accessing child's foetus failed!" + e.getMessage());
		}

		Hashtable<String, String> supportedMessages = f.getSupportedMessages();
		Enumeration<String> e = supportedMessages.elements();

		OSCPortOut sender;
		try
		{
			// (m_IP, m_osc_send_port)
			InetAddress ip = InetAddress.getByName(m_IP);
			sender = new OSCPortOut(ip, m_osc_send_port);

			ArrayList<String> list = new ArrayList<String>();
			for (Enumeration<String> ek = supportedMessages.keys(); ek.hasMoreElements();)
			{
				list.add(ek.nextElement());
				list.add(e.nextElement());
			}

			Object args[] = new Object[list.size()];

			for (int i = 0; i < list.size(); i++)
			{
				args[i] = list.get(i);
			}

			OSCMessage msg = new OSCMessage("/Synth_supported_messages/" + childName, args);

			sender.send(msg);
		}
		catch (UnknownHostException e1)
		{
			e1.printStackTrace();
		}
		catch (SocketException e1)
		{
			e1.printStackTrace();
		}
		catch (IOException ex)
		{
			ex.printStackTrace();
		}
	}

	public void init()
	{
		// Useless initializations, unless the program doesn't fint the .ini file at all...
		m_Width 		= 640;
		m_Height 		= 480;
		m_FullScreen 	= true;

		// For OSC
		m_IP 				= "127.0.0.1";
		m_osc_receive_port 	= 7005;
		m_osc_send_port 	= 5432;
		
		m_Synth_Folder 		= "X:\\Lumia Synths";

		// Loading setup values from .ini file
		
	    if (System.getProperty("os.name").toLowerCase().indexOf("mac") != -1) {
	    	 loadIniFile(r_Parent.sketchPath("data/mother" + ".ini")); // Mac
	    }
	    else { 
	        loadIniFile(r_Parent.sketchPath("data//mother" + ".ini")); // Windows  	
	    }
		

		if (r_Parent.frame != null && m_FullScreen == true)
		{
			r_Parent.frame.removeNotify();// make the frame not displayable
			r_Parent.frame.setResizable(false);
			r_Parent.frame.setUndecorated(true);
			r_Parent.println("frame is at " + r_Parent.frame.getLocation());
			r_Parent.frame.addNotify();
		}
	}

	static public void main(String args[])
	{
		int 		pos_X;
		int 		pos_Y;

		FileParser fp = new FileParser("data//mother" + ".ini");

		// parse ini file if it exists
		if (fp.fileExists())
		{
			if (fp.getIntValue("FullScreen") == 1)
			{
				int outputScreen = fp.getIntValue("outputScreen");

				GraphicsEnvironment environment = GraphicsEnvironment.getLocalGraphicsEnvironment();
				GraphicsDevice devices[] = environment.getScreenDevices();
				String location;

				Rectangle virtualBounds = new Rectangle();

				if (devices.length > outputScreen)
				{ // we have a 2nd display/projector

					GraphicsConfiguration[] gc = devices[outputScreen].getConfigurations();

					if (gc.length > 0)
					{
						virtualBounds = gc[0].getBounds();
					}

					location = "--location=" + virtualBounds.x + "," + virtualBounds.y;

					pos_X = virtualBounds.x;
					pos_Y = virtualBounds.y;
				}
				else
				{// leave on primary display
					location = "--location=0,0";

					pos_X = 0;
					pos_Y = 0;
				}

				PApplet.main(new String[] { location, "--hide-stop", /* display, */"Mother" });
			}
			else
			{
				PApplet.main(new String[] { "Mother" });
			}
		}
	}

	private void callRegisteredMethod(ChildWrapper w, String parameter)
	{
		try
		{
			Class params[] 	= new Class[1];
			params[0] 		= String.class;
			
			Method m = (Method) ((Class<? extends PApplet>) w.Child().getClass().getGenericSuperclass())
					.getDeclaredMethod("handleMethods", params);
			
			 m.setAccessible(true);

			 m.invoke(w.Child(), parameter);
			 
//			Field sven;
//
//			sven = (Field) ((Class<? extends PApplet>) w.Child().getClass().getGenericSuperclass())
//					.getDeclaredField(fieldName);
//
//			sven.setAccessible(true);
//
//			RegisteredMethods regMethods = (RegisteredMethods) sven.get(w.Child());
//			regMethods.handle();
			
			/* EXAMPLE: 
			 * 
			 * C1 c1inst=new C1()
			 * Method m = c1inst.getClass().getDeclaredMethod("printing", null);
			 * m.setAccessible(true);
			 * m.invoke(t, null);
			 */
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	private void dealWithMessageStack()
	{
		synchronized (m_MessageStack)
		{
			Object[] args;
			OscMessage theOscMessage;
			OSCMessage m;
			for (int i = 0; i < m_MessageStack.size(); i++)
			{
				m = m_MessageStack.get(i).message;
				args = m.getArguments();

				theOscMessage = new OscMessage(m.getAddress(), args);

				oscEvent(theOscMessage);
			}

			// System.out.println("Message stack size: " + m_MessageStack.size());
			m_MessageStack.clear();
		}
	}

	private void printFrameRate()
	{
		if (!firstProfiledFrame)
		{
			if (++profiledFrameCount == 30)
			{
				long endTimeMillis = System.currentTimeMillis();
				double secs = (endTimeMillis - startTimeMillis) / 1000.0;
				double fps = 30.0 / secs;
				// double ppf = tileSize * tileSize * 2;
				// double mpps = ppf * fps / 1000000.0;
				/*
				 * System.err.println("fps: " + fps + " polys/frame: " + ppf + " million polys/sec: " + mpps +
				 * " DrawElements calls/frame: " + (numDrawElementsCalls / 30));
				 */
				// System.err.println(vboEnabled);
				profiledFrameCount = 0;
//				numDrawElementsCalls = 0;
				startTimeMillis = System.currentTimeMillis();

				NumberFormat nf = NumberFormat.getInstance();

				nf.setMaximumFractionDigits(3);

				String number = nf.format(fps);

				System.out.println(number);
			}
		}
		else
		{
			startTimeMillis = System.currentTimeMillis();
			firstProfiledFrame = false;
		}
	}

	private void handleImageRecording()
	{
		if (m_WriteImage)
		{
			// sendPicWritingStartedMessage();
			// noLoop();
			r_Parent.saveFrame(m_ImageFolder + "Mother-#####.png");
			// loop();
			// sendNextFrameMessage();
		}
	}

	private void listenToOSC()
	{
		try
		{
			OSCPortIn receiver = new OSCPortIn(m_osc_receive_port);

			OSCListener listener = new OSCListener()
			{
				public void acceptMessage(java.util.Date time, OSCMessage message)
				{
					motherAcceptMessage(time, message);
				}
			};

			receiver.addListener("/Mother/*", listener);
			receiver.startListening();
		}
		catch (Exception e)
		{
			r_Parent.println("Address already in use: Cannot bind");
			System.exit(0);
		}
	}

	/**
	 * Loads the Settings from the Client INI file
	 */
	private void loadIniFile(String fileString)
	{
		fp = new FileParser(fileString);

		// parse ini file if it exists
		if (fp.fileExists())
		{
			m_IP = fp.getStringValue("IP");
			m_osc_receive_port = fp.getIntValue("osc_receive_port");
			m_osc_send_port = fp.getIntValue("osc_send_port");
			int[] localDim = fp.getIntValues("screenSize");
//			m_OutputScreen = fp.getIntValue("outputScreen");

			
			m_Width = localDim[0];
			m_Height = localDim[1];

			if (fp.getIntValue("FullScreen") == 1) {
				m_FullScreen = true;
			}
			else {
				m_FullScreen = false;
			}
			
			if (fp.getIntValue("UseCustomSynthFolder") == 1) {
				m_Synth_Folder = fp.getStringValue("SynthFolder");
			}
			else {
				if (System.getProperty("os.name").toLowerCase().indexOf("mac") != -1)
					m_Synth_Folder = r_Parent.sketchPath("data/Synths");  // Mac
		        else 
		        	m_Synth_Folder = r_Parent.sketchPath("data\\Synths"); // Windows
			}

			String frameRateString = fp.getStringValue("frameRate");

			m_FrameRate = Float.parseFloat(frameRateString);
			m_ImageFolder = fp.getStringValue("imagePath");

			String speedFractionString = fp.getStringValue("speedFraction");

			m_SpeedFraction = Float.parseFloat(speedFractionString);

			if (fp.getIntValue("stereo") == 1)
			{
				m_Stereo = true;
			}
			else
			{
				m_Stereo = false;
			}
			
			if (fp.getIntValue("billboard") == 1)
			{
				m_Billboard = true;
			}
			else
			{
				m_Billboard = false;
			}
		}
	}

	/*
	 * public String getMenuTitle() { return "Mother 0.7"; }
	 * 
	 * public void init(Editor arg0) { // TODO Auto-generated method stub
	 * 
	 * }
	 */
	/*
	 * public void run() { main(null); }
	 */
}
