// AudioProcessing

import ddf.minim.*;
import ddf.minim.analysis.*;

public class AudioProcessing
{
  FFT mFft;

  AudioProcessing(int timeSize, float sampleRate)
  {
    mFft = new FFT(timeSize, sampleRate);
    mFft.window(FFT.GAUSS);
    mFft.logAverages(55,12); // ?? bands

    minAmplitude =  1000;
    maxAmplitude = -1000;

    println("AudioProcessing");
  }

  public void sample(AudioBuffer buffer)
  {
    mFft.forward(buffer);
    //println("AudioProcessing: sample");
  }

  public int getSpecSize()
  {
    //println("AudioProcessing: getSpecize");
    return mFft.specSize();
  }

  public float getBandAmplitude(int band)
  {
    //println("AudioProcessing: getBandAmplitude");
    return adjustAmplitude(mFft.getBand(band), band);
  }

  public Note getNote(GuitarString theString)
  {
    int   loudestNote;
    int   noteOffset;
    float noteAmplitude;
    float amplitude;

    //println("AudioProcessing: getNote: " + theString.getLowNote() + ", " + theString.getHighNote());

    // amplitude to be 0 to 1.0, nominally, may overflow
    // internally want dB scale, then EQ
    // private method to adjustAmplitude with constants
    // private method to EQ amplitude
    // Heavy Duty max is 79.2dB, min is -infinity at 1st point
    // 
    // search through FFT data from low to hi note for highest peak
    loudestNote   = 0;
    noteAmplitude = 0;

    //println(" mFft.avgSize() = " + mFft.avgSize());

    for (int i = theString.getLowNote(); i <= theString.getHighNote(); i++) {
      if (i > mFft.avgSize()) {
          println("i > mFft.avgSize()");
        break;
      }
      amplitude = adjustAmplitude(mFft.getAvg(i),i);

      //println(" i = " + i + ", amplitude = " + amplitude);
      if (amplitude > noteAmplitude) {
        noteAmplitude = amplitude;
        loudestNote   = i;
      }
    }
    Note note = new Note(loudestNote, noteAmplitude);
    //println("note= " + loudestNote + ", " + noteAmplitude);

    return note;
  }

  private float minAmplitude;
  private float maxAmplitude;

  private float adjustAmplitude(float amplitudeIn, int i) {
    float amplitudeOut;

    //amplitudeOut = amplitudeIn;

    amplitudeOut = 20*log(amplitudeIn);
    amplitudeOut = eqAmplitude(amplitudeOut, i);

    if (amplitudeOut > maxAmplitude) {
      maxAmplitude = amplitudeOut;
      println("maxAmplitude= " + maxAmplitude);
    }
    if (amplitudeOut < minAmplitude) {
      minAmplitude = amplitudeOut;
      println("minAmplitude= " + minAmplitude);
    }

    amplitudeOut -= 20; // offset and scale
    amplitudeOut /= 60; // 80 to 20 dB maps to 1 to 0

    // limit underflow, but allow overflow
    if (amplitudeOut < 0) amplitudeOut = 0;
    if (amplitudeOut > 1) {
      println("AudioProcessing: adjustAmplitude: overflow!");
    }

    if (amplitudeOut > maxAmplitude) {
      maxAmplitude = amplitudeOut;
      println("maxAmplitude= " + maxAmplitude);
    }
    if (amplitudeOut < minAmplitude) {
      minAmplitude = amplitudeOut;
      println("minAmplitude= " + minAmplitude);
    }
    
    return amplitudeOut;
  }

  private float eqAmplitude(float amplitudeIn, int i) {
    float amplitudeOut;

    amplitudeOut = amplitudeIn;

    if (i > 75) {
      amplitudeOut += 20;
    } 
    else if (i > 70) {
      // ramp up from +10 to +20
      amplitudeOut += 10;
      amplitudeOut += 10*(i-70)/5;
    } 
    else if (i > 35) {
      amplitudeOut += 10;
    } 
    else if (i > 30) {
      // ramp up from 0 to +10
      amplitudeOut += 0;
      amplitudeOut += 10*(i-30)/5;

    } 
    else if (i > 10) {
      // no change.
    } 
    else if (i > 7)  {
      // ramp up from -20 to 0
      amplitudeOut += -20;
      amplitudeOut += 20*(i-7)/3;

    } 
    else {
      amplitudeOut -= 20;
    }

    return amplitudeOut;
  }
}

