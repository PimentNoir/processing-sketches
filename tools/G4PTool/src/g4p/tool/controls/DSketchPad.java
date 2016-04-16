package g4p.tool.controls;

import g4p.tool.ToolMessages;
import g4p.tool.gui.ToolImage;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.ObjectInputStream;


@SuppressWarnings("serial")
public class DSketchPad extends DBase {

	transient public BufferedImage icon;
	
	public DSketchPad(){
		super();
		componentClass = "GSketchPad";
		set_name(NameGen.instance().getNext("sketchPad"));
		_0826_width = 80;
		_0827_height = 60;
		eventHandler_edit = eventHandler_show = false;
		icon = ToolImage.getImage("SPAD_ICON");
	}
	
	/**
	 * There are no events for this control
	 * @return
	 */
	protected String get_event_definition(){
		return "";
	}
	
	/**
	 * Get the creator statement var = new Foo(...);
	 * @return
	 */
	protected String get_creator(DBase parent, String window){
		String s = "";
		s = ToolMessages.build(CTOR_SPAD, _0010_name, window, 
				$(_0820_x), $(_0821_y), $(_0826_width), $(_0827_height));
		s += super.get_creator(parent, window);
		return s;
	}

	public void draw(Graphics2D g, AffineTransform paf, DBase selected){
		AffineTransform af = new AffineTransform(paf);
		af.translate(_0820_x, _0821_y);
		g.setTransform(af);
		
		g.setColor(DBase.globalJpalette[6]);
		g.fillRect(0, 0, _0826_width, _0827_height);
		g.drawImage(icon, 0, 0, _0826_width, _0827_height, null);
		g.setStroke(stdStroke);

		super.draw(g, paf, selected);
		
		if(this == selected)
			drawSelector(g);
		else {
			g.setColor(DASHED_EDGE_COLOR);
			g.setStroke(dashed);
			g.drawRect(0, 0, _0826_width, _0827_height);		
		}
		g.setTransform(paf);
	}

	protected void read(){
		super.read();
		icon = ToolImage.getImage("SPAD_ICON");
	}
	
	private void readObject(ObjectInputStream in)
	throws IOException, ClassNotFoundException
	{
		in.defaultReadObject();
		read();
	}

}
