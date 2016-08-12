/*
 * z_fft by zambari
 * parts based on Get Line In by Damien Di Fede.
 *  
 *
 * early, not very developed version
 */
import processing.opengl.*;

import ddf.minim.analysis.*;
import ddf.minim.*;
import javax.sound.sampled.*;

Debug debug;

// Runtime variables
int fft_history_filter;
int fft_visualization_src;

// Non runtime booleans.
boolean isDebug;

PFont fontA;
Minim minim;
Minim minim2;
FFT fft;
FFT fft2;
AudioInput in; // For the big buffering
AudioInput in2; // For the small buffering
int nrOfIterations=100; // =29 fps on windows
int iterationDistance=80;
int bufferSizeSmall=512;
int fftRatio=16; // how many times bigger is the big buffer for detailed analysis
int bufferSizeBig=bufferSizeSmall*fftRatio;
int fftHistSize;
float[] logPos;
float[][] fftHistory;
float fftMin;
float fftMax; 
int nextBuffer=0;
Zcam myCamera; 
LFO lfo1;  

void setup()
{  
  size(1024, 576, P3D);
  textFont(createFont("SanSerif", 27));
  // Debug for now.
  isDebug = true;
  debug = new Debug(isDebug);
  minim = new Minim(this);
  minim2 = new Minim(this);
  if (isDebug) {
    minim.debugOn();
    minim2.debugOn();
  }
  Mixer.Info[] mixerInfo;
  mixerInfo = AudioSystem.getMixerInfo(); 
  for (int i = 0; i < mixerInfo.length; i++) {
    debug.prStr(i + ": " + mixerInfo[i].getName());
  } 
  // 0 is pulseaudio mixer on GNU/Linux
  Mixer mixer = AudioSystem.getMixer(mixerInfo[0]); 
  minim.setInputMixer(mixer);
  minim2.setInputMixer(mixer); 
  in = minim.getLineIn(Minim.STEREO, bufferSizeBig); 
  in2 = minim2.getLineIn(Minim.STEREO, bufferSizeSmall);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft2 = new FFT(in2.bufferSize(), in2.sampleRate());
  fftHistSize = fft.specSize(); // Give the FFT history the number of FFT values. 
  fftHistory = new float[nrOfIterations][fftHistSize]; // We keep nrOfIterations of all FFT values at a given point in time.
  fft_history_filter = 0;
  fft_visualization_src = 2;
  logPos = new float[fftHistSize];
  for (int i=0; i<fftHistSize; i++) { 
    logPos[i] = log(i)*40;
  };
  fftMin=log(1);
  fftMax=1/log(bufferSizeBig);
  myCamera = new Zcam();
  lfo1=new LFO(6000);
}

void keyPressed() { 
  if (key == 'h') {
    if  (key == '0') {
      fft_history_filter = 0; 
      debug.UndoPrinting();
    }
    if (key == '1') {
      fft_history_filter = 1;
      debug.UndoPrinting();
    }
  }
}

void draw()
{  
  myCamera.placeCam();
  scale(0.1);
  background(color(0, 0, 0, 15));
  stroke(255);

  // draw the waveforms of fft2 (small buffer size) 
  pushMatrix();
  scale(4);
  for (int i = 0; i < in2.bufferSize() - 1; i++)
  {
    line(i, 200+50 + in2.left.get(i)*50, i+1, 200+60 + in2.left.get(i+1)*50);
    line(i, 200+80 + in2.right.get(i)*50, i+1, 200+90 + in2.right.get(i+1)*50);
  }
  popMatrix();

  fft.forward(in.mix);
  fft2.forward(in2.mix);
 
  for (int k=nrOfIterations-1; k>0; k--) {
    for (int i = 0; i < fftHistSize; i++)
    {
      switch(fft_history_filter) {
      case 0:
        // Build the FTT values history with a sort of fading in the values     
        fftHistory[k][i]=fftHistory[k][i]*0.5+fftHistory[k-1][i]*0.5;
        //debug.prStrOnce("FFT history filter : fftHistory[k][i]=fftHistory[k][i]*0.5+fftHistory[k-1][i]*0.5"); 
        break;
      case 1:
        // Build the history without any alterations in the values
        arrayCopy(fftHistory[k-1], fftHistory[k]);
        //debug.prStrOnce("FFT history filter : No alteration"); 
        break;
      default: 
        // Build the history without any alterations in the values
        arrayCopy(fftHistory[k-1], fftHistory[k]);
        //debug.prStrOnce("FFT history filter : No alteration");
      }
    }
  }

  
  int n=0;
  float blendratio;
  for (int i = 1; i < fftHistSize; i++)
  { 
    switch(fft_visualization_src) {
    case 0:
      blendratio=(i%fftRatio)/(fftRatio*1.0);
      fftHistory[0][n]=(fft.getBand(i/(fftRatio))*(1-blendratio) + fft.getBand(i/(fftRatio)+1)*(blendratio)); 
      break;     
    case 1:    
      fftHistory[0][n]+=log(fftHistory[0][n])*10;
      break;
    case 2:
      fftHistory[0][n]=fft.getBand(i)*4;
      break;  
    case 3:
      fftHistory[0][i]=fft.getBand(floor(map(1/log(i), fftMin, fftMax, 0, bufferSizeBig)))*9;
      break;
    case 4:
      fftHistory[0][i]=fft.getBand(i)*2;
      break;
    default: 
      fftHistory[0][i]=fft.getBand(i)*4;
    }
    n++;


    //line(i*20,(int)-fft.getBand(i)*4,(i+1)*20,(int)-fft.getBand(i+1)*4);
    if (i>50) i++;  
    if (i>100) i++;  
    if (i>200) i++;  
    if (i>300) i++;  
    if (i>400) i++;  
    if (i>500) i++;
  }
  //}
  debug.prStr(frameRate + " fps");

  float x=0;
  float oldx=0;
  for (int k=1; k<nrOfIterations; k++)
  {
    stroke(255-255*k/nrOfIterations);
    for (int i = 0; i < n-1; i++)
    { //   fftHistory[k][i]=fftHistory[k-1][i];  // there must be a quicker way // circular buffer ?
      //   line(i, -fftHistory[k-1][i],-k*30, i, -fftHistory[k][i],-k*20);  
      oldx=x;
      //   x=log(i)*40.0;     
      x=logPos[i];      
      //   line(x*20, -fftHistory[k][i],-k*50, (x+1)*20, -fftHistory[k][i+1],-k*50); 
      line(oldx*20, -fftHistory[k][i], -k*iterationDistance, x*20, -fftHistory[k][i+1], -k*iterationDistance); 
      if (i%10==235)
      {
        //   line(i*20,10,i*20,-20);
      }
      //   if (i%10==0)
      //   {               line(i*20, -fftHistory[k-1][i],-k*50, (i)*20, -fftHistory[k][i],-(k+1)*50); 
      //   }  
      if ((i%10==0)&&(k==1))
        text(i, x*20, 10);
    }
    //      line(i*20, -fftHistory[k][i],-k*30, i*20, -fftHistory[k][i+1],-k*30);


    fill(255);
    resetMatrix();
    text("FFT1 val " + "ddD", 5, 20);
    text("The window being used is: ", 5, 40);
    // Last call to a debug.prStrOnce() function in the processing runtime.
    debug.DonePrinting();
  }
}

void stop()
{
  //original comment : always close Minim audio classes when you are done with them
  in.close();
  in2.close();
  minim.stop();

  super.stop();
}