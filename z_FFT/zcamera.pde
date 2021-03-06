// -------- CAMERA BEGIN

class Zcam {
  public PVector camOrigin, camOriginNext, camUp, camOrbit, camOriginCurrent, camAngle, camAngleVel, camAngleNext, camOriginVel;
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
    camDistance=1000;
    camUp.x=0;
    camUp.y=1;
    camUp.z=0;
    camOrigin.x=0;
    camOrigin.y=height*0.5f;
    camOrigin.z=0;
  }

  public void placeCam()
  {  
    // FIXME: camDistance should also be handled here
    // new camera position + velocity begin
    temp=camOriginNext.copy();
    temp.sub(camOrigin); //
    temp.mult(camOriginBounce); // increase velocity factor!
    camOriginVel.add(temp);
    camOriginVel.mult(camOriginDumping);
    temp=camOriginVel.copy();
    temp.mult(camOriginSpeed);
    camOrigin.add(temp);
    // new camera position + velocity end

    // new camera angle + velocity begin
    temp=camAngleNext.copy();
    temp.sub(camAngle); // get the difference between desired and current
    temp.mult(camAngleBounce);
    camAngleVel.add(temp);
    camAngleVel.mult(camAngleDumping);
    temp=camAngleVel.copy();           
    temp.mult(camAngleSpeed);
    camAngle.add(temp);     
    // new camera angle + velocity end

    //camOriginCurrent.x=camOrigin.x;
    //camOriginCurrent.y=camOrigin.y;
    //camOriginCurrent.z=camOrigin.z+camDistance; //*sin(camOrbit.y)-distance*sin(camOrbit.x);
    camera(camOrigin.x+camLfoX.val()*camLfoXAmp, camOrigin.y+camLfoY.val()*camLfoYAmp, camOrigin.z+camDistance, camOrigin.x, camOrigin.y, camOrigin.z, camUp.x, camUp.y, camUp.z);
    translate(camOrigin.x, camOrigin.y, camOrigin.z);
    rotateX(camAngle.x);
    rotateY(camAngle.y); 
    translate(-camOrigin.x, -camOrigin.y, -camOrigin.z);
  }
}


// -------- CAMERA END

class LFO {
  float m;
  public float period;
  LFO(float per) { // constructor
    m = millis();
    period = per;
  }
  float val() // return function
  {
    return sin((((millis()-m)/period)*2*PI)); //current time vs period
  }
}