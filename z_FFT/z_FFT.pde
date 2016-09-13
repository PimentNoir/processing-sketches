/*  //<>//
 * z_FFT by zambari and Jérôme Benoit <jerome.benoit@piment-noir.org>
 * parts based on Get Line In by Damien Di Fede.
 *   
 * Key bindings : 
 * f + [0-9] = Change FFT history filter (0 = EMA, 1 = Log decay, 2 = SMA, etc.) 
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
  keys = new boolean[nrKeys];
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
  visualization_type = 0;
  y = new float[fftHistSize];
  x = new float[fftHistSize];
  angle = new float[fftHistSize];
  logPos = new float[fftHistSize];
  for (int i = 0; i < fftHistSize; i++) { 
    logPos[i] = (float)Math.log10(i)*10; // It's like the dB log scale
  };
  myCamera = new Zcam();
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

boolean SMAFirstrun = true, SMMFirstrun = true, WMAFirstrun = true;
// How to fill the FFT history at histIndex with values?
// FIXME?: Pass the filter type as an argument
// FIXME: Pass as arguments the bidimensional array class with the boundaries 
void fill_fft_history_filter(int histIndex, int fftIndex, float fftValue, int fftValueMultiplicator, float fftFreqValue, int fftFreqValueMultiplicator, boolean inInit) {
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
    fftFreqHistory[histIndex][fftIndex] = max(fftFreqHistory[histIndex][fftIndex] * decay, fftFreqValueMultiplicator*(float)Math.log(1 + fftFreqValue));
    //Debug.prStrOnce("FFT history filter : Log decay with decay = " + decay);
    break;
  case 2:
    // Build the FFT history values with a Simple Moving Average aka SMA with window = nrOfIterations on the first index
    if (nrOfIterations < 1) { 
      Debug.prStr("nrOfIterations doit être supérieur à zéro"); 
      exit();
    }
    if (SMAFirstrun && !inInit) {
      float[] SMAFFTAvg = new float[nrOfIterations];
      float[] SMAFreqAvg = new float[nrOfIterations];
      // Initialize the two local arrays
      for (int i = 0; i < nrOfIterations; i++) {
        SMAFFTAvg[i] = 0;
        SMAFreqAvg[i] = 0;
      }
      // The FFT values history has been properly initialized, so calculate the very first SMA values
      for (int HIndex = 0; HIndex < nrOfIterations; HIndex++) {
        SMAFFTAvg[HIndex] += fftValueMultiplicator * fftHistory[HIndex][fftIndex];
        SMAFreqAvg[HIndex] += fftFreqValueMultiplicator * fftFreqHistory[HIndex][fftIndex];
        if (HIndex == nrOfIterations - 1) {
          SMAFFTAvg[HIndex] = SMAFFTAvg[HIndex] / SMAFFTAvg.length;
          SMAFreqAvg[HIndex] = SMAFreqAvg[HIndex] / SMAFreqAvg.length;
          fftHistory[HIndex][fftIndex] = SMAFFTAvg[HIndex];
          fftFreqHistory[HIndex][fftIndex] = SMAFreqAvg[HIndex];
        }
      }
      SMAFirstrun = false;
    } else if (inInit) {
      fftHistory[histIndex][fftIndex] = fftValueMultiplicator * fftValue;
      fftFreqHistory[histIndex][fftIndex] = fftFreqValueMultiplicator * fftFreqValue;
    } else {
      // Use recursive SMA formula afterwards 
      fftHistory[histIndex][fftIndex] = fftHistory[histIndex][fftIndex] + (fftValueMultiplicator * fftValue - fftHistory[nrOfIterations - 1][fftIndex])/(nrOfIterations);
      fftFreqHistory[histIndex][fftIndex] = fftFreqHistory[histIndex][fftIndex] + (fftFreqValueMultiplicator * fftFreqValue - fftFreqHistory[nrOfIterations - 1][fftIndex])/(nrOfIterations);
    }
    break;
  case 3:
    // Build the FFT history values with a Weighted Moving Average (special case : weight is the arithmetic progression)
    if (WMAFirstrun && !inInit) {
      float[] WMAFFTAvg = new float[nrOfIterations];
      float[] WMAFreqAvg = new float[nrOfIterations];
      for (int i = 0; i < nrOfIterations; i++) {
        WMAFFTAvg[i] = 0;
        WMAFreqAvg[i] = 0;
      }
      for (int HIndex = nrOfIterations - 1; HIndex >= 0; HIndex--) {
        WMAFFTAvg[HIndex] += fftValueMultiplicator * (nrOfIterations - HIndex) * fftHistory[HIndex][fftIndex];
        WMAFreqAvg[HIndex] += fftFreqValueMultiplicator * (nrOfIterations - HIndex) * fftFreqHistory[HIndex][fftIndex];
        if (HIndex == 0) {
          WMAFFTAvg[HIndex] = (2 * WMAFFTAvg[HIndex]) / (WMAFFTAvg.length * (WMAFFTAvg.length + 1));
          WMAFreqAvg[HIndex] = (2 * WMAFreqAvg[HIndex]) / (WMAFreqAvg.length * (WMAFreqAvg.length + 1));
          fftHistory[HIndex][fftIndex] = WMAFFTAvg[HIndex];
          fftFreqHistory[HIndex][fftIndex] = WMAFreqAvg[HIndex];
        }
      }
      WMAFirstrun = false;
    } else if (inInit) {
      fftHistory[histIndex][fftIndex] = fftValueMultiplicator * fftValue;
      fftFreqHistory[histIndex][fftIndex] = fftFreqValueMultiplicator * fftFreqValue;
    } else {
      fftHistory[histIndex][fftIndex] = ((fftValueMultiplicator * fftValue) * 2 + fftHistory[histIndex][fftIndex] * (nrOfIterations - 1)) / (nrOfIterations + 1);
      fftFreqHistory[histIndex][fftIndex] = ((fftFreqValueMultiplicator * fftFreqValue) * 2 + fftFreqHistory[histIndex][fftIndex] * (nrOfIterations - 1)) / (nrOfIterations + 1);
    }
    break;
  case 4:
    // Build the FFT history values with a Modified Moving Average aka MMA (or Smoothed Moving Average aka SMA)
    // MMA is a special case EMA with smooth_factor = 1 / window_size. 
    fftHistory[histIndex][fftIndex] = ((nrOfIterations - 1) * fftHistory[histIndex][fftIndex] + fftValueMultiplicator * fftValue) / nrOfIterations;
    fftFreqHistory[histIndex][fftIndex] = ((nrOfIterations - 1) * fftFreqHistory[histIndex][fftIndex] + fftFreqValueMultiplicator * fftFreqValue) / nrOfIterations; 
    break;
  case 5:
    // Build the history with a multiplicator of the values of fftValue
    fftHistory[histIndex][fftIndex]=fftValueMultiplicator*fftValue;
    fftFreqHistory[histIndex][fftIndex]=fftFreqValueMultiplicator*fftFreqValue;
    //Debug.prStrOnce("FFT history filter : fft values with a multiplicator = " + fftValueMultiplicator);
    break;
  case 6:
    if (nrOfIterations < 1) { 
      Debug.prStr("nrOfIterations doit être supérieur à zéro"); 
      exit();
    }

    // Build the FFT history values with a Simple Moving Median aka SMM
    // In order the avoid a full recomputing of the median each time, we will make use of the median estimation recursive formula of Jeff McClintock
    float[][] fftMeanHistory = new float[nrOfIterations][fftHistSize];
    float[][] fftFreqMeanHistory = new float[nrOfIterations][fftHistSize];
    if (SMMFirstrun && !inInit) {
      for (int i = 0; i < nrOfIterations; i++) {
        for (int j = 0; j < fftHistSize; j++) {
          fftMeanHistory[i][j] = fftHistory[i][j];
          fftFreqMeanHistory[i][j] = fftFreqHistory[i][j];
        }
      }

      float[] SMAFFTAvg = new float[nrOfIterations];
      float[] SMAFreqAvg = new float[nrOfIterations];
      // Initialize the two local arrays
      for (int i = 0; i < nrOfIterations; i++) {
        SMAFFTAvg[i] = 0;
        SMAFreqAvg[i] = 0;
      }
      // The FFT values history has been properly initialized, so calculate the very first SMA values
      for (int HIndex = 0; HIndex < nrOfIterations; HIndex++) {
        SMAFFTAvg[HIndex] += fftValueMultiplicator * fftMeanHistory[HIndex][fftIndex];
        SMAFreqAvg[HIndex] += fftFreqValueMultiplicator * fftFreqMeanHistory[HIndex][fftIndex];
        if (HIndex == nrOfIterations - 1) {
          SMAFFTAvg[HIndex] = SMAFFTAvg[HIndex] / SMAFFTAvg.length;
          SMAFreqAvg[HIndex] = SMAFreqAvg[HIndex] / SMAFreqAvg.length;
          fftMeanHistory[HIndex][fftIndex] = SMAFFTAvg[HIndex];
          fftFreqMeanHistory[HIndex][fftIndex] = SMAFreqAvg[HIndex];
        }
      }

      float[] SMMFFTMed = new float[nrOfIterations];
      float[] SMMFreqMed = new float[nrOfIterations];
      for (int HIndex = 0; HIndex < nrOfIterations; HIndex++) {
        // Initialize the two local arrays
        SMMFFTMed[HIndex] = fftValueMultiplicator * fftHistory[HIndex][fftIndex];
        SMMFreqMed[HIndex] = fftFreqValueMultiplicator * fftFreqHistory[HIndex][fftIndex];
        // The FFT values history has been properly initialized, so calculate the very first SMM values
        Arrays.sort(SMMFFTMed);
        Arrays.sort(SMMFreqMed);
        if (SMMFFTMed.length % 2 == 0) {
          SMMFFTMed[HIndex] = (SMMFFTMed[SMMFFTMed.length/2] + SMMFFTMed[SMMFFTMed.length/2 - 1])/2;
          SMMFreqMed[HIndex] = (SMMFreqMed[SMMFreqMed.length/2] + SMMFreqMed[SMMFreqMed.length/2 - 1])/2;
        } else {
          SMMFFTMed[HIndex] = SMMFFTMed[SMMFFTMed.length/2];
          SMMFreqMed[HIndex] = SMMFreqMed[SMMFreqMed.length/2];
        }
        fftHistory[HIndex][fftIndex] = SMMFFTMed[HIndex];
        fftFreqHistory[HIndex][fftIndex] = SMMFreqMed[HIndex];
      }

      SMMFirstrun = false;
    } else if (inInit) {
      fftHistory[histIndex][fftIndex] = fftValueMultiplicator * fftValue;
      fftFreqHistory[histIndex][fftIndex] = fftFreqValueMultiplicator * fftFreqValue;
    } else {
      fftMeanHistory[histIndex][fftIndex] += (fftValueMultiplicator * fftValue - fftMeanHistory[histIndex][fftIndex]) * 0.1f; // rough running average
      fftFreqMeanHistory[histIndex][fftIndex] += (fftFreqValueMultiplicator * fftFreqValue - fftFreqMeanHistory[histIndex][fftIndex]) * 0.1f; // rough running average
      fftHistory[histIndex][fftIndex] += Math.copySign(fftMeanHistory[histIndex][fftIndex]* 0.01f, fftValueMultiplicator * fftValue -  fftHistory[histIndex][fftIndex]);
      fftFreqHistory[histIndex][fftIndex] += Math.copySign(fftFreqMeanHistory[histIndex][fftIndex]* 0.01f, fftFreqValueMultiplicator * fftFreqValue -  fftFreqHistory[histIndex][fftIndex]);
    }
    break;
  default: 
    // Build the history without any alteration in the values of fftValue
    fftHistory[histIndex][fftIndex]=fftValue;
    fftFreqHistory[histIndex][fftIndex]=fftFreqValue;
    //Debug.prStrOnce("Default FFT history filter : fft values with no alteration");
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
    //sphere(fftValues[i]/20+fftFreqValues[i]/15);
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
    box(fftValues[i]/20+fftFreqValues[i]/15);
    //sphere(fftValues[i]/20+fftFreqValues[i]/15);
    popMatrix();
  }
  popMatrix();
}

void draw()
{  
  // FIXME: Should be per visualization 
  colorMode(RGB, 255);
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
      fill_fft_history_filter(indexCount, i, ZeroNaNValue(fft.getBand(i)), valueMultiplicator, ZeroNaNValue(fft.getFreq(i)), valueMultiplicator, true);
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
    // histIndex = 0 is a special case
    if (fftHistBufferCount == 0) {
      // Fill the FFT history buffer with new values from the FFT forward on the mix buffer (histIndex = 0)
      for (int i = 0; i < fftHistSize; i++) {
        fill_fft_history_filter(fftHistBufferCount, i, ZeroNaNValue(fft.getBand(i)), valueMultiplicator, ZeroNaNValue(fft.getFreq(i)), valueMultiplicator, false);
      }
    }
  }

  // Now draw something from the FFT history filtered values
  switch(visualization_type) {   
  case 0:
    background(color(0, 0, 0, 15));
    // Draw the waveforms of fft
    stroke(255);

    pushMatrix();
    for (int i = 0; i < fft.specSize(); i++)
    {     
      line(i, 200+50 + in.left.get(i)*50, i+1, 200+60 + in.left.get(i+1)*50);
      line(i, 200+80 + in.right.get(i)*50, i+1, 200+90 + in.right.get(i+1)*50);
    }
    popMatrix();

    float x=0;
    float oldx=0;
    for (int fftHistBufferCount = 0; fftHistBufferCount < nrOfIterations; fftHistBufferCount++)
    {
      stroke(255-255*(fftHistBufferCount)/(nrOfIterations));
      pushMatrix();
      for (int i = 0; i < fftHistSize - 1; i++)
      {   
        oldx=x;   
        x=logPos[i]; // Log base 10 scale on the FFT index in order to center artificially the frequencies bands where things happen. Frequency weighting is probably better.      
        line(oldx*80, -fftHistory[fftHistBufferCount][i], -fftHistBufferCount*iterationDistance, x*80, -fftHistory[fftHistBufferCount][i+1], -fftHistBufferCount*iterationDistance);
        // FIXME: build the log base 10 scale index displaying with some smart skipping 
        //if ((i%10==0)&&(fftHistBufferCount==0))
        //  text(i, x*80, 27);
      }
      popMatrix();
    }
    break;
  case 1:
    background(color(0, 0, 0, 15));
    // Draw the waveforms of fft
    stroke(255);
    pushMatrix();
    for (int i = 0; i < fft.specSize(); i++)
    {
      line(i, 200+50 + in.left.get(i)*50, i+1, 200+60 + in.left.get(i+1)*50);
      line(i, 200+80 + in.right.get(i)*50, i+1, 200+90 + in.right.get(i+1)*50);
    }
    popMatrix();

    for (int fftHistBufferCount = 0; fftHistBufferCount < nrOfIterations; fftHistBufferCount++)
    {
      stroke(255-255*(fftHistBufferCount)/(nrOfIterations));
      pushMatrix();
      for (int i = 0; i < fftHistSize - 1; i++)
      {   
        line(i*10, -fftHistory[fftHistBufferCount][i], -fftHistBufferCount*iterationDistance, (i+1)*10, -fftHistory[fftHistBufferCount][i+1], -fftHistBufferCount*iterationDistance);
        if ((i%10==0)&&(fftHistBufferCount==0)) {
          fill(255);
          text(i, i*10, 27);
        }
      }
      popMatrix();
    }
    break;
  case 2:
    background(color(0, 0, 0, 15));
    stroke(255);
    pushMatrix();
    for (int i = 0; i < fftHistSize - 1; i++) {
      line(i*20, -fftHistory[0][i], (i+1)*20, -fftHistory[0][i+1]);
    }
    popMatrix();
    break;
  case 3:
    background(0);
    doubleAtomicSprocket(fftHistory[0], fftFreqHistory[0]);
    break;
  default:
    background(color(0, 0, 0, 15));
    stroke(255);
    pushMatrix();
    for (int i = 0; i < fftHistSize - 1; i++) {
      line(i*20, -fftHistory[0][i], (i+1)*20, -fftHistory[0][i+1]);
    }
    popMatrix();
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