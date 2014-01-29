package g4p.tool.controls;

import g4p.tool.Messages;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.util.ArrayList;
import java.util.Enumeration;

@SuppressWarnings("serial")
public class DToggleGroup extends DBase {

	
	public DToggleGroup(){
		super();
		selectable = false;
		resizeable = false;
		moveable = false;

		componentClass = "GToggleGroup";
		set_name(NameGen.instance().getNext("togGroup"));
		name_label = "Variable name";
		name_tooltip = "Java naming rules apply";
		name_edit = true;
		x_show = y_show = width_show = height_show = false;
		allowsChildren = true;
	}
	
	public void make_creator(ArrayList<String> lines, DBase parent, String window){
		DOption comp;
		Enumeration<?> e;
		String ccode = get_creator(parent, window);
		if(ccode != null && !ccode.equals(""))
			lines.add(ccode);
		if(allowsChildren){
			e = children();
			while(e.hasMoreElements()){
				comp = (DOption)e.nextElement();
				comp.make_creator(lines, this, window);
			}
			System.out.println("Adding options " + (parent != null) + "   " + (parent instanceof DWindow));
//			if(parent != null && !(parent instanceof DWindow)){
			// Add options to the option group
			boolean onPanel = (parent instanceof DPanel);
				e = children();
				while(e.hasMoreElements()){
					comp = (DOption)e.nextElement();
					lines.add(Messages.build(ADD_A_CHILD, _0010_name, comp._0010_name));
					if(comp._0101_selected)
						lines.add(Messages.build(SEL_OPTION, comp._0010_name, "true"));
					// If this group is on a panel then add the options
					if(onPanel)
						lines.add(Messages.build(ADD_A_CHILD, parent._0010_name, comp._0010_name));
				}
//			}
		}				
	}

	protected String get_creator(DBase parent, String window){
		return Messages.build(CTOR_GOPTIONGROUP, _0010_name);
	}

	/**
	 * This class has no events
	 */
	protected String get_event_definition(){
		return null;
	}

	public void draw(Graphics2D g, AffineTransform paf, DBase selected){
		AffineTransform af = new AffineTransform(paf);
		Enumeration<?> e = children();
		while(e.hasMoreElements()){
			((DBase)e.nextElement()).draw(g, af, selected);
		}
		g.setTransform(paf);
	}

}
