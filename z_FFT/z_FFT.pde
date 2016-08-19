/*
 * z_FFT by zambari and Jérôme Benoit <jerome.benoit@piment-noir.org
 * parts based on Get Line In by Damien Di Fede.
 *  
 *
 * early, not very developed version
 */
import processing.opengl.*;

import ddf.minim.analysis.*;
import ddf.minim.*;
import javax.sound.sampled.*;

import java.util.Arrays;

Debug debug;

// Runtime variables
boolean[] keys;
int fft_history_filter;
int visualization_type;


// Non runtime booleans.
boolean isDebug;
boolean isZeroNaN;

//PFont fontA;
Minim minim;
Minim minim2;
FFT fft;
FFT fft2;
WindowFunction fftWindow;
AudioInput in; // For the big buffering
AudioInput in2; // For the small buffering
int nrOfIterations = 75;
int iterationDistance = 55;
int fftForwardCount;
int bufferSizeSmall = 512;
//int fftRatio = 16; // How many times bigger is the big buffer for detailed analysis?
int fftRatio = 4; // How many times bigger is the big buffer for detailed analysis?
int bufferSizeBig = bufferSizeSmall * fftRatio;
int fftHistBufferCount;
int fftHistSize;
float[] logPos;
float[][] fftHistory;
float fftMin;
float fftMax; 
Zcam myCamera; 
LFO lfo1;  

void setup()
{  
  size(1024, 576, P3D);
  textFont(createFont("SanSerif", 27));
  keys = new boolean[9]; // Number of keys to track
  for (int i = 0; i < keys.length; i++ )
  {
    keys[i] = false;
  }
  // Zero NaN FFT values to avoid display glitches
  isZeroNaN = false;
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
  // index = 0 is pulseaudio mixer on GNU/Linux
  Mixer mixer = AudioSystem.getMixer(mixerInfo[0]); 
  minim.setInputMixer(mixer);
  minim2.setInputMixer(mixer); 
  in = minim.getLineIn(Minim.STEREO, bufferSizeBig); 
  in2 = minim2.getLineIn(Minim.STEREO, bufferSizeSmall);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft2 = new FFT(in2.bufferSize(), in2.sampleRate());
  fft.noAverages();
  fft2.noAverages();
  fftWindow = FFT.HAMMING;
  fft.window(fftWindow);
  fft2.window(fftWindow);
  fftForwardCount = 0;
  //fftHistBufferCount = 0;
  fftHistSize = fft.specSize(); // Give the FFT history buffer size for a fixed index the number of FFT values. 
  fftHistory = new float[nrOfIterations][fftHistSize]; // We keep nrOfIterations of all FFT values at a given point in time.
  fft_history_filter = 1;
  visualization_type = 0;
  logPos = new float[fftHistSize];
  for (int i = 0; i < fftHistSize; i++) { 
    logPos[i] = log(i)*40;
  };
  fftMin = log(1);
  fftMax = 1/log(bufferSizeBig);
  myCamera = new Zcam();
  lfo1 = new LFO(6000);
}

float ZeroNaNValue(float Value) {
  if ((Float.isNaN(Value)) && isZeroNaN) { 
    return 0.0f;
  } else {
    return Value;
  }
}  

void keyPressed() { 
  if (key == 'f') {
    keys[0] = true;
  }
  if (key == 'v') {
    keys[1] = true;
  }
  if (key == '0') {
    keys[2] = true;
  }
  if (key == '1') {
    keys[3] = true;
  }
  if (key == '2') {
    keys[4] = true;
  }
  if (key == '3') {
    keys[5] = true;
  }
  if (key == '4') {
    keys[6] = true;
  }
  if (key == '5') {
    keys[7] = true;
  }
  if (key == '6') {
    keys[8] = true;
  }
  if (keys[0] && keys[2]) {
    fft_history_filter = 0; 
    debug.UndoPrinting();
  }
  if (keys[0] && keys[3]) {
    fft_history_filter = 1;
    debug.UndoPrinting();
  }
  if (keys[0] && keys[4]) {
    fft_history_filter = 2;
    debug.UndoPrinting();
  }
  if (keys[0] && keys[5]) {
    fft_history_filter = 3;
    debug.UndoPrinting();
  }
  if (keys[0] && keys[6]) {
    fft_history_filter = 4;
    debug.UndoPrinting();
  }
  if (keys[0] && keys[7]) {
    fft_history_filter = 5;
    debug.UndoPrinting();
  }
  if (keys[0] && keys[8]) {
    fft_history_filter = 6;
    debug.UndoPrinting();
  }
  if (keys[1] && keys[2]) {
    visualization_type = 0; 
    debug.UndoPrinting();
  }
  if (keys[1] && keys[3]) {
    visualization_type = 1;
    debug.UndoPrinting();
  }
}

