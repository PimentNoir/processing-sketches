String axiom = "F";
//String rule = "Fz-F+F";
//String rule = "zF-[F]";
//String rule = "F[a+F[z--F]]";
//String rule = "FaF-F";
//String rule = "+F+aFa-";
//String rule = "[F+]FzFz-";
//String rule = "[-F+a[F]]";
//String rule = "[z]Fz+aFa";
//String rule ="aFaaFF+zF";
//String rule = "aFF-z";
//String rule = "FF[F+F]z+";
//String rule = "-F[aF]";
//String rule = "a+a+FzF";//the broken dome
//String rule = "FzzFaF+"; //the worm
//String rule = "a+F+F+-za";
//String rule = "Fz++zF"; //the wheel
//String rule = "F-zaF[a+F]"; //Qsplosion
//String rule = "-F++[aFz]"; //shaman
//String rule = "zFz-F"; //flowerish
//String rule = "Fz+FzFF"; //turkey...
String rule = "F[-zF[zF]]"; //a nice tree
//String rule = "aFaF[z[+F]]"; //freaky tree
//String rule = "F+z+F"; // mandala
//String rule = "+FFz[-z-F]"; //thorn bush
//String rule = "-FzF-"; //indescribably awesome geometric
//String rule = "aF+zF"; // ball of string
//String rule = "F[[Fa]+aF]"; //treekazoid
//String rule = "F[+F][-F][aF][zF]"; //symmetree
//String rule = "[+F]F[zF]"; // yet another tree thing
//String rule = "F[+F][--F][aF][zzF]"; //asymmetree (awesome)
//String rule = "[-aF]FFFa"; //freakstarfishcake
//String rule = "FaF-"; //geode ashtray
//String rule = "[F-F]FFa"; //star
//String rule = "F+FaF-FzF";
//String rule = "a+FzFFzF+"; //a 90 d 3 s .5 
//String rule = "F[FF]z+a-a+F[+Fzaaz]"; //thornwheel
//
//String rule = "FaF-";
//
float distance=50;
float distMax = 100;
int depth = 3;
float angle=60;
float scaleFactor = .7;
float angleStep = 1;
float zoom = 0;
float xrot = 0;
float yrot = 0;
boolean zooming = false;
float zoom_start = 0;
float x_start = 0;
float y_start = 0;
float xrot_start = 0;
float yrot_start = 0;
boolean enteringRule = false;
//
String bigString = "";
char F = 'F', minus = '-', plus = '+', a = 'a', zee = 'z', openBracket = '[', closeBracket = ']';
//
void setup() {
  size(500, 500, P3D);
  bigString = iterate(depth);
  colorMode(HSB);
  noStroke();
  PFont arial = loadFont("ArialMT-12.vlw");
  textFont(arial);
  //textMode(SCREEN);
}
void draw() {
  if (mousePressed) {
    if (zooming) {
      zoom = zoom_start + (mouseY - y_start) / height * 500;
    } else {
      xrot = xrot_start + ((float)(mouseX)- x_start) / width * 360;
      yrot = yrot_start + -1 * ((float)(mouseY) - y_start) / height * 360;
    }
  } 
  background(0);
  updateText();
  translate(width/2, height/2);
  translate(0, 0, zoom);
  rotateY(radians(xrot));
  rotateX(radians(yrot));
  lights();
  if (!enteringRule) {
    drawIt();
  }
}
void updateText() {
  fill(255);
  text("rule:", 10, 15);
  text(rule, 100, 15);
  text("current angle:", 10, 35);
  text(angle, 100, 35); 
  text("angle step:", 10, 55);
  text(angleStep, 100, 55);
  text("depth:", 10, 75);
  text(depth, 100, 75);
}
void mousePressed() {
  if (keyPressed && keyCode==SHIFT) {
    zooming = true;
    zoom_start = zoom;
    y_start = mouseY;
  } else {
    zooming = false;
    y_start = mouseY;
    yrot_start = yrot;
    x_start = mouseX;
    xrot_start = xrot;
  }
}
void keyPressed() {
  if (keyCode == RIGHT) {
    angle += angleStep;
  }
  if (keyCode == LEFT) {
    angle -= angleStep;
  }
  if (keyCode == UP) {
    angleStep *= 2;
  }
  if (keyCode == DOWN) {
    angleStep /= 2;
  }
  if ((key == 'a') && (depth < 9)) {
    depth++;
    bigString = iterate(depth);
  }
  if ((key == 'z') && (depth > 1)) {
    depth--;
    bigString = iterate(depth);
  }
  if (key == 'n') {
    generateRandomRule();
    bigString = iterate(depth);
    drawIt();
  } 
  if (key == 'q') {
    println("z: " + zoom + " xr: " + xrot + " yr: " + yrot);
  }
  //presets
  if (key == '1') {
    reset();
    rule = "FaF-";
    angle = 90;
    angleStep = .5;
    xrot = -500;
    yrot = -115;
    depth = 6;
    bigString = iterate(depth);
    drawIt();
  } 
  if (key == '2') {
    reset();
    rule = "F[+F][-F][aF][zF]"; //symmetree
    angle = 45;
    angleStep = 1;
    xrot=20;
    yrot=-35;
    zoom = 120;
    bigString = iterate(depth);
    drawIt();
  }
  if (key == '3') {
    reset();
    rule = "F[+F][--F][aF][zzF]"; //asymmetree
    angle = 198;
    angleStep = 1;
    xrot=-45;
    yrot=0;
    zoom = 182;
    bigString = iterate(depth);
    drawIt();
  }
  if (key == '4') {
    reset();
    rule = "[-aF]FFFa";
    angle = 263;
    angleStep = .25;
    xrot=-12;
    yrot=-38;
    zoom = -428;
    bigString = iterate(depth);
    drawIt();
  }
  // new rule entry
  if (key == 'e') {
    enteringRule = true;
    rule = "";
  }
  if (enteringRule) {
    if (key == 'f') {
      rule += F;
    }
    if (key == '=' || key == '+') {
      rule += plus;
    }
    if (key == '-') {
      rule += minus;
    }
    if (key == 'a') {
      rule += a;
    }
    if (key == 'z') {
      rule += zee;
    }
    if (key == '[') {
      rule += openBracket;
    }
    if (key == ']') {
      rule += closeBracket;
    }
    if (key == ENTER) {
      enteringRule = false;
      validateRule();
      reset();
      iterate(depth);
      drawIt();
    }
  }
} 
void validateRule() {
  String[] openBrackets = split(rule, openBracket);
  int nOpen = openBrackets.length - 1;
  String[] closeBrackets = split(rule, closeBracket);
  int nClose = closeBrackets.length - 1;
  if (nOpen != nClose) {
    rule = "number of [ and ] must match.  Press e to try again.";
    enteringRule = true;
  }
}
void reset() {
  angle = 60;
  depth = 3;
  angleStep = 1;
  zoom = 0;
  xrot = 0;
  yrot = 0;
}
void generateRandomRule() {
  int numNoCloseBracket = 6;
  int numWithCloseBracket = 7;
  int numSymbols = numNoCloseBracket;
  int bracketsOpen = 0;
  int nF = 0;
  int nplus = 0;
  int nminus = 0;
  int na = 0;
  int nz = 0;
  int nbrackets = 0;
  int len = 2+int(random(20));
  char[] symbolSet = {
    F, minus, plus, a, zee, openBracket, closeBracket                                                    };
  String temp  = "";
  for (int i=0; i<len; i++) {
    char newSymbol = symbolSet[int(random(numSymbols))];
    if ((numSymbols == numNoCloseBracket) && (newSymbol == openBracket)) {
      numSymbols = numWithCloseBracket;
    }
    if (newSymbol == openBracket) {
      bracketsOpen++;
      nbrackets++;
    }
    if (newSymbol == closeBracket) {
      bracketsOpen--;
    }
    if (bracketsOpen < 1) {
      numSymbols = numNoCloseBracket;
    }
    if (newSymbol == F) {
      nF++;
    }
    if (newSymbol == plus) {
      nplus++;
    }
    if (newSymbol == minus) {
      nminus++;
    }
    if (newSymbol == a) {
      na++;
    }
    if (newSymbol == zee) {
      nz++;
    }
    temp += newSymbol;
  }
  if (bracketsOpen > 0) {
    for (int i=0; i<bracketsOpen; i++) {
      temp += closeBracket;
    }
  }
  println(temp);
  rule = temp;
  if ((nF <= 1) || ((na + nz) == 0) || ((nplus + nminus) == 0)) {
    generateRandomRule();
  }
  reset();
}
void drawIt() {
  float jitter = .0001;
  for (int i = 0; i<bigString.length(); i++) {
    if (bigString.charAt(i) == F) {
      float newhue = float(i)/bigString.length()*255; 
      fill(color(newhue, 255, 255));
      //translate(0,0,distance/2);
      //box(distance/4+(jitter*i%100),distance/4+(jitter*i%100),distance+(jitter*i%100));
      //translate(0,0,distance/2);
      translate(0, distance/-2, 0);
      box(distance/4+(jitter*i%100), distance+(jitter*i%100), distance/4+(jitter*i%100));
      translate(0, distance/-2, 0);
    } else if (bigString.charAt(i) == minus) {
      rotateX(radians(-angle));
    } else if (bigString.charAt(i) == plus) {
      rotateX(radians(angle));
    } else if (bigString.charAt(i) == zee) {
      rotateZ(radians(angle));
    } else if (bigString.charAt(i) == a) {
      rotateZ(radians(-angle));
    } else if (bigString.charAt(i) == openBracket) {
      pushMatrix();  
      distance = distance * scaleFactor;
    } else if (bigString.charAt(i) == closeBracket) {
      popMatrix();    
      distance = distance / scaleFactor;
    }
  }
}
String rewrite(String s) {
  String temp = "";
  for (int i = 0; i<s.length(); i++) {
    if (s.charAt(i) == F) {
      temp += rule;
    } else {
      temp += str(s.charAt(i));
    }
  }
  return (temp);
}
String iterate(int n) {
  String[] fs = split(rule, F);
  int A = fs.length - 1;
  int B = rule.length() - A;
  int num = n;
  float predictedLength = pow(A, num) + B * (pow(A, num) - 1) / (A - 1);
  String output = axiom;
  for (int j = 0; j<n; j++) {
    output = rewrite(output);
  }
  println("A: " + A + " B: " + B);
  println("predicted length: " + predictedLength);
  println("actual length: " + output.length());
  /*  println("segments: " + pow(A, num));
   if (predictedLength < 1000) {
   println(output);
   }
   */
  return(output);
}