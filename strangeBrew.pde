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


Guitar guitar;
Guitar2Serial guitarInterface;

// Please don't modify or remove anything in here
// It's ok to add initialization etc
void setup()
{
  size(480, 400);  // create the window

  guitar = new Guitar();
  guitarInterface = new Guitar2Serial(this, guitar);
}


void draw ()
{
  guitar.play();
  guitarInterface.updateDisplay();
}




void stop()
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
void mousePressed()
{
  guitarInterface.getStatus();
}
