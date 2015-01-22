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
	private color[] mLeds = new color[sNumStrings * sNumLedsPerString];

	// Animation vars (temporary)

	private int curString = 0;
	private int curLed = 0;
	private color curColor = #FF0000;

	// ctor

	Guitar()
	{
		for(color c : mLeds) {c = 0;}

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

	public color[] getLeds()
	{
		int ledIdx = 0;
		for(GuitarString s : mString)
		{
			color[] stringLeds = s.getLeds();
			arrayCopy(stringLeds, 0, mLeds, ledIdx, sNumLedsPerString);
			ledIdx += sNumLedsPerString;
		}
		return mLeds;
	}

	public color getLed(int stringNum, int intLedIdx)
	{
		return mString[stringNum].getLed(intLedIdx);
	}

	public void setLed(int stringNum, int intLedIdx, color led)
	{
		mString[stringNum].setLed(intLedIdx, led);
	}

	public void setAll(color c)
	{
	  for(int j = 0; j < sNumStrings; j++)
	  {
	    for(int i = 0; i < sNumLedsPerString; i++)
	    {
	      setLed(j, i, c);
	    }
	  }
	}

	public void setString(int stringNum, color c)
	{
	    for(int i = 0; i < sNumLedsPerString; i++)
	    {
	      setLed(stringNum, i, c);
	    }
	}

	private void playAnimation()
	{
		//setLed(5, 10, #00FF00);
		
		//if(frameCount % 10 == 0)
		if(true)
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
						curColor = #FF0000;
					}
				}
			}
		}
	}
}
