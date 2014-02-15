/**
 z_fft by zambari
 ** parts based on* Get Line In by Damien Di Fede.
 *  
 
 early, not very developed version
*/
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.opengl.*;

PFont fontA;
Minim minim;
Minim minim2;
FFT fft;
FFT fft2;
AudioInput in;
AudioInput in2;
int  nrOfIterations=100; //=29 fps on windows
int iterationDistance=80;
int bufferSizeSmall=512;
int fftRatio=16; // how many times bigger is the big buffer for detailed analisis
int bufferSizeBig=bufferSizeSmall*fftRatio;
int fftHistSize=512;  
float[] logPos=new float[fftHistSize];
float[][] fftHistory=new float[nrOfIterations][fftHistSize];
int nextBuffer=0;
 Zcam myCamera; 
 LFO lfo1;  
 
void setup()
{  
  size(1024, 576, OPENGL);
  textFont(createFont("SanSerif", 27));
  minim = new Minim(this);
  minim2 = new Minim(this);
  minim.debugOn();
  minim2.debugOn();
  in = minim.getLineIn(Minim.STEREO, bufferSizeBig);
  in2 = minim2.getLineIn(Minim.STEREO, bufferSizeSmall);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft2 = new FFT(in2.bufferSize(), in2.sampleRate());
  myCamera = new Zcam();
                  lfo1=new LFO(6000); 
   addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
                public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
                  mouseWheel(evt.getWheelRotation());
              }}); 
    
for (int i=0;i<fftHistSize;i++) { logPos[i]=log(i)*40;};
   float fftMin=log(1);
   float fftMax=1/log(bufferSizeBig);
}

void draw()
{  
  myCamera.placeCam();
  scale(0.1);
  background(color(0,0,0,15));
  stroke(255);

//   draw the waveforms
 // for(int i = 0; i < in.bufferSize() - 1; i++)
 // {
 //   line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
 //   line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
//  }
pushMatrix();
scale(4);
  for(int i = 0; i < in2.bufferSize() - 1; i++)
  {
    line(i, 200+50 + in2.left.get(i)*50, i+1,  200+60 + in2.left.get(i+1)*50);
    line(i,  200+80 + in2.right.get(i)*50, i+1, 200+90 + in2.right.get(i+1)*50);
  }
  popMatrix();

  fft.forward(in.mix);
  fft2.forward(in2.mix);
  //fft2.forward(in2.mix);
  //void logAverages(int minBandwidth, int bandsPerOctave)
  //fft.logAverages(10, 2); //use once??
  
  
 // scene.beginDraw();
 float blendratio;
    for (int k=nrOfIterations-1;k>0;k--)
//          for(int i = 0; i < 172; i++) //buahahah dirty!!!
           for(int i = 0; i < 272; i++) //buahahah dirty!!!
                {
              //   arrayCopy(fftHistory[k-1], fftHistory[k]);
                fftHistory[k][i]=fftHistory[k][i]*0.5+fftHistory[k-1][i]*0.5;
                }  
        
       int n=0;
        for(int i = 1; i <fftHistSize ; i++)
        {          blendratio=(i%fftRatio)/(fftRatio*1.0);
                    fftHistory[0][n]=(fft2.getBand(i/(fftRatio))*(1-blendratio)+
                                  fft2.getBand(i/(fftRatio)+1)*(blendratio)); 
        //   fftHistory[0][n]+=log(fftHistory[0][n])*10;  
                 fftHistory[0][n]=fft.getBand(i)*4;
                 n++;
        //  fftHistory[0][i]=fft.getBand(floor(map(1/log(i),fftMin,fftMax,0,bufferSizeBig)))*9;
        //  fftHistory[0][i]=fft.getBand(i)*2;
        //  line(i*20,(int)-fft.getBand(i)*4,(i+1)*20,(int)-fft.getBand(i+1)*4);
  if (i>50) i++;  
  if (i>100) i++;  
   if (i>200) i++;  
  if (i>300) i++;  
  if (i>400) i++;  
  if (i>500) i++;  
 
      }        
      println(frameRate);
  
       float x=0;
       float oldx=0;
    for (int k=1;k<nrOfIterations;k++)
                {
        stroke(255-255*k/nrOfIterations);
          for(int i = 0; i < n-1; i++)
          {         //      fftHistory[k][i]=fftHistory[k-1][i];  // there must be a quicker way // circular buffer bayve?
                    //   line(i, -fftHistory[k-1][i],-k*30, i, -fftHistory[k][i],-k*20);  
                oldx=x;
                      //  x=log(i)*40.0;     
                x=logPos[i];      
//                        line(x*20, -fftHistory[k][i],-k*50, (x+1)*20, -fftHistory[k][i+1],-k*50); 
                          line(oldx*20, -fftHistory[k][i],-k*iterationDistance, x*20,-fftHistory[k][i+1],-k*iterationDistance); 
                if (i%10==235)
                {
                // line(i*20,10,i*20,-20); 
                }
            //     if (i%10==0)
            //   {               line(i*20, -fftHistory[k-1][i],-k*50, (i)*20, -fftHistory[k][i],-(k+1)*50); 
            //   }  
                  if ((i%10==0)&&(k==1))
                    text(i,x*20,10);
               
                    }
       //              line(i*20, -fftHistory[k][i],-k*30, i*20, -fftHistory[k][i+1],-k*30);  
                     
    
  } 
  
  fill(255);
  resetMatrix();
  text("FFt1 val " + "ddD", 5, 20);
  text("The window being used is: ", 5, 40);
  //     fftLin.linAverages(30);
  //  fftLog = new FFT(jingle.bufferSize(), jingle.sampleRate());
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages

}


void stop()
{
  //original comment : always close Minim audio classes when you are done with them
  in.close();
  minim.stop();

  super.stop();
}

