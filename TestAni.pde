// Test Animation

public class TestAni implements Animation
{
	PApplet mApp;
	Guitar mGuitar;
	String mCtorParams;
	String mStartParams;
	String mName = new String("Test");

	FrameTimer mTimer;

	boolean mIsNewPass;

	int mCurString;
	int mCurLed;
	color mCurColor;
	int mCurPass;
	color[] mPass0Colors = {#FF0000,
							#00FF00,
							#0000FF,
							#FFFFFF};

	color[] mPass1Colors = {#FF0000,
							#00FF00,
							#0000FF,
							#FFFFFF};

	color[] mPass2Colors = {#FF0000,
							#00FF00,
							#0000FF,
							#FFFFFF};
	int mPassSubpass = 0;

	final static int sNumPasses = 3;


	TestAni(PApplet app,
		    Guitar guitar,
		    String ctorParams)
	{
		mApp = app;
		mGuitar = guitar;
		mCtorParams = ctorParams;

		mTimer = new FrameTimer(sFrameRate);
	}
	
	public void start(String startParams)
	{
		mStartParams = startParams;
		mGuitar.setAll(#000000);
		mCurPass = 0;
		mIsNewPass = true;
		mPassSubpass = 0;
		mCurString = 0;
		mCurLed = 0;
		mCurColor = #FF0000;
	}

	public void update()
	{
		switch(mCurPass)
		{
		 case 0 :
		 	if(mIsNewPass)
		 	{
		 		mIsNewPass = !mIsNewPass;
		 	}
			mGuitar.setAll(#000000);
			mGuitar.setLed(mCurString, mCurLed++, mPass0Colors[mPassSubpass]);
			if(mCurLed == Guitar.sNumLedsPerString)
			{
				mCurLed = 0;
				mCurString++;
				if(mCurString == Guitar.sNumStrings)
				{
					mCurString =0;
					if(++mPassSubpass == mPass0Colors.length)
					{
						mPassSubpass = 0;
						mCurPass = (++mCurPass) % sNumPasses;
						initNewPass(mCurPass);
					}
				}
			}
			break;
		 case 1 :
		 	if(mIsNewPass)
		 	{
		 		mIsNewPass = !mIsNewPass;
		 		mPassSubpass = 0;

		 		mTimer.startTimer(1000, false);
				mGuitar.setString(mCurString, mPass1Colors[mPassSubpass]);
		 	}
		 	else
		 	{
		 		if(mTimer.hasFired())
		 		{
		 			mGuitar.setAll(#000000);
		 			if(++mCurString == Guitar.sNumStrings)
		 			{
		 				mCurString = 0;
		 				if(++mPassSubpass == mPass1Colors.length)
						{
							mPassSubpass = 0;
							mCurPass = (++mCurPass) % sNumPasses;
							initNewPass(mCurPass);
							break;
						}
		 			}
 					mGuitar.setString(mCurString, mPass1Colors[mPassSubpass]);
 					mTimer.startTimer(1000, false);
		 		}
		 	}
			break;
		 case 2 :
		 	if(mIsNewPass)
		 	{
		 		mIsNewPass = !mIsNewPass;
		 		mPassSubpass = 0;

		 		mTimer.startTimer(1500, false);
				mGuitar.setAll(mPass2Colors[mPassSubpass]);
		 	}
		 	else
		 	{
		 		if(mTimer.hasFired())
		 		{
	 				if(++mPassSubpass == mPass2Colors.length)
					{
						mPassSubpass = 0;
						mCurPass = (++mCurPass) % sNumPasses;
						initNewPass(mCurPass);
						break;
					}
					mGuitar.setAll(mPass2Colors[mPassSubpass]);
					mTimer.startTimer(1500, false);
	 			}
		 	}
			break;

		 default:
		 	println("ERROR: TestAni mCurPass out of range!");
		 	exit();
		 	break;
		}
	}

	public void stop()
	{
		mGuitar.setAll(#000000);
	}

	public String getName()
	{
		return mName;
	}

	private void initNewPass(int passNum)
	{
		mGuitar.setAll(#000000);
		mIsNewPass = true;
	}
}