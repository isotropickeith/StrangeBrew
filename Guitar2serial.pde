

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
import processing.serial.*;
//import java.awt.Rectangle;

public class Guitar2Serial
{

  public static final float gamma = 1.7;

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
      gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
    }
    //size(480, 400);  // create the window
    //myMovie.loop();  // start the movie :-)
  }

 
  // movieEvent runs for each new frame of movie data
  public void updateDisplay() {
    
    //if (framerate == 0) framerate = m.getSourceFrameRate();
    framerate = 30.0; // TODO, how to read the frame rate???
    
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
    int usec = (int)((1000000.0 / framerate) * 0.75);
    ledData[1] = (byte)(usec);   // request the frame sync pulse
    ledData[2] = (byte)(usec >> 8); // at 75% of the frame time
    // send the raw data to the LEDs  :-)
    ledSerial[0].write(ledData); 
  }

  // image2data converts the Guitar's pixels to OctoWS2811's raw data format.
  // The data array must be the proper size for the image.
  void strings2data(byte[] data) {
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
        data[offset++] = byte(pixel[x] >> 16);  // G
        data[offset++] = byte(pixel[x] >> 8);   // R
        data[offset++] = byte(pixel[x]);        // B
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
  int colorWiring(int c)
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
  int percentage(int num, int percent)
  {
    double mult = percentageFloat(percent);
    double output = num * mult;
    return (int)output;
  }

  // scale a number by the inverse of a percentage, from 0 to 100
  int percentageInverse(int num, int percent)
  {
    double div = percentageFloat(percent);
    double output = num / div;
    return (int)output;
  }

  // convert an integer from 0 to 100 to a float percentage
  // from 0.0 to 1.0.  Special cases for 1/3, 1/6, 1/7, etc
  // are handled automatically to fix integer rounding.
  double percentageFloat(int percent)
  {
    if (percent == 33) return 1.0 / 3.0;
    if (percent == 17) return 1.0 / 6.0;
    if (percent == 14) return 1.0 / 7.0;
    if (percent == 13) return 1.0 / 8.0;
    if (percent == 11) return 1.0 / 9.0;
    if (percent ==  9) return 1.0 / 11.0;
    if (percent ==  8) return 1.0 / 12.0;
    return (double)percent / 100.0;
  }
}
