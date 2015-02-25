package com.drich.libge;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.app.NativeActivity;
import android.content.Context;
import android.os.Bundle;
import android.opengl.GLSurfaceView;
import android.view.Window;
import android.view.SurfaceView;
import android.view.Surface;
import android.view.SurfaceHolder;

public class LibGE extends NativeActivity
{
	static {
		System.loadLibrary("ge");
	}

	public static native void setHasSurface(int hasSurface);
	public static native void setSurface(Surface surface, int x, int y);

	private GLSurfaceView glSurfaceView;
	private SurfaceView surfaceView;
	private Surface surface;

	public void onCreate(Bundle savedInstanceState)
	{
		setHasSurface(1);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);

		surfaceView = new SurfaceView(this);
		surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
			@Override
			public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
				surface = holder.getSurface();
				int[] loc = new int[2];
				surfaceView.getLocationOnScreen(loc);
				setSurface(surface, loc[0], loc[1]);
			}
			@Override
			public void surfaceCreated(SurfaceHolder holder) {
			}
			@Override
			public void surfaceDestroyed(SurfaceHolder holder) {}
		});
		getWindow().setContentView(surfaceView);
	}

	@Override
	public void onStart()
	{
		super.onStart();
	}
}
