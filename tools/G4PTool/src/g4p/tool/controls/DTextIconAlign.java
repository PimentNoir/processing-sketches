package g4p.tool.controls;

import g4p.tool.ToolMessages;
import g4p.tool.gui.propertygrid.EditorBase;
import g4p.tool.gui.propertygrid.EditorJComboBox;
import g4p.tool.gui.propertygrid.EditorJFileChooser;
import g4p.tool.gui.propertygrid.Validator;
import g4p_controls.StyledString;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;

@SuppressWarnings("serial")
public class DTextIconAlign extends DTextStyle {

	transient protected BufferedImage icon = null;

	protected int iconX, iconY, iconWidth, iconHeight;
	protected int iconHAlign, iconVAlign;
	public int iconNo = 0;
	
	public String 		_0140_text_x_alignment = "CENTER";
	transient public 	EditorBase text_x_alignment_editor = new EditorJComboBox(H_ALIGN_3);
	public Boolean 		text_x_alignment_edit = true;
	public Boolean 		text_x_alignment_show = true;
	public String 		text_x_alignment_label = "Text X align";
	public String 		text_x_alignment_updater = "textAlignChanged";

	public String 		_0141_text_y_alignment = "MIDDLE";
	transient public 	EditorBase text_y_alignment_editor = new EditorJComboBox(V_ALIGN);
	public Boolean 		text_y_alignment_edit = true;
	public Boolean 		text_y_alignment_show = true;
	public String 		text_y_alignment_label = "Text Y align";
	public String 		text_y_alignment_updater = "textAlignChanged";

	public String 		_0150_icon_file = "";
	transient public 	EditorJFileChooser icon_file_editor = new EditorJFileChooser();
	public Boolean 		icon_file_edit = true;
	public Boolean 		icon_file_show = true;
	public String 		icon_file_label = "Icon file";
	public String 		icon_file_updater = "iconChanged";

	public int	 		_0152_nbr_tiles = 1;
	public Boolean 		nbr_tiles_edit = true;
	public Boolean 		nbr_tiles_show = false;
	public String 		nbr_tiles_label = "Nbr of tiles in icon";
	public String 		nbr_tiles_updater = "nbrTilesChanged";
	public Validator 	nbr_tiles_validator = Validator.getValidator(int.class, 1, 3);

	public String 		_0154_icon_x_alignment = "RIGHT";
	transient public 	EditorBase icon_x_alignment_editor = new EditorJComboBox(H_ALIGN_2);
	public Boolean 		icon_x_alignment_edit = true;
	public Boolean 		icon_x_alignment_show = false;
	public String 		icon_x_alignment_label = "Icon X align";
	public String 		icon_x_alignment_updater = "iconAlignChanged";

	public String 		_0155_icon_y_alignment = "MIDDLE";
	transient public 	EditorBase icon_y_alignment_editor = new EditorJComboBox(V_ALIGN);
	public Boolean 		icon_y_alignment_edit = true;
	public Boolean 		icon_y_alignment_show = false;
	public String 		icon_y_alignment_label = "Icon Y align";
	public String 		icon_y_alignment_updater = "iconAlignChanged";

	// These are placed here so GTextField and GTextArea are unaffected
	public String 		width_updater = "sizeChanged";
	public String 		height_updater = "sizeChanged";

	public DTextIconAlign(){
		super();
		iconHAlign = ListGen.instance().getIndexOf(H_ALIGN_2, _0154_icon_x_alignment);
		iconVAlign = ListGen.instance().getIndexOf(V_ALIGN, _0155_icon_y_alignment);
		textHAlign = ListGen.instance().getIndexOf(H_ALIGN_3, _0140_text_x_alignment);
		textVAlign = ListGen.instance().getIndexOf(V_ALIGN, _0141_text_y_alignment);
	}

	protected String get_creator(DBase parent, String window){
		String s = "";
		if(_0150_icon_file.length() > 0){
			s = ToolMessages.build(SET_ICON, _0010_name, _0150_icon_file, _0152_nbr_tiles, _0154_icon_x_alignment, _0155_icon_y_alignment);
		}
		else if(icon != null && !isIconAlignDefaults()){
			s = ToolMessages.build(SET_ICON_ALIGN, _0010_name, _0154_icon_x_alignment, _0155_icon_y_alignment);
		}
		if(!isTextAlignDefaults())
			s += ToolMessages.build(SET_TEXT_ALIGN, _0010_name, _0140_text_x_alignment, _0141_text_y_alignment);
		s += super.get_creator(parent, window);
		return s;
	}

	protected boolean isTextAlignDefaults(){
		return (textHAlign == CENTER && textVAlign == MIDDLE);
	}

