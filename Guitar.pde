// Guitar
//
// StrageBrew Guitar

public class Guitar
{
	public static final int sLowE = 7;			// Index
	public static final int sLowA = 12;		
	public static final int sLowD = 17;
	public static final int sLowG = 22;
	public static final int sLowB = 26;
	public static final int sHiE  = 31;

	public static final int sNumLedsPerString = 147;
	public static final int sNumStrings = 6;
	public static final int sBridgeStartLed = 6;
	public static final int sPickLed = 25;			// LED where string is picked
	public static final int sNumFrets = 23;

	public static final color sBackgroundColor = #080808;  //color when strings are idle

	public final int[] sFretLed = {	  -1,	 // Open sting, no LED
									  139,   // 8  1st fret
									  132,   // 7
									  125,
									  118,	 // 7
									  112,   // 6
									  104,
									  100,   // 6
									  95,    // 5
									  90,    // 5
									  85,    // 5
									  81,    // 4
									  77,	 // 12th fret (octave)
									  73,    
									  69,
									  65,    // 4
									  62,    // 3
									  59,
									  56,
									  53,
									  50,    // 3
									  49,    // 2
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

	public GuitarString getString(int idx)
	{
		if(idx < mString.length)
		{
			return mString[idx];
		}
		else 
		{
			return null;
		}
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

	public int getFretLed(int fret)
	{
		if(fret < sFretLed.length)
		{
			return sFretLed[fret];
		}
		else
		{
			return -1;
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
