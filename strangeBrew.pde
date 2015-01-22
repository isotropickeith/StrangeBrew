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

ArrayList<Animation> mAnimations;
Animation mCurAnimation;


int curAnimationIdx = 0;

// set to true if wanting to use line audio as source
boolean isUsingLineInput = true;

// Please don't modify or remove anything in here
// It's ok to add initialization etc
void setup()
{
  size(480, 400);  // create the window
  background(200);

  guitar = new Guitar();
  guitarInterface = new Guitar2Serial(this, guitar);

  // Instantiate Animations
  mAnimations = new ArrayList<Animation>();

  Animation newAnimation = new OffAni(this, guitar, "");
  mAnimations.add(newAnimation);

  newAnimation = new TestAni(this, guitar, "");
  mAnimations.add(newAnimation);

  newAnimation = new SpectrumAni(this, guitar, "");
  mAnimations.add(newAnimation);

  mCurAnimation = mAnimations.get(0); // Start with the first animation

  mCurAnimation.start(isUsingLineInput ? "LINE_IN" : "");

  printCurAnimation();
  printLineInMode();
  printScreenHelp();
}


void draw ()
{
  mCurAnimation.update();
  //guitar.play();
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

// respond to key press commands
void keyTyped()
{
  if((key >= '0') && (key <= '9'))
  {
    int idx = key - '0';

    if((idx < mAnimations.size()) && (mAnimations.get(idx) != mCurAnimation))
    {
      // legit NEW animation, stop current animation and start new one
      mCurAnimation.stop();
      mCurAnimation = mAnimations.get(idx);
      mCurAnimation.start(isUsingLineInput ? "LINE_IN" : "");

      printCurAnimation();
    }
  }
  else if(key == '?')
  {
    printHelp();
  }
  else if((key == 'l') || (key == 'L'))
  {
    isUsingLineInput = !isUsingLineInput;   // toggle Line Input Mode
    mCurAnimation.stop();
    mCurAnimation.start(isUsingLineInput ? "LINE_IN" : "");
    printLineInMode();
  }
  else
  {
    println();
    println("Unknown keypress : " + key);
    printHelp();
  }
}

void printHelp()
{
  println();
  println("Valid Keys");
  println("==========");
  for(int i = 0; i < mAnimations.size(); i++)
  {
    println(i + " : " + mAnimations.get(i).getName() + " animation");
  }
  println("L : Toggle Line Input Mode");
  println("? : Print Help");
  println();
}

void printCurAnimation()
{
  String s = new String("Animation : " + mCurAnimation.getName());
  println(s);

  // on screen :
  fill(200);
  noStroke();
  textSize(14);
  rect(10, 10, (width / 2) - 10, height / 15);
  fill(0, 102, 153);
  text(s, 10, 10, (width / 2) - 10, height / 15);
}

void printLineInMode()
{
  String s = new String("Line In : " + (isUsingLineInput ? "ENABLED" : "DISABLED"));
  println(s);

  // on screen :
  fill(200);
  noStroke();
  textSize(14);
  rect(10, 10 + (height / 15), (width / 2) - 10, 2 * height / 15);
  fill(0, 102, 153);
  text(s, 10, 10 + (height / 15), (width / 2) - 10, 2 * height / 15);
}

void printScreenHelp()
{
  String s = new String("Animation Keys :\n");
  for(int i = 0; i < mAnimations.size(); i++)
  {
    s += (i + " : " + mAnimations.get(i).getName() + " animation\n");
  }
  s += ("L : Toggle Line Input");

  textSize(14);
  textLeading(15);
  //rect(10, 10, width / 2, height / 15);
  fill(0, 102, 153);
  text(s, width / 2, 10, (width / 2) - 10, height / 2);

}