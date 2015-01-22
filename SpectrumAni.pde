// SpectrumAnalyzer animation

import ddf.minim.*;
import ddf.minim.analysis.*;

public class SpectrumAni implements Animation
{
	PApplet mApp;
	Guitar mGuitar;
	String mCtorParams;
	String mStartParams;
	String mName;

	Minim mMinim;
	AudioSource mSource;
	FFT mFft;

	ArrayList<String> mSongs;
	String mCurSong;
	int mCurSongIdx;

	boolean mIsLineIn;

	final static int sBufferSize = 512;


	SpectrumAni(PApplet app,
				Guitar guitar,
		        String ctorParams)
	{
		mApp = app;
		mGuitar = guitar;
		mCtorParams = ctorParams;

		mName = new String("Spectrum");

		mIsLineIn  = false;

		mSongs = new ArrayList<String>();

		mCurSong = new String("HeavyDuty.mp3");
		mSongs.add(mCurSong);

		mCurSongIdx = 0;

		// add more songs here (must be in the data subdirectory)

		mMinim = new Minim(mApp);
	}
	
	public void start(String startParams)
	{
		mStartParams = startParams;

		mIsLineIn  = mStartParams.equals("LINE_IN");
		if(mIsLineIn)
		{
			mSource = mMinim.getLineIn(Minim.STEREO, sBufferSize);
		}
		else
		{
			mSource = mMinim.loadFile(mCurSong, sBufferSize);
			((AudioPlayer)mSource).play();
		}

		mFft = new FFT(mSource.bufferSize(), mSource.sampleRate());
	}

	public void update()
	{
		mFft.forward(mSource.mix);

		// clear last area
		noStroke();
		fill(200);
  		rect(10, height / 3, width - 20, 2 * height / 3);


		stroke(255, 0, 0, 128);
	    // draw the spectrum as a series of vertical lines
	  	// I multiple the value of getBand by 4 
	  	// so that we can see the lines better
	  	for(int i = 0; i < mFft.specSize(); i++)
	  	{
	    	line(i + 10, height, i + 10, height - mFft.getBand(i) * 4);
	  	}
	}

	public void stop()
	{
		if(mIsLineIn)
		{
		}
		else
		{
			((AudioPlayer)mSource).close();
		}
	}

	String getName()
	{
		return mName;
	}
}