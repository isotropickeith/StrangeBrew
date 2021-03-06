// StrangeBrew

// set noGuitar to true if no Teesy3.1 attached via serial
boolean noGuitar = true;  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< LIVE!!!@!!

Guitar guitar;
Guitar2Serial guitarInterface;

ArrayList<Animation> mAnimations;
Animation mCurAnimation;

final static int sFrameRate = 60;

int curAnimationIdx = 0;

// set to true if wanting to use line audio as source
boolean isUsingLineInput = true;

// setot true to enable use of a rolling hue base
boolean isUsingRollingHue = false;

// Please don't modify or remove anything in here
// It's ok to add initialization etc
void setup()
{
  size(480, 800);  // create the window
  background(200);
  frameRate(sFrameRate);

  guitar = new Guitar();

  if(!noGuitar)
  {
      guitarInterface = new Guitar2Serial(this, guitar);
  }

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
  printModes();
  printScreenHelp();
}


void draw ()
{
  mCurAnimation.update();
  //guitar.play();
  if(!noGuitar)
  {
    guitarInterface.updateDisplay();
  }

  printGuitar();   // On the computer screen
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

boolean isRollingHueOn()
{
  return isUsingRollingHue;
}


// respond to mouse clicks as pause/play
void mousePressed()
{
  if(!noGuitar)
  {
    guitarInterface.getStatus();
  }
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
    printModes();
  }
  else if((key == 'h') || (key == 'H'))
  {
    isUsingRollingHue = !isUsingRollingHue;   // toggle Rolling Hue Mode
    mCurAnimation.stop();
    mCurAnimation.start(isUsingLineInput ? "LINE_IN" : "");
    printModes();
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

void printModes()
{
  String s = new String("Line In : " + (isUsingLineInput ? "ENABLED" : "DISABLED") +
                        "\n Rolling Hue : " + (isUsingRollingHue ? "ENABLED" : "DISABLED"));
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
  s += ("\nH : Toggle Rolling Hue");

  textSize(14);
  textLeading(15);
  //rect(10, 10, width / 2, height / 15);
  fill(0, 102, 153);
  text(s, width / 2, 10, (width / 2) - 10, height / 2);

}

void printGuitar()
{
  int string1x = 3 * width / 4;
  int string1y = height - 10;
  int ledYInterval = 4;
  int ledXInterval = 8;
  int boxX = string1x - 10;
  int boxY = string1y - 10 - (Guitar.sNumLedsPerString * ledYInterval);
  int ledSize = 3;

  fill(0);
  stroke(255, 0, 0);
  rect(boxX, boxY, ledXInterval * Guitar.sNumStrings + 10, ledYInterval * Guitar.sNumLedsPerString + 20);


  for(int j = 0; j < Guitar.sNumStrings; j++)
  {
    for(int i = 0; i < Guitar.sNumLedsPerString; i++)
    {
      fill(guitar.getLed(j, i));
      stroke(guitar.getLed(j, i));
      ellipse(string1x + (ledXInterval * j), string1y - (ledYInterval * i), ledSize, ledSize);
    }
  }
}