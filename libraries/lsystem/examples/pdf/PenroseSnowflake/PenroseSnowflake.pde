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


import lsystem.turtle.Turtle;   // My custom LSystem library available at Kenai version 0.7.3
import lsystem.collection.TurtleStack;// http://kenai.com/projects/l-system-utilities/downloads
import lsystem.Grammar;
import lsystem.SimpleGrammar;
import java.text.CharacterIterator;

/** 
 * PenroseSnowflake.pde
 * Loosely based on a processing PenroseSnowflake
 * processing sketch by Geraldine Sarmiento 
 */
import processing.pdf.*;


ArrayList<float[]>pts;
final float DELTA = PI/10; // 36 degrees
Grammar grammar; 
String axiom;
String rule;
String production;
float startLength;
float drawLength;
float theta;
float xpos;
float ypos;
TurtleStack ts;
PFont myFont; 

void setup() {
  size(700,  900);   
  createLSystem();
  pts = new ArrayList<float[]>();
  ts = new TurtleStack(this);
  theta = PI/5;
  stroke(0);
  strokeWeight(3);
  noFill();
  smooth();
  translateRules();
  background(255);
  myFont = createFont("/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf", 18); // for the benefit debian users?
  // myFont = createFont("any suitable ttf font", 18);
  renderToPDF();
}

void createLSystem() {
  int generations = 3;                 // set no of recursions
  String axiom = "F3-F3-F3-F3-F3-";  
  grammar = new SimpleGrammar(this,  axiom);  // initialize custom library
  grammar.addRule('F', "F3-F3-F45-F++F3-F"); // add rule

  float startLength = 350;
  grammar.generateGrammar(generations);
  drawLength = startLength * pow(0.4, generations);
}

void translateRules() {
  float x_temp,  y_temp;
  int repeat = 1;
  Turtle turtle = new Turtle(width*0.95,  height/3, theta);
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      x_temp = turtle.getX();
      y_temp = turtle.getY();
      turtle.setX(x_temp - drawLength * cos(turtle.getTheta()));
      turtle.setY(y_temp - drawLength * sin(turtle.getTheta()));
      float[] temp = {
        x_temp,  y_temp,  turtle.getX(),  turtle.getY()
        };
        pts.add(temp);
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
}

void renderToPDF() {
  beginRecord(PDF, "PenroseSnowflake.pdf");
  for (float[] pt : pts) {
    line(pt[0], pt[1], pt[2], pt[3]);
  }
  fill(0);
  textFont(myFont, 18);
  text("Penrose Snowflake", 300, 50);
  text(grammar.toString(), 100, 720);
  endRecord();
}

