/* 
 * z_FFT by zambari and Jérôme Benoit <jerome.benoit@piment-noir.org>
 * parts based on Get Line In by Damien Di Fede.
 *   
 * Key bindings : 
 * f + [0-9] = Change FFT history filter (0 = EMA, 1 = Log decay, etc.) 
 * v + [0-9] = Change the visualization
 * With EMA filter : s + {-,+} = Increase or decrease the EMA smooth factor
 * With log decay filter : d + {-,+} = Increase or decrease the decay
 * m + {-,+} = Increment or decrement the FFT values integer multiplicator
 *
 */

import ddf.minim.analysis.*;
import ddf.minim.*;
import javax.sound.sampled.*;

import java.util.Arrays;

Debug debug;

// Runtime variables
boolean[] keys;
int fft_history_filter;
int visualization_type;
float smooth_factor, decay;

// Non runtime booleans.
boolean isDebug;
boolean isZeroNaN;

Minim minim;
FFT fft;
WindowFunction fftWindow;
AudioInput in;
int nrOfIterations = 100;
int iterationDistance = 40;
int bufferSize;
int fftHistSize, fftForwardCount, valueMultiplicator;
float[] logPos;
float[][] fftHistory, fftFreqHistory;
float[] angle;
float[] y, x;
Zcam myCamera;   

void setup()
{  
  size(1024, 576, P3D);
  textFont(createFont("SanSerif", 27));
  keys = new boolean[18]; // Number of keys state to track
  for (int i = 0; i < keys.length; i++ )
  {
    keys[i] = false;
  }
  // Zero NaN FFT values to avoid display glitches
  isZeroNaN = true;
  // Debug for now.
  isDebug = true;
  debug = new Debug(isDebug);
  minim = new Minim(this);
  if (isDebug) {
    minim.debugOn();
  }
  Mixer.Info[] mixerInfo;
  mixerInfo = AudioSystem.getMixerInfo(); 
  for (int i = 0; i < mixerInfo.length; i++) {
    Debug.prStr(i + ": " + mixerInfo[i].getName());
  } 
  // index = 0 is pulseaudio mixer on GNU/Linux
  Mixer mixer = AudioSystem.getMixer(mixerInfo[0]); 
  minim.setInputMixer(mixer); 
  bufferSize = 2048;
  in = minim.getLineIn(Minim.STEREO, bufferSize); 
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.noAverages();
  fftWindow = FFT.HAMMING;
  fft.window(fftWindow);
  fftHistSize = fft.specSize(); // Give the FFT history buffer size for a fixed first index the number of FFT values. 
  fftHistory = new float[nrOfIterations][fftHistSize]; // We keep nrOfIterations of all FFT values at a given point in time.
  fftFreqHistory = new float[nrOfIterations][fftHistSize];
  fftForwardCount = 0;
  fft_history_filter = 0;
  // Log decay FFT filter, better on clean sound source such as properly mixed songs in the time domain.
  // In the frequency domain, it's a visual smoother.
  decay = 0.93f;
  // Exponential Moving Average aka EMA FFT filter, better on unclean sound source in the time domain, it's a low pass filter.
  // In the frequency domain, it's also a very simple and efficient visual smoother. 
  // Adjust the default smooth factor for a visual rendering very smooth for the human eyes.
  smooth_factor = 0.93f;
  valueMultiplicator = 10;
  visualization_type = 3;
  y = new float[fftHistSize];
  x = new float[fftHistSize];
  angle = new float[fftHistSize];
  logPos = new float[fftHistSize];
  for (int i = 0; i < fftHistSize; i++) { 
    logPos[i] = (float)Math.log10(i)*10; // It's like the dB log scale
  };
  myCamera = new Zcam();
}

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

float ZeroNaNValue(float Value) {
  if ((Float.isNaN(Value)) && isZeroNaN) { 
    return 0.0f;
  } else {
    return Value;
  }
} 

float dB(float x) {
  if (x == 0) {
    return 0;
  } else {
    return 10 * (float)Math.log10(x);
  }
}

