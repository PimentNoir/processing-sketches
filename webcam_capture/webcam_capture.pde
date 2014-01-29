import processing.video.*;
Capture webcam;
// nombre de lignes copiées en hauteur
int hauteur=2;

void setup() 
{
 size(640, 480);
 frameRate(30);
 webcam = new Capture(this, width, height, 30);
}

void draw() {
 
 if(webcam.available()) { 
   webcam.read(); 
   // choisir le point à copier
   int wichline=int(random(height));
   // copier depuis l'image vers l'ecran
   copy(webcam, 0, wichline, width, hauteur, 0, wichline, width, hauteur);
 } 
}

// pour avoir la capture totale affichée, appuyer sur une touche
void keyPressed() {
   webcam.read(); 
   image(webcam,0,0);
}
