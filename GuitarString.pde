// StrangeBrew GuitarString

public class GuitarString
{

	Guitar mGuitar;
	int mOpenNote;
	int mHighNote;
	color[] mLeds = new color[Guitar.sNumLedsPerString];

	GuitarString(Guitar guitar,
		         int openNote)
	{
		mGuitar = guitar;
		mOpenNote = openNote;
		mHighNote = mOpenNote + Guitar.sNumFrets;

		for(color c : mLeds) {c = 0;}

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

	public int getLowNote()
	{
		return mOpenNote;
	}

	public int getHighNote()
	{
		return mHighNote;
	}
}