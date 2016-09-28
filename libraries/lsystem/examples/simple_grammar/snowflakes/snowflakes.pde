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
import lsystem.turtle.Turtle;          // My custom LSystem library available at Kenai version 0.9.1
import lsystem.collection.TurtleStack; // http://kenai.com/projects/l-system-utilities/downloads
import lsystem.Grammar;
import lsystem.SimpleGrammar;

/** 
 * Penrose3.pde
 * Loosely based on a processing PenroseSnowflake
 * processing sketch by Geraldine Sarmiento 
 */
import processing.pdf.*;

final float DELTA = PI/10; // 36 degrees
Grammar grammar; 
String axiom = "F3-F3-F3-F3-F3-";  
float distance = 250;
PShape penrose, penrose2;
TurtleStack ts;

void setup() {
  size(700,  900, P2D);   
  ts = new TurtleStack(this);
  grammar = new SimpleGrammar(this,  axiom);  // initialize custom library
  grammar.addRule('F', "F3-F3-F45-F++F3-F"); // add rule
  createLSystem(3);   // 3 generations
  ts = new TurtleStack(this);  
  penrose = generateShape(color(255, 0, 0));
  penrose2 = generateShape(color(0, 0, 255));
}

void draw(){
  background(255);
  translate(-width/4, -height/8);
  shape(penrose);
  scale(0.8, 0.8);
  translate(width/2, height*0.7);
  shape(penrose2);
}

void createLSystem(int generations) {  
  grammar.generateGrammar(generations);
  distance *= pow(0.4, generations);
}

PShape generateShape(color st) {
  PShape pshape = createShape();
  pshape.beginShape();
  pshape.stroke(st);
  pshape.strokeWeight(2);
  pshape.noFill();
  int repeat = 1;
  Turtle turtle = new Turtle(width*0.95,  height/3, 2 * DELTA);
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      pshape.vertex(turtle.getX(), turtle.getY());
      turtle.setX(turtle.getX() - distance * cos(turtle.getTheta()));
      turtle.setY(turtle.getY() - distance * sin(turtle.getTheta()));
      break;
    case '+':
      turtle.setTheta(turtle.getTheta() + DELTA * repeat);
      repeat = 1;
      break;
    case '-':
      turtle.setTheta(turtle.getTheta() - DELTA * repeat);
      repeat = 1;
      break;
    case '[':
      ts.push(new Turtle(turtle)); // NB has a copy constructor 
      break;
    case ']':
      turtle = ts.pop();
      break; 
    case '3':   // 48 = ascii '0'
    case '4':
    case '5':   // increment repeat using char ascii code 
      repeat += (int)ch - 48;
      break;  
    default:
      System.err.println("character " + ch + " not in grammar");
      break;
    }
  }
  pshape.vertex(turtle.getX(), turtle.getY()); 
  pshape.endShape();
  return pshape;
}