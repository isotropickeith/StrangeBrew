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

	AudioProcessing mAudioProcess;

	Note[] mCurNotes = new Note[Guitar.sNumStrings];

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

		mAudioProcess = new AudioProcessing(mSource.bufferSize(), mSource.sampleRate());
		// mFft = new FFT(mSource.bufferSize(), mSource.sampleRate());
	}

	public void update()
	{
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

	public String getName()
	{
		return mName;
	}

	// display the note on the GuitarString
	private void displayNote(GuitarString theString, Note note)
 	{
 		float amplitude = min(note.getAmplitude(), 1.0);  // limit amplitude
 		int noteLed = theString.getLedIdx(note);
 		int topLed = noteLed - 1;
 		if(noteLed != -1)
 		{
 			theString.setLed(noteLed, #FFFFFF);
 		}
 		else
 		{
 			topLed = Guitar.sNumLedsPerString - 1;
 		}
 		int ledCenter = Guitar.sBridgeStartLed + ((topLed - Guitar.sBridgeStartLed) / 2);
 		colorMode(HSB, 360, 1.0, 1.0);
 		color centerColor = color(0, 1.0, amplitude);  // Red
 		color endColor = color(269, 1.0, amplitude);   // Violet
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