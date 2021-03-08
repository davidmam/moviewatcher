
// movie annotator

import java.util.HashMap;
import java.util.Map;
import processing.video.*;
import java.io.File;
import java.util.Iterator;
import java.util.prefs.Preferences;
import java.nio.file.Files;

java.awt.Insets insets;
Movie myMovie;
File infile;
File infiledir ;
String defaultinfile=new File(System.getProperty("user.home"),"video.mp4").toString();
File outfile;
File outfiledir;
String defaultoutfile=new File(System.getProperty("user.home"),"results.txt").toString();
PrintWriter outfilestream;
//movie
boolean running= false;
int framerate=30;
int framecount=0;
int movH;
int tboxw = 700;
int tboxh = 200;
float hRatio;
float wRatio;
float movRatio=1.0;
float speedfactor=4.0;
int movW;
int lastcount;
float lasttime;
boolean p3=true;
int eventcount=0;
Preferences prefs = Preferences.userNodeForPackage(this.getClass());
HashMap <String, Integer> keysdown = new HashMap <String, Integer> ();
int status = 0; // status 0 - need to select movie. status 1 select output. status 2 ready status 3 running.
void keyReleased (){
  //find key.
  char [] kp ={key};
  String k = new String(kp);
  if (status == 3){
  // if (running){
    if (keysdown.containsKey(k)){
      // write to file
      String filename=infile.getName();
      outfilestream.println(filename+"\t"+k +"\t"+keysdown.get(k)+"\t"+framecount);
      outfilestream.flush();
      //delete key
      keysdown.remove(k);
      eventcount+=1;
    }
  } else if (status == 2) {
    //start running and 
    outfilestream=createWriter(outfile.getAbsolutePath());
    outfilestream.println("Frame data for file "+infile.getAbsolutePath());
    outfilestream.println("");
    outfilestream.println("File\tKey\tStart\tEnd");
    myMovie = new Movie(this, infile.getAbsolutePath());
    framecount=0;
    lasttime=0.0;
    lastcount=0;
    println("MovieW " + myMovie);
    //myMovie.read();
    //myMovie.speed(speedfactor);
    myMovie.play(); 
    //myMovie.speed(speedfactor);
    status = 3;
  }
    
  //check if running
  //get key down from keysPressed
  //get movie frame and write key, start stop to outfile
  //delete from keysPressed
  //else
  //check status and start running
  
}

void keyPressed () {
  //get key
  if (status < 3){
    if (key == 88 || key == 120){
      exit();
    }
  }
  if (status == 0){
    selectInput("Select input movie file:", "selectInputFile", infiledir);
  } else if (status == 1) {
    selectOutput("Select output data file:", "selectOutputFile", outfiledir);
  } else if (status == 3) {
    
    if (key==CODED || key <40 || key > 126){
      return;
    }
    char [] kp ={key};
    String k = new String(kp);
  
    if (! keysdown.containsKey(k)){
      keysdown.put(k, framecount);
    }
  }
  //if running store current frame in keysPressed(k)
  // else if +/- adjust frame rate.
  
  // if escape
    // stop movie. Close files and exit.
}



void selectOutputFile(File selection){
 if (selection == null) {
  } else {
    outfile=selection;
    outfiledir=outfile;
    prefs.put("outfiledir", outfiledir.toString());
    status = 2;
  }
  
}
void selectInputFile(File selection){
 if (selection == null) {
  } else {
    infile=selection;
    infiledir=infile;
    prefs.put("infiledir", infiledir.toString());
    status = 1;
  }
  
}
void movieEvent(Movie m) {
    //println("time: "+myMovie.time()+" Duration: "+myMovie.duration());
  if( m.available()){
    m.read();
  framecount=framecount+1;
  } else {
    if( myMovie.time()==myMovie.duration()){
        doFinish();
    }
  }
    
}

void doFinish(){
  if (outfilestream !=null){
    Iterator it = keysdown.keySet().iterator();
    while (it.hasNext()) {
      String nextKey=(String) it.next();
       outfilestream.println(nextKey +"\t"+keysdown.get(nextKey)+"\t"+framecount);
      //delete key
      keysdown.remove(nextKey);
      eventcount+=1;
    }
    outfilestream.println();
    outfilestream.println("Total frames: "+framecount);
    outfilestream.println("Total events: "+eventcount);
    outfilestream.flush();
    outfilestream.close();
    myMovie = null;
    status = 0;
    eventcount=0;
    //exit();
  }
}


void setup (){
frame.pack();  // Get insets. Get more!
  insets = frame.getInsets();
 
  
  infiledir = new File(prefs.get("infiledir", defaultinfile));
  //selectInput("Select input movie file:", "selectInputFile", infiledir);
  
  
  outfiledir = new File(prefs.get("outfiledir",defaultoutfile));
  //selectOutput("Select output data file:", "selectOutputFile", outfiledir);
  
}

void draw (){
  
 if (status == 0){
   surface.setSize(tboxw, tboxh);
     
     setSize(tboxw, tboxh);
     fill(0,0,0);
     rect(0,0, tboxw,tboxh);
     fill(0,150,50);
     textSize(20);
     text("press a key to select a movie",50,30);
     text("or press X to quit",50,80);
 } else if (status == 1 ){
     surface.setSize(tboxw, tboxh);
     
     setSize(tboxw, tboxh);
     fill(0,0,0);
     rect(0,0, tboxw,tboxh);
     fill(100,100,250);
     textSize(16);
     text("Selected movie:   "+infile.toString(), 100,80);
     textSize(20);
     text("Press a key to select output file or X to cancel",100,120);
 } else if (status == 2) {
      surface.setSize(tboxw, tboxh);
     
     setSize(tboxw, tboxh);
     fill(0,0,0);
     rect(0,0, tboxw,tboxh);
     fill(255,50,128);
     textSize(16);
     text("Saving results to "+outfile.toString(), 100,60);
     textSize(20);
     text("Press a key to start or X to cancel",100,100);
     textSize(16);
     text("Once started, press any of the keys A-Z0-9 to record activity", 100,180);
 } else if (status==3){

  //tint(255, 20);
    
  if (lasttime==myMovie.time()){
    lastcount+=1;
  }else{
    lastcount=0;
    lasttime=myMovie.time();
  }
  if (lastcount==100){
    doFinish();
  }
  int textposx = 50;
  int textposy = 140;
  textSize(72);
  
  try{
    image(myMovie, insets.left,insets.top,width-(insets.left+insets.right), height-(insets.bottom+insets.top));
  } catch (Exception e){
    doFinish();
  }
   for (Map.Entry me : keysdown.entrySet()) {
        text((String)me.getKey(),textposx, textposy);
        textposx += 50;
    }
   movH=600;
   
    
    hRatio=(float)movH/(float)(displayHeight-100);
    movW=800;
    
    wRatio=(float)movW/(float)(displayWidth-100);
   // println("movie height "+movH+" movie width "+movW);
    if (hRatio>1 || wRatio>1){
      movRatio=max(hRatio,wRatio);
    }
    
    surface.setSize((int)((float)movW/movRatio)+insets.left+insets.right, (int)((float)movH/movRatio)+insets.top+insets.bottom);
    
    setSize((int)(movW/movRatio)-insets.right, (int)(movH/movRatio)-insets.bottom);
 } 
 
}
