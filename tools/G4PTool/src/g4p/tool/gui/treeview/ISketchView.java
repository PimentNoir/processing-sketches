package g4p.tool.gui.treeview;

import java.awt.Dimension;
import java.awt.Point;
import java.io.File;
import java.util.ArrayList;

import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeModel;

import g4p.tool.controls.DBase;

/** 
 * 
 * View of available methods in CtrlSketchView
 *  
 * 
 * @author Peter Lager
 *
 */
public interface ISketchView {

	/**
	 * Sets the selected node in this tree view.
	 * 
	 * @param comp
	 */
	public abstract void setSelectedComponent(DBase comp);

	/**
	 * For a given component find which window it is in
	 * @param comp
	 * @return the window or null if it is not inside a window
	 */
	public abstract DBase getWindowFor(DBase comp);

	/**
	 * Get the nearest gui
	 * @param comp
	 * @return
	 */
	public abstract DBase getGuiContainerFor(DBase comp);

	public Point getPosition(DBase comp, Point loc);

	/**
	 * This is used when a new component is being added. Starting with comp it 
	 * Searches for the first component that supports children (i.e. Application/Window/Panel/OptGroup)
	 * 
	 * @param comp
	 * @return
	 */
	public DBase getRoot();
	
	public void addComponent(DBase comp);
	
	public void removeComponent();
	
	public void saveModel(File file);
	
	public DefaultTreeModel loadModel(File file);

	public void setModel(TreeModel m);
	
	public void generateDeclarations(ArrayList<String> lines);
	
	public void generateEvtMethods(ArrayList<String> lines);
	
	public void generateCreator(ArrayList<String> lines);
	
	public Dimension getSketchSizeFromDesigner();
	
	public String getSketchRendererFromDesigner();

	
	
}