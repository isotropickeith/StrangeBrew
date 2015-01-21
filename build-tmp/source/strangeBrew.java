import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.analysis.*; 
import ddf.minim.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class strangeBrew extends PApplet {

PImage effectImage;
PImage sourcePattern;




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


Guitar guitar;
Guitar2Serial guitarInterface;

// Please don't modify or remove anything in here
// It's ok to add initialization etc
public void setup()
{
  size(480, 400);  // create the window

  guitar = new Guitar();
  guitarInterface = new Guitar2Serial(this, guitar);
}


public void draw ()
{
  guitar.play();
  guitarInterface.updateDisplay();
}




public void stop()
{
  // always close Minim audio classes when you are finished with them
  //in.close();
  //song.close();
  // always stop Minim before exiting
  //minim.stop();
  // this closes the sketch
  super.stop();
}


// respond to mouse clicks as pause/play
public void mousePressed()
{
  guitarInterface.getStatus();
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
// Guitar
//
// StrageBrew Guitar

public class Guitar
{
	public static final int sLowE = 82;			// Hz
	public static final int sLowA = 110;		// Hz
	public static final int sLowD = 147;		// Hz
	public static final int sLowG = 196;		// Hz
	public static final int sLowB = 247;		// Hz
	public static final int sHiE  = 330;		// Hz

	public static final int sNumLedsPerString = 147;
	public static final int sNumStrings = 6;
	public static final int sBridgeStartLed = 6;
	public static final int sNumFrets = 23;

	public final int[] sFretLed = {	  139,   // 8  1st fret
									  132,   // 7
									  125,
									  118,	 // 7
									  112,   // 6
									  106,
									  100,   // 6
									  95,    // 5
									  90,    // 5
									  85,    // 5
									  81,    // 4
									  77,
									  73,    // 12th fret (octave)
									  69,
									  65,    // 4
									  62,    // 3
									  59,
									  56,
									  53,
									  50,    // 3
									  48,    // 2
									  46,
									  44 };	 // 2 23rd fret

	//GuitarString[sNumStrings] mString;
	private GuitarString[] mString = new GuitarString[0];
	private int[] mLeds = new int[sNumStrings * sNumLedsPerString];

	// Animation vars (temporary)

	private int curString = 0;
	private int curLed = 0;
	private int curColor = 0xffFF0000;

	// ctor

	Guitar()
	{
		for(int c : mLeds) {c = 0;}

		mString  = (GuitarString[])append(mString, new GuitarString(this, sLowE));
		mString  = (GuitarString[])append(mString, new GuitarString(this, sLowA));
		mString  = (GuitarString[])append(mString, new GuitarString(this, sLowD));
		mString  = (GuitarString[])append(mString, new GuitarString(this, sLowG));
		mString  = (GuitarString[])append(mString, new GuitarString(this, sLowB));
		mString  = (GuitarString[])append(mString, new GuitarString(this, sHiE));
	}

	public void play()
	{
		if(frameCount % 60 == 0)
		{
			println("Frame : " + frameCount);
		}

		playAnimation();   //### Test Animation
	}
	// getLeds returns an array of Colors organized as follows:

	public int[] getLeds()
	{
		int ledIdx = 0;
		for(GuitarString s : mString)
		{
			int[] stringLeds = s.getLeds();
			arrayCopy(stringLeds, 0, mLeds, ledIdx, sNumLedsPerString);
			ledIdx += sNumLedsPerString;
		}
		return mLeds;
	}

	public int getLed(int stringNum, int intLedIdx)
	{
		return mString[stringNum].getLed(intLedIdx);
	}

	public void setLed(int stringNum, int intLedIdx, int led)
	{
		mString[stringNum].setLed(intLedIdx, led);
	}

	private void playAnimation()
	{
		if(frameCount % 10 == 0)
		{
			setLed(curString, curLed, curColor);
			if(++curLed == sNumLedsPerString)
			{
				curLed = 0;
				if(++curString == sNumStrings)
				{
					curString = 0;
					curColor = curColor >> 1;
					if(curColor == 0)
					{
						curColor = 0xffFF0000;
					}
				}
			}
		}
	}
}


/*  OctoWS2811 movie2serial.pde - Transmit video data to 1 or more
      Teensy 3.0 boards running OctoWS2811 VideoDisplay.ino
    http://www.pjrc.com/teensy/td_libs_OctoWS2811.html
    Copyright (c) 2013 Paul Stoffregen, PJRC.COM, LLC

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

// To configure this program, edit the following sections:
//
//  1: change myMovie to open a video file of your choice    ;-)
//
//  2: edit the serialConfigure() lines in setup() for your
//     serial device names (Mac, Linux) or COM ports (Windows)
//
//  3: if your LED strips have unusual color configuration,
//     edit colorWiring().  Nearly all strips have GRB wiring,
//     so normally you can leave this as-is.
//
//  4: if playing 50 or 60 Hz progressive video (or faster),
//     edit framerate in movieEvent().

//import processing.video.*;

//import java.awt.Rectangle;

public class Guitar2Serial
{

  public static final float gamma = 1.7f;

  public static final int sNumConfigParams = 10;

  int numPorts=0;  // the number of serial ports in use
  int maxPorts=1;  // maximum number of serial ports

  Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
  //Rectangle[] ledArea = new Rectangle[maxPorts]; // the area of the movie each port gets, in % (0-100)
  //boolean[] ledLayout = new boolean[maxPorts];   // layout of rows, true = even is left->right
  //PImage[] ledImage = new PImage[maxPorts];      // image sent to each port
  int[] gammatable = new int[256];
  int errorCount=0;
  float framerate=0;

  PApplet mApp;
  Guitar mGuitar;

  Guitar2Serial(PApplet app, Guitar guitar)
  {
    mApp = app;
    mGuitar = guitar;

    String[] list = Serial.list();
    delay(20);
    println("Serial Ports List:");
    println(list);
    serialConfigure("/dev/tty.usbmodem414851");  // change these to your port names
    //serialConfigure("/dev/ttyACM1");
    if (errorCount > 0) exit();
    for (int i=0; i < 256; i++) {
      gammatable[i] = (int)(pow((float)i / 255.0f, gamma) * 255.0f + 0.5f);
    }
    //size(480, 400);  // create the window
    //myMovie.loop();  // start the movie :-)
  }

 
  // movieEvent runs for each new frame of movie data
  public void updateDisplay() {
    
    //if (framerate == 0) framerate = m.getSourceFrameRate();
    framerate = 30.0f; // TODO, how to read the frame rate???
    
    //for (int i=0; i < numPorts; i++) {    
      // copy a portion of the movie's image to the LED image
      //int xoffset = percentage(m.width, ledArea[i].x);
      //int yoffset = percentage(m.height, ledArea[i].y);
      //int xwidth =  percentage(m.width, ledArea[i].width);
      //int yheight = percentage(m.height, ledArea[i].height);
      //ledImage[i].copy(m, xoffset, yoffset, xwidth, yheight,
      //                 0, 0, ledImage[i].width, ledImage[i].height);
      // convert the LED image to raw data
    byte[] ledData =  new byte[(8 * Guitar.sNumLedsPerString * 3) + 3];


    strings2data(ledData);

    ledData[0] = '*';  // first Teensy is the frame sync master
    int usec = (int)((1000000.0f / framerate) * 0.75f);
    ledData[1] = (byte)(usec);   // request the frame sync pulse
    ledData[2] = (byte)(usec >> 8); // at 75% of the frame time
    // send the raw data to the LEDs  :-)
    ledSerial[0].write(ledData); 
  }

  // image2data converts the Guitar's pixels to OctoWS2811's raw data format.
  // The data array must be the proper size for the image.
  public void strings2data(byte[] data) {
    int offset = 3;
    int pixel[] = new int[8];

    for(int y = 0; y < Guitar.sNumLedsPerString; y++)
    {
      for(int x = 0; x < 8; x++)
      {
        if(x >= Guitar.sNumStrings)
        {
          pixel[x] = 0;  // Fill non-existant strings with zeros
        }
        else
        {
          pixel[x] = mGuitar.getLed(x, y);
          pixel[x] = colorWiring(pixel[x]);
        }
        data[offset++] = PApplet.parseByte(pixel[x] >> 16);  // G
        data[offset++] = PApplet.parseByte(pixel[x] >> 8);   // R
        data[offset++] = PApplet.parseByte(pixel[x]);        // B
      }
    }
  }

  /********************************
  // image2data converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  void image2data(PImage image, byte[] data, boolean layout) {
    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int linesPerPin = image.height / 8;
    int pixel[] = new int[8];
    
    for (y = 0; y < linesPerPin; y++) {
      if ((y & 1) == (layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = image.width;
        xinc = 1;
      } else {
        // odd numbered rows are right to left
        xbegin = image.width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = image.pixels[x + (y + linesPerPin * i) * image.width];
          pixel[i] = colorWiring(pixel[i]);
        }
        // convert 8 pixels to 24 bytes
        for (mask = 0x800000; mask != 0; mask >>= 1) {
          byte b = 0;
          for (int i=0; i < 8; i++) {
            if ((pixel[i] & mask) != 0) b |= (1 << i);
          }
          data[offset++] = b;
        }
      }
    } 
  }
  ********************************************/

  // translate the 24 bit color from RGB to the actual
  // order used by the LED wiring.  GRB is the most common.
  public int colorWiring(int c)
  {
    int red = (c & 0xFF0000) >> 16;
    int green = (c & 0x00FF00) >> 8;
    int blue = (c & 0x0000FF);
    red = gammatable[red];
    green = gammatable[green];
    blue = gammatable[blue];
    return (green << 16) | (red << 8) | (blue); // GRB - most common wiring
  }

  // ask a Teensy board for its LED configuration, and set up the info for it.
  private void serialConfigure(String portName)
  {
    if (numPorts >= maxPorts) {
      println("too many serial ports, please increase maxPorts");
      errorCount++;
      return;
    }
    try {
      ledSerial[numPorts] = new Serial(mApp, portName);
      if (ledSerial[numPorts] == null) throw new NullPointerException();
      ledSerial[numPorts].write('?');
    } catch (Throwable e) {
      println("Serial port " + portName + " does not exist or is non-functional");
      errorCount++;
      return;
    }
    delay(50);
    String line = ledSerial[numPorts].readStringUntil(10);
    if (line == null) {
      println("Serial port " + portName + " is not responding.");
      println("Is it really a Teensy 3.1 running StrangeBrew?");
      errorCount++;
      return;
    }
    String param[] = line.split(",");
    if (param.length != sNumConfigParams) {
      println("Error: port " + portName + " did not respond to LED config query");
      println(line);
      errorCount++;
      return;
    }
    // only store the info and increase numPorts if Teensy responds properly
    //ledImage[numPorts] = new PImage(Integer.parseInt(param[0]), Integer.parseInt(param[1]), RGB);
    //ledArea[numPorts] = new Rectangle(Integer.parseInt(param[5]), Integer.parseInt(param[6]),
    //                   Integer.parseInt(param[7]), Integer.parseInt(param[8]));
    //ledLayout[numPorts] = (Integer.parseInt(param[5]) == 0);
    numPorts++;
  }

  // getStatus returns TRUE if no errors, else FALSE
  public boolean getStatus()
  {
    try {
      if (ledSerial[0] == null) throw new NullPointerException();
      ledSerial[0].write('?');
    } catch (Throwable e) {
      println("Serial port does not exist or is non-functional");
      errorCount++;
      return false;
    }
    delay(50);
    String line = ledSerial[0].readStringUntil(10);
    if (line == null) {
      println("Serial port is not responding.");
      println("Is it really a Teensy 3.1 running StrangeBrew?");
      errorCount++;
      return false;
    }
    String param[] = line.split(",");
    if (param.length != sNumConfigParams) {
      println("Error: port did not respond to LED config query");
      println(line);
      errorCount++;
      return false;
    }
    // All good, print status
    println(param[0] + ", " + param[1] + ", " + param[2] + ", " + param[3]);
    println(param[4]);
    println(param[5]);
    println(param[6]);
    println(param[7]);
    println(param[8]);
    println(param[9]);

    return true;
  }



  // scale a number by a percentage, from 0 to 100
  public int percentage(int num, int percent)
  {
    double mult = percentageFloat(percent);
    double output = num * mult;
    return (int)output;
  }

  // scale a number by the inverse of a percentage, from 0 to 100
  public int percentageInverse(int num, int percent)
  {
    double div = percentageFloat(percent);
    double output = num / div;
    return (int)output;
  }

  // convert an integer from 0 to 100 to a float percentage
  // from 0.0 to 1.0.  Special cases for 1/3, 1/6, 1/7, etc
  // are handled automatically to fix integer rounding.
  public double percentageFloat(int percent)
  {
    if (percent == 33) return 1.0f / 3.0f;
    if (percent == 17) return 1.0f / 6.0f;
    if (percent == 14) return 1.0f / 7.0f;
    if (percent == 13) return 1.0f / 8.0f;
    if (percent == 11) return 1.0f / 9.0f;
    if (percent ==  9) return 1.0f / 11.0f;
    if (percent ==  8) return 1.0f / 12.0f;
    return (double)percent / 100.0f;
  }
}
// StrangeBrew GuitarString

public class GuitarString
{

	Guitar mGuitar;
	int mOpenNote;
	int[] mLeds = new int[Guitar.sNumLedsPerString];

	GuitarString(Guitar guitar,
		         int openNote)
	{
		mGuitar = guitar;
		mOpenNote = openNote;

		for(int c : mLeds) {c = 0;}

	}

	public int[] getLeds()
	{
		return mLeds;
	}

	public int getLed(int idx)
	{
		return mLeds[idx];
	}

	public void setLed(int idx, int led)
	{
		mLeds[idx] = led;
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "strangeBrew" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
