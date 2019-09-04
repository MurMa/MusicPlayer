import processing.serial.*;

import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import ddf.minim.*;

import controlP5.*;

import java.util.Arrays;
import java.util.Collections;

ControlP5 cp5;

Minim minim;
AudioPlayer player;
AudioMetaData meta;

String[] resolutions = {"2560 x 1440", "1920 x 1080", "1600 x 1200", "1280 x 720", "1024 x 768"};


int halfwidth;
int halfheight;

int resx;
int resy;

//int ys = 80;
//int yi = 15;
//int y = ys;

String mypath = null;

String savefilespath = "/SongData/";

String[] Capsfilenames;
String[] filenames;
int filepos = 0;

int progress = 0;
int calcpos = 0;
boolean isCalculating = false;
boolean ignoreExistingData;

long menuSwitchMillis;

StringList SearchResults = new StringList();

byte spectra[];
float difx;
float Diagramscale = 1.0;
int diagramY;
int diagramX;
boolean CalcDia = true;
boolean RenderDia = true;
int mina = 80;
int maxa = 220;
color DiagramColor;
color MyDiagramColor = color(100, 180, 240);
color DiagramColorNight = color(200, 40, 40);



boolean FFTHighlights = true;

color FFTColor;
color FFTHighlight1;
color FFTHighlight2;
color MyFFTColor = color(255, 255, 255);
color MyFFTHighlight1 = color(105, 205, 5);
color MyFFTHighlight2 = color(0, 190, 240); 
color FFTColorNight = color(255, 150, 150);
color FFTHighlight1Night = color(220, 130, 40);
color FFTHighlight2Night = color(200, 50, 0);

FFT fft;
boolean goOnlyFFT = false;
boolean CalcFFT = true;
boolean RenderFFT = true;
int FFTX;
int FFTY;
int FFTbars = 65;
float FFTdifx;
int FFTvalues[] = new int[65];
int FFToldvalues[] = new int[65];


String altTitle;

boolean Playing = false;



boolean goIdle = false;
double idletimer;
int idletime = 60000;

boolean goEco = true;
int rtimer = 0;
int rrate = 40;

boolean animateBackground = false;
int BGAnimation = 1;
int numparticle = 5;
float[]partsize = new float[numparticle];
PVector[] apos = new PVector[numparticle];
PVector[] adir = new PVector[numparticle];

boolean drawWallpaper = false;
String PathWallpaper;
PImage Wallpaper;


float volume;
float gain;

int lowestGain = -50;
byte highestGain = 2;

int curTabIndex;


////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////#

int possteps = 1000;
int posvalue;
int posdivide = 100;

int playerlengthsec = 0;
int playerlengthmin = 0;


boolean InputAction = true;

color BGcolor;
color AnimBGcolor;

CColor myTheme;
boolean UseTheme = false;
color CForeground;
color CBackground;
color CLabel;
color CActive;

PFont Raleway;
PFont Iconfont;
ControlFont CtrRaleway;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

boolean resizeWindow = false;

//

