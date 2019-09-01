import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import ddf.minim.*; 
import controlP5.*; 
import java.util.Arrays; 
import java.util.Arrays; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ch.bildspur.postfx.builder.*; 
import ch.bildspur.postfx.pass.*; 
import ch.bildspur.postfx.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MusicPlayerV18 extends PApplet {















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
float Diagramscale = 1.0f;
int diagramY;
int diagramX;
boolean CalcDia = true;
boolean RenderDia = true;
int mina = 80;
int maxa = 220;
int DiagramColor;
int MyDiagramColor = color(100, 180, 240);
int DiagramColorNight = color(200, 40, 40);



boolean FFTHighlights = true;

int FFTColor;
int FFTHighlight1;
int FFTHighlight2;
int MyFFTColor = color(255, 255, 255);
int MyFFTHighlight1 = color(105, 205, 5);
int MyFFTHighlight2 = color(0, 190, 240); 
int FFTColorNight = color(255, 150, 150);
int FFTHighlight1Night = color(220, 130, 40);
int FFTHighlight2Night = color(200, 50, 0);

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

int BGcolor;
int AnimBGcolor;

CColor myTheme;
boolean UseTheme = false;
int CForeground;
int CBackground;
int CLabel;
int CActive;

PFont Raleway;
PFont Iconfont;
ControlFont CtrRaleway;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

boolean resizeWindow = false;

//

public void setup()
{
  //size(1280, 720, P2D);

  //size(displayWidth, displayHeight, P2D);

  
  frameRate(60);

  //surface.setResizable(true);

  halfwidth = width/2;
  halfheight = height/2;

  rectMode(CENTER);




  for (int i = 0; i<numparticle; i++) {
    apos[i] = new PVector(random(-550, 1000), random(-150, 100)+720);
    adir[i] = new PVector(10, random(-2, 2));
    adir[i].setMag(random(0.4f, 0.8f));
    partsize[i] = random(300, 600);
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////

  if (loadStrings("MyBackgroundColor.txt") == null) {
    BGcolor = color(0, 20, 50);
  } else {
    int col = unhex(loadStrings("MyBackgroundColor.txt")[0]);
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




public void draw()
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


public void mouseWheel() {
  idletimer = millis();
  InputAction = true;
}

public void mousePressed() {
  idletimer = millis();
  InputAction = true;
}

public void mouseMoved() {
  idletimer = millis();
  InputAction = true;
}

public void keyPressed() {
  idletimer = millis();
  InputAction = true;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public void SaveThemeLoopBack() {
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



public void WallpaperSelected(File selection) {
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

public void RenderWallpaper() {
  if (Wallpaper != null) {
    image(Wallpaper, 0, 0, width, height); //Image streched
    //image(Wallpaper, 0, 0);
  }
}


public void animBG() {
  switch(BGAnimation) {
  case 1: 
    for (int i = 0; i<numparticle; i++) {
      if (apos[i].x > 1600 || apos[i].x < -600 || apos[i].y > 1200 || apos[i].y < -400) {
        apos[i] = new PVector(random(-550, -300), random(-150, 100)+720);
        adir[i] = new PVector(10, random(-2, 2));
        adir[i].setMag(random(0.4f, 0.8f));
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



public void renderprogressbar(String log, String prog) {
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

public void listSearchResults() {
  ListSongs.addItems(SearchResults.array());
}

public void updatePosition() {
  posvalue = player.position()/posdivide;
  SlPosition.setBroadcast(false);
  SlPosition.setValue(posvalue);
  SlPosition.setBroadcast(true);
}

public void updateTime() {
  int seconds = PApplet.parseInt((player.position() / 1000) % 60 );
  int minutes = PApplet.parseInt((player.position() / 60000) % 60);
  TxtLSongTime.setText(minutes + ":" + String.format("%02d", seconds) + "/" + playerlengthmin + ":" + String.format("%02d", playerlengthsec));
}


public void updateMetaInfo() {
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

public void nameLoadSong(String SongName) {

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
  playerlengthsec = PApplet.parseInt((player.length() / 1000) % 60);
  playerlengthmin = PApplet.parseInt((player.length() / 60000) % 60);
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


public void loadSong(boolean n) {

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
  playerlengthsec = PApplet.parseInt((player.length() / 1000) % 60);
  playerlengthmin = PApplet.parseInt((player.length() / 60000) % 60);
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

public boolean mouseIdle() {
  return (millis()>idletimer+idletime);
}

public void autoloadSong() {
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

  public void setItemSize(int w, int h) {
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

int gridSizeX;
int gridSizeY;

float gridDx;
float gridDy;

float rectDim;

float BgSmooth;

BackgroundNode bgNodes[][];

public void setBackgroundConsts() {

  rectDim = 100;

  while (width % rectDim != 0) {
    rectDim--;
    while (height % rectDim != 0) {
      rectDim--;
    }
  }

  gridSizeX = floor(width/rectDim);
  gridSizeY = floor(height/rectDim);

  gridDx = rectDim;
  gridDy = rectDim;

  BgSmooth = 0.01f;

  bgNodes = new BackgroundNode[gridSizeX][gridSizeY];

  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j] = new BackgroundNode(gridDx*i, gridDy*j, rectDim);
    }
  }
}


public void drawBackground() {
  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j].run();
    }
  }
  fxVisCanvas.filter(blurHor);
  fxVisCanvas.filter(blurVert);
  fxVisCanvas.rectMode(CORNER);
}

public void setBackgroundColorsByIndex(int index) {
  backgroundVisCol = backgroundColors[index];
  fittingBackgroundVisCol = fittingBackgroundColors[index];
}

public void changeColorSchemeRdm() {
  if (random(1) < 0.05f) {
    changeColorScheme();
  }
}


public void changeColorScheme() {
  //backgroundVisCol = color(150*rdm1, 150*rdm2, 150*rdm3);
  int rdm = floor(random(0, backgroundColors.length));
  setBackgroundColorsByIndex(rdm);
  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j].setColorAndFadeTo(backgroundVisCol, 0.02f);
    }
  }
}

class BackgroundNode {

  float posX;
  float posY;
  float dim;

  float alpha;

  float flashFac;
  float oldFlashFac;

  float fadePos;
  float fadeSpeed;

  int curCol;
  int lastCol;
  int nextCol;

  BackgroundNode(float posXTmp, float posYTmp, float dimTmp) {
    posX = posXTmp;
    posY = posYTmp;
    dim = dimTmp;
    alpha = 0;
    flashFac = 0;
    oldFlashFac = flashFac;

    fadePos = 10;
    fadeSpeed = 0.05f;
    curCol = color(0, 0, 255);
    nextCol = curCol;
  }

  public void run() {
    update();
    display();
  }

  public void update() {
    flashFac = 0;
    flashFac += constrain(heightToFTTVal(posY), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac += constrain(heightToFTTVal(posY+dim/2), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac += constrain(heightToFTTVal(posY+dim), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac =  constrain(flashFac*0.5f, 40, 255);

    float change = flashFac-oldFlashFac;
    flashFac = PApplet.parseInt(flashFac+change*BgSmooth);
    oldFlashFac = flashFac;

    updateColor();

    //alpha = noise(posX*0.0008, posY*0.0002, t*0.1)*255.0;

    alpha = 100;

    //alpha = 255*(posX/width);

    //alpha = constrain(alpha,20,255);
  }

  public void updateColor() {
    if (fadePos<1-fadeSpeed) {
      fadePos += fadeSpeed;
      curCol = lerpColor(lastCol, nextCol, fadePos);
    } else if (fadePos != 10) {
      fadePos = 10;
      curCol = nextCol;
    }
  }

  public void display() {
    float r = (curCol >> 16) & 0xFF;  
    float g = (curCol >> 8) & 0xFF;   
    float b = curCol & 0xFF;
    float curBright = (flashFac/255)*(alpha/255);
    r *= curBright;
    g *= curBright;
    b *= curBright;
    fxVisCanvas.fill(r, g, b, 170);
    fxVisCanvas.noStroke();

    //rectMode(CORNER);
    //rect(posX, posY, dim, dim);

    fxVisCanvas.ellipseMode(CORNER);
    fxVisCanvas.ellipse(posX, posY, dim, dim);
  }

  public void setColorAndFadeTo(int next, float speed) {
    lastCol = curCol;
    nextCol = next;
    fadeSpeed = speed;
    fadePos = 0;
  }

  public void setAlpha(float in) {
    alpha = in;
  }
}


public void calcAllDiagrams(int pos) {
  println("Analysing file " + pos);

  if (loadBytes(savefilespath + filenames[pos] + ".dat") == null || ignoreExistingData) {
    calcSongDiagram(filenames[pos]);
    saveBytes(savefilespath + filenames[pos] + ".dat", spectra);
  } else {
    println("File already exists!");
  }

  progress = PApplet.parseInt(map(pos, 0, filenames.length, 0, 680));
}




public void loadSongDiagram(String myfile) {

  println("Loading Diagram for " + myfile);

  if (loadBytes(savefilespath + myfile + ".dat") == null) {
    calcSongDiagram(myfile);
  } else {
    spectra = loadBytes(savefilespath + myfile + ".dat"); 
    //printArray(spectra);
    float diagramwidth = width-width/10;
    difx = diagramwidth/spectra.length;
    //println("Difx: " + difx);
    Diagramscale = 1.5f;
    for (int i = 0; i<spectra.length; i++) {
      while (spectra[i]*Diagramscale>80) {
        Diagramscale = Diagramscale-0.1f;
      }
    }
  }
}






public void calcSongDiagram(String myfile) {
  println("-----------------------------------------------");
  println("Calculating Song Diagram");
  int oldmillis = millis();

  int chunkStartIndex;
  int chunkSize;


  AudioPlayer tempplayer = minim.loadFile(mypath + myfile);
  println("Tempplayer loaded after " + (millis()-oldmillis) + " ms");
  if (tempplayer.length()>2000000 || tempplayer.length() < 0) {
    println("FILE TOO BIG OR ZERO, CLOSING!");
    println("-----------------------------------------------");
    spectra = new byte[0];
    tempplayer.close();
    return;
  }
  tempplayer.close();


  int s = 1; //stretching samples

  println("Attempting to load " + myfile);
  AudioSample jingle = minim.loadSample(mypath + myfile);
  println("File loaded after " + (millis()-oldmillis) + " ms");
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  println("filelength: " + leftChannel.length);

  int fftSize = 1024;

  int totalChunks = (leftChannel.length / (fftSize*s)) + 1;
  println("Chunks: " + totalChunks);

  while (totalChunks>190) {
    fftSize = fftSize*2;
    totalChunks = (leftChannel.length / (fftSize*s)) + 1;
    println("NEWChunks: " + totalChunks);
    println("NEWFFTSize: " + fftSize);
  }

  float[] fftSamples = new float[fftSize];// then we create an array we'll copy sample data into for the FFT object
  FFT fft = new FFT( fftSize, jingle.sampleRate() );

  spectra = new byte[totalChunks];

  println("Starting analysis after " + (millis()-oldmillis) + " ms");
  for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx) {

    chunkStartIndex = chunkIdx * fftSize * s;

    chunkSize = min( leftChannel.length - chunkStartIndex, fftSize );    // the chunk size will always be fftSize, except for the last chunk, which will be however many samples are left in source

    System.arraycopy( leftChannel, chunkStartIndex, fftSamples, 0, chunkSize );// copy first chunk into our analysis array

    if ( chunkSize < fftSize ) {
      java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0f ); // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes
    }

    fft.forward( fftSamples );

    spectra[chunkIdx] = PApplet.parseByte(fft.calcAvg(0, jingle.bufferSize())/5);

    //println("float[" + chunkIdx + "]: " + (fft.calcAvg(0, jingle.bufferSize())/4.5)  );
    //println("byte[" + chunkIdx + "]: " + spectra[chunkIdx]);
  }
  //printArray(spectra);
  jingle.close();
  float diagramwidth = width-width/10;
  difx = diagramwidth/spectra.length;
  println("Finished after " + (millis()-oldmillis) + " ms");
  println("spectralength: " + spectra.length);
  println("DifX: " + difx);
  println("Writing File: " + myfile + ".dat");

  saveBytes(savefilespath + myfile + ".dat", spectra);

  println("-----------------------------------------------");
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


public void renderSongDiagram() {
  rectMode(CORNER);

  strokeWeight(1);
  float a;
  float dist;
  float curpos = map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length);
  for (int i = 0; i<spectra.length; i++) {

    dist = curpos-i+0.5f;
    a = constrain(dist*210, mina, maxa);
    //float dist = dist(i , 500 , map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length) , 500);
    //float a = 255 - constrain( dist*20 , 0 , 255) + mina;

    fill(DiagramColor, a); 
    stroke(0);
    rect(PApplet.parseInt(i*difx+diagramX), diagramY, 5, -spectra[i]*Diagramscale);
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




public void RenderFFT() {
  rectMode(CENTER);
  FFToldvalues = Arrays.copyOf(FFTvalues, FFTvalues.length);
  fft.forward(player.mix);

  strokeWeight(1);
  int c;

  for (int i = 0; i<FFTbars; i++) {
    c = color(FFTColor);
    if (FFTHighlights) {
      if (fft.getBand(i)-180 > 0) {
        c = FFTHighlight1;
      } else if (i>6 && fft.getBand(i) > fft.getBand(i+1) && fft.getBand(i) > fft.getBand(i-1) && fft.getBand(i) > 60) {
        c = FFTHighlight2;
      }
    }

    stroke(0);
    fill(c, 100+constrain((fft.getBand(i)-5)*1.2f, 0, 155));

    float change = fft.getBand(i)-FFToldvalues[i];
    FFTvalues[i] = PApplet.parseInt(FFTvalues[i]+change*0.25f);

    //line(int(i*FFTdifx+20), 720, int(i*FFTdifx+20), -fft.getBand(i)+720);
    rect(PApplet.parseInt(i*FFTdifx+FFTX), FFTY, 14, constrain(FFTvalues[i]*1.5f, 0, 250));
  }
}


/*
color c;
 
 for (int i = 0; i<FFTbars; i++) {
 float cfade = constrain(fft.getBand(i)-180, 0, 50);
 c = color(255, 255, 255, 100+constrain((fft.getBand(i)-5)*1.2, 0, 155));
 if (advanced) {
 if (cfade > 0) {
 c = color(255-cfade*3, 255-cfade, 255-cfade*5, 100+constrain((fft.getBand(i)-5)*1.2, 0, 155));
 } else {
 if (i>6 && fft.getBand(i) > fft.getBand(i+1) && fft.getBand(i) > fft.getBand(i-1) && fft.getBand(i) > 60) {
 c = color(0, 190, 240, 150+constrain((fft.getBand(i)-5)*1.5, 0, 105));
 }
 }
 }
 stroke(0);
 fill(c);
 */

public void drawPerlinLine(float time, float phaseDif, int innerRad, int outerRad, int col, float jitter, int offset) {
  float p1 = map(noise(lineTime*10+offset), 0.2f, 0.7f, -1, 1);
  fxVisCanvas.strokeWeight(1);
  drawLine(time, phaseDif+p1*jitter, innerRad, outerRad, col);
}

public void changePhaseDif() {
  int rand1 = round(random(0, 1));
  float randomPhase = 0;
  if (rand1 == 0 && linePhaseDif != 0) {
    randomPhase = 0;
  } else {
    randomPhase = linePhaseDif+random(-1, 1);
    randomPhase = constrain(randomPhase, -HALF_PI, HALF_PI);
  }

  lastPhaseDif = linePhaseDif;
  targetPhaseDif = randomPhase;
  linePhaseFadePos = 0;
}

public void fadePhaseDif() {
  float bonusSpeed = lastSecVol*0.000000004f;
  float fadeSpeed = 0.0010f+bonusSpeed;
  if (linePhaseFadePos > 1 && linePhaseFadePos != 10) {
    linePhaseFadePos = 10;
    linePhaseDif = targetPhaseDif;
  } else if (linePhaseFadePos<1-fadeSpeed) {
    linePhaseFadePos += fadeSpeed;
    linePhaseDif = lerp(lastPhaseDif, targetPhaseDif, linePhaseFadePos);
  }
}

public void fadeLineSpeed() {
  float bonusSpeed = lastSecVol*0.000000001f;
  float fadeSpeed = 0.0000005f+bonusSpeed;
  if (abs(lineSpeed - targetLineSpeed) < fadeSpeed) {
    lineSpeed = targetLineSpeed;
    return;
  }
  if (lineSpeed > targetLineSpeed) {
    lineSpeed -= fadeSpeed;
  } else if (lineSpeed < targetLineSpeed) {
    lineSpeed += fadeSpeed;
  }
}

//Single Laser line
public void drawLine(float time, float phaseDif, int innerRad, int outerRad, int col) {
  float x1 = cos(time)*innerRad;
  float y1 = sin(time)*innerRad;
  float x2 = cos(time-phaseDif)*outerRad;
  float y2 = sin(time-phaseDif)*outerRad;
  fxVisCanvas.stroke(col);
  fxVisCanvas.line(width/2+x2, height/2+y2, width/2+x1, height/2+y1);
}

//Bunch of laser lines
public void drawLines() {
  fadePhaseDif();
  fadeLineSpeed();

  float bonusSpeed = lastSecVol*0.00000002f;
  targetLineSpeed = 0.001f+bonusSpeed;
  lineTime += lineSpeed;
  int innerRad = 80;
  int outerRad = height+200;

  float bonusFac = lastSecVol*0.000002f;
  //println(bonusFac);
  float stren = FFTvaluesVis[1];
  float flashFac = constrain((stren/100)+bonusFac, 0.25f, 2);
  float r1 = 20+flashFac*30;
  float g1 = 80+flashFac*20;
  float b1 = 200+flashFac*25;
  float r2 = 20+flashFac*60;
  float g2 = 80+flashFac*40;
  float b2 = 200+flashFac*25;
  float a1 = constrain(flashFac*130, 0, 255);
  float a2 = a1*a1*0.0035f;

  int col = color(r1, g1, b1, a1);
  int col2 = color(r2, g2, b2, a2);

  float jitter = flashFac*0.01f;
  float p1 = map(noise(lineTime*30), 0.2f, 0.7f, -1, 1);
  float p2 =  map(noise(lineTime*30+5), 0.2f, 0.7f, -1, 1);
  //println(p1);
  int lineCount = 10;

  fxVisCanvas.strokeWeight(3);
  drawLine(lineTime, linePhaseDif, innerRad, outerRad, col);
  for (int i = 0; i< lineCount; i++) {
    drawPerlinLine(lineTime, linePhaseDif, innerRad, outerRad, col2, jitter, i);
  }
  fxVisCanvas.strokeWeight(3);
  drawLine(lineTime+HALF_PI, linePhaseDif, innerRad, outerRad, col);
  for (int i = 0; i< lineCount; i++) {
    drawPerlinLine(lineTime+HALF_PI, linePhaseDif, innerRad, outerRad, col2, jitter, i);
  }
  fxVisCanvas.strokeWeight(3);
  drawLine(lineTime+PI, linePhaseDif, innerRad, outerRad, col);
  for (int i = 0; i< lineCount; i++) {
    drawPerlinLine(lineTime+PI, linePhaseDif, innerRad, outerRad, col2, jitter, i);
  }
  fxVisCanvas.strokeWeight(3);
  drawLine(lineTime-HALF_PI, linePhaseDif, innerRad, outerRad, col);
  for (int i = 0; i< lineCount; i++) {
    drawPerlinLine(lineTime-HALF_PI, linePhaseDif, innerRad, outerRad, col2, jitter, i);
  }

  //So that the laser beams fade out
  drawEllipseFade(new PVector(width/2, height/2), 1600, 40, 40.0f);
}

public void drawEllipseFade(PVector o, float size, int steps, float endalpha) {
  fxVisCanvas.ellipseMode(CENTER);
  PVector origin = o.copy();
  fxVisCanvas.noStroke();
  float difSize = size / steps;
  float difAlpha = endalpha / steps;
  for (int i = 0; i<steps; i++) {
    fxVisCanvas.fill(0, endalpha-(difAlpha*i));
    fxVisCanvas.ellipse(origin.x, origin.y, i*difSize, i*difSize);
  }
}

public void drawLight(PVector o, int amount) {
  fxVisCanvas.ellipseMode(CENTER);
  PVector origin = o.copy();
  amount = PApplet.parseInt(constrain(amount*1.4f, 0, 60));
  fxVisCanvas.fill(50+amount*amount/18, 200-amount*amount/18, amount+50, 120-constrain(amount*2, 0, 119));
  fxVisCanvas.noStroke();
  for (int i = 0; i< amount; i++) {
    fxVisCanvas.ellipse(origin.x, origin.y, i*i/6, i*i/65);
    fxVisCanvas.ellipse(origin.x, origin.y, i*i/5, i/9);
  }
}

public void drawLightning(PVector o, int amount) {
  if (amount > 0) {
    int bolts = amount;
    PVector lDim = new PVector(500, 30);
    PVector origin = o.copy();
    PVector P1 = origin.copy().add(new PVector(0, random(-lDim.y/2, lDim.y/2)));
    float bS = 25; //Brightness scale
    int maxA = 200;

    float difA = 0;
    if (bolts > 0) {
      difA = 250/bolts;
    }
    fxVisCanvas.rectMode(CENTER);

    PVector P2 = new PVector(random(0, 20), random(-5, 5));
    fxVisCanvas.pushMatrix();
    fxVisCanvas.translate(P1.x, P1.y);
    for (int i = 0; i< bolts; i++) {
      fxVisCanvas.stroke(bolts*bS, bolts*bS, bolts*bS, constrain(maxA-i*i/10*difA, 0, 255));
      fxVisCanvas.line(0, 0, P2.x, P2.y);
      //ellipse(0,0,2,2);

      fxVisCanvas.translate(P2.x, P2.y);
      P2 = new PVector(random(0, 20), random(-5, 5));
    }
    fxVisCanvas.popMatrix();

    P2 = new PVector(random(-20, 0), random(-5, 5));
    fxVisCanvas.pushMatrix();
    fxVisCanvas.translate(P1.x, P1.y);
    for (int i = 0; i< bolts; i++) {
      fxVisCanvas.stroke(bolts*bS, bolts*bS, bolts*bS, constrain(maxA-i*i/10*difA, 0, 255));
      fxVisCanvas.line(0, 0, P2.x, P2.y);
      //ellipse(0,0,2,2);

      fxVisCanvas.translate(P2.x, P2.y);
      P2 = new PVector(random(-20, 0), random(-5, 5));
    }
    fxVisCanvas.popMatrix();
  }
}

public void RenderLights() {
  for (int i = 0; i<FFTbarsVis; i++) {
    int amount = constrain(PApplet.parseInt(FFTvaluesVis[i]/2)-10, 0, 400);
    if (amount > 0) {
      PVector pos = new PVector(width-FFTXVis, height-FFTYVis-i*FFTdify);
      drawLight(pos, amount);
    }
  }
}

public void RenderLightning() {
  for (int i = 0; i<FFTbarsVis; i++) {
    drawLightning(new PVector(FFTXVis, height-FFTYVis-i*FFTdify), constrain(PApplet.parseInt(FFTvaluesVis[i]/2)-20, 0, 100));
  }
}




public void controlEvent(ControlEvent theControlEvent) {
  if (curTabIndex != 4 || (curTabIndex == 4 && B6 != null && B6.MouseOverButton())) {
    if (theControlEvent != null && theControlEvent.isTab()) {
      curTabIndex = theControlEvent.getTab().getId();
      switch(curTabIndex) {
      case 1: //SongList
        RenderDia = false;
        RenderFFT = false;
        BuQuit.moveTo(TabSonglist);
        menuSwitchMillis = millis();
        break;
      case 2: //Player
        RenderDia = true;
        if (CalcFFT) {
          RenderFFT = true;
        }
        BuQuit.moveTo(TabPlayer);
        menuSwitchMillis = millis();
        break;
      case 3: //Settings
        RenderDia = false;
        RenderFFT = false;
        BuQuit.moveTo(TabSettings);
        menuSwitchMillis = millis();
        break;
      case 4: //Visualizer        
        visualizerAnalyseSong();
        //visualizerCheckLiveMode();
        RenderDia = false;
        RenderFFT = false;
        menuSwitchMillis = millis();
        break;
      }
    }
    if (theControlEvent != null && theControlEvent.isFrom(CheckSettings2)) {
      float[]a = CheckSettings2.getArrayValue();
      if (a[0] == 1) {
        goIdle= true;
      } else {
        goIdle= false;
      }
      if (a[1] == 1) {
        goEco= true;
      } else {
        goEco= false;
      }
      println("Eco: " + goEco);
      println("Idle: " + goIdle);
      println("---");
    }
    if (theControlEvent != null && theControlEvent.isFrom(MyBGColorPicker)) {
      int col = MyBGColorPicker.getRGB();
      BGcolor = col;
      String[] temp = new String[1];
      temp[0] = hex(col);
      saveStrings("MyBackgroundColor.txt", temp);
    }

    if (GroupTheme.isVisible()) {
      if (theControlEvent != null && theControlEvent.isFrom(BackgroundCP) && theControlEvent.arrayValue().length == 4) {
        int r = PApplet.parseInt(theControlEvent.getArrayValue(0));
        int g = PApplet.parseInt(theControlEvent.getArrayValue(1));
        int b = PApplet.parseInt(theControlEvent.getArrayValue(2));
        int a = PApplet.parseInt(theControlEvent.getArrayValue(3));
        int col = color(r, g, b, a);
        CBackground = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorBackground(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(ForegroundCP) && theControlEvent.arrayValue().length == 4) {
        int r = PApplet.parseInt(theControlEvent.getArrayValue(0));
        int g = PApplet.parseInt(theControlEvent.getArrayValue(1));
        int b = PApplet.parseInt(theControlEvent.getArrayValue(2));
        int a = PApplet.parseInt(theControlEvent.getArrayValue(3));
        int col = color(r, g, b, a);
        CForeground = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorForeground(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(ActiveCP) && theControlEvent.arrayValue().length == 4) {
        int r = PApplet.parseInt(theControlEvent.getArrayValue(0));
        int g = PApplet.parseInt(theControlEvent.getArrayValue(1));
        int b = PApplet.parseInt(theControlEvent.getArrayValue(2));
        int a = PApplet.parseInt(theControlEvent.getArrayValue(3));
        int col = color(r, g, b, a);
        CActive = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorActive(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(LabelCP) && theControlEvent.arrayValue().length == 4) {
        int r = PApplet.parseInt(theControlEvent.getArrayValue(0));
        int g = PApplet.parseInt(theControlEvent.getArrayValue(1));
        int b = PApplet.parseInt(theControlEvent.getArrayValue(2));
        int a = PApplet.parseInt(theControlEvent.getArrayValue(3));
        int col = color(r, g, b, a);
        CLabel = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorLabel(col);
        }
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void Yes() {
  YNWindow.setVisible(false);
  if (TxtLQuestion.getStringValue() == "The Files in your directory have changed. Do you want to calculate the Diagrams now?") {
    savefilestatus();
    isCalculating = true;
    calcpos = 0;
    progress = 0;
    renderprogressbar(filenames[calcpos], calcpos + "/" + filenames.length);
    ListSongs.open();
  }
}

public void No() {
  YNWindow.setVisible(false);
  if (TxtLQuestion.getStringValue() == "The Files in your directory have changed. Do you want to calculate the Diagrams now?") {
    savefilestatus();
    ListSongs.open();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void RandomSong() {
  filepos = PApplet.parseInt(random(0, filenames.length));
  if (filenames.length > filepos) {
    nameLoadSong(filenames[filepos]);
  }
}


public void PlayPause(boolean value) {
  if (value) {
    Playing = true;
    player.play();
  } else {
    player.pause();
    Playing = false;
  }
}

public void NextSong() {
  loadSong(true);
}

public void LastSong() {
  loadSong(false);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void ChSettings(float[]a ) {
  if (a[0] == 1) {
    CalcDia= true;
    if (filenames.length > filepos) {
      loadSongDiagram(filenames[filepos]);
    }
  } else {
    CalcDia= false;
    spectra = new byte[0];
  }
  if (a[1] == 1) {
    CalcFFT = true;
  } else {
    CalcFFT = false;
  }
  if (a[2] == 1) {
    goOnlyFFT = true;
  } else {
    goOnlyFFT = false;
  }
}

public void ChVisSettings(float[]a ) {
  if (a[0] == 1) {
    liveModeVis= true;
    visualizerCheckLiveMode();
  } else {
    liveModeVis= false;
    visualizerCheckLiveMode();
  }
}



public void SaveSettings() {
  cp5.saveProperties("SavedSettings", "default");
}

public void DefaultSettings() {
  cp5.loadProperties(("DefaultSettings"));
  cp5.saveProperties("SavedSettings", "default");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void Idletime(float t) {
  idletime = PApplet.parseInt(t*1000);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void Search(String searchtext) {
  if (searchtext.length() > 0) {
    searchtext = searchtext.toUpperCase();
    println("SearchText: " + searchtext);
    ListSongs.setCaptionLabel("Results: ");
    SearchResults.clear();
    ListSongs.clear();
    for (int i = 0; i<filenames.length; i++) {
      if (Capsfilenames[i].indexOf(searchtext) > -1) {
        SearchResults.append(filenames[i]);
      }
    }
    listSearchResults();
    printArray("Search Results: " + SearchResults);
  } else {
    SearchResults.clear();
    ListSongs.clear();
    ListSongs.addItems(filenames);
    ListSongs.setCaptionLabel("Your Songs: ");
  }
}

public void ClearSearch() {
  TxtFSearch.clear();
  SearchResults.clear();
  ListSongs.clear();
  ListSongs.addItems(filenames);
  ListSongs.setCaptionLabel("Your Songs: ");
}

public void SongList(int Res) {
  if (SearchResults.size() > 0) {
    nameLoadSong(SearchResults.get(Res));
  } else {
    nameLoadSong(filenames[Res]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void Quit() {
  println("QUITTING!");
  player.close();
  minim.stop();
  super.stop();
  exit();
}



public void ChangeDirectory() {
  selectFolder("Select a folder to process:", "folderSelected");
}



public void Volume(float vol) {
  volume = vol;
  println("new Volume: " + volume);
  gain = PApplet.parseInt(map(volume, 0, 100, lowestGain, highestGain));
  player.shiftGain(player.getGain(), gain, 300);
}



public void Position(int pos) {
  if (cp5.getController("Position").isMousePressed()) {
    if (cp5.getController("Position").isMouseOver()) {
      println("new Position: " + pos);
      int newposition = pos*posdivide;
      player.cue(newposition);
    }
  }
}

public void CalcAllDia() {
  isCalculating = true;
  calcpos = 0;
  progress = 0;
  renderprogressbar(filenames[calcpos], calcpos + "/" + filenames.length);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void Resolution(int Res) {

  if (resizeWindow) {

    String NewRes = resolutions[Res];
    String[] parts = NewRes.split("x");
    parts[0] = parts[0].substring(0, parts[0].length()-1);
    parts[1] = parts[1].substring(1, parts[1].length());
    resx = Integer.parseInt(parts[0]);
    resy = Integer.parseInt(parts[1]);
    println("New Resolution: " + resx + " x " + resy);
    if (resx != width && resy != height) {
      surface.setSize(resx, resy);
    }
    halfwidth = width/2;
    halfheight = height/2;

    cp5.getWindow().setPositionOfTabs(halfwidth-225, 20);

    BuPlayPause.setPosition(halfwidth-70, height-120);
    BuNextSong.setPosition(halfwidth-50+150, height-110);
    BuLastSong.setPosition(halfwidth-50-150, height-110);

    BuQuit.setPosition(width-100, 20);

    TxtLSongTitle.setPosition(halfwidth-100, height-320);
    CheckSettings.setPosition(halfwidth-300, 130);
    CheckSettings2.setPosition(halfwidth-110, height-150);

    TxtFSearch.setPosition(width-360, 80);
    ListSongs.setSize(width-100, height-160);
    BuClearSearch.setPosition(width-90, 85);

    GroupBG.setPosition(halfwidth-350, halfheight-250-10);
    GroupTheme.setPosition(halfwidth-350, halfheight-250-10);

    BackgroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40);
    ForegroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40+160);
    ActiveCP.setPosition(halfwidth-350+350, halfheight-250-10+40);
    LabelCP.setPosition(halfwidth-350+350, halfheight-250-10+40+160);

    MyBGColorPicker.setPosition(halfwidth-350+40, halfheight-250-10+40);

    SlIdleTime.setPosition(halfwidth-225, height-80);
    SlVolume.setPosition(width-130, 100);
    SlPosition.setPosition(width/20, height-200);
    SlPosition.setSize(width-width/10, 40); 
    SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
    TxtLSongTime.setPosition(width-220, height-140);  

    BuCalcAllDia.setPosition(halfwidth+50, 130);



    float diagramwidth = width-width/10;
    difx = diagramwidth/spectra.length;
    diagramX = width/20;
    diagramY = height-200;
    FFTX = width/20;
    FFTY = halfheight-100;
    float FFTwidth = width-FFTX*2;
    FFTdifx = FFTwidth/FFTbars;

    //println("Difx: " + difx);
  }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void BGWindow() {
  GroupBG.setVisible(true);
  MyBGColorPicker.setVisible(true);
  CheckSettings.setVisible(false);
  CheckSettings2.setVisible(false);
  BuCalcAllDia.setVisible(false);
}

public void HideBGWindow() {
  GroupBG.setVisible(false);
  MyBGColorPicker.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
}

public void UseWallpaper(boolean state) {
  if (state) {
    PathWallpaper = loadStrings("MyWallpaperPath.txt")[0];
    Wallpaper = loadImage(PathWallpaper);
    drawWallpaper = true;
  } else {
    drawWallpaper = false;
  }
}

public void BGWallpaper() {
  selectInput("Select your wallpaper:", "WallpaperSelected");
}

public void AnimBGList(int Res) {
  if (Res == 0) {
    animateBackground = false;
  } 
  if (Res == 1) {
    BGAnimation = 1;
    animateBackground = true;
  }
  if (Res == 2) {
    BGAnimation = 2;
    animateBackground = true;
  }
  if (Res == 3) {
    BGAnimation = 3;
    animateBackground = true;
  }
}


public void NMode(boolean state) {
  if (state) {
    CForeground = unhex(loadStrings("ThemeRed.txt")[0]);
    CBackground = unhex(loadStrings("ThemeRed.txt")[1]);
    CActive = unhex(loadStrings("ThemeRed.txt")[2]);
    CLabel = unhex(loadStrings("ThemeRed.txt")[3]);
    myTheme = new CColor(CForeground, CBackground, CActive, CLabel, CLabel);
    cp5.setColor(myTheme);
    tint(250, 50, 50);
    DiagramColor = DiagramColorNight;
    FFTColor = FFTColorNight;
    FFTHighlight1 = FFTHighlight1Night;
    FFTHighlight2 = FFTHighlight2Night;
  } else {
    ForegroundCP.setColorValue(CForeground);
    BackgroundCP.setColorValue(CBackground);
    ActiveCP.setColorValue(CActive);
    LabelCP.setColorValue(CLabel);
    if (UseTheme) {
      CForeground = unhex(loadStrings("MyTheme.txt")[0]);
      CBackground = unhex(loadStrings("MyTheme.txt")[1]);
      CActive = unhex(loadStrings("MyTheme.txt")[2]);
      CLabel = unhex(loadStrings("MyTheme.txt")[3]);
      SaveThemeLoopBack();
    } else {
      cp5.setColor(ControlP5.THEME_CP52014);
    }
    noTint();
    DiagramColor = MyDiagramColor;
    FFTColor = MyFFTColor;
    FFTHighlight1 = MyFFTHighlight1;
    FFTHighlight2 = MyFFTHighlight2;
    setConsoleStyle();
  }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////

public void ThemeWindow() {
  GroupTheme.setVisible(true);
  BackgroundCP.setVisible(true);
  ForegroundCP.setVisible(true);
  ActiveCP.setVisible(true);
  LabelCP.setVisible(true);
  CheckSettings.setVisible(false);
  CheckSettings2.setVisible(false);
  BuCalcAllDia.setVisible(false);
}

public void HideThemeWindow() {
  GroupTheme.setVisible(false);
  BackgroundCP.setVisible(false);
  ForegroundCP.setVisible(false);
  ActiveCP.setVisible(false);
  LabelCP.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
  if (UseTheme) {
    SaveThemeLoopBack();
  }
}

public void ExitThemeWindow() {
  CForeground = unhex(loadStrings("MyTheme.txt")[0]);
  CBackground = unhex(loadStrings("MyTheme.txt")[1]);
  CActive = unhex(loadStrings("MyTheme.txt")[2]);
  CLabel = unhex(loadStrings("MyTheme.txt")[3]);
  ForegroundCP.setColorValue(CForeground);
  BackgroundCP.setColorValue(CBackground);
  ActiveCP.setColorValue(CActive);
  LabelCP.setColorValue(CLabel);
  GroupTheme.setVisible(false);
  BackgroundCP.setVisible(false);
  ForegroundCP.setVisible(false);
  ActiveCP.setVisible(false);
  LabelCP.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
}

public void UseTheme(boolean state) {
  if (state) {
    UseTheme = true;
    SaveThemeLoopBack();
  } else {
    UseTheme = false;
    String[] temp = new String[5];
    temp[0] = hex(CForeground);
    temp[1] = hex(CBackground);
    temp[2] = hex(CActive);
    temp[3] = hex(CLabel);
    temp[4] = hex(BGcolor);
    saveStrings("MyTheme.txt", temp);
    cp5.setColor(ControlP5.THEME_CP52014);
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
}



public void toggleconsole(boolean state) {
  /*
  if (state) {
   consoleText.show();
   consoleText.bringToFront();
   } else {
   consoleText.hide();
   }
   */
}



public void checkfilestatus() {
  if (loadStrings("Songlist.txt") == null) {
    savefilestatus();
    return;
  }
  if (Arrays.equals(loadStrings("Songlist.txt"), filenames)==false) {
    println("NEW FILES DETECTED!");
    TabPlayer.setActive(false);
    TabSonglist.setActive(true);
    RenderDia = false;
    RenderFFT = false;
    YNWindow.moveTo(TabSonglist);
    TxtLQuestion.setText("The Files in your directory have changed. Do you want to calculate the Diagrams now?");
    YNWindow.setVisible(true);
    YNWindow.bringToFront();
    ListSongs.close();
  }
}

public void savefilestatus() {
  saveStrings("Songlist.txt", filenames);
}




public void readFilesInDirectory() {
  println("Files found in path: ");
  filenames = listFileNames(mypath);
  printArray(filenames);
}



public void filterfilenames() {
  if (filenames != null) {
    StringList filterednames = new StringList();
    for (int i = 0; i<filenames.length; i++) {
      String ss1 = filenames[i].substring(filenames[i].length()-3);
      if (ss1.equals("mp3") || ss1.equals("wav")) {
        filterednames.append(filenames[i]);
      }
    }
    filenames = filterednames.array();
    println("Filtered files: ");
    printArray(filenames);

    Capsfilenames = new String[filenames.length];
    for (int i = 0; i<filenames.length; i++) {
      Capsfilenames[i] = filenames[i].toUpperCase();
    }
  }
}



public String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


public void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    mypath = selection.getAbsolutePath();
    String newpath = (mypath + "/");
    println("New Path is: " + newpath);
    mypath = newpath;
    String[] temp = new String[1];
    temp[0] = mypath;
    saveStrings("MyDirectory.txt", temp);
    readFilesInDirectory();
    filterfilenames();
    ListSongs.clear();
    ListSongs.addItems(filenames);
    filepos = -1;
    loadSong(true);
    checkfilestatus();
  }
}



Tab TabPlayer;
Tab TabSonglist;
Tab TabSettings;
Tab TabVisualizer;

ScrollableList ListRes;
ScrollableList ListSearchResults;
ScrollableList ListSongs;
Icon BuClearSearch;

CheckBox CheckSettings;
CheckBox CheckVisSettings;
RadioButton CheckSettings2;

Textlabel TxtLSongTime;
Textlabel TxtLSongTitle;
Textfield TxtFSearch;

Button BuChangeDirectory;
Button BuQuit;
Button BuCalcAllDia;
Button BuRandomSong;
Button BuSaveSettings;
Button BuDefaultSettings;

Icon BuPlayPause;
Icon BuNextSong;
Icon BuLastSong;

Group YNWindow;
Icon BuYes;
Icon BuNo;
Textlabel TxtLQuestion;



Group GroupBG;
//MyColorPicker MyBGColorPicker;
ColorWheel MyBGColorPicker;
Button BuBGWindow;
Button BuWallpaper;
Toggle TogUseWallpaper;
Icon BuHideBGWindow;
ScrollableList ListAnimBG;

Group GroupTheme;
Button BuThemeWindow;
Toggle TogUseTheme;
Icon BuHideThemeWindow;
Icon BuExitThemeWindow;
Slider SlThemeExample;
MyColorPicker ForegroundCP;
MyColorPicker BackgroundCP;
MyColorPicker LabelCP;
MyColorPicker ActiveCP;

Toggle TogNightMode;

Toggle TogConsole;

Slider SlIdleTime;
Slider SlVolume;
Slider SlPosition;

Println console;
Textarea consoleText;

public void InitializeGUI() {

  println("Start to initialize GUI");




  CtrRaleway.setSize(20);
  Textlabel FrameRate = cp5.addFrameRate()
    .setInterval(20)
    .setPosition(10, height-30)
    ;

  CtrRaleway.setSize(16);
  TabSonglist = cp5.addTab("Songs")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(1)
    ;
  TabSonglist.getCaptionLabel().setFont(CtrRaleway);

  TabPlayer = cp5.getTab("default")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setLabel("Player")
    .setId(2)
    ;
  TabPlayer.getCaptionLabel().setFont(CtrRaleway);
  curTabIndex = 2;


  TabSettings = cp5.addTab("Settings")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(3)
    ;
  TabSettings.getCaptionLabel().setFont(CtrRaleway);

  TabVisualizer = cp5.addTab("Visualizer")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(4)
    ;
  TabVisualizer.getCaptionLabel().setFont(CtrRaleway);


  cp5.getWindow().setPositionOfTabs(halfwidth-225, 20);

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  Iconfont = loadFont("musicplayer-50.vlw");
  BuPlayPause = cp5.addIcon("PlayPause", 10)
    .setPosition(halfwidth-70, height-120)
    .setSize(140, 90)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcons(0xe811, 0xe818)
    .setScale(0.9f, 1)
    .setSwitch(true)
    .showBackground()
    ;


  Iconfont = loadFont("musicplayer-40.vlw");
  BuNextSong = cp5.addIcon("NextSong", 10)
    .setPosition(halfwidth-50+150, height-110)
    .setSize(100, 70)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe815)
    .setScale(0.9f, 1)
    .showBackground()
    ;

  BuLastSong = cp5.addIcon("LastSong", 10)
    .setPosition(halfwidth-50-150, height-110)
    .setSize(100, 70)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe816)
    .setScale(0.9f, 1)
    .showBackground()
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  YNWindow = cp5.addGroup("YNWindow")
    .setPosition(halfwidth-250, halfheight-150)
    .setSize(500, 300)
    .setBackgroundColor(color(0, 150, 250))
    .hideBar()
    ;

  BuYes = cp5.addIcon("Yes", 10)
    .setPosition(50, 200)
    .setSize(150, 80)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9f, 1)
    .showBackground()
    .setGroup(YNWindow)
    ;

  BuNo = cp5.addIcon("No", 10)
    .setPosition(300, 200)
    .setSize(150, 80)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9f, 1)
    .showBackground()
    .setGroup(YNWindow)
    ;

  CtrRaleway.setSize(26);
  TxtLQuestion = cp5.addTextlabel("Question")
    .setPosition(20, 20)
    .setSize(460, 150)
    .setMultiline(true)
    .setFont(CtrRaleway)
    .setText("Are you sure?")
    .setGroup(YNWindow)
    ;

  YNWindow.setVisible(false);

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  BuRandomSong = cp5.addButton("RandomSong")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Random Song")
    ;


  CtrRaleway.setSize(16);
  BuChangeDirectory = cp5.addButton("ChangeDirectory")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Directory")
    ;

  CtrRaleway.setSize(18);
  BuCalcAllDia = cp5.addButton("CalcAllDia")
    .setPosition(halfwidth+50, 130)
    .setSize(250, 50)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Calculate Diagrams")
    ;

  CtrRaleway.setSize(12);
  BuQuit = cp5.addButton("Quit")
    .setPosition(width-100, 20)
    .setSize(80, 30)
    .setColorCaptionLabel(color(255))
    ;

  CtrRaleway.setSize(16);
  BuSaveSettings = cp5.addButton("SaveSettings")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Save settings")
    ;

  CtrRaleway.setSize(16);
  BuDefaultSettings = cp5.addButton("DefaultSettings")
    .setPosition(30, 80)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Reset settings")
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(32);
  TxtLSongTime = cp5.addTextlabel("SongTime")
    .setPosition(width-220, height-140)
    ;

  CtrRaleway.setSize(32);
  TxtLSongTitle = cp5.addTextlabel("SongTitle")
    .setPosition(halfwidth-100, height-320)
    ;
  TxtLSongTitle.get().align(ControlP5.CENTER, ControlP5.CENTER);
  TxtLSongTitle.setSize(800, 200);

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  CheckSettings = cp5.addCheckBox("ChSettings")
    .setPosition(halfwidth-300, 130)
    .setSize(50, 50)
    .setItemsPerRow(1)
    .setSpacingColumn(100)
    .setSpacingRow(20)
    .addItem("Draw Graphs", 0)
    .addItem("Draw Frequency Spectrum", 0)
    .addItem("Go Only Spectrum", 0)
    ;
  CheckSettings.getItem(0).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);
  CheckSettings.getItem(1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);
  CheckSettings.getItem(2).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);

  CtrRaleway.setSize(16);
  CheckVisSettings = cp5.addCheckBox("ChVisSettings")
    .setPosition(halfwidth-300, 370)
    .setSize(50, 50)
    .setItemsPerRow(1)
    .setSpacingColumn(100)
    .setSpacingRow(20)
    .addItem("Live Mode", 0)
    ;
  CheckVisSettings.getItem(0).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);


  CtrRaleway.setSize(16);
  CheckSettings2 = cp5.addRadioButton("ChSettings2")
    .setPosition(halfwidth-110, height-150)
    .setSize(60, 40)
    .setItemsPerRow(2)
    .setSpacingColumn(100)
    .setSpacingRow(10)
    .addItem("Go Idle", 0)
    .addItem("Go Eco", 0)
    ;


  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(20);
  TxtFSearch = cp5.addTextfield("Search")
    .setPosition(width-360, 80)
    .setSize(250, 40)
    .setAutoClear(false)
    ;
  TxtFSearch.setCaptionLabel("Search:");
  TxtFSearch.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
  TxtFSearch.getValueLabel().setSize(22);


  CtrRaleway.setSize(16);
  ListSongs = cp5.addScrollableList("SongList")
    .setPosition(50, 140)
    .setSize(width-100, height-160)
    .setBarHeight(35)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    ;
  ListSongs.getCaptionLabel().setSize(18);
  ListSongs.addItems(filenames);
  ListSongs.setCaptionLabel("Your Songs: ");
  ListSongs.getCaptionLabel().setLineHeight(10);

  Iconfont = loadFont("musicplayer-40.vlw");
  BuClearSearch = cp5.addIcon("ClearSearch", 10)
    .setPosition(width-90, 85)
    .setSize(30, 30)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9f, 1)
    .showBackground()
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  BuBGWindow = cp5.addButton("BGWindow")
    .setPosition(30, 150)
    .setSize(140, 40)
    .setCaptionLabel("Background")
    ;

  GroupBG = cp5.addGroup("BGGroup")
    .setPosition(halfwidth-350, halfheight-250-10)
    .setSize(700, 520)
    .setBackgroundColor(color(40))
    .hideBar()
    .setVisible(false)
    ;

  TogUseWallpaper = cp5.addToggle("UseWallpaper")
    .setPosition(40, 300)
    .setSize(60, 60)
    .setMode(ControlP5.DEFAULT)
    .setGroup(GroupBG)
    .setCaptionLabel("")
    ;

  CtrRaleway.setSize(18);
  BuWallpaper = cp5.addButton("BGWallpaper")
    .setPosition(140, 300)
    .setSize(180, 60)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Wallpaper")
    .setGroup(GroupBG)
    ;

  /*
  
   MyBGColorPicker = new MyColorPicker(cp5, "BGCP");
   MyBGColorPicker.setPosition(halfwidth-350+40, halfheight-250-10+40);
   MyBGColorPicker.setColorValue(BGcolor);
   MyBGColorPicker.setItemSize(400, 30);
   MyBGColorPicker.setVisible(false);
   */
  CtrRaleway.setSize(16);
  MyBGColorPicker = cp5.addColorWheel(cp5, "BGCP")
    .setPosition(halfwidth-350+40, halfheight-250-10+40)
    .setVisible(false);
  ;

  CtrRaleway.setSize(16);
  ListAnimBG = cp5.addScrollableList("AnimBGList")
    .setPosition(360, 40)
    .setSize(300, 200)
    .setBarHeight(60)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    .addItem("Off", 0)
    .addItem("Circles", 0)
    .addItem("-2-", 0)
    .addItem("-3-", 0)
    .setGroup(GroupBG)
    .close()
    ;
  ListAnimBG.getCaptionLabel().setSize(18);
  ListAnimBG.setCaptionLabel("Animated Background");

  BuHideBGWindow = cp5.addIcon("HideBGWindow", 10)
    .setPosition(560, 420)
    .setSize(100, 60)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9f, 1)
    .showBackground()
    .setGroup(GroupBG)
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  CtrRaleway.setSize(16);
  BuThemeWindow = cp5.addButton("ThemeWindow")
    .setPosition(30, 200)
    .setSize(140, 40)
    .setCaptionLabel("Theme")
    ;

  GroupTheme = cp5.addGroup("ThemeGroup")
    .setPosition(halfwidth-350, halfheight-250-10)
    .setSize(700, 520)
    .setBackgroundColor(color(40))
    .hideBar()
    .setVisible(false)
    ; 

  TogUseTheme = cp5.addToggle("UseTheme")
    .setPosition(40, 400)
    .setSize(60, 60)
    .setMode(ControlP5.DEFAULT)
    .setGroup(GroupTheme)
    .setCaptionLabel("Use Theme")
    ;  

  CtrRaleway.setSize(16);
  BackgroundCP = new MyColorPicker(cp5, "ThemeBGCP");
  BackgroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40);
  BackgroundCP.setColorValue(CBackground);
  BackgroundCP.setItemSize(260, 30);
  BackgroundCP.setVisible(false);

  ForegroundCP = new MyColorPicker(cp5, "ThemeFGCP");
  ForegroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40+160);
  ForegroundCP.setColorValue(CForeground);
  ForegroundCP.setItemSize(260, 30);
  ForegroundCP.setVisible(false);

  ActiveCP = new MyColorPicker(cp5, "ThemeActiveCP");
  ActiveCP.setPosition(halfwidth-350+350, halfheight-250-10+40);
  ActiveCP.setColorValue(CActive);
  ActiveCP.setItemSize(260, 30);
  ActiveCP.setVisible(false);

  LabelCP = new MyColorPicker(cp5, "ThemeLabelCP");
  LabelCP.setPosition(halfwidth-350+350, halfheight-250-10+40+160);
  LabelCP.setColorValue(CLabel);
  LabelCP.setItemSize(260, 30);
  LabelCP.setVisible(false);

  SlThemeExample = cp5.addSlider("ThemeExample")
    .setPosition(200, 380)
    .setSize(260, 40)
    .setCaptionLabel("Example")
    .setValue(50)
    .setGroup(GroupTheme)
    ;
  SlThemeExample.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);

  BuHideThemeWindow = cp5.addIcon("HideThemeWindow", 10)
    .setPosition(560, 420)
    .setSize(100, 60)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9f, 1)
    .showBackground()
    .setGroup(GroupTheme)
    ;

  Iconfont = loadFont("musicplayer-40.vlw");
  BuExitThemeWindow = cp5.addIcon("ExitThemeWindow", 10)
    .setPosition(660, 10)
    .setSize(30, 30)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9f, 1)
    .showBackground()
    .setGroup(GroupTheme)
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  TogNightMode = cp5.addToggle("NMode")
    .setPosition(30, 260)
    .setSize(140, 40)
    .setCaptionLabel("Night Mode")
    ;
  TogNightMode.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /*
  CtrRaleway.setSize(16);
   TogConsole = cp5.addToggle("toggleconsole")
   .setPosition(30, 320)
   .setSize(140, 40)
   .setCaptionLabel("console")
   ;
   TogConsole.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);
   
   CtrRaleway.setSize(16);
   consoleText = cp5.addTextarea("console")
   .setPosition(200, 100)
   .setSize(850, 400)
   .setLineHeight(15)
   .setFont(CtrRaleway)
   .setMoveable(true) 
   .setTab(TabSettings)
   ;
   consoleText.hide();
   consoleText.clear();
   console = cp5.addConsole(consoleText);
   console.pause();
   */
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  ListRes = cp5.addScrollableList("Resolution")
    .setPosition(30, 380)
    .setSize(200, 130)
    .setBarHeight(35)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    .addItems(resolutions)
    .close()
    ;
  ListRes.setCaptionLabel("Select resolution: ");

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  int idletimeSec = idletime/1000;

  CtrRaleway.setSize(16);
  SlIdleTime = cp5.addSlider("Idletime")
    .setPosition(halfwidth-225, height-80)
    .setSize(450, 40)
    .setRange(0, 300)
    .setNumberOfTickMarks(21)
    .setValue(idletimeSec)
    .setCaptionLabel("Idle Time")
    .setColorCaptionLabel(color(255))
    ;

  CtrRaleway.setSize(12);
  SlPosition = cp5.addSlider("Position")
    .setPosition(width/20, height-200)
    .setSize(width-width/10, 40)
    .setRange(0, possteps)
    .setColorCaptionLabel(color(255))
    ;
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
  SlPosition.getValueLabel().setSize(10);



  CtrRaleway.setSize(12);
  SlVolume = cp5.addSlider("Volume")
    .setPosition(width-130, 100)
    .setSize(60, 250)
    .setRange(0, 100)
    .setValue(50)
    .setNumberOfTickMarks(51)
    .setColorCaptionLabel(color(255))
    ;
  SlVolume.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  TxtLSongTitle.moveTo(TabPlayer);
  BuPlayPause.moveTo(TabPlayer);
  BuNextSong.moveTo(TabPlayer);
  BuLastSong.moveTo(TabPlayer);
  BuRandomSong.moveTo(TabPlayer);

  TxtFSearch.moveTo(TabSonglist);
  ListSongs.moveTo(TabSonglist);
  BuChangeDirectory.moveTo(TabSonglist);
  BuClearSearch.moveTo(TabSonglist);

  SlVolume.moveTo(TabSettings);
  SlIdleTime.moveTo(TabSettings);
  CheckSettings.moveTo(TabSettings);
  CheckVisSettings.moveTo(TabSettings);
  CheckSettings2.moveTo(TabSettings);
  BuCalcAllDia.moveTo(TabSettings);
  BuSaveSettings.moveTo(TabSettings);
  BuDefaultSettings.moveTo(TabSettings);

  GroupBG.moveTo(TabSettings);
  BuBGWindow.moveTo(TabSettings);
  MyBGColorPicker.moveTo(TabSettings);

  GroupTheme.moveTo(TabSettings);
  BuThemeWindow.moveTo(TabSettings);
  ForegroundCP.moveTo(TabSettings);
  BackgroundCP.moveTo(TabSettings);
  LabelCP.moveTo(TabSettings);
  ActiveCP.moveTo(TabSettings);
  TogNightMode.moveTo(TabSettings);
  //TogConsole.moveTo(TabSettings);
  ListRes.moveTo(TabSettings);

  ////////////////////////////////////////////////////////////////////////////////////////////////////



  cp5.getProperties().setFormat(ControlP5.SERIALIZED);

  cp5.getProperties().remove(cp5.getController("SongList"));
  cp5.getProperties().remove(cp5.getController("SongTitle"));
  cp5.getProperties().remove(cp5.getController("Position")); 
  cp5.getProperties().remove(cp5.getController("PlayPause")); 
  cp5.getProperties().remove(cp5.getController("SongTime")); 
  //cp5.getProperties().remove(cp5.getController("Volume")); 
  cp5.getProperties().remove(cp5.getController("Search")); 
  cp5.getProperties().remove(cp5.getController("NextSong")); 
  cp5.getProperties().remove(cp5.getController("LastSong")); 
  cp5.getProperties().remove(cp5.getController("Question")); 
  cp5.getProperties().remove(cp5.getController("console")); 
  cp5.getProperties().remove(cp5.getController("ThemeExample")); 

  //cp5.getProperties().print();


  println("Loading Settings");

  if (createInput("DefaultSettings.ser") == null) {
    cp5.saveProperties("DefaultSettings", "default");
  } 

  if (createInput("SavedSettings.ser") != null) {
    cp5.loadProperties(("SavedSettings.ser"));
  } else {
    cp5.loadProperties(("DefaultSettings.ser"));
  }

  /*
  ChSettings(CheckSettings.getArrayValue());
   float[]a = CheckSettings2.getArrayValue();
   if (a[0] == 1) {
   goIdle= true;
   } else {
   goIdle= false;
   }
   if (a[1] == 1) {
   goEco= true;
   } else {
   goEco= false;
   }
   
   if (TogUseWallpaper.getState() == true) {
   drawWallpaper = true;
   }
   if (drawWallpaper) {
   PathWallpaper = loadStrings("MyWallpaperPath.txt")[0];
   Wallpaper = loadImage(PathWallpaper);
   }
   
   if (TogUseTheme.getState() == true) {
   UseTheme = true;
   }
   if (UseTheme) {
   myTheme = new CColor(CForeground, CBackground, CActive, CLabel, CLabel);
   CForeground = unhex(loadStrings("MyTheme.txt")[0]);
   CBackground = unhex(loadStrings("MyTheme.txt")[1]);
   CActive = unhex(loadStrings("MyTheme.txt")[2]);
   CLabel = unhex(loadStrings("MyTheme.txt")[3]);
   BGcolor = unhex(loadStrings("MyTheme.txt")[4]);
   ForegroundCP.setColorValue(CForeground);
   BackgroundCP.setColorValue(CBackground);
   ActiveCP.setColorValue(CActive);
   LabelCP.setColorValue(CLabel);
   cp5.setColor(myTheme);
   } else {
   cp5.setColor(ControlP5.THEME_CP52014);
   }
   
   ForegroundCP.setColorValue(CForeground);
   BackgroundCP.setColorValue(CBackground);
   ActiveCP.setColorValue(CActive);
   LabelCP.setColorValue(CLabel);
   
   */

  setConsoleStyle();

  if (RenderFFT) {
    CheckSettings.activate("Draw Frequency Spectrum");
  }
  if (CalcDia) {
    CheckSettings.activate("Draw Graphs");
  }
  if (goOnlyFFT) {
    CheckSettings.activate("Go Only Spectrum");
  }
  if (goIdle) {
    CheckSettings2.activate("Go Idle");
  }
  if (goEco) {
    CheckSettings2.activate("Go Eco");
  }
  if (liveModeVis) {
    CheckVisSettings.activate("Live Mode");
  }
  if (TogNightMode.getState() == true) {
    NMode(true);
  } 
  MyBGColorPicker.setRGB(BGcolor);


  if (CalcDia) {
    if (filenames.length > filepos) {
      loadSongDiagram(filenames[filepos]);
      renderSongDiagram();
    }
  }

  updateMetaInfo();
  if (player != null) {
    playerlengthsec = PApplet.parseInt((player.length() / 1000) % 60);
    playerlengthmin = PApplet.parseInt((player.length() / 60000) % 60);
    possteps = player.length()/posdivide;
  }
  SlPosition.setRange(0, possteps);
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
}





////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////



public void setConsoleStyle() {
  /*
  consoleText.setColor(color(0));
   consoleText.setColorBackground(color(255, 240));
   consoleText.setColorForeground(color(100));
   consoleText.setColorActive(color(200));
   consoleText.setScrollBackground(color(80)); 
   consoleText.setScrollForeground(color(150)); 
   consoleText.setScrollActive(color(30));
   */
}

class Node {

  int band;
  PVector pos;
  float val;

  float size;

  Node connections[];

  Node(int b) {
    band = b;

    pos = getNewPos();
    if (nodes != null && nodes.length > 0) {
      float closestDist = getClosestDist();
      int minDist = 100;
      int tries = 0;
      while (closestDist < minDist && tries < 100) {
        tries++;
        pos = getNewPos();
        closestDist = getClosestDist();
      }
    }

    connections = new Node[3];
  }

  public float getClosestDist() {
    float record = 100000;
    for (Node n : nodes) {
      if (n != null) {
        float dist = dist(pos.x, pos.y, n.pos.x, n.pos.y);
        if (dist < record) {
          record = dist;
        }
      }
    }
    return record;
  }

  public PVector getNewPos() {
    int borderOutside = 200;
    int borderInside = 300;

    float x;
    if (random(1) < 0.5f) {
      x  = random(borderOutside, width/2-borderInside);
    } else {
      x  = random(width/2+borderInside, width-borderOutside);
    }
    float bandHeight = height-FFTYVis-band*FFTdify;
    float y = bandHeight+random(-200, 200);
    y = constrain(y, borderOutside, height-borderOutside);

    return new PVector(x, y);
  }

  public void run() {
    update();
    display();
  }

  public void update() {
    size = val * (band/30+0.6f) * 1.2f;
    size = constrain(size, 0, 300);
    if (size > 60) {
      if (showParticles) {
        particleSystem.addParticleSystem(PApplet.parseInt(size/18), size/240, pos, true);
      }
    }
  }

  public void display() {

    //stroke(255, 0, 0,20);
    //line(pos.x, pos.y, width/2, height-FFTYVis-band*FFTdify);

    for (int i = 0; i<connections.length; i++) {
      float combVal = ((val/10)*(connections[i].val/10))*0.1f;
      fxVisCanvas.stroke(255, combVal*combVal);
      fxVisCanvas.line(pos.x, pos.y, connections[i].pos.x, connections[i].pos.y);
    }

    int c = color(FFTColorVis);
    if (colorNodes) {
      c = fittingBackgroundVisCol;
    }
    if (fillBars) {
      fxVisCanvas.fill(c, 0+constrain((val-5)*1.2f, 0, 155));
      if (strokeBars) {
        fxVisCanvas.stroke(c, 0+constrain((val-5)*1.2f, 0, 100));
      }
    } else {
      fxVisCanvas.noFill();
      if (strokeBars) {
        fxVisCanvas.stroke(c, 20+constrain((val-5)*1.2f, 0, 100));
      }
    }

   fxVisCanvas.ellipse(pos.x, pos.y, size, size);
  }

  public void addConnection(int index, Node n) {
    connections[index] = n;
  }

  public void setVal(float set) {
    float change = set-val;
    val = val+change*nodeSmooth;
  }

  public int getBand() {
    return band;
  }

  public boolean isLeftSide() {
    return pos.x < width/2;
  }
}
Serial rgbCubePort;  // Create object from Serial class

String portName; //change the 0 to a 1 or 2 etc. to match your port

public void runRgbCube() {
  sendCubeData();
}

public void setupRgbCube() {
  try {
    portName = Serial.list()[2];
    rgbCubePort = new Serial(this, portName, 115200);
  }
  catch(Exception e) {
    println(e);
  }
}

public void sendCubeData() {
  if(rgbCubePort == null){
    return;
  }

  int startIndex = 1;
  float add = 2.5f;
  for (int i=0; i<8; i++) {
    // rgbCubePort.write((byte)(freq_height[i]));
    //println((freq_height[i]));
    //println((byte)(freq_height[i]));
    if (round(startIndex + i*add) < FFTvaluesVis.length) {
      float val = FFTvaluesVis[round(startIndex + i*add)];
      if (i >= 1) {
        val += FFTvaluesVis[round(startIndex + i*add -1)];
        val += FFTvaluesVis[round(startIndex + i*add +1)];
        val = val/3;
      }

      rgbCubePort.write((byte)(val));
    }
  }
  rgbCubePort.write('B');
}
public void mouseReleased() {
  if (curTabIndex == 4) {

    if (B6.MouseOverButton()) {
      TabPlayer.mousePressed();
    }
    if (millis() > menuSwitchMillis+100) {
      if (B1.MouseOverButton()) {
        showFFTHighlights = B1.toggle();
      }
      if (B2.MouseOverButton()) {
        fillBars = B2.toggle();
      }
      if (B3.MouseOverButton()) {
        strokeBars = B3.toggle();
      }
      if (B4.MouseOverButton()) {
        showLights = B4.toggle();
      }
      if (B5.MouseOverButton()) {
        showLightning = B5.toggle();
      }
      if (B7.MouseOverButton()) {
        showParticles = B7.toggle();
      }
      if (B8.MouseOverButton()) {
        colorNodes = B8.toggle();
      }
      if (B9.MouseOverButton()) {
        showLaserBeams = B9.toggle();
      }
      if (B10.MouseOverButton()) {
        showPostFx = B10.toggle();
      }
    }
  }
}

public void keyReleased() {
  if (key == 'n') {    
    shockwave sw = new shockwave(new PVector(mouseX, mouseY), 15, 200, 1, false);
    shockwaveSystem.addShockwave(sw);
  }
  if (key == CODED) {
    if (keyCode == UP) {
      SlVolume.setValue(volume+5);
    } else if (keyCode == DOWN) {
      SlVolume.setValue(volume-5);
    } else if (keyCode == LEFT) {
      LastSong();
    } else if (keyCode == RIGHT) {
      NextSong();
    }
  }
}

public void drawMenu() {
  menuVisCanvas.beginDraw();
  if (menuY > -100) {
    menuVisCanvas.filter(blur);
    menuVisCanvas.filter(blur);
    menuVisCanvas.rectMode(CORNER);
    menuVisCanvas.noStroke();
    menuVisCanvas.pushMatrix();
    menuVisCanvas.translate(0, menuY);

    menuVisCanvas.fill(180, 220, 255, 150);
    menuVisCanvas.rect(0, 0, width, 100);

    menuVisCanvas.fill(50, 100, 150, 200);
    menuVisCanvas.rect(0, 100, width, 5);

    B1.run();
    B2.run();
    B3.run();
    B4.run();
    B5.run();
    B6.run();
    B7.run();
    B8.run();
    B9.run();
    B10.run();

    menuVisCanvas.popMatrix();
  }
  if (menuY < 0 && menuY > -100) {
    menuVisCanvas.rectMode(CORNER);
    menuVisCanvas.noStroke();

    menuVisCanvas.fill(0, 255);
    menuVisCanvas.rect(0, menuY+90, width, 25);
  }
  menuVisCanvas.endDraw();
}

public void showMenu() {
  if (menuY < 0) {
    menuY += 8;
  }
}


public void hideMenu() {

  if (menuY > -100) {
    menuY -= 8;
  }
}
class MyButton {

  PVector dimensions;
  PVector position;

  int CheckborderR;
  int CheckborderL;
  int CheckborderU;
  int CheckborderD;

  int btncolor;

  int colorAct = color(220);
  int colorDea = color(100);

  boolean output;

  String label;
  String secondLabel;

  boolean animations = true;
  float curLerpVal;

  boolean gradients = true;

  boolean disabled;

  PFont Font;

  MyButton(PVector s, PVector t, String l, int a, int d) {
    position = s.copy();
    dimensions = t.copy();
    CheckborderR = PApplet.parseInt(position.x+dimensions.x);
    CheckborderL = PApplet.parseInt(position.x);
    CheckborderU = PApplet.parseInt(position.y);
    CheckborderD = PApplet.parseInt(position.y+dimensions.y);
    label = l;
    colorAct = a;
    colorDea = d;
    btncolor = colorDea;
    disabled = false;
    secondLabel = "";
    standardFont();
    autoFontSize();
  }

  MyButton(PVector s, PVector t, String l) {
    position = s.copy();
    dimensions = t.copy();
    CheckborderR = PApplet.parseInt(position.x+dimensions.x);
    CheckborderL = PApplet.parseInt(position.x);
    CheckborderU = PApplet.parseInt(position.y);
    CheckborderD = PApplet.parseInt(position.y+dimensions.y);
    btncolor = colorDea;
    label = l;
    disabled = false;
    secondLabel = "";
    standardFont();
    autoFontSize();
  }

  public void setLabel(String s) {
    label = s;
  }

  public void setSecondLabel(String s) {
    secondLabel = s;
  }

  public void setDisabled(boolean s) {
    disabled = s;
  }

  public void standardFont() {
    Font = createFont("Arial", 36);
  }

  public void setFont(String name, int size, boolean autoSize) {
    Font = createFont(name, size);
    if (autoSize) {
      autoFontSize();
    }
  }

  public void autoFontSize() {
    while (Font.getSize()*label.length()*0.7f > dimensions.x) {
      Font = createFont(Font.getName(), Font.getSize()-1);
    }
  }

  public void run() {
    update();
    display();
  }

  public void display() {
    menuVisCanvas.stroke(0);
    menuVisCanvas.strokeWeight(1);

    if (gradients) {
      menuVisCanvas.stroke(lerpColor(colorDea, color(0), 0.5f));
      menuVisCanvas.noFill();
      menuVisCanvas.rect (position.x-1, position.y-1, dimensions.x+2, dimensions.y+2);
      for (int i = 0; i<=dimensions.y; i++) {
        menuVisCanvas.stroke(lerpColor(colorAct, btncolor, i/dimensions.y));
        menuVisCanvas.line(position.x, position.y+i, position.x+dimensions.x, position.y+i);
      }
    } else {
      menuVisCanvas.fill(btncolor);
      menuVisCanvas.rect(position.x, position.y, dimensions.x, dimensions.y);
    }
    if (disabled) {
      menuVisCanvas.fill(0, 100);
      menuVisCanvas.rect(position.x, position.y, dimensions.x, dimensions.y);
    }

    menuVisCanvas.textAlign(CENTER, CENTER);
    menuVisCanvas.textFont(Font);
    menuVisCanvas.fill(0);
    if (secondLabel.length() > 0) {
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/3.4f);
      menuVisCanvas.fill(0, 200);
      menuVisCanvas.text(secondLabel, position.x+dimensions.x/2, position.y+dimensions.y/1.6f);
    } else {
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/2.4f);
    }
  }

  public void update() {
    if (!disabled) {
      if (animations) {
        if (MouseOverButton()) {
          if (curLerpVal < 1) {
            curLerpVal += 0.1f;
            btncolor = lerpColor(colorDea, colorAct, curLerpVal);
          }
        } else if (curLerpVal > 0) {
          curLerpVal -= 0.1f;
          btncolor = lerpColor(colorDea, colorAct, curLerpVal);
        }
      } else {
        if (MouseOverButton()) {
          btncolor = colorAct;
        } else {
          btncolor = colorDea;
        }
      }
    }
  }

  public boolean MouseOverButton() {
    return(mouseX > CheckborderL && mouseX < CheckborderR && mouseY > CheckborderU && mouseY < CheckborderD);
  }

  public boolean clicked() {
    return(!disabled && MouseOverButton());
  }

  public boolean pressed() {
    return (mousePressed == true && MouseOverButton());
  }
}



class MyToggle {

  PVector dimensions;
  PVector position;

  int CheckborderR;
  int CheckborderL;
  int CheckborderU;
  int CheckborderD;

  int btnAlpha;

  int btncolor;

  int alphaAct = 220;
  int alphaDea = 180;
  int colorAct = color(200, 255, 200);
  int colorDea = color(255, 200, 200);

  int fontColor = color(0);

  boolean value;

  boolean disabled;

  String label;
  String secondLabel;
  boolean labelOutside;

  PFont Font;

  MyToggle(PVector s, PVector t, String l, boolean val, int a, int d) {
    position = s.copy();
    dimensions = t.copy();
    CheckborderR = PApplet.parseInt(position.x+dimensions.x);
    CheckborderL = PApplet.parseInt(position.x);
    CheckborderU = PApplet.parseInt(position.y);
    CheckborderD = PApplet.parseInt(position.y+dimensions.y);
    colorAct = a;
    colorDea = d;
    btncolor = colorDea;
    label = l;
    disabled = false;
    labelOutside = false;
    secondLabel = "";
    value = val;
    standardFont();
    autoFontSize();
  }

  public void setLabel(String s) {
    label = s;
  }

  public void setSecondLabel(String s) {
    secondLabel = s;
  }

  public void setDisabled(boolean s) {
    disabled = s;
  }

  public void standardFont() {
    Font = createFont("Arial", 36);
  }

  public void setLabelOutside(boolean in) {
    labelOutside = in;
  }

  public void setFont(String name, int size, boolean autoSize) {
    Font = createFont(name, size);
    if (autoSize) {
      autoFontSize();
    }
  }

  public void setFontColor(int col) {
    fontColor = col;
  }

  public void autoFontSize() {
    while (Font.getSize()*label.length()*0.7f > dimensions.x) {
      Font = createFont(Font.getName(), Font.getSize()-1);
    }
  }

  public void run() {
    update();
    display();
  }

  public void display() {
    menuVisCanvas.strokeWeight(1);
    menuVisCanvas.stroke(255, 200);
    if (value) {
      btncolor = colorAct;
    } else {
      btncolor = colorDea;
    }
    menuVisCanvas.fill(btncolor, btnAlpha);
    menuVisCanvas.rect (position.x, position.y, dimensions.x, dimensions.y);
    if (disabled) {
      menuVisCanvas.fill(0, 50);
      menuVisCanvas.rect(position.x, position.y, dimensions.x, dimensions.y);
    }
    menuVisCanvas.textFont(Font);
    menuVisCanvas.fill(fontColor);
    if (labelOutside) {
      menuVisCanvas.textAlign(CORNER, CENTER);
      menuVisCanvas.text(label, position.x+dimensions.x+20, position.y+dimensions.y/2.4f);
    } else {
      menuVisCanvas.textAlign(CENTER, CENTER);
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/2.4f);
    }
  }

  public void update() {
    if (!disabled) {
      if (MouseOverButton()) {
        btnAlpha = alphaAct;
      } else {
        btnAlpha = alphaDea;
      }
    }
  }

  public boolean toggle() {
    value = !value;
    return value;
  }

  public boolean MouseOverButton() {
    return(mouseX > CheckborderL && mouseX < CheckborderR && mouseY > CheckborderU && mouseY < CheckborderD);
  }

  public boolean clicked() {
    return(!disabled && MouseOverButton());
  }

  public boolean pressed() {
    return (mousePressed == true && MouseOverButton());
  }
}










float[] FFTvaluesVis;
float[] FFToldvaluesVis;

int FFTColorVis;
int FFTHighlight1Vis;
int FFTHighlight2Vis;


int FFTXVis;
int FFTYVis;
int FFTbarsVis;
float FFTdify;
float FFTsmooth;

float t;
//Laser beams
float lineTime;
float lineSpeed;
float targetLineSpeed;
float lastPhaseDif;
float linePhaseDif;
float linePhaseFadePos;
float targetPhaseDif;

FFT fftVis;

//Current color theme
int backgroundVisCol;
int fittingBackgroundVisCol;

//Shader for blurring when in menu
PShader blur;

//Shaders for blurring background Nodes
PShader blurHor;
PShader blurVert;

ParticleSystem particleSystem;
int partcount;

ShockwaveSystem shockwaveSystem;
boolean spawnShockwaveNextBeat;

float menuY;

float totalVolume;
float bassVolume;
float globalMoveSpeedMod;

//Calculating overall song volume in one second
float iterCount;
float curSecVol;
float lastSecVol;

int bassStreakCounter;

//Variables to set with toggle buttons
boolean showFFTHighlights;
boolean showLightning;
boolean showLights;
boolean fillBars;
boolean strokeBars;
boolean showParticles;
boolean colorNodes;
boolean showLaserBeams;
boolean showPostFx;

PFont RalewayS;
PFont RalewayM;
PFont RalewayL;

MyToggle B1;
MyToggle B2;
MyToggle B3;
MyToggle B4;
MyToggle B5;
MyButton B6;
MyToggle B7;
MyToggle B8;
MyToggle B9;
MyToggle B10;

AudioInput liveIn;
boolean liveModeVis;

int phaseDiffThreshold;
int shockwaveTriggerThreshold;
int changeColorThemeThreshold;

float[][] spectraVisualizer;
int[] bandCounter;
Node[] nodes;
int nodeCount;
float nodeSmooth;
int[] totalNodesMadeCounter;
int[] standardNodeBands;

int[] backgroundColors;
int[] fittingBackgroundColors;

PGraphics menuVisCanvas;
PGraphics fxVisCanvas;
PostFXSupervisor supervisor;
BlurPass blurPass;
BloomPass bloomPass;
RGBSplitPass rgbSplitPass;
BrightnessContrastPass brightnessContrastPass;

public void setupVisualizer() {

  colorMode(RGB, 255);

  menuVisCanvas = createGraphics(width, height, P2D);
  fxVisCanvas = createGraphics(width, height, P2D);
  // create supervisor and load shaders
  supervisor = new PostFXSupervisor(this);
  blurPass = new BlurPass(this, 40, 100.0f, true);
  bloomPass = new BloomPass(this, 0.6f, 20, 40.0f);
  rgbSplitPass = new RGBSplitPass(this, 0);
  brightnessContrastPass = new BrightnessContrastPass(this, 0.0f, 1.0f);

  lineTime = 0;
  linePhaseDif = 0;

  menuY = -100;

  totalVolume = 0;
  globalMoveSpeedMod = 0;

  lastSecVol = 0;
  curSecVol = 0;
  iterCount = 0;

  //                             BLUE               PURPLE              YELLOW              GREEN                CYAN
  backgroundColors = new int[]{color(0, 30, 255), color(240, 0, 255), color(255, 231, 0), color(116, 238, 21), color(77, 238, 234)};
  fittingBackgroundColors = new int[]{color(255, 231, 0), color(102, 255, 204), color(255, 102, 0), color(255, 51, 153), color(102, 255, 102)};
  //                                    YELLOW              LIGHT CYAN            ORANGE              PINK                  GREEN-CYAN

  setBackgroundConsts();

  showLightning = false;
  showLights = true;
  fillBars = true;
  strokeBars = true;
  showFFTHighlights = true;
  showParticles = true;
  colorNodes = true;
  showLaserBeams = true;
  showPostFx = true;

  FFTbarsVis = 25;

  FFTvaluesVis = new float[FFTbarsVis];

  FFTColorVis = color(255, 255, 255);
  FFTHighlight1Vis = color(105, 205, 5);
  FFTHighlight2Vis = color(0, 190, 240); 

  FFTXVis = width/2;
  FFTYVis = 100;

  float FFTheight = height-FFTYVis*2;
  FFTdify = FFTheight/FFTbarsVis;

  FFTsmooth = 0.3f;
  nodeSmooth = 0.5f;

  // FFT-Instanz für die Spektrumsanalyse der beiden Kanäle
  fftVis = new FFT (player.bufferSize (), player.sampleRate ());

  RalewayS = createFont("Raleway", 12);
  RalewayM = createFont("Raleway", 20);
  RalewayL = createFont("Raleway", 36);
  textFont(RalewayM);

  PVector btnPos = new PVector(20, 25);
  int btnDX = width/50;
  int btnCount = 10;
  PVector btnDim = new PVector((width-btnDX*btnCount)/btnCount, 50);
  PVector btnCurpos = btnPos.copy();

  B6 = new MyButton(btnCurpos, btnDim, "Back", color(200), color(100));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B1 = new MyToggle(btnCurpos, btnDim, "Highlights", showFFTHighlights, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B2 = new MyToggle(btnCurpos, btnDim, "Fill Bars", fillBars, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B3 = new MyToggle(btnCurpos, btnDim, "Stroke Bars", strokeBars, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B4 = new MyToggle(btnCurpos, btnDim, "Lights", showLights, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B5 = new MyToggle(btnCurpos, btnDim, "Lightning", showLightning, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B7 = new MyToggle(btnCurpos, btnDim, "Particles", showParticles, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B8 = new MyToggle(btnCurpos, btnDim, "Color Nodes", colorNodes, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B9 = new MyToggle(btnCurpos, btnDim, "Laser Beams", showLaserBeams, color(200, 255, 200), color(255, 200, 200));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B10 = new MyToggle(btnCurpos, btnDim, "Post Fx", showPostFx, color(200, 255, 200), color(255, 200, 200));

  B1.setFont("Raleway", 24, true);
  B2.setFont("Raleway", 24, true);
  B3.setFont("Raleway", 24, true);
  B4.setFont("Raleway", 24, true);
  B5.setFont("Raleway", 24, true);
  B6.setFont("Raleway", 24, true);
  B7.setFont("Raleway", 24, true);
  B8.setFont("Raleway", 24, true);
  B9.setFont("Raleway", 24, true);
  B10.setFont("Raleway", 24, true);

  particleSystem = new ParticleSystem();

  shockwaveSystem = new ShockwaveSystem();
  spawnShockwaveNextBeat = false;

  //Thresholds: The higher, the bigger the change in overall volume change has to be in order to trigger the action
  phaseDiffThreshold = 75000; //Laser angle change threshold
  shockwaveTriggerThreshold = 140000;
  changeColorThemeThreshold = 100000; //Color Theme (Background and Nodes color)

  setBackgroundColorsByIndex(0);

  blur = loadShader("blur.glsl"); 

  float blurSteps = 50.0f;
  float blurStrength = 190.0f;

  blurHor = loadShader("blurStretchHor.glsl"); 
  blurVert = loadShader("blurStretchVert.glsl"); 

  blurHor.set("STEPS", blurSteps);
  blurVert.set("STEPS", blurSteps);
  blurHor.set("blurRange", blurStrength);
  blurVert.set("blurRange", blurStrength);

  noStroke();

  nodeCount = 20;
  nodes = new Node[nodeCount];
  standardNodeBands = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 23, 42, 46};
  bandCounter = new int[FFTbarsVis];
  totalNodesMadeCounter = new int[FFTbarsVis];

  setupRgbCube();
}

public void visualizerCheckLiveMode() {
  if (liveModeVis) {
    liveIn = minim.getLineIn();
    fftVis = new FFT(liveIn.bufferSize(), liveIn.sampleRate());
  } else {
    fftVis = new FFT (player.bufferSize(), player.sampleRate());
  }
  visualizerAnalyseSong();
}

public void visualizerAnalyseSong() {
  if (!liveModeVis) {
    analyzeUsingAudioSample();
    calculateBandCounts();
    makeNodes();
  } else {
    makeStandardNodes();
  }
}

public void setRgbSplitPassByBassLevel() {
  float delta = FFTvaluesVis[1]*0.0045f;
  delta = constrain(delta, 0, 2.5f);
  //println("delta:",delta);
  float minDelta = 0.1f;
  if (delta > minDelta) {
    rgbSplitPass.setDelta(delta*delta*100);
  }
}

public void setContrastPassByVolumeLevel() {
  float contrast = lastSecVol*0.000004f;
  contrast = constrain(contrast*contrast+0.1f, 0, 2.5f);
  //println("contrast:", contrast);
  brightnessContrastPass.setContrast(contrast);
}

public void drawVisualizer() {
  fxVisCanvas.beginDraw();

  fxVisCanvas.ellipseMode(CENTER);
  fxVisCanvas.rectMode(CORNER);
  fxVisCanvas.fill(0, 150);
  fxVisCanvas.noStroke();
  fxVisCanvas.rect(0, 0, width, height);

  t += 0.01f;

  CalculateFFT();

  if (showPostFx) {
    setRgbSplitPassByBassLevel();
    setContrastPassByVolumeLevel();
  }

  drawBackground();
  if (showLaserBeams) {
    drawLines();
  }

  runRgbCube();

  detectMoodChange();
  checkShockwave();
  checkBassStreak();

  if (showLightning) {
    RenderLightning();
  }
  if (showLights) {
    RenderLights();
  }


  particleSystem.run();

  partcount = particleSystem.particles.size();

  shockwaveSystem.run();

  RenderFFTVis();

  fxVisCanvas.ellipseMode(CENTER);
  for (int i = 0; i<nodes.length; i++) {
    nodes[i].setVal(FFTvaluesVis[nodes[i].getBand()]);
    nodes[i].run();
  }

  drawMenu();
  if (mouseY < 100) {
    showMenu();
  } else {
    hideMenu();
  }

  fxVisCanvas.textAlign(CORNER);
  fxVisCanvas.fill(255);
  fxVisCanvas.textFont(RalewayS);
  fxVisCanvas.text(frameRate, 10, 20);
  fxVisCanvas.text(partcount, 10, 40);
  fxVisCanvas.text(bassStreakCounter, 10, 60);

  fxVisCanvas.endDraw();

  blendMode(BLEND);
  image(fxVisCanvas, 0, 0);
  if (menuY > -100) {
    image(menuVisCanvas, 0, 0);
  }

  blendMode(SCREEN);
  supervisor.render(menuVisCanvas);
  supervisor.render(fxVisCanvas);
  if (menuY < -100 && showPostFx) {
    supervisor.pass(bloomPass);
    supervisor.pass(rgbSplitPass);
    supervisor.pass(brightnessContrastPass);
  }
  supervisor.compose();
  blendMode(BLEND);
}


public float heightToFTTVal(float posY) {
  int index = floor(map(constrain(posY, FFTYVis, height-FFTYVis), FFTYVis, height-FFTYVis, FFTbarsVis, 0));
  index = constrain(index, 0, FFTbarsVis-1);
  return FFTvaluesVis[index];
}

public void detectMoodChange() {
  iterCount++;
  if (iterCount > 40) {
    iterCount = 0;
    float change = curSecVol - lastSecVol;
    //println("change to last sec: " + change);
    if (abs(change) > phaseDiffThreshold) {
      //Laser angle
      changePhaseDif();
    }
    if (abs(change) > changeColorThemeThreshold) {
      //Background and Nodes color
      changeColorScheme();
    }
    if (abs(change) > shockwaveTriggerThreshold) {
      //Shockwave trigger
      spawnShockwaveNextBeat = true;
    }
    lastSecVol = curSecVol;
    curSecVol = 0;
  }
}

public void checkShockwave() {
  int minVal = 220;
  if (spawnShockwaveNextBeat) {
    for (int i = 1; i<4; i++) {
      if (FFTvaluesVis[i] >= minVal) {
        float swStrength = floor((FFTvaluesVis[i]-minVal)/100);
        int swDur = 200;
        int swSpeed = 15;
        boolean pullIn = false;

        PVector swPos = new PVector(FFTXVis, height-FFTYVis-i*FFTdify);

        shockwave sw = new shockwave(swPos, swSpeed, swDur, swStrength, pullIn);
        shockwaveSystem.addShockwave(sw);
        if (random(1) < 0.2f) { //in 1/5 of cases spawn another shockwave that starts from a node
          for (int j = 0; j<nodes.length; j++) {
            if (nodes[j].getBand() == i) {
              swPos = nodes[j].pos.copy();
              swStrength += 3;
              swDur = 30;
              swSpeed = 10;
              pullIn = true;
              shockwave sw2 = new shockwave(swPos, swSpeed, swDur, swStrength, pullIn);
              shockwaveSystem.addShockwave(sw2);
            }
          }
        } 

        spawnShockwaveNextBeat = false;
        return;
      }
    }
  }
}

public void checkBassStreak() {
  int minVal = 200;
  int minStreak = 20;
  if (FFTvaluesVis[1] >= minVal) {
    bassStreakCounter++;
  } else {
    if (bassStreakCounter >= minStreak) {
      float swStrength = (bassStreakCounter-minStreak)/40;
      int swDur = 200;
      int swSpeed = 15;
      boolean pullIn = false;
      PVector swPos = new PVector(FFTXVis, height-FFTYVis-1*FFTdify);
      shockwave sw = new shockwave(swPos, swSpeed, swDur, swStrength, pullIn);
      shockwaveSystem.addShockwave(sw);
    }
    bassStreakCounter = 0;
  }
}

public void checkSpawnShockwaveStrongHit(float change, int index) {
  if (change > 450) {
    float swStrength = change/350;
    int swDur = 200;
    int swSpeed = 15;
    boolean pullIn = false;
    PVector swPos = new PVector(FFTXVis, height-FFTYVis-index*FFTdify);
    shockwave sw = new shockwave(swPos, swSpeed, swDur, swStrength, pullIn);
    shockwaveSystem.addShockwave(sw);
  }
}

public void CalculateFFT() {
  FFToldvaluesVis = Arrays.copyOf(FFTvaluesVis, FFTvaluesVis.length);
  if (liveModeVis) {
    fftVis.forward(liveIn.mix);
  } else {
    fftVis.forward(player.mix);
  }
  for (int i = 0; i<FFTbarsVis; i++) {
    fftVis.scaleBand(i, i/50+1);
  }

  for (int i = 0; i<FFTbarsVis; i++) {
    float val = fftVis.getBand(i);

    float change = val-FFToldvaluesVis[i];
    checkSpawnShockwaveStrongHit(change, i);
    FFTvaluesVis[i] = FFTvaluesVis[i]+change*FFTsmooth;
  }
}


public void RenderFFTVis() {
  fxVisCanvas.rectMode(CENTER);
  //noStroke();
  //noFill();
  if (!strokeBars) {
    fxVisCanvas.noStroke();
  }
  fxVisCanvas.strokeWeight(1);
  int c;

  totalVolume = 0;
  bassVolume = 0;

  for (int i = 0; i<FFTbarsVis; i++) {
    float val = FFTvaluesVis[i];
    c = color(FFTColorVis);

    if (i > 0 && i < 4) {
      bassVolume += val;
    }
    totalVolume += val*map(i, 0, 60, 8, 0.5f);

    PVector systemPos = new PVector(FFTXVis, height-FFTYVis-i*FFTdify);
    if (val > 180) {
      if (showFFTHighlights) {
        c = FFTHighlight1Vis;
      }
      if (showParticles) {
        particleSystem.addParticleSystem(15, -val/150, systemPos, false);
        particleSystem.addParticleSystem(15, val/150, systemPos, false);
      }
    } else if (i>6 && val > fftVis.getBand(i+1) && val > fftVis.getBand(i-1) && val > 60) {
      if (showFFTHighlights) {
        c = FFTHighlight2Vis;
      }
      if (showParticles) {
        particleSystem.addParticleSystem(15, -val/150, systemPos, false);
        particleSystem.addParticleSystem(15, val/150, systemPos, false);
      }
    } else if (val > 30) {
      if (showParticles) {
        particleSystem.addParticleSystem(1, -val/150, systemPos, false);
        particleSystem.addParticleSystem(1, val/150, systemPos, false);
      }
    }

    if (fillBars) {
      fxVisCanvas.fill(c, 20+constrain((val-5)*0.7f, 0, 200));
      if (strokeBars) {
        fxVisCanvas.stroke(c, 40+constrain((val-5)*0.6f, 0, 200));
      }
    } else {
      fxVisCanvas.noFill();
      if (strokeBars) {
        fxVisCanvas.stroke(c, 60+constrain((val-5)*1.2f, 0, 190));
      }
    }

    fxVisCanvas.rect(FFTXVis, height-FFTYVis-i*FFTdify, constrain(FFTvaluesVis[i]*2, 0, 600), FFTdify);
  }

  globalMoveSpeedMod = bassVolume/500;
  curSecVol += totalVolume;
}


public void analyzeUsingAudioSample()
{
  AudioPlayer tempplayer = minim.loadFile(mypath + filenames[filepos]);
  if (tempplayer.length()>2000000 || tempplayer.length() < 0) {
    println("FILE TOO BIG OR ZERO, CLOSING!");
    println("-----------------------------------------------");
    spectra = new byte[0];
    tempplayer.close();
    return;
  }
  tempplayer.close();

  AudioSample jingle = minim.loadSample(mypath + filenames[filepos], 2048);

  // get the left channel of the audio as a float array
  // getChannel is defined in the interface BuffereAudio, 
  // which also defines two constants to use as an argument
  // BufferedAudio.LEFT and BufferedAudio.RIGHT
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);

  // then we create an array we'll copy sample data into for the FFT object
  // this should be as large as you want your FFT to be. generally speaking, 1024 is probably fine.
  int fftSize = 1024;
  println("FFtsize: " + fftSize);
  float[] fftSamples = new float[fftSize];
  FFT fft = new FFT( fftSize, jingle.sampleRate() );

  // now we'll analyze the samples in chunks
  int totalChunks = (leftChannel.length / fftSize) + 1;
  println("Chunks: " + totalChunks);

  // allocate a 2-dimentional array that will hold all of the spectrum data for all of the chunks.
  // the second dimension if fftSize/2 because the spectrum size is always half the number of samples analyzed.
  spectraVisualizer = new float[totalChunks][FFTbarsVis];

  for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx)
  {
    int chunkStartIndex = chunkIdx * fftSize;

    // the chunk size will always be fftSize, except for the 
    // last chunk, which will be however many samples are left in source
    int chunkSize = min( leftChannel.length - chunkStartIndex, fftSize );

    // copy first chunk into our analysis array
    System.arraycopy( leftChannel, // source of the copy
      chunkStartIndex, // index to start in the source
      fftSamples, // destination of the copy
      0, // index to copy to
      chunkSize // how many samples to copy
      );

    // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes        
    if ( chunkSize < fftSize )
    {
      // we use a system call for this
      java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0f );
    }

    // now analyze this buffer
    fft.forward( fftSamples );

    // and copy the resulting spectrum into our spectra array
    for (int i = 0; i<FFTbarsVis; i++) {
      fft.scaleBand(i, i/40+1);
    }

    for (int i = 0; i < FFTbarsVis; ++i)
    {
      spectraVisualizer[chunkIdx][i] = fft.getBand(i);
    }
  }

  jingle.close();
}

public void calculateBandCounts() {
  for (int i = 0; i<spectraVisualizer.length; i++) { //loop though all points in time
    for (int j = 0; j < spectraVisualizer[i].length; j++) {
      if (j != 0 && j != spectraVisualizer[i].length-1) {
        if (isAHit(spectraVisualizer[i][j], spectraVisualizer[i][j-1], spectraVisualizer[i][j+1])) {
          bandCounter[j]++;
        }
        if (isABonusHit(spectraVisualizer[i][j], spectraVisualizer[i][j-1], spectraVisualizer[i][j+1])) {
          bandCounter[j] += 10;
        }
      } else if (j == 0) {
        if (isAHit(spectraVisualizer[i][j], spectraVisualizer[i][j+1])) {
          bandCounter[j]++;
        }
        if (isABonusHit(spectraVisualizer[i][j], spectraVisualizer[i][j+1])) {
          bandCounter[j] += 10;
        }
      } else if (j == spectraVisualizer[i].length-1) {
        if (isAHit(spectraVisualizer[i][j], spectraVisualizer[i][j-1])) {
          bandCounter[j]++;
        }
        if (isABonusHit(spectraVisualizer[i][j], spectraVisualizer[i][j-1])) {
          bandCounter[j] += 10;
        }
      }
    }
  }
  for (int i = 0; i < bandCounter.length; i++) {
    //println("Band " + i + " : " + bandCounter[i]);
  }
}

float valThreshold = 30;

public boolean isAHit(float curVal, float lastVal, float nextVal) {
  return curVal > valThreshold && curVal > lastVal && curVal > nextVal;
}

public boolean isAHit(float curVal, float otherVal) {
  return curVal > valThreshold && curVal > otherVal;
}

float bonusHitDif = 1.8f;

public boolean isABonusHit(float curVal, float lastVal, float nextVal) {
  return curVal > valThreshold && curVal > lastVal*bonusHitDif && curVal > nextVal*bonusHitDif;
}
public boolean isABonusHit(float curVal, float otherVal) {
  return curVal > valThreshold && curVal > otherVal*bonusHitDif;
}

public void makeStandardNodes() {
  for (int i = 0; i < nodeCount; i++) {
    int index = 0;
    if (standardNodeBands[i] < FFTbarsVis) {
      index = standardNodeBands[i];
    } else {
      index = floor(random(0, FFTbarsVis));
    }
    nodes[i] = new Node(index);
    //println("Made node for band " + bestBands.get(i));
  }
  makeNodeConnections();
}

public void makeNodes() {  
  /*
  int totalHits = 0;
   for (int i = 0; i < bandCounter.length; i++) {
   totalHits += bandCounter[i];
   }
   println("totalHits: " + totalHits);
   
   int maxHits = 0;
   for (int i = 0; i < bandCounter.length; i++) {
   if (bandCounter[i] > maxHits) {
   maxHits = bandCounter[i];
   }
   }
   println("maxHits: " + maxHits);
   
   int medianHits = totalHits/bandCounter.length;
   println("medianHits: " + medianHits);
   */

  ArrayList<Integer> bestBands = new ArrayList<Integer>();
  for (int i = 0; i<nodeCount; i++) {
    int record = 0;
    int recordIndex = 0;
    for (int j = 0; j < bandCounter.length; j++) {
      //println("counters[" + j + "] = " + counters.get(j));
      if (!bestBands.contains(j) && bandCounter[j] > record) {
        record = bandCounter[j];
        recordIndex = j;
      }
    }
    //println("bestIndex: " + recordIndex);
    bestBands.add(recordIndex);
  }

  for (int i = 0; i < bestBands.size(); i++) {
    nodes[i] = new Node(bestBands.get(i));
    totalNodesMadeCounter[bestBands.get(i)]++;
    //println("Made node for band " + bestBands.get(i));
  }
  writeTotalNodesMadeToFile();
  makeNodeConnections();
}

public void makeNodeConnections() {
  for (int i = 0; i<nodes.length; i++) {
    float oldRecord = 0;
    for (int j = 0; j<nodes[i].connections.length; j++) {
      float record = 10000;
      int recordIndex = 0;
      for (int h = 0; h<nodes.length; h++) {
        float distance = dist(nodes[i].pos.x, nodes[i].pos.y, nodes[h].pos.x, nodes[h].pos.y);
        if (distance < record && distance > oldRecord) {
          record = distance;
          recordIndex = h;
        }
      }
      oldRecord = record;
      nodes[i].addConnection(j, nodes[recordIndex]);
    }
  }
}

public void writeTotalNodesMadeToFile() {
  String[] list = new String[totalNodesMadeCounter.length];
  for (int i = 0; i < totalNodesMadeCounter.length; i++) {
    list[i] = (i+ " : " + totalNodesMadeCounter[i]);
  }
  saveStrings("totalNodesMadeCounter.txt", list);
}

class ParticleSystem {
  ArrayList<particle> particles;
  float dragfac;

  ParticleSystem() {
    particles = new ArrayList<particle>();
    dragfac = 0.005f;
  }

  public void addParticleSystem(int num, float dir, PVector origin, boolean radial) {
    for (int i = 0; i<num; i++) {
      particle p;
      float angle = 0;
      PVector posOffset = new PVector(random(-10, 10), random(-FFTdify/2, FFTdify/2));
      if (radial) {
        angle = random(0, TWO_PI);
        PVector tmpDir = PVector.fromAngle(angle);
        tmpDir.setMag(random(0, 20));
        posOffset = tmpDir;
      }
      p = new particle(origin.copy().add(posOffset), angle, dir);
      addParticle(p);
    }
  }

  public void addParticle(particle p) {
    particles.add(p);
  }

  public ArrayList<particle> getParticlesAtRange(PVector posIn, float range, int thres) {
    ArrayList<particle> parts = new ArrayList<particle>();
    for (particle p : particles) {
      float dist = dist(p.pos.x, p.pos.y, posIn.x, posIn.y);
      if (dist > range-thres && dist < range+thres) {
        parts.add(p);
      }
    }
    return parts;
  }

  public void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}


class particle {

  PVector pos;
  PVector ppos;
  PVector vel;
  PVector acc;

  int lifespan;

  PVector drag;

  boolean hitByShockwave;

  particle(PVector p, float a, float d) {
    pos = p.copy();
    //vel = new PVector(d*3, random(-0.05, 0.05)+moveDir);
    float angle = a+random(-0.05f, 0.05f);
    vel = PVector.fromAngle(angle);
    vel.setMag(d*1.8f+d*random(0,1.5f));
    acc = new PVector(0, 0);

    hitByShockwave = false;

    ppos = pos.copy();
    lifespan = PApplet.parseInt(random(200, 500)*PApplet.parseInt(random(1.0f, 2.01f)));
  }

  public void run() {
    update();
    display();
  }

  public void display() {
    //stroke(abs(vel.x*255),0,abs(vel.y*255),40);
    //point(pos.x, pos.y);
    float bandValue = heightToFTTVal(pos.y-FFTdify/2);
    float bonusFlash = 0;
    if (hitByShockwave) {
      bonusFlash = 0.3f;
    }
    float flashFac = constrain((bandValue/70) + bonusFlash, 0.4f, 2.5f);
    float r = abs(vel.x)*100+flashFac*40;
    float g = 255-abs(vel.x)*60+flashFac*60;
    float b = abs(vel.y)*400+flashFac*80;
    float a = constrain(lifespan*flashFac, 0, 255);
    fxVisCanvas.stroke(r, g, b, a);
    fxVisCanvas.line(pos.x, pos.y, ppos.x, ppos.y);
  }

  public void updatePpos() {
    ppos = pos.copy();
  }

  public void update() {
    lifespan -= 2;
    updatePpos();

    drag = vel.copy();
    drag.setMag(particleSystem.dragfac*vel.mag());

    float angle = noise(pos.x/4, pos.y/4, t) * TWO_PI * 4;
    PVector noiseVec = PVector.fromAngle(angle);
    noiseVec.setMag(0.03f); 
    acc.add(noiseVec);

    vel.add(acc);
    vel.sub(drag);
    pos.add(vel.copy().mult(1+globalMoveSpeedMod));

    acc = new PVector(0, 0);
  }

  public void applyForce(PVector f) {
    acc.add(f);
  }

  public boolean isDead() {
    return (lifespan < 0);
  }
}
class ShockwaveSystem {
  ArrayList<shockwave> shockwaves;

  ShockwaveSystem() {
    shockwaves = new ArrayList<shockwave>();
  }

  public void addShockwave(shockwave p) {
    shockwaves.add(p);
  }

  public void run() {
    for (int i = shockwaves.size()-1; i >= 0; i--) {
      shockwave p = shockwaves.get(i);
      p.run();
      if (p.isDead()) {
        shockwaves.remove(i);
      }
    }
  }
}


class shockwave {

  PVector pos;

  int lifetime;
  int lifespan;

  int speed;

  float curRad;

  float strength;

  boolean pullIn;

  shockwave(PVector p, int sp, int dur, float sB, boolean pI) {
    pos = p.copy();
    speed = sp;
    lifespan = dur;
    pullIn = pI;

    lifetime = lifespan;
    curRad = 0;
    strength = 1+sB;
  }

  public void run() {
    update();
    //display();
    //coolDisplay();
  }

  public void display() {
    noFill();
    stroke(255, 0, 0, map(lifetime, lifespan, 0, 250, 0));
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, curRad, curRad);
  }

  public void update() {
    lifetime--;
    curRad = (lifespan-lifetime)*speed;
    applyForceToParticles();
  }

  public void applyForceToParticles() {
    ArrayList<particle> parts = new ArrayList<particle>();

    parts = particleSystem.getParticlesAtRange(pos, curRad/2, speed/2);

    float curMag = map(lifetime, lifespan, 0, strength, 0);
    for (particle p : parts) {
      if (!p.hitByShockwave) {
        p.hitByShockwave = true;
        PVector normal = p.pos.copy().sub(pos);
        if (pullIn) {
          normal = pos.copy().sub(p.pos);
        } 
        normal.setMag(curMag);

        p.applyForce(normal);
      }
    }
  }

  public void coolDisplay() {
    int iters = floor(curRad*0.15f);
    float radStep = TWO_PI/iters;
    for (int i = 0; i < iters; i++) {
      float curAngle = radStep*i;
      PVector curPos = getPositionOnCircle(pos, curRad/2, curAngle);
      fill(255, 0, 0, map(lifetime, lifespan, 0, 30, 0));
      noStroke();
      ellipseMode(CENTER);
      ellipse(curPos.x, curPos.y, 20, 20);
    }
  }

  private PVector getPositionOnCircle(PVector center, float radius, float rad) {
    PVector p = new PVector((float) (center.x + radius * cos(rad)), (float) (center.y + radius* sin(rad)));
    return p;
  }

  public boolean isDead() {
    return (lifetime < 0 || curRad > width);
  }
}
  public void settings() {  fullScreen(P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MusicPlayerV18" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
