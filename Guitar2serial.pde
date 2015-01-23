

/*  OctoWS2811 Guitar2serial.pde - Transmit six guitar strings to a
      Teensy 3.1 board running OctoWS2811 StrangeBrew.ino

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import processing.serial.*;

public class Guitar2Serial
{

  public static final float gamma = 1.7;

  public static final int sNumConfigParams = 10;

  int numPorts=0;  // the number of serial ports in use
  int maxPorts=1;  // maximum number of serial ports

  Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
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

    serialConfigure("/dev/tty.usbmodem419751");  // The real guitar
    //serialConfigure("/dev/tty.usbmodem414851");    // Keith's test Teensy3.1

    if (errorCount > 0) exit();
    for (int i=0; i < 256; i++) {
      gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
    }
  }

 
  // movieEvent runs for each new frame of movie data
  public void updateDisplay() {
    
    //if (framerate == 0) framerate = m.getSourceFrameRate();
    framerate = 30.0; // TODO, how to read the frame rate???
    
    // convert the LED image to raw data
    byte[] ledData =  new byte[(8 * Guitar.sNumLedsPerString * 3) + 3];


    strings2data(ledData);

    ledData[0] = '*';  // first Teensy is the frame sync master
    int usec = (int)((1000000.0 / framerate) * 0.75);
    ledData[1] = (byte)(usec);   // request the frame sync pulse
    ledData[2] = (byte)(usec >> 8); // at 75% of the frame time

    // send the raw data to the LEDs  :-)
    ledSerial[0].write(ledData);

    // debug########
    //if(frameCount % 30 == 0)
    //{
    //  dump(ledData);
    //}
  }

  // image2data converts the Guitar's pixels to OctoWS2811's raw data format.
  // The data array must be the proper size for the image.
  void strings2data(byte[] data) {
    int offset = 3;
    int pixel[] = new int[8];
    int mask;

    for(int x = 0; x < Guitar.sNumLedsPerString; x++) { 
      for(int y = 0; y < 6; y++) {
        // fetch 8 pixels from the image, 1 for each pin
        pixel[y] = mGuitar.getLed(y, x);
        pixel[y] = colorWiring(pixel[y]);
      }
      // now pixel[] has the 24 bit values of each string as index of the x LED
      // so need to get 24 bits * 8 indexes to 8 bits * 24 indexes (offset marks index)

        for (mask = 0x800000; mask != 0; mask >>= 1) {
          byte b = 0;
          for (int y = 0; y < 6; y++) {
            if ((pixel[y] & mask) != 0) b |= (1 << y);
          }
          data[offset++] = b;
        }
    }
  }

  // translate the 24 bit color from RGB to the actual
  // order used by the LED wiring.  GRB is the most common.
  private int colorWiring(int c)
  {
    int red = (c & 0xFF0000) >> 16;
    int green = (c & 0x00FF00) >> 8;
    int blue = (c & 0x0000FF);
    red = gammatable[red];
    green = gammatable[green];
    blue = gammatable[blue];
    return (green << 16) | (red << 8) | (blue);   // GRB - most common wiring
    //return (red << 16) | (green << 8) | (blue); // RGB wiring
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

  public void dump(byte[] data)
  {
    println( data[0] + ", " + data[1] + ", " + data[2]);
    println( data[3] + ", " + data[4] + ", " + data[5] + ", " + data[6] + ", " + data[7] + ", " + data[8] + ", " + data[9] + ", " + data[10]);
  }
}


