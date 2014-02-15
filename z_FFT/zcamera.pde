
class Zcam {
  public PVector camOrigin,camOriginNext,camUp,camOrbit,camOriginCurrent,camAngle,camAngleVel,camAngleNext,camOriginVel;
  PVector temp;
 public int camXmouse;
 public int camYmouse;
  public float camLfoXAmp=1;
  public float camLfoYAmp=1;
  float camOriginDumping=0.9;
  float camOriginSpeed=0.005;
  float camAngleDumping=0.9;
  float camAngleSpeed=0.005;
  float camAngleBounce=2;
  float camOriginBounce=2;
  public float camLfoXPeriod=5000;
  public float camLfoYPeriod=4000;
 LFO camLfoX;  
 LFO camLfoY; 
 public float camDistance;
  Zcam()
   {
     camLfoX = new LFO(camLfoXPeriod);
     camLfoY = new LFO(camLfoYPeriod);
     temp=new PVector();
      camOriginNext = new PVector();
       camOriginCurrent = new PVector();
       camOrigin = new PVector();
       camOriginVel = new PVector();
       camUp = new PVector();
       camAngle= new PVector();
       camAngleNext= new PVector();
       camAngleVel= new PVector();
    camDistance=300;
                 camUp.x=0;
                 camUp.y=1;
                 camUp.z=0;
       camOrigin.x=width/2.0;
       camOrigin.x=height/2.0;
       camOrigin.x=0;
  
    }

 public void placeCam()
 {  
// new camera position + velocity begin
                temp=camOriginNext.get();
                temp.sub(camOrigin); //
               temp.mult(camOriginBounce); // increase velocity factor!
                camOriginVel.add(temp);
                camOriginVel.mult(camOriginDumping);
                temp=camOriginVel.get();
                temp.mult(camOriginSpeed);
                camOrigin.add(temp);
// new camera position + velocity end

// new camera angle + velocity begin
                temp=camAngleNext.get();
                temp.sub(camAngle); // get the difference between desired and current
                temp.mult(camAngleBounce);
                camAngleVel.add(temp);
                camAngleVel.mult(camAngleDumping);
                temp=camAngleVel.get();           
                temp.mult(camAngleSpeed);
                camAngle.add(temp);     
                
// new camera angle + velocity end

  //camOriginCurrent.x=camOrigin.x;
  //camOriginCurrent.y=camOrigin.y;
  //camOriginCurrent.z=camOrigin.z+camDistance; //*sin(camOrbit.y)-distance*sin(camOrbit.x);
   camera(camOrigin.x+camLfoX.val()*camLfoXAmp,camOrigin.y+camLfoY.val()*camLfoYAmp,camOrigin.z+camDistance, camOrigin.x, camOrigin.y, camOrigin.z, camUp.x, camUp.y, camUp.z);
    translate(camOrigin.x,camOrigin.y,camOrigin.z);
    rotateX(camAngle.x);
    rotateY(camAngle.y); 
    translate(-camOrigin.x,-camOrigin.y,-camOrigin.z);
 }

}


// -------- CAMERA END


//-----------------------	
void mouseWheel(int delta) {
  //println(delta); 
 myCamera.camOriginNext.z+=delta*200;
}
//-----------------------	
void mousePressed()
{
  myCamera.camXmouse=mouseX;
  myCamera.camYmouse=mouseY;
}
//-----------------------	
void mouseDragged() { 
          //  statements
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

class LFO {
       float m;
       public float period;
    LFO(float per) { // constructor
          m = millis();
          period=per; }
    float val() // return function
       {
        return sin((((millis()-m)/period)*2*PI)); //current time vs period
       }
}
