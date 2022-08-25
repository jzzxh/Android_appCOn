import android.os.Environment;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;
import android.app.DownloadManager;
import android.net.Uri;
import java.io.File;

import oscP5.*;
import netP5.*;

float val = 0;
int val2 = 0;
//PFont fontA;

OscP5 oscP5;
NetAddress myRemoteLocation;

boolean openState = true;
boolean downState = true;

void setup() {
  fullScreen(P2D);

  //noLoop();
  //frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 8888);

  myRemoteLocation = new NetAddress("192.168.0.224", 12000);

  smooth();
  textAlign(CENTER);
  textSize(55);

  // test file path
  //File file = new File(getActivity().getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS));
  //String file = getActivity().getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();
  //String file = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath();

  //Context context = surface.getContext();
  //File fl = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
  //String folder_download = "vrFiles";
  //File fd = new File(fl, folder_download);
  //File fvid = new File(fd, "BigBuckBunny.mp4");
  //String vpath = "http://192.168.0.224/vid/BigBuckBunny.mp4";
  //DownloadManager.Request request = new DownloadManager.Request(Uri.parse(vpath)).setTitle("BigBuckBunny").setDescription("Downloading")
  //  //.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE | DownloadManager.Request.NETWORK_WIFI)
  //  .setAllowedOverMetered(false)
  //  .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED).setDestinationUri(Uri.fromFile(fvid)).setAllowedOverRoaming(false);
  //DownloadManager downloadManager = (DownloadManager) getActivity().getSystemService(context.DOWNLOAD_SERVICE);
  //downloadManager.enqueue(request);
  //println(downloadManager);
  //if(!fd.exists()){
  //  fd.mkdirs();
  //}

  //String file2 = fl.getAbsolutePath();
  //println(file2);
  //File[] files = fl.listFiles();
  //for (int i = 0; i < files.length; i++) {
  //  println(files[i].getName());
  //}

  //File directory = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES));
}



void draw() {
  //if (mousePressed) {
  //  ellipse(mouseX, mouseY, 50, 50);
  //}
  background(220);
  fill(0);
  text("Test. "+String.valueOf(val), width/2, height/2);
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/ttt")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("i")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int firstValue = theOscMessage.get(0).intValue();  // get the first osc argument
      //float secondValue = theOscMessage.get(1).floatValue(); // get the second osc argument
      //String thirdValue = theOscMessage.get(2).stringValue(); // get the third osc argument
      //print("### received an osc message /test with typetag ifs.");
      //println(" values: "+firstValue+", "+secondValue+", "+thirdValue);
      //println(firstValue);
      if (firstValue == 1) {
        turnOnFlash();
      } else {
        turnOffFlash();
      }
      val = firstValue;
      return;
    }
  }

  // Intent Test
  if (theOscMessage.checkAddrPattern("/oapp")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("i")) {
      int _val = theOscMessage.get(0).intValue();  // get the first osc argument

      if (_val == 1 && openState) {
        Context context = surface.getContext();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage("com.jzzxh.VR360_1111");
        if (launchIntent != null) {
          launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          startActivity(launchIntent);//null pointer check in case package name was not found
        }

        println(launchIntent);

        //kill all activity & task list
        getActivity().finishAndRemoveTask();
        //int pid = android.os.Process.myPid();
        //android.os.Process.killProcess(pid);
        openState = false;
      }

      return;
    }
  }

  // Download Test
  if (theOscMessage.checkAddrPattern("/download")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("i")) {
      int _val = theOscMessage.get(0).intValue();  // get the first osc argument

      if (_val == 1 && downState) {
        Context context = surface.getContext();
        File fl = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        String folder_download = "vrFiles";
        File fd = new File(fl, folder_download);
        File fvid = new File(fd, "BigBuckBunny.mp4");
        String vpath = "http://vrvideo.down/BigBuckBunny.mp4";
        DownloadManager.Request request = new DownloadManager.Request(Uri.parse(vpath)).setTitle("BigBuckBunny").setDescription("Downloading")
          //.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE | DownloadManager.Request.NETWORK_WIFI)
          .setAllowedOverMetered(false)
          .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED).setDestinationUri(Uri.fromFile(fvid)).setAllowedOverRoaming(false);
        DownloadManager downloadManager = (DownloadManager) getActivity().getSystemService(context.DOWNLOAD_SERVICE);
        downloadManager.enqueue(request);
        println(downloadManager);

        downState = false;
      }

      return;
    }
  }
}


public void turnOnFlash() {
  Context context = surface.getContext();
  if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)) {
    CameraManager mCameraManager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
    try {
      String mCameraId = mCameraManager.getCameraIdList()[0];
      mCameraManager.setTorchMode(mCameraId, true);
    }
    catch (CameraAccessException e) {
      e.printStackTrace();
    }
  }
}

public void turnOffFlash() {
  Context context = surface.getContext();
  if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)) {
    CameraManager mCameraManager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
    try {
      String mCameraId = mCameraManager.getCameraIdList()[0];
      mCameraManager.setTorchMode(mCameraId, false);
    }
    catch (CameraAccessException e) {
      e.printStackTrace();
    }
  }
}
