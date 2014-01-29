package mother.library;

import java.text.NumberFormat;
import java.util.*;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.Rectangle;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.*;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.URLClassLoader;
import java.net.UnknownHostException;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Hashtable;

import processing.core.PApplet;

//import processing.core.PApplet.RegisteredMethods;

import foetus.*;

public class SynthContainer
{
	ArrayList<URL> m_Visual_Synth_urls;

	URL[] m_Library_file_URLS;

	Hashtable<String, String> m_Visual_Synth_Names;

	ArrayList<ChildWrapper> m_VisualSynths;

	ArrayList<ChildWrapper> Synths()
	{
		return m_VisualSynths;
	}

	Hashtable<String, String> m_Visual_Synth_Keys;

	String m_Synth_Folder;

	URL[] get_Library_File_URLS()
	{
		return m_Library_file_URLS;
	}

	Hashtable<String, String> get_Synth_Names()
	{
		return m_Visual_Synth_Names;
	}

	public SynthContainer(String folder)
	{
		m_VisualSynths = new ArrayList<ChildWrapper>();
		m_Visual_Synth_Names = new Hashtable<String, String>();
		m_Visual_Synth_Keys = new Hashtable<String, String>();

		m_Synth_Folder = folder;

		PopulateSynthURLS();
		PopulateLibraryURLS();
	}

	/*
	 * Scans folder containing synths and stores URL for each
	 */
	private void PopulateSynthURLS()
	{
		String[] fileName;
		File oooClassPath = new File(m_Synth_Folder);
		File[] files = oooClassPath.listFiles();
		m_Visual_Synth_urls = new ArrayList<URL>();

		if (files != null)
		{
			for (int i = 0; i < files.length; i++)
			{
				try
				{
					fileName = files[i].getName().split("\\.");

					if ((fileName.length > 1) && (fileName[fileName.length - 1].compareTo("jar") == 0))
					{
						m_Visual_Synth_urls.add(files[i].toURI().toURL());
						System.out.println("Found Synth: " + fileName[0]);

						m_Visual_Synth_Names.put(fileName[0], fileName[0]);
					}
				}
				catch (MalformedURLException ex)
				{
					System.out.println("MalformedURLException: " + ex.getMessage());
				}
				catch (Exception e)
				{
					System.out.println(e.getMessage());
					e.printStackTrace();
				}
			}
		}
		else
		{
			System.out.println("Synth folder not found, or empty!");
		}
	}

	private void PopulateLibraryURLS()
	{
		String[] fileName;
		File oooClassPath;

		if (System.getProperty("os.name").toLowerCase().indexOf("mac") != -1)
			oooClassPath = new File(m_Synth_Folder + "/libraries"); // Mac
		else
			oooClassPath = new File(m_Synth_Folder + "//" + "libraries"); // Windows

		File[] files = oooClassPath.listFiles();

		ArrayList<URL> temp_Library_file_URLS = new ArrayList<URL>();

		// Check if Libraries folder exists. If not, create empty list.
		if (files != null)
		{
			try
			{
				for (int i = 0; i < files.length; i++)
				{
					fileName = files[i].getName().split("\\.");

					if ((fileName.length > 1) && (fileName[fileName.length - 1].compareTo("jar") == 0))
					{
						temp_Library_file_URLS.add(files[i].toURI().toURL());
						System.out.println("Found library: " + fileName[0]);
					}
				}
			}
			catch (MalformedURLException ex)
			{
				System.out.println("MalformedURLException: " + ex.getMessage());
			}
			catch (Exception e)
			{
				System.out.println(e.getMessage());
				e.printStackTrace();
			}

			m_Library_file_URLS = new URL[temp_Library_file_URLS.size()];

			for (int i = 0; i < temp_Library_file_URLS.size(); i++)
			{
				m_Library_file_URLS[i] = temp_Library_file_URLS.get(i);
			}
		}
		else
		{
			m_Library_file_URLS = new URL[0];
		}
	}

	public boolean contains(String key)
	{
		if (!m_Visual_Synth_Keys.containsKey(key))
		{
			return false;
		}
		else
			return true;
	}

