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
	//FFT mFft;

	ArrayList<String> mSongs;
	String mCurSong;
	int mCurSongIdx;

	boolean mIsLineIn;

	boolean mIsRollingHue;

	AudioProcessing mAudioProcess;

	Note[] mCurNotes = new Note[Guitar.sNumStrings];

	float mRollingHue;
	final static int sRollingHuePeriod = 15 * 60 * sFrameRate; // 15 minutes to roll thruogh the hues
	final static float sRollingHueIncrement = 360.0 / sRollingHuePeriod;  // hue increment each frame

	final static int sBufferSize = 512;
	final static float sDisplayAmplitudeThreshold = 0.25;


	SpectrumAni(PApplet app,
				Guitar guitar,
		        String ctorParams)
	{
		mApp = app;
		mGuitar = guitar;
		mCtorParams = ctorParams;

		mName = new String("Spectrum");

		mIsLineIn  = false;

		mIsRollingHue = false;
		mRollingHue = 0;

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
			((AudioPlayer)mSource).loop();
		}

		mAudioProcess = new AudioProcessing(mSource.bufferSize(), mSource.sampleRate());
		// mFft = new FFT(mSource.bufferSize(), mSource.sampleRate());

		mIsRollingHue = isRollingHueOn();
	}

	public void update()
	{
		mRollingHue = (mRollingHue + sRollingHueIncrement) % 360.0;

		mGuitar.setAll(Guitar.sBackgroundColor);
		if(mAudioProcess != null)
		{
			mAudioProcess.sample(mSource.mix);

			for(int stringNum = 0; stringNum < Guitar.sNumStrings; stringNum++)
			{
				GuitarString curString = mGuitar.getString(stringNum);
				Note curNote = mAudioProcess.getNote(curString); // This will be 0.0 - 1.0 (mostly)
				mCurNotes[stringNum] = curNote;

				// display the note on the GuitarString
				displayNote(curString, curNote);
			}

			displaySpectrum();

			//mFft.forward(mSource.mix);

			// clear last area
			//noStroke();
			//fill(200);
	  		//rect(10, height / 3, (2 * width / 3) - 20, 2 * height / 3);


			//stroke(255, 0, 0, 128);
		    // draw the spectrum as a series of vertical lines
		  	// I multiple the value of getBand by 4 
		  	// so that we can see the lines better
		  	//for(int i = 0; i < mFft.specSize(); i++)
		  	//{
		    //	line(i + 10, height, i + 10, max(height - mFft.getBand(i) * 4, height / 3));
		  	//}
		}
	}

	public void stop()
	{
		mAudioProcess = null;
		if(mIsLineIn)
		{
		}
		else
		{
			((AudioPlayer)mSource).close();
		}
	}

	public void setRollingHueOn()
	{
		mIsRollingHue = true;
	}

	public void setRollingHueOff()
	{
		mIsRollingHue = false;
	}


	public String getName()
	{
		return mName;
	}

	// display the note on the GuitarString
	private void displayNote(GuitarString theString, Note note)
 	{
 		float amplitude = min(note.getAmplitude(), 1.0);  // limit amplitude

 		if(amplitude < sDisplayAmplitudeThreshold)
 		{
 			//If amplitude is too low show string quiet and set noStrike
 			theString.setAllLeds(Guitar.sBackgroundColor);
 			theString.noStrike();
 		}
 		else
 		{
 			int noteLed = theString.getLedIdx(note);
	 		int topLed = noteLed - 1;
	 		colorMode(HSB, 360, 1.0, 1.0);
	 		if(noteLed != -1)
	 		{
	 			theString.setLed(noteLed, color(getAdjustedHue(297), 1.0, 1.0));
	 		}
	 		else
	 		{
	 			topLed = Guitar.sNumLedsPerString - 1;
	 		}
	 		int ledCenter = Guitar.sBridgeStartLed + ((topLed - Guitar.sBridgeStartLed) / 2);
	 		//colorMode(HSB, 360, 1.0, 1.0);
	 		color centerColor = color(getAdjustedHue(0), 1.0, amplitude);  // Red
	 		color endColor = color(getAdjustedHue(269), 1.0, amplitude);   // Violet
	 		float hueIncrement = (hue(endColor) - hue(centerColor)) / ((topLed - Guitar.sBridgeStartLed) / 2);

	  		//println("centerLed = " + centerLed);
			theString.setLed(ledCenter, centerColor);

	 		color curColor = centerColor;
	 		float curHue = hue(centerColor);
	 		for(int i = ledCenter + 1; i <= topLed; i++)
	 		{
	 			curHue += hueIncrement;
	 			curColor = color(curHue, saturation(centerColor), brightness(centerColor));
	 			//println("setLed#1 i = " + i);
	 			theString.setLed(i, curColor);
	 		}
	 		curColor = centerColor;
	 		curHue = hue(centerColor);
	 		for(int i = ledCenter - 1; i >= Guitar.sBridgeStartLed; i--)
	 		{
	 			curHue += hueIncrement;
	 			curColor = color(curHue, saturation(centerColor), brightness(centerColor));
	 			//println("setLed#2 i = " + i);
	 			theString.setLed(i, curColor);
	 		}

	 		// display a strike if detected
	 		if(theString.strike() == false)  // if no strike last frame...
	 		{
	 			theString.setLed(Guitar.sPickLed, color(51, 36, 100));
	 			theString.setLed(Guitar.sPickLed + 1, color(51, 69, 15));
	 			theString.setLed(Guitar.sPickLed - 1, color(51, 69, 15));
	 			//theString.setLed(Guitar.sPickLed + 2, color(51, 100, 100));
	 			//theString.setLed(Guitar.sPickLed - 2, color(51, 100, 100));
	 		}

	 		// restore colorMode
	 		colorMode(RGB, 255);
	 	}
	}

	private float getAdjustedHue(float hueIn)
	{
		float hueOut = hueIn;
		if(mIsRollingHue)
		{
			hueOut = (hueOut + mRollingHue) % 360.0;
		}
		return hueOut;
	}

	private void displaySpectrum()
	{
		// clear last area
		noStroke();
		fill(200);
  		rect(10, height / 3, (2 * width / 3) - 20, 2 * height / 3);


		stroke(255, 0, 0, 128);
	    // draw the spectrum as a series of vertical lines
	  	// I multiple the value of getBand by 4 
	  	// so that we can see the lines better
	  	for(int i = 0; i < mAudioProcess.getSpecSize(); i++)
	  	{
	  		// dbg: adding colors to find EQ for adjustAmplitude
	  		if (i > 100) {
	  			stroke(255,0,0,128);
	  		}
	  		else if (i > 75) {
	  			stroke(0,255,0,128);
	  		}
	  		else if (i > 50) {
				stroke(255,0,0,128);
	  		}
	  		else if (i > 25) {
				stroke(0,255,0,128);
	  		}
	    	line(i + 10,
	    		 height,
	    		 i + 10,
	    		 max(height - mAudioProcess.getBandAmplitude(i) * 512, height / 3));
	  	}
	}
}