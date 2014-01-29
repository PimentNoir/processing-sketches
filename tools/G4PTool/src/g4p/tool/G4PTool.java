/**
 * GUI form designer for G4P.
 *
 * (C) 2013
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 * 
 * @author		Peter Lager http://www.lagers.org.uk
 * @modified	12/27/2013
 * @version		##version##
 */
package g4p.tool;

import g4p.tool.gui.GuiDesigner;
import g4p_controls.GCScheme;

import java.io.File;

import javax.swing.JFrame;

import processing.app.Base;
import processing.app.Sketch;
import processing.app.tools.Tool;

/**
 * 
 * @author Peter Lager
 *
 */
public class G4PTool implements Tool, TFileConstants {

	// Keep track of the editor using this sketch
	private processing.app.Editor editor;
	// keep track of the FUI designer for this sketch
	private GuiDesigner dframe;

	private boolean g4p_error_shown = false;
	
	public String getMenuTitle() {
		return "GUI builder";
	}

	/**
	 * Get version string of this tool
	 * @return revision number string
	 */
	public static String getVersion(){
		return "2.4.1";
	}
	
	/**
	 * Get compatible version string of this tool
	 * @return revision number string
	 */
	public static String getCompatibleVersionNo(){
		String n[] = "2.4.1".split("[\\.]");
		return n[0] + "." + n[1];
	}
	
	/**
	 * Get version number of this tool as an integer with the form  <br>
	 * MMmmii <br>
	 * M = Major revision <br>
	 * m = minor revision <br>
	 * i = internal revision <br>
	 * @return version number as int
	 */
	public static int getVersionNo(){
		String n[] = "2.4.1".split("[\\.]");
		int[] vnp = new int[3];
		for(int i = 0; i < n.length; i++){
			try {
				vnp[i] = Integer.parseInt(n[i]);
			}
			catch(Exception excp){
			}
		}
		return ((vnp[0] * 100) + vnp[1]) * 100 + vnp[2];
	}
	
	/**
	 * Called once first time the tool is called
	 */
	public void init(processing.app.Editor theEditor) {
		this.editor = theEditor;
	}

	/**
	 * This is executed every time we launch the tool using the menu item in Processing IDE
	 * 
	 */
	public void run() {
		GCScheme.makeColorSchemes();
		
//		Base base = editor.getBase();
		Sketch sketch = editor.getSketch();
		File sketchFolder = sketch.getFolder();
		File sketchbookFolder = Base.getSketchbookFolder();

		// Provide a warning (first time only) if G4P is not loaded
		if (!g4p_error_shown && !g4pJarExists(Base.getSketchbookLibrariesFolder())) {
			Base.showWarning("GUI Builder warning", 
					"Although you can use this tool the sketch created will not \nwork because the G4P library needs to be installed.\nSee G4P at http://www.lagers.org.uk/g4p/",
					(Exception) null);
			g4p_error_shown = true;
		}
		// The tool is not open so create the designer window
		if (dframe == null) {
			System.out.println("===================================================");
			System.out.println("   G4PTool V2.4.1 created by Peter Lager");
			System.out.println("===================================================");
			
			// If the gui.pde tab does not exist create it
			if (!guiTabExists(sketch)) {
				System.out.println("G4PTool : run()   ---   adding   gui.tab");
				System.out.println("Sketch book floder: " + sketchbookFolder);
				System.out.println(G4P_TOOL_DATA_FOLDER + SEP + PDE_TAB_NAME);
				System.out.println("-----------------------------------------------------------");
				sketch.addFile(new File(sketchbookFolder, G4P_TOOL_DATA_FOLDER + SEP + PDE_TAB_NAME));
			}
			// Create data folder if necessary
			sketch.prepareDataFolder();
			
			// Create a sub-folder called 'GUI_BUILDER_DATA' inside the sketch folder if
			// it doesn't already exist
			File configFolder = new File(sketchFolder, CONFIG_FOLDER);
			if (!configFolder.exists()) {
				configFolder.mkdir();
			}
			
			dframe = new GuiDesigner(editor);
			
//			try {
//				BufferedImage img = ImageIO.read(new File(sketchbookFolder, G4P_TOOL_DATA_FOLDER + SEP + "default_gui_palette.png"));
//				System.out.println("Image " + img);
//			} catch (IOException e) {
//				System.out.println("Unable to load colour schemes");
//				e.printStackTrace();
//			}
		}
		// Design window exists so make visible, open to normal size
		// and bring to front.
		dframe.setVisible(true);
		dframe.setExtendedState(JFrame.NORMAL);
		dframe.toFront();
	}

	/**
	 * See if the G4P library has been installed in the SketchBook libraries folder correctly
	 * @param sketchbookLibrariesFolder
	 * @return true if found else false
	 */
	private boolean g4pJarExists(File sketchbookLibrariesFolder) {
		boolean exists = false;
		System.out.println("G4PTool : g4pJarExists() : testing whether G4P has been installed.");
		System.out.println("Libraries folder: " + sketchbookLibrariesFolder);
		System.out.println(G4P_LIB);
		File f = new File(sketchbookLibrariesFolder, G4P_LIB);
		exists = f.exists();
		System.out.println("G4P installed " + exists);
		System.out.println("-----------------------------------------------------");
		return exists;
	}

	/**
	 * See if the gui.pde tab has been created already if not
	 * @param sketch
	 * @return
	 */
	private boolean guiTabExists(Sketch sketch) {
		File f = new File(sketch.getFolder(), PDE_TAB_NAME);
		return f.exists();
	}
}