/*
PImage effectImage;
PImage sourcePattern;
import ddf.minim.analysis.*;
import ddf.minim.*;


// create global objects and variables
Minim minim;
//AudioInput in;
AudioPlayer in;
BeatDetect beat;
FFT fft;
int[] fftHold = new int[192];
float[] fftSmooth = new float[192];

ArrayList Drops;

// 120,4 : 32
//  60,4 : 64
//  60,12 : 192
int bandsPerOctave = 24;
int lowestFreq = 120;

// Please don't modify or remove anything in here
// It's ok to add initialization etc
void setup() {
  
  // initialize Minim object
  minim = new Minim(this);

  // select audio source, comment for sample song or recording source
  //in = minim.getLineIn(Minim.STEREO, 1024);
  //in = minim.loadFile("Gosprom_-_12_-_San_Francisco.mp3",1024); // Creative Commons
  in = minim.loadFile("HeavyDuty.mp3",1024); // Creative Commons
  in.play();

  //beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());  
  beat.setSensitivity(300);
  beat.detectMode(BeatDetect.FREQ_ENERGY);
 
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.GAUSS);
  //fft.logAverages(60,5); // ?? bands
  //fft.logAverages(lowestFreq, bandsPerOctave); // ?? bands
  //fft.logAverages(120,4); // 32 bands
  fft.linAverages(192);
  
  //size(320,320);  
  //size(160,128);  
  size(1024,640);  
  frameRate(30);
  
  sourcePattern = loadImage("spiral1.png");
  
  Drops = new ArrayList();
}


void draw () {
  
  // sample effects are drawn in upper 320x160 half of screen
  //effect_spinImage();
  //effect_drops();
  effect_spectrum();
  
  
  // capture upper half of screen and pixelize to 16x8
  //effectImage = get(19,9,319,159);
  
  // Test for my screensize
  //effectImage.resize(160, 128);

  //effectImage.resize(30, 15);
  //effectImage.resize(16, 8);
  //effectImage.loadPixels();
  
  // Put pixelized image in lower half of window
  //image(effectImage,0,height/2, width, height/2);
  
  // Draw grid over pixels on bottom half
  //drawGrid();
  
}

// draw grid in lower half
void drawGrid() {
  stroke(127);
  strokeWeight(1);
  for (int i = 1; i < 16; i++) {
   line(i*20,160,i*20,319);
  }
  for (int i = 0; i < 8; i++) {
   line(0,i*20+160,319,i*20+160);
  } 
}



// --- EFFECT ---
// Raindrops
// Generates expanding droplets on isKick detection
int dropWallSize = 30;
int dropHue = 0;
void effect_drops() {

  beat.detect(in.mix);
  
  background(0);

  if ( beat.isKick() ) {
    Drops.add(new drop1(int(random(19,299)),int(random(19,139)),dropHue));
    dropHue += 4;
    if (dropHue > 100) dropHue -= 100;
  }
  
  for (int i = Drops.size() - 1; i >= 0; i--) {
    drop1 drop = (drop1) Drops.get(i);
    drop.update();
    if (drop.done()) Drops.remove(i); 
  }
  
}

// Class for Raindrops effect
class drop1 {
  
  int xpos, ypos, dropcolor, dropSize;
  boolean finished;
  
  drop1 (int x, int y, int c) {
    xpos = x;
    ypos = y;
    dropcolor = c;
    finished = false;
  }
  
  void update() {
    if (!finished) {
      colorMode(HSB, 100);
      noFill();
      strokeWeight(dropWallSize); 
      stroke(dropcolor,100,100);
      ellipse(xpos,ypos,dropSize,dropSize);
      if (dropSize < 550) {
        dropSize += 15;
      } else {
        finished = true;
      }
      colorMode(RGB, 255);
    }
  }
  
  boolean done() {
    return finished;
  }
}


// --- EFFECT ---
// Spin image
// Rotates an image and bounces back on isKick
color ledColor;
int rotDegrees = 0;
void effect_spinImage() {

  beat.detect(in.mix);  
  
  int imageSize = 400;
  background(0);
  pushMatrix();
  translate(width/2,height/4);

  rotDegrees += 10;
  if (beat.isKick()) rotDegrees -= 36;
  if (rotDegrees > 359) rotDegrees -= 360;
  if (rotDegrees < 0) rotDegrees += 360;

  rotate(radians(rotDegrees));
  
  image(sourcePattern,-(imageSize/2),-(imageSize/2),imageSize,imageSize);
  popMatrix();
  
}

// --- EFFECT ---
// Spectrum
// Draws an FFT with peak hold
void effect_spectrum() {
 background(0);
  
 fft.forward(in.mix);
 
  noStroke();
    // draw the linear averages
  int w = int(width/fft.avgSize());
  int h;
  
  for(int i = 0; i < fft.avgSize(); i++)
  {
    //fftSmooth[i] = 0.3 * fftSmooth[i] + 0.7 * fft.getAvg(i);
    fftSmooth[i] =  fft.getAvg(i) * 8;
    
    //h = int(log(fftSmooth[i]*3)*30);
    //h = int(log(fftSmooth[i]*3)*10);
    h = int(fftSmooth[i]);
    if (fftHold[i] < h) {
      fftHold[i] = h;
    }
    
    rectMode(CORNERS);
    //This gives the bar color on the basis of height
    fill(255*h/80,0,255-255*h/80);
    //This is the amplitude bar
    // North side
    //rect(i*w*2, 0, i*w*2 + w*2, h);
    // South side
    rect(i*w*2, height - h, i*w*2 + w*2, height);
    // This is the color green for the peak bar
    //fill(0,255,0);
    // This is the peak bar
    // North side
    //rect(i*w*2, fftHold[i] - 1, i*w*2 + w*2, fftHold[i]+2);
    // South side
    //rect(i*w*2, height-fftHold[i] -2, i*w*2 + w*2, height - fftHold[i]+1);


    //fftHold[i] = fftHold[i] - 4;
    fftHold[i] = fftHold[i] - 2;
    if (fftHold[i] < 0) fftHold[i] = 0;
  }
  
}




void stop()
{
  // always close Minim audio classes when you are finished with them
  in.close();
  //song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}

*/