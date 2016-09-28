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
import lsystem.turtle.Pen;
import lsystem.collection.PenStack;
import lsystem.Grammar;
import lsystem.SimpleGrammar;


final float DELTA = PI/5; // 36 degrees
Grammar grammar; 
String axiom;
String rule;
float startLength;
float drawLength;
float theta;
float xpos;
float ypos;
PenStack ps;
int BLUE = 70<<24|0<<16|0<<8|200; // create color int using bit ops
int RED = 70<<24|200<<16|0<<8|0;

void setup() {
  size(600, 600);
  createLSystem();
  ps = new PenStack(this);
  strokeWeight(3);
  noFill();
  smooth();
  background(0);
  translateRules();
}

void createLSystem(){
  int generations = 5;               // set no of recursions
  axiom = "[X]2+[X]2+[X]2+[X]2+[X]"; // note use of abbreviated axiom and rules 
  grammar = new SimpleGrammar(this, axiom); // initialize custom library
  grammar.addRule('F', "");                 // add char substitution rules
  grammar.addRule('W', "YBF2+ZRF4-XBF[-YBF4-WRF]2+");
  grammar.addRule('X', "+YBF2-ZRF[3-WRF2-XBF]+");
  grammar.addRule('Y', "-WRF2+XBF[3+YBF2+ZRF]-");
  grammar.addRule('Z', "2-YBF4+WRF[+ZRF4+XBF]2-XBF");
  startLength = 600;
  grammar.generateGrammar(generations);
  drawLength = startLength * pow(0.5, generations); 
}

void translateRules() {
  float x_temp, y_temp;
  int repeat = 1;
  Pen pen = new Pen(this, width/2, height/2, 0.0, RED);
  CharacterIterator it = grammar.getIterator(); // re-use grammar iterator
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()){
    switch (ch) {
    case 'F':
      x_temp = pen.getX();
      y_temp = pen.getY();
      pen.setX(x_temp - drawLength * cos(pen.getTheta()));
      pen.setY(y_temp - drawLength * sin(pen.getTheta()));      
      stroke(pen.getColor());
      line(x_temp, y_temp, pen.getX(), pen.getY());
      break;
    case '+':
      pen.setTheta(pen.getTheta() + DELTA * repeat);
      repeat = 1;
      break;
    case '-':
      pen.setTheta(pen.getTheta() - DELTA * repeat);
      repeat = 1;
      break;
    case '[':
      ps.push(new Pen(pen)); 
      break;
    case ']':
      pen = ps.pop();
      break;
    case 'B':
      pen.setColor(BLUE);
      break;
    case 'R':
      pen.setColor(RED);
      break;  
    case 'W':   // do nothing other than
    case 'X':   // confirm W,X,Y&Z as valid grammar
    case 'Y':
    case 'Z':
      break;
    case '2':   // set repeat using char ascii code 
    case '3':   // 48 = ascii '0'
    case '4':
      repeat = (int)ch - 48;
      break;  
    default:
      System.err.println("character " + ch + " not in grammar");
      break;
    }
  }
}





