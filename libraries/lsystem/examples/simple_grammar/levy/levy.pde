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
 * levy.pde  
 * (a levy carpet, created by two levy curves use axiom 'FX' for a single curve)
 * Demonstrates the use of a Simple Grammar with two 'substitution' rules.
 * A CharacterIterator instance used to create the grammar, is re-used to 
 * parse the hidden 'production' string.
 * lines are 'stored' as vertices in a PShape object
 */

final float DELTA = radians(45); 
final float REDUCE = 1/sqrt(2);
float distance = 80;
Grammar grammar;
PShape levy;

void setup() {
  size(600, 600, P2D);
  createLSystem(16);
  levy = generateShape(color(255, 0, 0));  
  noLoop();
}

void draw() {
  background(0);
  shape(levy);
}

void createLSystem(int generations) {
  String axiom = "FX4-FX";  
  grammar = new SimpleGrammar(this, axiom);  // initialize library
  grammar.addRule('X', "+FX2-FX+");          // add rule
  grammar.generateGrammar(generations);
  distance *= pow(REDUCE, generations);
}

/**
 * Abbreviated form and repeat saves some multiple loops
 */
PShape generateShape(color st){
  int repeat = 1;
  Turtle turtle = new Turtle(width * 0.72, height * 0.5, 0);
  CharacterIterator it = grammar.getIterator();
  PShape pshape = createShape();
  pshape.beginShape(PShape.POLYGON);
  pshape.noFill();
  pshape.strokeWeight(2);
  pshape.stroke(st);
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      pshape.vertex(turtle.getX(), turtle.getY());
      turtle.setX(turtle.getX() - distance * cos(turtle.getTheta()));
      turtle.setY(turtle.getY() - distance * sin(turtle.getTheta()));
      break;
    case'+':
      turnRight(turtle, repeat);
      repeat = 1;
      break;
    case '-':
      turnLeft(turtle, repeat);
      repeat = 1;
      break;
    case 'X': // do nothing
      break;
    case '2':   // set repeat using char ascii code 
    case '4':   // 48 = ascii '0'
      repeat = (int)ch - 48;
      break;  
    default:
      System.err.println("character " + ch + " not in grammar");
      break;
    }
  }
    pshape.vertex(turtle.getX(), turtle.getY());
    pshape.endShape(); // yes we don't want close
    return pshape;
  }

  void turnLeft(Turtle turtle, int rep) {
    turtle.setTheta(turtle.getTheta() + DELTA * rep);
  }

  void turnRight(Turtle turtle, int rep) {
    turtle.setTheta(turtle.getTheta() - DELTA * rep);
  }

