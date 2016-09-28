import java.text.CharacterIterator;
import lsystem.util.*;
import lsystem.turtle.*;
import lsystem.collection.*;
import lsystem.collection.csrule.*;
import lsystem.*;
import lsystem.collection.wrule.*;

/* 
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


import lsystem.turtle.Turtle;
import lsystem.Grammar;
import lsystem.SimpleGrammar;

/**
* dragon.pde
* Demonstrates the use of a Simple Grammar with two 'substitution' rules.
* A CharacterIterator instance is used to create the grammar, and is  
* re-used to parse the generated 'production' string.
* lines are 'stored' as a crude list of pts
*/

final float DELTA = radians(45); // 45 degrees to radians
final float REDUCE = 1/sqrt(2);

float distance = 100;
ArrayList<float[]>pts; 
Grammar grammar;

void setup() {
  size(600, 500);
  createLSystem(14);              // 14 generations
  pts = new ArrayList<float[]>();
  strokeWeight(2);
  stroke(255, 0, 0);
  noFill();
  smooth();
  translateRules();
  background(0);
  noLoop();
}

void createLSystem(int generations){
  String axiom = "FX";  
  grammar = new SimpleGrammar(this, axiom);  // initialize library
  grammar.addRule('X', "+FX--FY+");          // add rule
  grammar.addRule('Y', "-FX++FY-");
  grammar.generateGrammar(generations);
  distance *= pow(REDUCE, generations); 
}

void translateRules() {
  Turtle turtle = new Turtle(width/4, height/2, 0.0);
  float x_temp, y_temp;
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      x_temp = turtle.getX();
      y_temp = turtle.getY();
      turtle.setX(x_temp + distance * cos(turtle.getTheta()));
      turtle.setY(y_temp + distance * sin(turtle.getTheta()));
      float[] temp = {x_temp, y_temp, turtle.getX(), turtle.getY()};
      pts.add(temp);
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
}

void draw() {
  for (float[] pt : pts) {
    line(pt[0], pt[1], pt[2], pt[3]);
  }
}