void keyReleased()
{
  if (key == 'f')
    keys[0] = false;
  if (key == 'v')
    keys[1] = false;
  if (key == '0')
    keys[2] = false;
  if (key == '1')
    keys[3] = false;
  if (key == '2')
    keys[4] = false;
  if (key == '3')
    keys[5] = false;
  if (key == '4')
    keys[6] = false;
  if (key == '5')
    keys[7] = false;
  if (key == '6')
    keys[8] = false;
} 

// How to fill the FFT history at histIndex with values?
// FIXME?: Pass the filter type as an argument
void fill_fft_history_filter(int histIndex, int fftIndex, float fftValue) {
  switch(fft_history_filter) {
  case 0:
    // Build the FTT history values with an Exponential Moving Average aka EMA filter with smooth factor = 0.5f on fft.getBand(fftIndex) values
    fftHistory[histIndex][fftIndex]=fftHistory[histIndex][fftIndex]*0.5+fftValue*0.5;
    //debug.prStrOnce("FFT history filter : fftHistory[fftHistBufferCount][i]=fftHistory[fftHistBufferCount][i]*0.5+fftHistory[fftHistBufferCount-1][i]*0.5"); 
    break;
  case 1:
    // Build the FTT history values with a log decay with decay = 0.5f on fft.getBand(fftIndex) values
    fftHistory[histIndex][fftIndex] = max(fftHistory[histIndex][fftIndex] * 0.5, log(1 + fftValue)); 
    break;
  case 2:
    float blendratio=(fftIndex%fftRatio)/(fftRatio*1.0);
    debug.prStr("blendratio = " + blendratio);
    fftHistory[histIndex][fftIndex]=(fft.getBand(fftIndex/(fftRatio))*(1-blendratio) + fft.getBand(fftIndex/(fftRatio)+1)*(blendratio)); 
    break;
  case 3: 
    /* if (fftHistBufferCount == 0 && fftForwardCount == 0) {
     fftHistory[histIndex][fftIndex]=fft.getBand(fftIndex);
     } else if (fftHistBufferCount == 0 && fftForwardCount != 0) {
     // Do nothing
     } else { */
    if (fftIndex > 0) { 
      fftHistory[histIndex][fftIndex]+=fftValue+log(fftHistory[histIndex-1][fftIndex])*10;
    }
    /* } */
    break;
  case 4:
    fftHistory[histIndex][fftIndex]=fft.getBand(floor(map(1/log(fftIndex), fftMin, fftMax, 0, bufferSizeBig)));
    break;
  case 5:
    // Build the history with a mutltiplicator of the values of fft.getBand(fftIndex)
    fftHistory[histIndex][fftIndex]=fft.getBand(fftIndex)*8;
    //debug.prStrOnce("FFT history filter : fft.getBand(fftIndex) values with a multiplicator");
    break;
  default: 
    // Build the history without any alteration in the values of fft.getBand(fftIndex)
    fftHistory[histIndex][fftIndex]=fft.getBand(fftIndex);
    //debug.prStrOnce("Default FFT history filter : fft.getBand(fftIndex) values with no alteration");
  }
}