// How to fill the FFT history at histIndex with values?
// FIXME?: Pass the filter type as an argument
// FIXME: Pass as arguments the bidimensional array class with the boundaries 
void fill_fft_history_filter(int histIndex, int fftIndex, float fftValue, int fftValueMultiplicator, float fftFreqValue, float fftFreqValueMultiplicator) {
  switch(fft_history_filter) {
  case 0:
    // Build the FTT history values with an Exponential Moving Average aka EMA filter on fftValue values
    fftHistory[histIndex][fftIndex]=fftHistory[histIndex][fftIndex]*smooth_factor+fftValueMultiplicator*fftValue*(1 - smooth_factor);
    fftFreqHistory[histIndex][fftIndex]=fftFreqHistory[histIndex][fftIndex]*smooth_factor+fftFreqValueMultiplicator*fftFreqValue*(1 - smooth_factor); 
    //Debug.prStrOnce("FFT history filter : EMA with smooth factor = " + smooth_factor);
    break;
  case 1:
    // Build the FTT history values with a log decay on fftValue values
    fftHistory[histIndex][fftIndex] = max(fftHistory[histIndex][fftIndex] * decay, fftValueMultiplicator*(float)Math.log(1 + fftValue));
    fftFreqHistory[histIndex][fftIndex] = max(fftFreqHistory[histIndex][fftIndex] * decay, fftValueMultiplicator*(float)Math.log(1 + fftValue));
    //Debug.prStrOnce("FFT history filter : Log decay with decay = " + decay);
    break;
  case 2:
    // Do nothing for now, was an EMA filter with some useless index skipping and automatic changing of the smooth factor value
    break;
  case 3: 
    // Do nothing for now
    break;
  case 4:
    // Do nothing for now
    break;
  case 5:
    // Build the history with a multiplicator of the values of fftValue
    fftHistory[histIndex][fftIndex]=fftValueMultiplicator*fftValue;
    fftFreqHistory[histIndex][fftIndex]=fftFreqValueMultiplicator*fftValue;
    //Debug.prStrOnce("FFT history filter : fftValue values with a multiplicator = " + Multiplicator);
    break;
  default: 
    // Build the history without any alteration in the values of fftValue
    fftHistory[histIndex][fftIndex]=fftValue;
    fftFreqHistory[histIndex][fftIndex]=fftFreqValue;
    //Debug.prStrOnce("Default FFT history filter : fftValue values with no alteration");
  }
}

void doubleAtomicSprocket(float[] fftValues, float[] fftFreqValues) {
  noStroke();
  pushMatrix();
  translate(width/2, height/2);
  for (int i = 0; i < fftValues.length; i++) {
    y[i] = y[i] + fftValues[i]/100;
    x[i] = x[i] + fftFreqValues[i]/100;
    angle[i] = angle[i] + fftFreqValues[i]/2000;
    rotateX(sin(angle[i]/2));
    rotateY(cos(angle[i]/2));
    //stroke(fftFreqValues[i]*2,0,fftValues[i]*2);
    fill(fftFreqValues[i]*2, 0, fftValues[i]*2);
    pushMatrix();
    translate((x[i]+50)%width/3, (y[i]+50)%height/3);
    box(fftValues[i]/20+fftFreqValues[i]/15);
    popMatrix();
  }
  popMatrix();
  pushMatrix();
  translate(width/2, height/2, 0);
  for (int i = 0; i < fftValues.length; i++) {
    y[i] = y[i] + fftValues[i]/1000;
    x[i] = x[i] + fftFreqValues[i]/1000;
    angle[i] = angle[i] + fftFreqValues[i]/100000;
    rotateX(sin(angle[i]/2));
    rotateY(cos(angle[i]/2));
    //stroke(fftFreqValues[i]*2,0,fftValues[i]*2);
    fill(0, 255-fftFreqValues[i]*2, 255-fftValues[i]*2);
    pushMatrix();
    translate((x[i]+250)%width, (y[i]+250)%height);
    box(fft.getBand(i)/20+fftFreqValues[i]/15);
    popMatrix();
  }
  popMatrix();
}

