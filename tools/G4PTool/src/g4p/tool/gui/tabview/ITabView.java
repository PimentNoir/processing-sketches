package g4p.tool.gui.tabview;

import java.awt.Rectangle;

import g4p.tool.controls.DBase;

public interface ITabView {

	/**
	 * Add a newly created window component as a tab.
	 * 
	 * @param window
	 */
	void addWindow(DBase window);

	/**
	 * Remove a tab for a window that is no longer needed
	 * @param window
	 * @return
	 */
	boolean deleteWindow(DBase window);

	public void deleteAllWindows();
	
	/**
	 * Get the visible aeea of the currently selected window
	 * @return
	 */
	public Rectangle getVisibleArea();
	
	/** 
	 * Change the selected tab to the window with this control
	 * @param comp
	 */
	void setSelectedComponent(DBase comp);

	/**
	 * Called when window name is changed in property view
	 */
	void updateCurrentTab();

	void repaint();
	
	/**
	 * This method should be called by the WindowView when a 
	 * different component has been selected. 
	 * 
	 * @param comp the new component selected
	 */
	public abstract void componentHasBeenSelected(DBase comp);
	
	/**
	 * The size or position of the component has changed in
	 * the GUI tab using the mouse.
	 * @param comp
	 */
	void componentChangedInGUI(DBase comp);
	
	
	void setShowGrid(boolean show);
	void setSnapToGrid(boolean snap);
	void setGridSize(int gsize);

	void scaleWindow(int scale);
	
}