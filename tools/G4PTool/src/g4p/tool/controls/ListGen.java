package g4p.tool.controls;

import g4p.tool.TDataConstants;

import java.util.HashMap;

import javax.swing.DefaultComboBoxModel;

/**
 * Singleton class used to create and store option lists for combobox editors. <br>
 * 
 * When adding a new type of list - need to modify the getValidator(type) method to 
 * included it.<br>
 * 
 * @author Peter Lager.
 *
 */
@SuppressWarnings("rawtypes")
public final class ListGen implements TDataConstants {


	private static ListGen instance;

	public static ListGen instance(){
		if(instance == null){
			instance = new ListGen();
		}
		return instance;
	}

	// ==============================================================
	// ==============================================================

	private HashMap<Integer, DefaultComboBoxModel> cbList;

	private ListGen(){
		cbList = new HashMap<Integer, DefaultComboBoxModel>();
		makeColourSchemeSelection(COLOUR_SCHEME);
		makeCursorShapeSelection(CURSOR_CHANGER);
		makeGWSliderSkinSelection(SLIDER_SKIN);
		makeRendererSelection(RENDERER);
		makeKnobControllerSelection(KNOB_CTRL);
		makeHorzAlignSelection2(H_ALIGN_2);
		makeHorzAlignSelection3(H_ALIGN_3);
		makeVertAlignSelection(V_ALIGN);
		makeValueTypeSelection(VALUE_TYPE);	
		makeTextOrientationSelection(TEXT_ORIENT);
		makeStickTypeSelection(STICK_TYPE);
		makeCloseActionSelection(CLOSE_ACTION);
		makeScaleSelection(SCALE);
	}
	
	@SuppressWarnings("unchecked")
	private void makeScaleSelection(int type) {
		String[] s = new String[] {"200", "150", "100", "75", "50", "25"};
		cbList.put(type,  new DefaultComboBoxModel(s));	
	}
	
	@SuppressWarnings("unchecked")
	private void makeCloseActionSelection(int type) {
		String[] s = new String[] {"KEEP_OPEN", "CLOSE_WINDOW", "EXIT_APP"};
		cbList.put(type,  new DefaultComboBoxModel(s));	
	}

	@SuppressWarnings("unchecked")
	private void makeStickTypeSelection(int type) {
		String[] s = new String[] {"X4", "X8"};
		cbList.put(type,  new DefaultComboBoxModel(s));	
	}

	@SuppressWarnings("unchecked")
	private void makeTextOrientationSelection(int type) {
		String[] s = new String[] {"ORIENT_TRACK", "ORIENT_LEFT", "ORIENT_RIGHT"};
		cbList.put(type,  new DefaultComboBoxModel(s));	
	}

	@SuppressWarnings("unchecked")
	private void makeValueTypeSelection(int type) {
		String[] s = new String[] {"INTEGER", "DECIMAL", "EXPONENT"};
		cbList.put(type,  new DefaultComboBoxModel(s));	
	}

	@SuppressWarnings("unchecked")
	private void makeRendererSelection(int type) {
		String[] s = new String[] {"JAVA2D", "P2D", "P3D", "OPENGL"};		
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	@SuppressWarnings("unchecked")
	private void makeColourSchemeSelection(int type){
		String[] s = new String[] { "RED_SCHEME", "GREEN_SCHEME",  
				"YELLOW_SCHEME", "PURPLE_SCHEME", "ORANGE_SCHEME", 
				"CYAN_SCHEME", "BLUE_SCHEME", "GOLD_SCHEME" };
		cbList.put(type,  new DefaultComboBoxModel(s));
	}
	
	@SuppressWarnings("unchecked")
	private void makeCursorShapeSelection(int type){
		String[] s = new String[] { "ARROW", "CROSS", 
				"HAND", "MOVE", "TEXT", "WAIT" };
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	@SuppressWarnings("unchecked")
	private void makeGWSliderSkinSelection(int type){
		String[] s = new String[] { "grey_blue", "blue18px", 
				"green_red20px", "purple18px", "red_yellow18px" };
		cbList.put(type,  new DefaultComboBoxModel(s));
	}
	
	@SuppressWarnings("unchecked")
	private void makeKnobControllerSelection(int type){
		String[] s = new String[] { "ANGULAR", "HORIZONTAL", "VERTICAL" };
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	@SuppressWarnings("unchecked")
	private void makeHorzAlignSelection2(int type){
		String[] s = new String[] { "LEFT", "RIGHT" };
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	@SuppressWarnings("unchecked")
	private void makeHorzAlignSelection3(int type){
		String[] s = new String[] { "LEFT", "RIGHT" , "CENTER"};
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	@SuppressWarnings("unchecked")
	private void makeVertAlignSelection(int type){
		String[] s = new String[] { "TOP", "BOTTOM" , "MIDDLE"};
		cbList.put(type,  new DefaultComboBoxModel(s));
	}

	// ================================================================
	
	public boolean hasComboModel(int type){
		return cbList.containsKey(type);
	}
	
	public DefaultComboBoxModel getComboBoxModel(int key){
		return cbList.get(key);
	}

	public void setSelectedValue(int key, String value){
		cbList.get(key).setSelectedItem(value);
	}
	
	public int getIndexOf(int key, String value){
		return cbList.get(key).getIndexOf(value);
	}
	
	public int getSize(int key){
		return cbList.get(key).getSize();
	}
}
