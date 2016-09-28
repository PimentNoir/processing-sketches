/**
 * Copyright (c) 2012 Martin Prout
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
import java.text.CharacterIterator;
import lsystem.turtle.Turtle;
import lsystem.Grammar;
import lsystem.SimpleGrammar;
import lsystem.util.LUT;

/**
 * dragon.pde
 * Demonstrates the use of a Simple Grammar with two 'substitution' rules.
 * A CharacterIterator instance used to create the grammar, is re-used to 
 * parse the hidden 'production' string.
 * lines are 'stored' as a PShape object
 * Also features use of my restricted lookup table for sin/cos which takes
 * degree input rather than radians (fixed precision of 1 degree), this 
 * example however is not improved by use of the lookup table.
 */

final int DELTA = 45; // float only used to match turtle interface
final float REDUCE = 1/sqrt(2);
float drawLength;
float theta;
Grammar grammar;
PShape dragon;

void setup() {
  size(600, 500, P2D);
  LUT.initialize();  // needed to initialize lookup table
  createLSystem();
  smooth(8);
  translateRules();
  background(0);
  noLoop();
}

void draw(){
shape(dragon);
}

void createLSystem() {
  int generations = 14;                      // set no of recursions
  String axiom = "FX";  
  grammar = new SimpleGrammar(this, axiom);  // initialize library
  grammar.addRule('X', "+FX--FY+");          // add rule
  grammar.addRule('Y', "-FX++FY-");
  float startLength = 100;
  grammar.generateGrammar(generations);
  drawLength = startLength * pow(REDUCE, generations);
}

/**
 * If you really don't like switch
 */
void translateRules() {
  Turtle turtle = new Turtle(width / 4, height / 2, 0);
  CharacterIterator it = grammar.getIterator();
  dragon = createShape();
  dragon.beginShape(PShape.POLYGON);
  dragon.noFill();
  dragon.strokeWeight(2);
  dragon.stroke(255, 0, 0);
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    if (ch == 'F') {
      drawLine(dragon, turtle);
    }
    else if (ch == '+') {
      turnRight(turtle);
    }
    else if (ch == '-') {
      turnLeft(turtle);
    }
    else if ((ch == 'X')||(ch == 'Y')) { // do nothing
    }  
    else {
      System.err.println("character " + ch + " not in grammar");
    }
  }
  dragon.endShape(); // yes we don't want close
}

void drawLine(PShape dragon, Turtle turtle) {
  dragon.vertex(turtle.getX(), turtle.getY());
  turtle.setX(turtle.getX() + drawLength * LUT.cos(turtle.getTheta()));
  turtle.setY(turtle.getY() - drawLength * LUT.sin(turtle.getTheta()));
  dragon.vertex(turtle.getX(), turtle.getY());
}

void turnLeft(Turtle turtle) {
  turtle.setTheta(turtle.getTheta() + DELTA);
}

void turnRight(Turtle turtle) {
  turtle.setTheta(turtle.getTheta() - DELTA);
}


