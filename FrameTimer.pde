/*
 * Simple timer class based on frameCount.
 *
 * Keith Rasmussen, 2014
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;

public class FrameTimer
{
  int mFrameRate;
  boolean mIsPeriodic;
  boolean mIsRunning;
  boolean mHasTriggered;
  int mTargetFrame;
  int mPeriod;          // period in frames
  
  FrameTimer(int fRate)        // frameRate (fps) programmed for the sketch
  {
    mFrameRate = fRate;
    mIsPeriodic = false;
    mIsRunning = false;
    mHasTriggered = false;
  }
  
  
  
  void
  startTimer(int period,    // period of the timer in milliseconds, rounded to nearest frame period
             boolean isPeriodic)
  {
    float msPerFrame = 1000.0 / mFrameRate;
    mPeriod = round(period / msPerFrame);    
    if(mPeriod < 1)
    {
      mPeriod = 1;
    }
    mIsPeriodic = isPeriodic;
    
    mTargetFrame = frameCount + mPeriod;
    //mHasTriggered = false;
    mIsRunning = true;
  }
  
  boolean
  hasFired()
  {
    if(mIsRunning && (frameCount >= mTargetFrame))
    {
      //Timer has fired!
      if(mIsPeriodic)
      {
        //mTargetFrame += mPeriod;
        mTargetFrame = frameCount + mPeriod;   // so pauses don't mess us up
      }
      else
      {
        mIsRunning = false;
      }
      return true;
    }
    else
    {
      return false;
    }
  }
  
  void cancel()
  {
    mIsRunning = false;
  }
}

        
        
