package g4p.tool.controls;

import g4p.tool.ToolMessages;
import g4p_controls.StyledString;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.io.IOException;
import java.io.ObjectInputStream;

@SuppressWarnings("serial")
public class DButton extends DTextIconAlign {

	public DButton(){
		super();
		componentClass = "GButton";
		set_name(NameGen.instance().getNext("button"));
		set_event_name(NameGen.instance().getNext(get_name()+ "_click"));
		_0130_text = "Face text";
		stext = new StyledString(_0130_text, textWidth);
		_0826_width = 80;
		_0827_height = 30;
		text_tooltip = "text to show on button";
		opaque_show = false;
		eventHandler_edit = eventHandler_show = true;
	}

	public void draw(Graphics2D g, AffineTransform paf, DBase selected){
		AffineTransform af = new AffineTransform(paf);
		af.translate(_0820_x, _0821_y);
		g.setTransform(af);
		
		g.setColor(jpalette[4]);
		g.fillRect(0, 0, _0826_width, _0827_height);
		g.setStroke(stdStroke);
		g.setColor(jpalette[3]);
		g.drawRect(0, 0, _0826_width, _0827_height);

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


	/**
	 * Get the creator statement var = new Foo(...);
	 * @return
	 */
	protected String get_creator(DBase parent, String window){
		String s = "";
		s = ToolMessages.build(CTOR_GBUTTON, _0010_name, window, 
				$(_0820_x), $(_0821_y), $(_0826_width), $(_0827_height));
		s += super.get_creator(parent, window);
		return s;
	}

	protected void read(){
		super.read();
	}
	
	private void readObject(ObjectInputStream in)
	throws IOException, ClassNotFoundException
	{
		in.defaultReadObject();
		read();
	}
}
