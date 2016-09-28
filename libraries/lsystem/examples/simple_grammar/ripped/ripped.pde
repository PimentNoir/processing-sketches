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
import lsystem.Grammar;
import lsystem.SimpleGrammar;

/**
* ripped.pde
* Another SimpleGrammar example, features an abbreviated LSystem syntax,
* repeats are indicated by an integer preceeding the instruction character.
* Since without any prefix, an instruction is performed once a prefix of 7 will be 
* repeated 8 times (reflects additive operation). The repeat values is reset to 
* 1 following the translation of the instruction.
*/


float drawLength;
float xpos;
float ypos;
float DELTA = QUARTER_PI/4; // 11.25 degrees
ArrayList<float[]> pts;
float theta = 0;
Grammar grammar;


void setup() {
  size(500, 500);
  createLSystem();
  pts = new ArrayList<float[]>();
  stroke(255, 0, 0);
  noFill();
  smooth();
  translateRules();
  background(0);
  noLoop();
}

void createLSystem(){
  int generations = 5;                       // set no of recursions
  String axiom = "F7-F7-F7-F7-";  
  grammar = new SimpleGrammar(this, axiom);  // initialize library
  grammar.addRule('F', "F6-F76+F6-F");       // add rule
  float startLength = 180;
  grammar.generateGrammar(generations);
  drawLength = startLength * pow(0.5, generations); 
}

void translateRules() {
  xpos = width/20;  // set starting position
  ypos = height/20;
  int repeat = 1;
  float x_temp, y_temp;
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F':
      x_temp = xpos;
      y_temp = ypos;
      xpos += drawLength * repeat * cos(theta);
      ypos -= drawLength * repeat * sin(theta);
      float[] pt = {x_temp, y_temp, xpos, ypos};
      pts.add(pt);
      repeat = 1;
      break;
    case '+':
      theta += (DELTA * repeat);
      repeat = 1;
      break;
    case '-':
      theta -= (DELTA * repeat);
      repeat = 1;
      break;
    case '6':
      repeat += 6;
      break;
    case '7':
      repeat += 7;
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
