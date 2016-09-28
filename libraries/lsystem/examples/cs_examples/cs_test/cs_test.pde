/**
 * cs_test.pde
 * Demonstrates a simple context sensitive grammar without ignored
 * symbols. No real sketch, just console output that demonstrates
 * character moving in the string (without adjusting length).
 * NB: you may need to scroll the console to see all the output.
 */

/* 
 * Copyright (c) 2012-2014  Martin Prout
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


import lsystem.CSGrammar;
import java.text.CharacterIterator;

CSGrammar grammar; 

void setup() {
  createGrammar();
  testGrammar();
}

void createGrammar() {
  String axiom = "baaaaaaa";  
  grammar = new CSGrammar(this, axiom); // initialize library
  grammar.addRule("b<a", "b");          // add cs replacement rule
  grammar.addRule('b', "a");            // add simple replacement rule
}

void testGrammar() {
  CharacterIterator it;
  for (int i = 0; i < 8; i++) {  // change 8 to 16 to see scroll around CS behaviour 
    grammar.generateGrammar(i);
    it = grammar.getIterator();
    for (char ch = it.first(); ch != CharacterIterator.DONE; ch = it.next()) {
      print(ch);
    }
    print("\n");
  }
}

/**
 Test Output, note the string does not grow in length,
 but the b character travels along the string.
 
 baaaaaaa
 abaaaaaa
 aabaaaaa
 aaabaaaa
 aaaabaaa
 aaaaabaa
 aaaaaaba
 aaaaaaab
 */
