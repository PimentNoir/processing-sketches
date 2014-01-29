/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package g4p.tool.gui.tabview;

import g4p.tool.TGuiConstants;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.geom.AffineTransform;

/**
 *
 * @author peter
 */
public class ScrollablePaper extends ScrollableArea implements TGuiConstants {

	protected int originalW, originalH;
	
    public ScrollablePaper(int w, int h) {
        super();
//        setOpaque(true);
//        setBackground(Color.white);
        originalW = canvasW = w;
        originalH = canvasH = h;
        setPreferredSize(new Dimension(canvasW, canvasH));
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D) g;
        g2d.setColor(Color.white);
        g2d.fillRect(0, 0, getWidth(), getHeight());
        AffineTransform orgAff = g2d.getTransform();
        AffineTransform aff = new AffineTransform(orgAff);
        aff.scale(scale, scale);
        g2d.setTransform(aff);
        g2d.setStroke(stdStroke);
        // Draw window and components
        user.getWindowComponent().draw(g2d, aff, user.getSelected());
        g2d.setTransform(orgAff);
     }

	
	@Override
    public void setCanvasSize(int w, int h) {
        if (w != originalW || h != originalH) {
        	originalW = w;
        	originalH = h;
        	canvasW = Math.round(originalW * scale);
        	canvasH = Math.round(originalH * scale);       	
            int deltaW = w - canvasW;
            int deltaH = w - canvasH;
 
            setPreferredSize(new Dimension(canvasW, canvasH));
            if (deltaW < 0 || deltaH < 0) {
                deltaW = Math.min(deltaW, 0);
                deltaH = Math.min(deltaH, 0);
                Point loc = this.getLocation();
                loc.x += deltaW;
                loc.y += deltaH;
                setLocation(loc);
            }
            revalidate();
        }
    }
    
	@Override
	public void setScale(float newScale, int mui) {
		if(newScale != scale){
			// Get new:old scale ratio
			float sf = newScale / scale;
			// Get current position for canvas top-left corner
			Point loc = this.getLocation();
			// Get current visible area size
			Rectangle r = this.getVisibleRect();
			// Calculate the current visible image center
			loc.x = -loc.x + r.width / 2;
			loc.y = -loc.y + r.height / 2;
			// Calculate center for new scale
			loc.x = Math.round(loc.x * sf);
			loc.y = Math.round(loc.y * sf);
			// Calculate and use size of scaled canvas
			canvasW = Math.round(originalW * newScale);
			canvasH = Math.round(originalH * newScale);
			setPreferredSize(new Dimension(canvasW, canvasH));
			// Update max increment
			maxUnitIncrement = mui;
			// Now center image so zoom appears to be on the center
			centerOn(loc.x, loc.y);
			scale = newScale;
			revalidate();
		}
	}
}
