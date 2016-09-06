
// Number of keys state to track
int nrKeys = 18;
boolean[] keys;

void keyPressed() { 
  if (key == '0') {
    keys[0] = true;
  }
  if (key == '1') {
    keys[1] = true;
  }
  if (key == '2') {
    keys[2] = true;
  }
  if (key == '3') {
    keys[3] = true;
  }
  if (key == '4') {
    keys[4] = true;
  }
  if (key == '5') {
    keys[5] = true;
  }
  if (key == '6') {
    keys[6] = true;
  }
  if (key == '7') {
    keys[7] = true;
  }
  if (key == '8') {
    keys[8] = true;
  }
  if (key == '9') {
    keys[9] = true;
  }
  if (key == '-') {
    keys[10] = true;
  }
  if (key == '+') {
    keys[11] = true;
  }
  if (key == 't') {
    keys[12] = true;
  }
  if (key == 'f') {
    keys[13] = true;
  }
  if (key == 'v') {
    keys[14] = true;
  }
  if (key == 's') {
    keys[15] = true;
  }
  if (key == 'd') {
    keys[16] = true;
  }
  if (key == 'm') {
    keys[17] = true;
  }
  if (keys[13] && keys[0]) {
    fft_history_filter = 0; 
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[1]) {
    fft_history_filter = 1;
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[2]) {
    fft_history_filter = 2;
    SMAFirstrun = true;
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[3]) {
    fft_history_filter = 3;
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[4]) {
    fft_history_filter = 4;
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[5]) {
    fft_history_filter = 5;
    Debug.UndoPrinting();
  }
  if (keys[13] && keys[6]) {
    fft_history_filter = 6;
    Debug.UndoPrinting();
  }
  if (keys[14] && keys[0]) {
    visualization_type = 0; 
    Debug.UndoPrinting();
  }
  if (keys[14] && keys[1]) {
    visualization_type = 1;
    Debug.UndoPrinting();
  }
  if (keys[14] && keys[2]) {
    visualization_type = 2;
    Debug.UndoPrinting();
  }
  if (keys[14] && keys[3]) {
    visualization_type = 3;
    Debug.UndoPrinting();
  }
  float inc = 0.01f;
  if (keys[15] && keys[10] && smooth_factor > inc && fft_history_filter == 0) {
    smooth_factor -= inc;
    Debug.UndoPrinting();
  }
  if (keys[15] && keys[11] && smooth_factor < 1 - inc && fft_history_filter == 0) {
    smooth_factor += inc;
    Debug.UndoPrinting();
  }
  if (keys[16] && keys[10] && decay > inc && fft_history_filter == 1) {
    decay -= inc;
    Debug.UndoPrinting();
  }
  if (keys[16] && keys[11] && decay < 1 - inc && fft_history_filter == 1) {
    decay += inc;
    Debug.UndoPrinting();
  }
  if (keys[17] && keys[10]) {
    valueMultiplicator--;
    Debug.UndoPrinting();
  }
  if (keys[17] && keys[11]) {
    valueMultiplicator++;
    Debug.UndoPrinting();
  }
}

void keyReleased()
{
  if (key == '0')
    keys[0] = false;
  if (key == '1')
    keys[1] = false;
  if (key == '2')
    keys[2] = false;
  if (key == '3')
    keys[3] = false;
  if (key == '4')
    keys[4] = false;
  if (key == '5')
    keys[5] = false;
  if (key == '6')
    keys[6] = false;
  if (key == '7')
    keys[7] = false;
  if (key == '8')
    keys[8] = false;
  if (key == '9')
    keys[9] = false;
  if (key == '-')
    keys[10] = false;
  if (key == '+')
    keys[11] = false;
  if (key == 't')
    keys[12] = false;
  if (key == 'f')
    keys[13] = false;
  if (key == 'v')
    keys[14] = false;
  if (key == 's')
    keys[15] = false;
  if (key == 'd')
    keys[16] = false;
  if (key == 'm')
    keys[17] = false;
}

//-----------------------  
void mouseWheel(MouseEvent msEvent) {  
  float delta = msEvent.getCount();
  if (delta > 0) {
    myCamera.camDistance += delta*4;
  }
  if (delta < 0) {
    myCamera.camDistance += delta*4;
  }
}
//-----------------------  
void mousePressed()
{
  myCamera.camXmouse=mouseX;
  myCamera.camYmouse=mouseY;
}
//-----------------------  
void mouseDragged() { 
  //statements
  // text((-myCamera.camXmouse+mouseX)/100.0,200,200);
  // text(myCamera.camYmouse-mouseY,200,300);

  if (mouseButton == RIGHT) {
    myCamera.camAngleNext.y+=(-myCamera.camXmouse+mouseX)/100.0;
    myCamera.camAngleNext.x+=(myCamera.camYmouse-mouseY)/100.0;
  } 

  if (mouseButton == LEFT)
  {
    myCamera.camOriginNext.x+=(myCamera.camXmouse-mouseX);
    myCamera.camOriginNext.y+=(myCamera.camYmouse-mouseY);
  }

  myCamera.camXmouse=mouseX;
  myCamera.camYmouse=mouseY;
}


//-----------------------