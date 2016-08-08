// word clock

// global variables

PFont bold;
PFont reg;

String prefix = "It's";

String[] the_hour = {"twelve", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"}; 
String[] the_min1 = {"o", "ten", "twenty", "thirty", "forty", "fifty", ""}; 
String[] the_min2 = {"", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty"}; 

void setup() {  
  size(170, 140);
  smooth();
  //  String[] fontList = PFont.list();
  //  println(fontList);
}

void draw() {
  background(0);
  int h = hour();
  if (h > 12) {
    h = h -12;
  }

  // comment out this section to run

  int m = minute(); 
  int s = second();

  // comment out this section to test (change the values to test)

  // int m = 20; 

  int tm2 = m%10;
  int tm1 = (m-tm2)/10;

  //println (tm1);
  //println (tm2);


  if (tm2 >= 10 && tm2 <=20) {
    tm2 = tm1*10+tm2;
    tm1 = 6;
  }

  //println (tm1);
  //println (tm2);

  bold = createFont("Arial Bold", 18);
  ;
  reg = createFont("Arial", 18);

  textSize(50);
  //textFont(reg,30);
  //text(prefix, 20, 40);
  textFont(bold, 30);
  text(the_hour[h], 20, 40);
  textFont(reg, 30);

  // from 1 to 9
  if (tm1 == 1 && tm2 >= 1 && tm2 <= 9) {
    //text(the_min1[tm1], 20, 80);
    text(the_min2[tm2+10], 20, 80);
    //print("*");
  }

  // from 10 to 20
  if (tm1 == 0 && tm2 >= 1 && tm2 <=10) {
    text(the_min1[tm1], 20, 80);
    text(the_min2[tm2], 20, 115);
    //print("/");
  }

  // from 21 to 59
  if (minute() >= 21 && tm1 > 1) {
    text(the_min1[tm1], 20, 80);
    text(the_min2[tm2], 20, 115);
    //println (tm1);
    //println (tm2);
    //print("b");
  }
}