// Note

public class Note
{

	public final static int sBaseNote = 55;  // Lower than Low A

	private int mNoteIdx;
	private float mAmplitude;

	Note(int 	noteIdx,
		 float 	amplitude)
	{
		mNoteIdx = noteIdx;
		mAmplitude = amplitude;
	}

	// default ctor
	Note()
	{
		mNoteIdx = 0;
		mAmplitude = 0.0;
	}

	public int getIdx()
	{
		return mNoteIdx;
	}

	public float getAmplitude()
	{
		return mAmplitude;
	}

}