	/**
	 * Loads a sketch from disk
	 * @param classPath
	 * @param className
	 * @return
	 */
	
	private PApplet LoadSketch(String classPath, String className, URL[] libraryURLS)
    {   
		File dir1 = new File (".");
	    
		if(libraryURLS==null) {
			  System.out.println ("libraryURLS IS NULL!");
			  libraryURLS = new URL[0];
		}
		
		try {
	      System.out.println ("Current dir : " + dir1.getCanonicalPath());
	    }
	    catch(Exception e) {	    	 
	    }		
	    
        File oooClassPath;
        
        if (System.getProperty("os.name").toLowerCase().indexOf("mac") != -1)
        	oooClassPath = new File(classPath + "//" + className + ".jar"); // Mac
        else 
        	oooClassPath = new File(classPath + "//" + className + ".jar"); // Windows

        URL[] toUse = new URL[1 + libraryURLS.length];
        
        try
        { 
	        for(int i = 0; i<libraryURLS.length; i++ )
	        {
	      		toUse[i] = libraryURLS[i];
	        }
	            
	        toUse[libraryURLS.length] = oooClassPath.toURI().toURL();
        	        	
        	URLClassLoader cl = new URLClassLoader( toUse, ClassLoader.getSystemClassLoader() );

        	PApplet toReturn = (PApplet)Class.forName(className, true, cl).newInstance(); 
        	
        	toReturn.noLoop();
        	
            return toReturn;
        } 
        catch (Exception ex)
        {
        	System.out.println("Loading child failed, probably jar file could not be found! " + 
        			ex.getMessage());
        }
        
        return null;
    } 
	
	/*
	 * Create a new synth layer
	 */
	public ChildWrapper Add(String key, String sketchName, Mother mother)
	{
		ChildWrapper new_Wrapper = null;
		
		if(!m_Visual_Synth_Keys.containsKey(key))
		{		
			PApplet child = null;
						
			child = LoadSketch(m_Synth_Folder, sketchName, m_Library_file_URLS);
			
			if(child!=null) {
				new_Wrapper = new ChildWrapper(		child,										 
													key, 
													mother.getBillboardFlag(), // Render Billboard
													mother);
				m_VisualSynths.add( new_Wrapper );
					
				InitChild( new_Wrapper, mother );
					
				m_Visual_Synth_Keys.put(key, sketchName);
			}
		}	
		
		return new_Wrapper;
	}

	public ChildWrapper GetChildWrapper(String key)
	{
		ChildWrapper toReturn = null;

		if (m_Visual_Synth_Keys.containsKey(key))
		{
			for (int i = 0; i < m_VisualSynths.size(); i++)
			{
				if (((ChildWrapper) m_VisualSynths.get(i)).GetName().compareTo(key) == 0)
				{
					return (ChildWrapper) m_VisualSynths.get(i);
				}
			}
		}

		return toReturn;
	}

	public ChildWrapper Remove(String key)
	{
		ChildWrapper toReturn = null;

		if (m_Visual_Synth_Keys.containsKey(key))
		{
			for (int i = 0; i < m_VisualSynths.size(); i++)
			{
				if (((ChildWrapper) m_VisualSynths.get(i)).GetName().compareTo(key) == 0)
				{
					toReturn = ((ChildWrapper) m_VisualSynths.get(i));

					((ChildWrapper) m_VisualSynths.get(i)).Child().stop();

					m_VisualSynths.remove(i);
					break;
				}
			}

			m_Visual_Synth_Keys.remove(key);

			return toReturn;
		}
		else
		{
			return toReturn;
		}
	}

	public boolean reset()
	{
		m_Visual_Synth_Keys.clear();
		m_VisualSynths.clear();

		return true;
	}

