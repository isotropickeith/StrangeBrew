// StrangeBrew GuitarString

public class GuitarString
{

	Guitar mGuitar;
	int mOpenNote;
	int mHighNote;

	boolean mStrike;

	color[] mLeds = new color[Guitar.sNumLedsPerString];

	GuitarString(Guitar guitar,
		         int openNote)
	{
		mGuitar = guitar;
		mOpenNote = openNote;
		mHighNote = mOpenNote + Guitar.sNumFrets;
		mStrike = false;

		setAllLeds(0);
		//for(color c : mLeds) {c = 0;}

	}

	public color[] getLeds()
	{
		return mLeds;
	}

	public color getLed(int idx)
	{
		return mLeds[idx];
	}

	public void setLed(int idx, color led)
	{
		mLeds[idx] = led;
	}

	public void setAllLeds(color led)
	{
		for(color c : mLeds) {c = led;}
	}

	public int getLowNote()
	{
		return mOpenNote;
	}

	public int getHighNote()
	{
		return mHighNote;
	}

	public int getFret(Note note)
	{
		int fret = note.getIdx() - mOpenNote;
		if((fret < 0) || (fret >= mGuitar.sNumFrets))
		{
			return -1;
		}
		else
		{
			return fret;
		}
	}

	public int getLedIdx(Note note)
	{
		int fret = getFret(note);
		if(fret == -1)
		{
			return -1;
		}
		else
		{
			return mGuitar.getFretLed(fret);
		}
	}

	public boolean strike()
	{
		boolean last = mStrike;
		mStrike = true;
		return last;
	}
	
	public boolean noStrike()
	{
		boolean last = mStrike;
		mStrike = false;
		return last;
	}
}