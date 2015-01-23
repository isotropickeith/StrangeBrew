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
		if(mAudioProcess != null)
		{
			mAudioProcess.sample(mSource.mix);

			for(int stringNum = 0; stringNum < Guitar.sNumStrings; stringNum++)
			{
				GuitarString curString = mGuitar.getString(stringNum);
				Note curNote = mAudioProcess.getNote(curString);
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
 		// TODO!!!!!!!!!!!!!!
		//theString.setLed(???);
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
	    	line(i + 10,
	    		 height,
	    		 i + 10,
	    		 max(height - mAudioProcess.getBandAmplitude(i) * 4, height / 3));
	  	}
	}
}