void draw()
{  
  myCamera.placeCam();
  scale(0.1);
  background(color(0, 0, 0, 15));
  stroke(255);

  fft.forward(in.mix);
  fft2.forward(in2.mix);

  // Draw the waveforms of fft2 (small buffering) 
  pushMatrix();
  scale(4);
  for (int i = 0; i < fft2.specSize(); i++)
  {
    line(i, 200+50 + in2.left.get(i)*50, i+1, 200+60 + in2.left.get(i+1)*50);
    line(i, 200+80 + in2.right.get(i)*50, i+1, 200+90 + in2.right.get(i+1)*50);
  }
  popMatrix();

  // Init the FFT history given a forward on the mix buffer is done
  // Bound the history array to nrOfIterations
  while (fftForwardCount < nrOfIterations) {
    // Do something with the FFT values - use filter here -
    for (int i = 0; i < fftHistSize; i++) {
      fill_fft_history_filter(fftForwardCount, i, fft.getBand(i));
    }
    // Do a forward on the mix buffer
    fft.forward(in.mix);
    // We count the number of forward iteration, starting at index = 0
    debug.prStr("fftForwardCount = " + fftForwardCount + " before incrementation");
    fftForwardCount++;
    debug.prStr("fftForwardCount = " + fftForwardCount + " after incrementation");
  }

  // Now we have an FFT history of nrOfIterations size
  // Each time a forward on the mix buffer is done, add the new filtered values to the FFT history and discard index = 0 FFT values in the history.  

  // FFT history index = 0 or index % nrOfIterations special case
  /* if (fftForwardCount == 0) {
   fftHistBufferCount = 0;
   debug.prStr("fftHistBufferCount = " + fftHistBufferCount +" (special case : index = 0 or index % nrOfIterations)");
   } else {
   debug.prStr("fftHistBufferCount = " + fftHistBufferCount + " before incrementation");
   fftHistBufferCount++;
   debug.prStr("fftHistBufferCount = " + fftHistBufferCount + " after incrementation" );
   //arrayCopy(fftHistory[fftHistBufferCount], fftHistory[fftHistBufferCount-1]);
   fftHistory[fftHistBufferCount] = fftHistory[fftHistBufferCount-1];
   } */

  for (int i = 0; i < fftHistSize; i++)
  {
    fftHistory[fftHistBufferCount][i] = ZeroNaNValue(fftHistory[fftHistBufferCount][i]);
  }
  // We count the number of forward iteration, starting at index = 0
  debug.prStr("fftForwardCount = " + fftForwardCount + " before incrementation");
  fftForwardCount++;
  debug.prStr("fftForwardCount = " + fftForwardCount + " after incrementation");
  //debug.prStr("fftHistory[" + fftHistBufferCount + "] content: " + Arrays.toString(fftHistory[fftHistBufferCount]));

  // Now draw something from the FFT filter history values
  float x=0;
  float oldx=0;
  for (int k = fftHistBufferCount; k == 0; k--) // FIXME: Should start or end at index 0 !
  {
    stroke(255-255*k/nrOfIterations);
    for (int i = 0; i < fftHistSize - 1; i++)
    { 
      //   line(i, -fftHistory[fftHistBufferCount-1][i],-k*30, i, -fftHistory[fftHistBufferCount][i],-k*20);  
      oldx=x;
      //   x=log(i)*40.0;     
      x=logPos[i];      
      //   line(x*20, -fftHistory[fftHistBufferCount][i],-k*50, (x+1)*20, -fftHistory[fftHistBufferCount][i+1],-k*50); 
      line(oldx*20, -fftHistory[fftHistBufferCount][i], -k*iterationDistance, x*20, -fftHistory[fftHistBufferCount][i+1], -k*iterationDistance); 
      if (i%10==235)
      {
        //   line(i*20,10,i*20,-20);
      }
      //   if (i%10==0)
      //   {               line(i*20, -fftHistory[fftHistBufferCount-1][i],-k*50, (i)*20, -fftHistory[fftHistBufferCount][i],-(k+1)*50); 
      //   }  
      if ((i%10==0)&&(k==1))
        text(i, x*20, 10);
    }
    //      line(i*20, -fftHistory[fftHistBufferCount][i],-k*30, i*20, -fftHistory[fftHistBufferCount][i+1],-k*30);
  } 
  debug.prStr(frameRate + " fps");
  // Last call to a debug.prStrOnce() function in the processing runtime.
  debug.DonePrinting();
  fill(255);
  resetMatrix();
  text("FFT1 val " + "ddD", 5, 20);
  text("The window being used is: ", 5, 40);
} 
//}

//line(i*20,(int)-fft.getBand(i)*4,(i+1)*20,(int)-fft.getBand(i+1)*4);

/*

 // Now draw something from the FFT filter history values
 float x=0;
 float oldx=0;
 for (int k = 1; k < nrOfIterations; k++) // FIXME: Should start at index 0 !
 {
 stroke(255-255*k/nrOfIterations);
 for (int i = 0; i < fftHistSize - 1; i++)
 { 
 //   line(i, -fftHistory[fftHistBufferCount-1][i],-k*30, i, -fftHistory[fftHistBufferCount][i],-k*20);  
 oldx=x;
 //   x=log(i)*40.0;     
 x=logPos[i];      
 //   line(x*20, -fftHistory[fftHistBufferCount][i],-k*50, (x+1)*20, -fftHistory[fftHistBufferCount][i+1],-k*50); 
 line(oldx*20, -fftHistory[fftHistBufferCount][i], -k*iterationDistance, x*20, -fftHistory[fftHistBufferCount][i+1], -k*iterationDistance); 
 if (i%10==235)
 {
 //   line(i*20,10,i*20,-20);
 }
 //   if (i%10==0)
 //   {               line(i*20, -fftHistory[fftHistBufferCount-1][i],-k*50, (i)*20, -fftHistory[fftHistBufferCount][i],-(k+1)*50); 
 //   }  
 if ((i%10==0)&&(k==1))
 text(i, x*20, 10);
 }
 //      line(i*20, -fftHistory[fftHistBufferCount][i],-k*30, i*20, -fftHistory[fftHistBufferCount][i+1],-k*30);
 } 
 //debug.prStr(frameRate + " fps");
 // Last call to a debug.prStrOnce() function in the processing runtime.
 debug.DonePrinting();
 fill(255);
 resetMatrix();
 text("FFT1 val " + "ddD", 5, 20);
 text("The window being used is: ", 5, 40); 
 } */

void stop()
{
  //original comment : always close Minim audio classes when you are done with them
  in.close();
  in2.close();
  minim.stop();

  super.stop();
}