void setup()
{
  //size(1280, 720, P2D);

  //size(displayWidth, displayHeight, P2D);

  fullScreen(P2D);
  frameRate(60);

  //surface.setResizable(true);

  halfwidth = width/2;
  halfheight = height/2;

  rectMode(CENTER);




  for (int i = 0; i<numparticle; i++) {
    apos[i] = new PVector(random(-550, 1000), random(-150, 100)+720);
    adir[i] = new PVector(10, random(-2, 2));
    adir[i].setMag(random(0.4, 0.8));
    partsize[i] = random(300, 600);
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////

  if (loadStrings("MyBackgroundColor.txt") == null) {
    BGcolor = color(0, 20, 50);
  } else {
    color col = unhex(loadStrings("MyBackgroundColor.txt")[0]);
    BGcolor = col;
  }
  background(BGcolor);

  AnimBGcolor = color(0, 80, 200, 100);

  if (loadStrings("MyTheme.txt") != null) {
    CForeground = unhex(loadStrings("MyTheme.txt")[0]);
    CBackground = unhex(loadStrings("MyTheme.txt")[1]);
    CActive = unhex(loadStrings("MyTheme.txt")[2]);
    CLabel = unhex(loadStrings("MyTheme.txt")[3]);
    //BGcolor = unhex(loadStrings("MyTheme.txt")[4]);
  } 


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  if (loadStrings("MyDirectory.txt") == null) {
    saveStrings("MyDirectory.txt", new String[]{"directory"});
  } else {
    String temp[] = loadStrings("MyDirectory.txt");
    if (temp.length > 0) {
      if (!temp[0].equals("directory")) {
        mypath = temp[0];
      }
    }
  }

  filenames = new String[]{};
  if (mypath != null) {
    println("Start to read files");
    readFilesInDirectory();
    filterfilenames();
  } else {
    mypath = "";
  }
  if (filenames.length == 0) {
    filenames = new String[]{"exampleSong.mp3"};
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  println("Start to initialize Player");

  minim = new Minim(this);
  volume = 50;
  gain = map(volume, 0, 100, lowestGain, highestGain);

  if (mypath != null) {
    player = minim.loadFile(mypath + filenames[0]);
  } 

  if (player != null) {
    player.pause();
    meta = player.getMetaData();

    player.shiftGain(player.getGain(), gain, 300);


    posvalue = 0;
    possteps = player.length()/posdivide;
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////


  //String[] fontList = PFont.list();
  //printArray(fontList);

  Iconfont = loadFont("musicplayer-50.vlw");

  Raleway = createFont("Raleway", 50);
  textFont(Raleway);
  textSize(12);

  CtrRaleway = new ControlFont(Raleway);

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5.setFont(CtrRaleway);
  //cp5.enableShortcuts();


  InitializeGUI();


  //consoleText.clear();

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  setupVisualizer();

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  if (RenderFFT) {
    fft = new FFT(player.bufferSize(), player.sampleRate());
  }

  diagramX = width/20;
  diagramY = height-200;

  FFTX = width/20;
  FFTY = halfheight-100;

  float FFTwidth = width-FFTX*2;
  FFTdifx = FFTwidth/FFTbars;

  /*
  if (TogNightMode.getState() == true) {
   FFTColor = FFTColorNight;
   DiagramColor = DiagramColorNight;
   FFTHighlight1 = FFTHighlight1Night;
   FFTHighlight2 = FFTHighlight2Night;
   } else {
   FFTColor = MyFFTColor;
   DiagramColor = MyDiagramColor;
   FFTHighlight1 = MyFFTHighlight1;
   FFTHighlight2 = MyFFTHighlight2;
   }*/

  //console.play();

  RandomSong();

  player.pause();
  BuPlayPause.setOff();
  Playing = false;

  println("Finished setup");
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




void draw()
{  
  autoloadSong();

  if (curTabIndex == 4) {
    drawVisualizer();
  } else {

    if (isCalculating) {
      calcAllDiagrams(calcpos);
      renderprogressbar(filenames[calcpos], calcpos + "/" + filenames.length);
      calcpos++;
      if (calcpos == filenames.length) {
        println("FINSISHED CALCULATION!");
        println("----------------------");
        isCalculating = false;
      }
      return;
    }


    if (InputAction) {
      background(BGcolor);
      if (drawWallpaper) {
        RenderWallpaper();
      }

      fill(255);


      updatePosition();

      rtimer++;
      if (rtimer >= 10) {
        rtimer = 0;
        updateTime();
        if (goIdle || goEco) {
          if (mouseIdle()) {
            InputAction = false;
            fill(255);
            text("IDLE", 70, height-30);
          }
        }
      }

      if (animateBackground) {
        animBG();
      }
      if (RenderDia && CalcDia) {
        renderSongDiagram();
      }
      if (RenderFFT && CalcFFT) {
        RenderFFT();
      }

      cp5.draw();


      //-----------------------------------------------------
    } else if (goEco) {

      if (goOnlyFFT) {
        if (drawWallpaper) {
          RenderWallpaper();
        } else {
          fill(BGcolor);
          noStroke();
          rectMode(CORNER);
          rect(20, 100, 1040, 270);
        }
        RenderFFT();
      } else {
        rtimer++;
      }
      if (rtimer >= rrate) {
        rtimer = 0;
        background(BGcolor);
        if (drawWallpaper) {
          RenderWallpaper();
        }
        fill(255);

        updateTime();
        updatePosition();

        if (RenderDia && CalcDia) {
          renderSongDiagram();
        }

        cp5.draw();
        fill(255);
        text("ECO", 70, height-30);
      }
    }
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void mouseWheel() {
  idletimer = millis();
  InputAction = true;
}

void mousePressed() {
  idletimer = millis();
  InputAction = true;
}

void mouseMoved() {
  idletimer = millis();
  InputAction = true;
}

void keyPressed() {
  idletimer = millis();
  InputAction = true;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void SaveThemeLoopBack() {
  String[] temp = new String[5];
  temp[0] = hex(CForeground);
  temp[1] = hex(CBackground);
  temp[2] = hex(CActive);
  temp[3] = hex(CLabel);
  temp[4] = hex(BGcolor);
  saveStrings("MyTheme.txt", temp);
  myTheme = new CColor(CForeground, CBackground, CActive, CLabel, CLabel);
  cp5.setColor(myTheme);
  CForeground = unhex(loadStrings("MyTheme.txt")[0]);
  CBackground = unhex(loadStrings("MyTheme.txt")[1]);
  CActive = unhex(loadStrings("MyTheme.txt")[2]);
  CLabel = unhex(loadStrings("MyTheme.txt")[3]);
  BGcolor = unhex(loadStrings("MyTheme.txt")[4]);
  ForegroundCP.setColorValue(CForeground);
  BackgroundCP.setColorValue(CBackground);
  ActiveCP.setColorValue(CActive);
  LabelCP.setColorValue(CLabel);
}



void WallpaperSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("Wallpaper selected: " + selection.getAbsolutePath());
    PathWallpaper = selection.getAbsolutePath();
    String[] temp = new String[1];
    temp[0] = PathWallpaper;
    Wallpaper = loadImage(PathWallpaper);
    saveStrings("MyWallpaperPath.txt", temp);
  }
}

void RenderWallpaper() {
  if (Wallpaper != null) {
    image(Wallpaper, 0, 0, width, height); //Image streched
    //image(Wallpaper, 0, 0);
  }
}


void animBG() {
  switch(BGAnimation) {
  case 1: 
    for (int i = 0; i<numparticle; i++) {
      if (apos[i].x > 1600 || apos[i].x < -600 || apos[i].y > 1200 || apos[i].y < -400) {
        apos[i] = new PVector(random(-550, -300), random(-150, 100)+720);
        adir[i] = new PVector(10, random(-2, 2));
        adir[i].setMag(random(0.4, 0.8));
        partsize[i] = random(300, 600);
      }
      apos[i] = apos[i].add(adir[i]);
      fill(AnimBGcolor);
      noStroke();
      ellipse(apos[i].x, apos[i].y, partsize[i], partsize[i]);
    }
    break;
  case 2:
    break;
  case 3: 
    break;
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



void renderprogressbar(String log, String prog) {
  rectMode(CORNER);
  textAlign(CORNER, TOP);
  stroke(255);
  strokeWeight(1);

  fill(0, 50, 100);
  rect(40, 650, 1000, 40);
  textSize(16);
  fill(255);
  text(log, 50, 660);
  text(prog, 960, 660);

  fill(0, 150, 250);
  rect(halfwidth-350, halfheight-75, 700, 150);
  stroke(0);
  fill(0, 50, 100);
  rect(halfwidth-340, halfheight-65, 680, 130);
  fill(200-map(progress, 0, 680, 0, 200), map(progress, 0, 680, 0, 200), 0);
  rect(halfwidth-340, halfheight-65, progress, 130);
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void updateFilenames(String[] names) {
  String[] clippedFilenames = new String[names.length];
  for (int i = 0; i<names.length; i++) {
    clippedFilenames[i] = names[i].substring(0, names[i].length()-4);
    if (clippedFilenames[i].endsWith("mp3") || clippedFilenames[i].endsWith("MP3")) {
      clippedFilenames[i] = clippedFilenames[i].substring(0, clippedFilenames[i].length()-4);
    }
  }
  ListSongs.addItems(clippedFilenames);
}

void listSearchResults() {
  ListSongs.addItems(SearchResults.array());
}

void updatePosition() {
  posvalue = player.position()/posdivide;
  SlPosition.setBroadcast(false);
  SlPosition.setValue(posvalue);
  SlPosition.setBroadcast(true);
}

void updateTime() {
  int seconds = int((player.position() / 1000) % 60 );
  int minutes = int((player.position() / 60000) % 60);
  TxtLSongTime.setText(minutes + ":" + String.format("%02d", seconds) + "/" + playerlengthmin + ":" + String.format("%02d", playerlengthsec));
}


void updateMetaInfo() {
  /*
  textSize(12);
   textAlign(LEFT);
   y = ys;
   fill(255);
   text("File Name: " + meta.fileName(), 5, y);
   text("Length (in milliseconds): " + meta.length(), 5, y+=yi);
   text("Title: " + meta.title(), 5, y+=yi);
   text("Author: " + meta.author(), 5, y+=yi); 
   text("Album: " + meta.album(), 5, y+=yi);
   text("Genre: " + meta.genre(), 5, y+=yi);
   */
  if (meta != null && meta.title().length() > 0) {
    //text(meta.title(), halfwidth, 370);
    TxtLSongTitle.setText(meta.title());
  } else if (filenames.length > filepos) {
    altTitle = filenames[filepos].substring(0, filenames[filepos].length()-4);
    //text(altTitle, halfwidth, 370);
    TxtLSongTitle.setText(altTitle);
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void nameLoadSong(String SongName) {

  player.close();
  //console.pause();
  player = minim.loadFile(mypath + SongName);
  //console.play();
  meta = player.getMetaData();
  println("Loaded new Song: " + SongName);
  println("has length: " + player.length());
  player.play();

  BuPlayPause.setOn();
  player.setGain(gain);
  Playing = true;
  updateMetaInfo();
  playerlengthsec = int((player.length() / 1000) % 60);
  playerlengthmin = int((player.length() / 60000) % 60);
  possteps = player.length()/posdivide;
  SlPosition.setRange(0, possteps);
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);

  for (int i = 0; i<filenames.length; i++) {
    if (filenames[i].equals(SongName)) {
      filepos = i;
      break;
    }
  }

  if (CalcDia) {
    loadSongDiagram(SongName);
  }
  if (RenderFFT) {
    fft = new FFT(player.bufferSize(), player.sampleRate());
  }
}


void loadSong(boolean n) {

  if (n) { //if load NEW song
    filepos++;
    if (filepos >= filenames.length) {
      filepos = 0;
    }
  } else { //if load OLD song
    filepos--;
    if (filepos < 0) {
      filepos = 0;
    }
  }

  player.close();
  //console.pause();
  player = minim.loadFile(mypath + filenames[filepos]);
  //console.play();
  meta = player.getMetaData();
  println("Loaded new Song: " + filenames[filepos]);
  println("has length: " + player.length());
  player.play();

  BuPlayPause.setOn();
  player.setGain(gain);
  Playing = true;
  updateMetaInfo();
  playerlengthsec = int((player.length() / 1000) % 60);
  playerlengthmin = int((player.length() / 60000) % 60);
  possteps = player.length()/posdivide; 
  SlPosition.setRange(0, possteps);
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);

  if (curTabIndex == 4) {
    visualizerAnalyseSong();
  }

  if (CalcDia) {
    loadSongDiagram(filenames[filepos]);
  }
  if (RenderFFT) {
    fft = new FFT(player.bufferSize(), player.sampleRate());
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

boolean mouseIdle() {
  return (millis()>idletimer+idletime);
}

void autoloadSong() {
  if (Playing && player.isPlaying() == false) {
    loadSong(true);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




class MyColorPicker extends ColorPicker {
  MyColorPicker(ControlP5 cp5, String theName) {
    super(cp5, cp5.getTab("default"), theName, 0, 0, 100, 10);
  }

  void setItemSize(int w, int h) {
    sliderRed.setSize(w, h);
    sliderGreen.setSize(w, h);
    sliderBlue.setSize(w, h);
    sliderAlpha.setSize(w, h);

    // you gotta move the sliders as well or they will overlap
    PVector SlG = new PVector();
    SlG.set(sliderGreen.getPosition());
    PVector SlB = new PVector();
    SlB.set(sliderBlue.getPosition());
    PVector SlA = new PVector();
    SlA.set(sliderAlpha.getPosition());
    sliderGreen.setPosition((SlG.add(new PVector(0, h-10))).array());
    sliderBlue.setPosition((SlB.add(new PVector(0, 2*(h-10)))).array());
    sliderAlpha.setPosition((SlA.add(new PVector(0, 3*(h-10)))).array());
  }
}


/*

 void drawWaveform() {
 stroke(255);
 
 for (int i = 0; i < player.bufferSize() - 1; i++)
 {
 float x1 = map( i, 0, player.bufferSize(), 0, width );
 float x2 = map( i+1, 0, player.bufferSize(), 0, width );
 line( x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50 );
 line( x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50 );
 }
 
 noStroke();
 fill( 255, 128 );
 
 // the value returned by the level method is the RMS (root-mean-square) 
 // value of the current buffer of audio.
 // see: http://en.wikipedia.org/wiki/Root_mean_square
 rect( 0, 50, player.left.level()*width, 100 );
 rect( 0, 150, player.right.level()*width, 100 );
 }
 */