	public boolean Move(String key, int newLocation)
	{
		if (m_Visual_Synth_Keys.containsKey(key))
		{
			for (int i = 0; i < m_VisualSynths.size(); i++)
			{
				ChildWrapper element = ((ChildWrapper) m_VisualSynths.get(i));

				if ((element.GetName().compareTo(key) == 0) && (m_VisualSynths.size() > newLocation)
						&& (newLocation >= 0))
				{
					m_VisualSynths.remove(i);

					m_VisualSynths.add(newLocation, element);
					break;
				}
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	public boolean Set_Synth_Blending(String key, int source, int dest)
	{
		if (m_Visual_Synth_Keys.containsKey(key))
		{
			for (int i = 0; i < m_VisualSynths.size(); i++)
			{
				ChildWrapper element = ((ChildWrapper) m_VisualSynths.get(i));

				if (element.GetName().compareTo(key) == 0)
				{
					/*
					 * GL_ZERO 0 GL_ONE 1 GL_SRC_COLOR 768 GL_ONE_MINUS_SRC_COLOR 769 GL_DST_COLOR 774
					 * GL_ONE_MINUS_DST_COLOR 775 GL_SRC_ALPHA 770 GL_ONE_MINUS_SRC_ALPHA 771 GL_DST_ALPHA 772
					 * GL_ONE_MINUS_DST_ALPHA 773 GL_SRC_ALPHA_SATURATE 776 GL_CONSTANT_COLOR 32769
					 * GL_ONE_MINUS_CONSTANT_COLOR 32770 GL_CONSTANT_ALPHA 32771 GL_ONE_MINUS_CONSTANT_ALPHA 32772
					 */

					element.SetBlending_Source(source);
					element.SetBlending_Destination(dest);

					break;
				}
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	public void Initialize(Mother mother)
	{
		for (int i = 0; i < m_VisualSynths.size(); i++)
		{
			InitChild(((ChildWrapper) m_VisualSynths.get(i)), mother);
		}
	}

	// private void initializeRegisteredMapField(ChildWrapper w)
	// {
	// try
	// {
	// Field sven;
	//
	// sven = (Field)((Class<? extends PApplet>)
	// w.Child().getClass().getGenericSuperclass()).getDeclaredField("registerMap");
	//
	// sven.setAccessible(true);
	//
	// sven.set(w.Child(), w.Child().new HashMap<String, PApplet.RegisteredMethods>());
	//
	// }
	// catch (Exception e)
	// {
	// e.printStackTrace();
	// }
	// }
	//
	/*
	 * 
	 */
	private void InitChild(ChildWrapper cw, Mother parent)
	{
		PApplet child = cw.Child();

		Method[] methods = child.getClass().getMethods();
		Method[] declaredMethods = child.getClass().getDeclaredMethods();

		child.g = parent.GetParent().g;

		child.setSize(parent.getChildWidth(), parent.getChildHeight());

		/*
		 * With this, I'm hoping the child will run in a separate thread, but its timer will not call the draw method.
		 * Instead, ony one timer is running, the one in Mother.
		 */
		child.noLoop();

		/*
		 * try { for(int i = 0; i < methods.length; i++) { if(methods[i].getName().equals("init")) {
		 * methods[i].invoke(child, new Object[] {}); break; } } } catch(Exception e) {
		 * System.out.println("CRASH PApplet.init: " + e.getMessage()); }
		 */

		// initializeRegisteredMapField(cw);

		child.frameCount = parent.GetParent().frameCount;
		child.frameRate = parent.GetParent().frameRate;
		child.frame = parent.GetParent().frame;
		// child.screen = parent.GetParent().screen;
		child.recorder = parent.GetParent().recorder;

		child.sketchPath = m_Synth_Folder;

		child.pixels = parent.GetParent().pixels;

		child.width = parent.getChildWidth();
		child.height = parent.getChildHeight();

		child.noLoop();

		Foetus foetusField;

		try
		{
			for (int i = 0; i < declaredMethods.length; i++)
			{
				if (declaredMethods[i].getName().equals("initializeFoetus"))
				{
					declaredMethods[i].invoke(child, new Object[] {});

					break;
				}
			}

			foetusField = (Foetus) child.getClass().getDeclaredField("f").get(child);

			cw.setFoetusField(foetusField);

			foetusField.standalone = false;

			foetusField.setSpeedFraction(parent.getSpeedFraction());
		}
		catch (Exception e)
		{
			System.out.println("CRASH while initializing synth. Message: " + e.getMessage());
		}
	}

}
