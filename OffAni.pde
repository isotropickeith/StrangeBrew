// "Off"  animation

public class OffAni implements Animation
{
	PApplet mApp;
	Guitar mGuitar;
	String mCtorParams;
	String mStartParams;
	String mName = new String("Off");

	int mLedPosn;

	final static color sBarColor = #0000FF;
	final static color sOffColor = #202020;


	OffAni(PApplet app,
		   Guitar guitar,
		   String ctorParams)
	{
		mApp = app;
		mGuitar = guitar;
		mCtorParams = ctorParams;

		mLedPosn = -1;
	}
	
	public void start(String startParams)
	{
		mStartParams = startParams;

		mLedPosn = Guitar.sNumLedsPerString;
		update();
	}

	public void update()
	{
		if(mLedPosn >= 0)
		{
			if(mLedPosn != 0)
			{
				for(int i = 0; i < Guitar.sNumStrings; i++)
				{
					mGuitar.setLed(i, mLedPosn - 1, sBarColor);
				}
			}
			if(mLedPosn != Guitar.sNumLedsPerString)
			{
				for(int i = 0; i < Guitar.sNumStrings; i++)
				{
					mGuitar.setLed(i, mLedPosn, sOffColor);
				}
			}
			mLedPosn--;
		}
	}

	public void stop()
	{

	}

	String getName()
	{
		return mName;
	}
}