// Test Animation

public class TestAni implements Animation
{
	PApplet mApp;
	Guitar mGuitar;
	String mCtorParams;
	String mStartParams;
	String mName = new String("Test");

	int mCurString;
	int mCurLed;
	color mCurColor;
	int mCurPass;
	final static int sNumPasses = 1;


	TestAni(PApplet app,
		    Guitar guitar,
		    String ctorParams)
	{
		mApp = app;
		mGuitar = guitar;
		mCtorParams = ctorParams;
	}
	
	public void start(String startParams)
	{
		mStartParams = startParams;
		mGuitar.setAll(#000000);
		mCurPass = 0;
		mCurString = 0;
		mCurLed = 0;
		mCurColor = #FF0000;
	}

	public void update()
	{

	}

	public void stop()
	{
		
	}

	String getName()
	{
		return mName;
	}
}