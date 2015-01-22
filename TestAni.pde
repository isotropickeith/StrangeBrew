// Test Animation

public class TestAni implements Animation
{
	PApplet mApp;
	Guitar mGuitar;
	String mCtorParams;
	String mStartParams;
	String mName = new String("Test");

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