void draw()
{  
  myCamera.placeCam();

  // Init the FFT history given a forward on the mix buffer is done
  // Bound the history array to nrOfIterations on the first dimension
  while (fftForwardCount < nrOfIterations) {
    if (fftForwardCount == 0) {
      fft.forward(in.mix);
    }
    int indexCount = (nrOfIterations - 1) - fftForwardCount;
    Debug.prStr("indexCount = " + indexCount + " in FFT history init loop");
    for (int i = 0; i < fftHistSize; i++) {
      fill_fft_history_filter(indexCount, i, ZeroNaNValue(fft.getBand(i)), valueMultiplicator, ZeroNaNValue(fft.getFreq(i)), valueMultiplicator);
    }
    // We count the number of forward iteration, starting at index = 0
    Debug.prStr("fftForwardCount = " + fftForwardCount + " before incrementation (in FFT history init loop)");
    fft.forward(in.mix);
    fftForwardCount++;
    Debug.prStr("fftForwardCount = " + fftForwardCount + " after incrementation (in FFT history init loop)");
  } // Now we have an FFT history of nrOfIterations size, last values at index = 0 on the first dimension

  Debug.prStrOnce("fftForwardCount = " + fftForwardCount + " at the end of the FFT history init loop");
  Debug.prStrOnce("FFT values multiplicator = " + valueMultiplicator + ", EMA smooth factor = " + smooth_factor + ", Log decay = " + decay);
  // Last call to a debug.prStrOnce() function in the processing runtime.
  Debug.DonePrinting();

  fft.forward(in.mix);

  // Each time a forward on the mix buffer is done, 
  // - add the new filtered values to the FFT history; 
  // - discard last index = 0 FFT values in the history. 
  for (int fftHistBufferCount = nrOfIterations - 1; fftHistBufferCount >= 0; fftHistBufferCount--) {
    // Rotate the FFT history values on the first index
    if (fftHistBufferCount < nrOfIterations - 1) {
      arrayCopy(fftHistory[fftHistBufferCount], fftHistory[fftHistBufferCount+1]);
      arrayCopy(fftFreqHistory[fftHistBufferCount], fftFreqHistory[fftHistBufferCount+1]);
    }
    if (fftHistBufferCount == 0) {
      // Fill the FFT history buffer with new values from the FFT forward on the mix buffer 
      for (int i = 0; i < fftHistSize; i++) {
        fill_fft_history_filter(fftHistBufferCount, i, ZeroNaNValue(fft.getBand(i)), valueMultiplicator, ZeroNaNValue(fft.getFreq(i)), valueMultiplicator);
      }
    }
  }

  // Now draw something from the FFT history filtered values
  switch(visualization_type) {   
  case 0:
    background(color(0, 0, 0, 15));
    // Draw the waveforms of fft
    stroke(255);
    for (int i = 0; i < fft.specSize(); i++)
    {
      line(i, 200+50 + in.left.get(i)*50, i+1, 200+60 + in.left.get(i+1)*50);
      line(i, 200+80 + in.right.get(i)*50, i+1, 200+90 + in.right.get(i+1)*50);
    }

    float x=0;
    float oldx=0;
    for (int fftHistBufferCount = 0; fftHistBufferCount < nrOfIterations; fftHistBufferCount++)
    {
      stroke(255-255*(fftHistBufferCount)/(nrOfIterations-1));
      for (int i = 0; i < fftHistSize - 1; i++)
      {   
        oldx=x;   
        x=logPos[i]; // Log base 10 scale on the FFT index in order to center artificially the frequencies bands where things happen. Frequency weighting is probably better.      
        line(oldx*80, -fftHistory[fftHistBufferCount][i], -fftHistBufferCount*iterationDistance, x*80, -fftHistory[fftHistBufferCount][i+1], -fftHistBufferCount*iterationDistance);
        // FIXME: build the log base 10 scale index displaying with some smart skipping 
        //if ((i%10==0)&&(fftHistBufferCount==0))
        //  text(i, x*80, 27);
      }
    }
    break;
  case 1:
    background(color(0, 0, 0, 15));
    // Draw the waveforms of fft
    stroke(255);
    for (int i = 0; i < fft.specSize(); i++)
    {
      line(i, 200+50 + in.left.get(i)*50, i+1, 200+60 + in.left.get(i+1)*50);
      line(i, 200+80 + in.right.get(i)*50, i+1, 200+90 + in.right.get(i+1)*50);
    }

    for (int fftHistBufferCount = 0; fftHistBufferCount < nrOfIterations; fftHistBufferCount++)
    {
      stroke(255-255*(fftHistBufferCount)/(nrOfIterations-1));
      for (int i = 0; i < fftHistSize - 1; i++)
      {   
        line(i*10, -fftHistory[fftHistBufferCount][i], -fftHistBufferCount*iterationDistance, (i+1)*10, -fftHistory[fftHistBufferCount][i+1], -fftHistBufferCount*iterationDistance);
        if ((i%10==0)&&(fftHistBufferCount==0))
          text(i, i*10, 27);
      }
    }
    break;
  case 2:
    background(color(0, 0, 0, 15));
    stroke(255);
    for (int i = 0; i < fftHistSize - 1; i++) {
      line(i*20, -fftHistory[0][i], (i+1)*20, -fftHistory[0][i+1]);
    }
    break;
  case 3:
    background(0);
    // FIXME: Make use of the fftHistory[][] array as an argument
    doubleAtomicSprocket(fftHistory[0], fftFreqHistory[0]);
    break;
  default:
    background(color(0, 0, 0, 15));
    stroke(255);
    for (int i = 0; i < fftHistSize - 1; i++) {
      line(i*20, -fftHistory[0][i], (i+1)*20, -fftHistory[0][i+1]);
    }
  }
  //Debug.prStr(frameRate + " fps");
} 

void stop()
{
  // original comment : always close Minim audio classes when you are done with them
  in.close();
  minim.stop();

  super.stop();
}