	public void textChanged(){
//		textWidthChanged = true;
		stext = new StyledString(_0130_text, textWidth);
		if(text_x_alignment_edit || text_y_alignment_edit){
			int currLength = _0130_text.length();
			if(currLength != lastLength){
				// Do we have to change the show alignment property.
				// If yes then the property model needs updating
				if(currLength == 0 || lastLength == 0){
					boolean hasText = (_0130_text.length() != 0);
					text_x_alignment_show = hasText;
					text_y_alignment_show = hasText;
					italic_show = hasText;
					bold_show = hasText;
					if(!hasText){
						_0136_bold = false;
						_0137_italic = false;
					}
					propertyModel.createProperties(this);
				}
				lastLength = currLength; // remember the current length
			}
		}
		propertyModel.hasBeenChanged();
	}
	
	// Override this method if needed
//	public void textChanged(){
//		super.textChanged();
//	}
	
//	public String get_text(){
//		return _0130_text;
//	}
	
	public void updatedInGUI(){
		sizeChanged();
	}

	/**
	 * If the width or height is changed then we need to update the text etc.
	 */
	public void sizeChanged(){
		textWidth = _0826_width;
		textWidthChanged = true;
		iconAlignChanged();
	}

	public void nbrTilesChanged(){
		iconWidth = icon.getWidth() / _0152_nbr_tiles;		
		iconAlignChanged();
	}

	public void iconAlignChanged(){
		System.out.println();
		iconHAlign = ListGen.instance().getIndexOf(H_ALIGN_2, _0154_icon_x_alignment);
		iconVAlign = ListGen.instance().getIndexOf(V_ALIGN, _0155_icon_y_alignment);
		if(iconHAlign == LEFT){
			iconX = 0;
			setHorzTextBoxValues(iconWidth, _0826_width - iconWidth);
		}
		else {
			iconX = _0826_width - iconWidth;
			setHorzTextBoxValues(0, _0826_width - iconWidth);
		}
		switch(iconVAlign){
		case TOP:
			iconY = 0;
			break;
		case MIDDLE:
			iconY = (_0827_height - iconHeight)/2;
			break;
		case BOTTOM:
			iconY = _0827_height - iconHeight;
			break;
		}
//		propertyModel.hasBeenChanged();
	}

	protected boolean isIconAlignDefaults(){
		return _0154_icon_x_alignment.equals("RIGHT") && _0155_icon_y_alignment.equals("MIDDLE");
	}

	public void iconChanged(){
		icon = this.getImageFromDataFolder(_0150_icon_file);
		if(icon != null){
			iconWidth = icon.getWidth() / _0152_nbr_tiles;
			iconHeight = icon.getHeight();
			if(iconWidth > _0826_width)
				_0826_width = iconWidth + 30;
			if(iconHeight > _0827_height)
				_0827_height = iconHeight + 4;
			nbr_tiles_show = true;
			icon_x_alignment_show = true;
			icon_y_alignment_show = true;
			iconAlignChanged();
			propertyModel.createProperties(this);
			propertyModel.hasBeenChanged();
		}
	}

	public void textAlignChanged(){
		textHAlign = ListGen.instance().getIndexOf(H_ALIGN_3, _0140_text_x_alignment);
		textVAlign = ListGen.instance().getIndexOf(V_ALIGN, _0141_text_y_alignment);
	}

	public void draw(Graphics2D g, AffineTransform paf, DBase selected){
		super.draw(g, paf, selected); // draw text
		if(icon != null)
			g.drawImage(icon, iconX, iconY, iconX + iconWidth, iconY + iconHeight, 
					iconNo * iconWidth, 0, iconNo * iconWidth + iconWidth, iconHeight, null);
	}

	protected void read(){
		super.read();
		text_x_alignment_editor = new EditorJComboBox(H_ALIGN_3);
		text_x_alignment_editor.setSelected(_0140_text_x_alignment);
		text_y_alignment_editor = new EditorJComboBox(V_ALIGN);
		text_y_alignment_editor.setSelected(_0141_text_y_alignment);
		
		icon_x_alignment_editor = new EditorJComboBox(H_ALIGN_3);
		icon_x_alignment_editor.setSelected(_0154_icon_x_alignment);
		icon_y_alignment_editor = new EditorJComboBox(V_ALIGN);
		icon_y_alignment_editor.setSelected(_0155_icon_y_alignment);
		
		icon_file_editor = new EditorJFileChooser();
		if(_0150_icon_file.length() > 0)
			icon = getImageFromDataFolder(_0150_icon_file);
	}
	
}
