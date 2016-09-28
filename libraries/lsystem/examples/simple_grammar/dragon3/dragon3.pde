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
 * parse the 'production' string.
 * Note the use of P2D, and PShape to store vertices
 */

final float DELTA = radians(45); 
final float REDUCE = 1/sqrt(2);
String axiom = "FX";
float distance = 100;
Grammar grammar;
PShape dragon1, dragon2;

void setup() {
  size(600, 500, P2D);
  grammar = new SimpleGrammar(this, axiom);  // initialize library
  grammar.addRule('X', "+FX--FY+");          // add rules
  grammar.addRule('Y', "-FX++FY-");
  createLSystem(14);                         // 14 generations
  dragon1 = generateShape(color(250, 0, 0)); 
  dragon2 = generateShape(color(250, 0, 250));   
  noLoop();
}

void draw() {
  background(0);
  shape(dragon1);
  translate(30, -200);
  shape(dragon2);
}

void createLSystem(int generations) { 
  grammar.generateGrammar(generations);
  distance *= pow(REDUCE, generations);
}

PShape generateShape(color st) {
  PShape dragon = createShape();
  dragon.beginShape(PShape.POLYGON);
  dragon.stroke(st);
  dragon.strokeWeight(2);
  dragon.noFill();
  Turtle turtle = new Turtle(width/4, height/2, 0.0);  
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      dragon.vertex(turtle.getX(), turtle.getY());
      turtle.setX(turtle.getX() + distance * cos(turtle.getTheta()));
      turtle.setY(turtle.getY() + distance * sin(turtle.getTheta()));      
      break;
    case '+':
      turtle.setTheta(turtle.getTheta() + DELTA);
      break;
    case '-':
      turtle.setTheta(turtle.getTheta() - DELTA);
      break;
    case 'X':  // recognize grammar and do nothing
      break;
    case 'Y':  // recognize grammar and do nothing
      break;
    default:
      System.err.println("character " + ch + " not in grammar");
    }
  }
  dragon.vertex(turtle.getX(), turtle.getY()); 
  dragon.endShape();
  return dragon;
}



