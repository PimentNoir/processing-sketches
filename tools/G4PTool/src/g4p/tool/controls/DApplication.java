package g4p.tool.controls;

import g4p.tool.ToolMessages;
import g4p.tool.gui.propertygrid.EditorBase;
import g4p.tool.gui.propertygrid.EditorJComboBox;
import g4p_controls.GCScheme;

import java.io.IOException;
import java.io.ObjectInputStream;

/**
 * This class represents the whole Processing sketch. <br>
 * 
 * It will be the root node for the tree view and its children 
 * should only be windows.
 * 
 * @author Peter Lager
 *
 */
@SuppressWarnings("serial")
public final class DApplication extends DBase {

	public Boolean 		_0951_show_messages  = false;
	public Boolean 		show_messages_edit = true;
	public Boolean 		show_messages_show = true;
	public String 		show_messages_label = "Show G4P messages";

	public String 		_0952_col_scheme = "BLUE_SCHEME";
	transient public 	EditorBase col_scheme_editor = new EditorJComboBox(COLOUR_SCHEME);
	public Boolean 		col_scheme_edit = true;
	public Boolean 		col_scheme_show = true;
	public String 		col_scheme_label = "Colour scheme";
	public String 		col_scheme_updater = "colourSchemeChange";

	public Boolean 		_0953_cursor  = true;
	public Boolean 		cursor_edit = true;
	public Boolean 		cursor_show = true;
	public String 		cursor_label = "Enable mouse over";
	public String		cursor_updater = "cursorChanger";

	public String 		_0954_cursor_off = "ARROW";
	transient public 	EditorBase cursor_off_editor = new EditorJComboBox(CURSOR_CHANGER);
	public Boolean 		cursor_off_edit = true;
	public Boolean 		cursor_off_show = true;
	public String 		cursor_off_label = "Cursor off image";


	/**
	 * 
	 */
	public DApplication() {
		super();
		selectable = true;
		resizeable = false;
		moveable = false;
		allowsChildren = true;
		_0010_name = "SKETCH";
		name_label = "PROCCESSING";
		name_edit = false;
		x_show = false;
		y_show = false;
		width_show = false;
		height_show = false;
		eventHandler_show = false;
	}

	public String get_creator(DBase parent, String window){ 
		StringBuilder sb = new StringBuilder();
		sb.append(ToolMessages.build(SET_G4P_MESSAGES, _0951_show_messages));
		sb.append(ToolMessages.build(SET_SKETCH_COLOR, _0952_col_scheme));
		if(_0953_cursor) {
			sb.append(ToolMessages.build(SET_CURSOR_OFF, _0954_cursor_off));
		}
		else {
			sb.append(ToolMessages.build(SET_MOUSE_OVER_ON, _0953_cursor));		
		}
		return new String(sb);
	}

	public String get_event_definition(){
		return null;
	}

	public String get_declaration(){
		return null;
	}

	public void cursorChanger(){
		cursor_off_show = _0953_cursor;;
		propertyModel.createProperties(this);
		propertyModel.hasBeenChanged();
	}

	public void colourSchemeChange(){
		DBase.globalColorSchemeID = ListGen.instance().getIndexOf(COLOUR_SCHEME, _0952_col_scheme);
		DBase.globalColorSchemeName = _0952_col_scheme;
		DBase.globalJpalette = GCScheme.getJavaColor(globalColorSchemeID);
	}

	protected void read(){
		super.read();
		col_scheme_editor = new EditorJComboBox(COLOUR_SCHEME);
		cursor_off_editor = new EditorJComboBox(CURSOR_CHANGER);		
		DBase.globalColorSchemeID = ListGen.instance().getIndexOf(COLOUR_SCHEME, _0952_col_scheme);
		DBase.globalJpalette = GCScheme.getJavaColor(globalColorSchemeID);
	}

	private void readObject(ObjectInputStream in)
	throws IOException, ClassNotFoundException
	{
		in.defaultReadObject();
		read();
	}

}
