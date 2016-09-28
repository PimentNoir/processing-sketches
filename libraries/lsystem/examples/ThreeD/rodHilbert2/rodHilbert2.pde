/**
 * A 3D LSystem example with a SimpleGrammar 
 * Features use of a Turtle3D interface (RodTurtle is currently the only implementing class) 
 * Note degree rather than radian for angle, depends on use of lookup tables (and int input), also 
 * use of yaw, pitch, & roll (cf rotateX, rotateY & rotateZ) where direction of travel is Z.
 * This LSystem library is available at Kenai version 0.9.2 see also csplant2 example
 * http://kenai.com/projects/l-system-utilities/downloads
 */

/* 
 * Copyright (c) 2011/12 Martin Prout
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
import lsystem.util.*;
import lsystem.turtle.Turtle3D;
import lsystem.turtle.RodTurtle;
import lsystem.Grammar;
import lsystem.SimpleGrammar;


Grammar grammar;
Turtle3D turtle;
float distance = 300;  
int depth = 2;
ArcBall arcball;

final float[] ADJUST = {     // see render for use
  0.0, 0.5, 1.5, 3.5, 7.5
};


int THETA = 90;   // NB RodTurtle uses my LUT, where int input is for degree
int PHI = 90;     // angles (use float input for radians, see below)
//float THETA = PI/2;   
//float PHI = PI/2;     


void setup() { 
  size(800, 600, P3D);
  smooth(8);
  turtle = new RodTurtle(this);
  /**
  NB: ArcBall now centers the sketch and updates rotation in "pre()" draw
  */
  arcball = new ArcBall(this); 
  LUT.initialize(); 
  setupGrammar();
  noStroke();
}

/**
 * Encapulates the lsystem rules, and calls the grammar to create the production rules
 * depth is number of repeats, and distance is adjusted according to the number of repeats
 */

void setupGrammar() {
  grammar = new SimpleGrammar(this, "A");   
  grammar.addRule('A', "B>F<CFC<F>D+F-D>F<1+CFC<F<B1^");
  grammar.addRule('B', "A+F-CFB-F-D1->F>D-1>F-B1>FC-F-A1^");
  grammar.addRule('C', "1>D-1>F-B>F<C-F-A1+FA+F-C<F<B-F-D1^");
  grammar.addRule('D', "1>CFB>F<B1>FA+F-A1+FB>F<B1>FC1^");
  grammar.generateGrammar(depth);
  if (depth > 0) {
    distance *= 1/(pow(2, depth) - 1);
  }
}

void draw() {
  background(20, 20, 200);
  lights();
  render();
}


/**
 * Render wraps the drawing logic; 
 * ADJUST is required to centre the Hilbert as depth increases.
 * Successive calls to turtle.draw(distance, depth) draw a
 * cylinder (capped by a sphere) to complete the hilbert according 
 * to lsystem rules (ie whenever there is an 'F').
 */

void render() {
  translate(-distance * ADJUST[depth], distance * ADJUST[depth], -distance * ADJUST[depth]);  
  int repeats = 1;  
  fill(191, 191, 191);
  ambientLight(80, 80, 80);
  directionalLight(100, 100, 100, -1, -1, 1);
  ambient(122, 122, 122); 
  lightSpecular(30, 30, 30); 
  specular(122, 122, 122); 
  shininess(0.7); 
  CharacterIterator it = grammar.getIterator();
  for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
    switch (ch) {
    case 'F': 
      turtle.draw(distance, depth);  // depth sets the level of sphere/cylinder detail
      break;
    case '+':
      turtle.yaw(THETA * repeats);
      repeats = 1;
      break;
    case '-':
      turtle.yaw(-THETA * repeats);
      repeats = 1;
      break;  
    case '>':
      turtle.pitch(THETA * repeats);
      repeats = 1;
      break;
    case '<':
      turtle.pitch(-THETA * repeats);
      repeats = 1;
      break;
    case '^':
      turtle.roll(PHI * repeats);
      repeats = 1;
      break;
    case '1':
      repeats += 1;
      break;  
    case 'A':
    case 'B':
    case 'C':
    case 'D': 
      break;
    default:
      System.err.println("character " + ch + " not in grammar");
    }
  }
}


void keyReleased() {
  switch(key) {
  case '+':
    if (depth <= 3) { // guard against a depth we can't handle
      depth++;
      distance = 300;
      setupGrammar();
    }
    break;
  case '-':
    if (depth > 1) {
      depth--;
      distance = 300;
      setupGrammar();
    }
    break;
  }
}

