import java.util.Arrays;

import ddf.minim.*;
import ddf.minim.analysis.*;

float[] FFTvaluesVis;
float[] FFToldvaluesVis;

boolean showFFTHighlights;

color FFTColorVis;
color FFTHighlight1Vis;
color FFTHighlight2Vis;


int FFTXVis;
int FFTYVis;
int FFTbarsVis;
float FFTdify;
float FFTsmooth;

float t;
float lineTime;
float linePhaseDif;
float linePhaseFadePos;
float lastPhaseDif;
float targetPhaseDif;

FFT fftVis;

PShader blur;
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

float iterCount;
float curSecVol;
float lastSecVol;

int bassStreakCounter;

boolean showLightning;
boolean showLights;
boolean fillBars;
boolean strokeBars;
boolean showParticles;

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

AudioInput liveIn;
boolean liveModeVis;

float[][] spectraVisualizer;
int[] bandCounter;
Node[] nodes;
int nodeCount;
float nodeSmooth;
int[] totalNodesMadeCounter;
int[] standardNodeBands;

void setupVisualizer() {

  colorMode(RGB, 255);

  lineTime = 0;
  linePhaseDif = 0;
  
  menuY = -100;

  totalVolume = 0;
  globalMoveSpeedMod = 0;

  lastSecVol = 0;
  curSecVol = 0;
  iterCount = 0;

  setBackgroundConsts();

  showLightning = false;
  showLights = true;
  fillBars = true;
  strokeBars = true;
  showFFTHighlights = true;
  showParticles = true;

  FFTbarsVis = 25;

  FFTvaluesVis = new float[FFTbarsVis];

  FFTColorVis = color(255, 255, 255);
  FFTHighlight1Vis = color(105, 205, 5);
  FFTHighlight2Vis = color(0, 190, 240); 

  FFTXVis = width/2;
  FFTYVis = 100;

  float FFTheight = height-FFTYVis*2;
  FFTdify = FFTheight/FFTbarsVis;

  FFTsmooth = 0.3;
  nodeSmooth = 0.5;

  // FFT-Instanz für die Spektrumsanalyse der beiden Kanäle
  fftVis = new FFT (player.bufferSize (), player.sampleRate ());

  RalewayS = createFont("Raleway", 12);
  RalewayM = createFont("Raleway", 20);
  RalewayL = createFont("Raleway", 36);
  textFont(RalewayM);

  PVector btnPos = new PVector(20, 25);
  int btnDX = width/40;
  int btnCount = 7;
  PVector btnDim = new PVector((width-btnDX*btnCount)/btnCount, 50);
  PVector btnCurpos = btnPos.copy();

  B6 = new MyButton(btnCurpos, btnDim, "Back", color(200), color(100));
  btnCurpos.add(new PVector(btnDim.x+btnDX, 0));
  B1 = new MyToggle(btnCurpos, btnDim, "FFT Highlights", showFFTHighlights, color(200, 255, 200), color(255, 200, 200));
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

  B1.setFont("Raleway", 24, true);
  B2.setFont("Raleway", 24, true);
  B3.setFont("Raleway", 24, true);
  B4.setFont("Raleway", 24, true);
  B5.setFont("Raleway", 24, true);
  B6.setFont("Raleway", 24, true);
  B7.setFont("Raleway", 24, true);

  particleSystem = new ParticleSystem();

  shockwaveSystem = new ShockwaveSystem();
  spawnShockwaveNextBeat = false;

  blur = loadShader("blur.glsl"); 

  float blurSteps = 50.0;
  float blurStrength = 190.0;

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

void visualizerCheckLiveMode() {
  if (liveModeVis) {
    liveIn = minim.getLineIn();
    fftVis = new FFT(liveIn.bufferSize(), liveIn.sampleRate());
  } else {
    fftVis = new FFT (player.bufferSize(), player.sampleRate());
  }
  visualizerAnalyseSong();
}

void visualizerAnalyseSong() {
  if (!liveModeVis) {
    analyzeUsingAudioSample();
    calculateBandCounts();
    makeNodes();
  } else {
    makeStandardNodes();
  }
}

void drawVisualizer() {
  //background(0);
  rectMode(CORNER);
  ellipseMode(CENTER);
  fill(0, 150);
  noStroke();
  rect(0, 0, width, height);
  t += 0.01;

  CalculateFFT();

  drawBackground();
  drawLines();

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

  ellipseMode(CENTER);
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

  textAlign(CORNER);
  fill(255);
  textFont(RalewayS);
  text(frameRate, 10, 20);
  text(partcount, 10, 40);
  text(bassStreakCounter, 10, 60);
}


float heightToFTTVal(float posY) {
  int index = floor(map(constrain(posY, FFTYVis, height-FFTYVis), FFTYVis, height-FFTYVis, FFTbarsVis, 0));
  index = constrain(index, 0, FFTbarsVis-1);
  return FFTvaluesVis[index];
}

void detectMoodChange() {
  iterCount++;
  if (iterCount > 80) {
    iterCount = 0;
    float change = curSecVol - lastSecVol;
    //println("change to last sec: " + change);
    if (abs(change) > 75000) {
      changePhaseDif();
    }
    if (abs(change) > 100000) {
      changeColorScheme();
    }
    if (abs(change) > 140000) {
      spawnShockwaveNextBeat = true;
    }
    lastSecVol = curSecVol;
    curSecVol = 0;
  }
}

void checkShockwave() {
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
        if (random(1) < 0.2) { //in 1/5 of cases spawn another shockwave that starts from a node
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

void checkBassStreak() {
  int minVal = 200;
  int minStreak = 40;
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

void checkSpawnShockwaveStrongHit(float change, int index) {
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

void CalculateFFT() {
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


void RenderFFTVis() {
  rectMode(CENTER);
  //noStroke();
  //noFill();
  if (!strokeBars) {
    noStroke();
  }
  strokeWeight(1);
  color c;

  totalVolume = 0;
  bassVolume = 0;

  for (int i = 0; i<FFTbarsVis; i++) {
    float val = FFTvaluesVis[i];
    c = color(FFTColorVis);

    if (i > 0 && i < 4) {
      bassVolume += val;
    }
    totalVolume += val*map(i, 0, 60, 8, 0.5);

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
      fill(c, 20+constrain((val-5)*0.7, 0, 200));
      if (strokeBars) {
        stroke(c, 40+constrain((val-5)*0.6, 0, 200));
      }
    } else {
      noFill();
      if (strokeBars) {
        stroke(c, 60+constrain((val-5)*1.2, 0, 190));
      }
    }

    rect(FFTXVis, height-FFTYVis-i*FFTdify, constrain(FFTvaluesVis[i]*2, 0, 600), FFTdify);
  }

  globalMoveSpeedMod = bassVolume/500;
  curSecVol += totalVolume;
}


void analyzeUsingAudioSample()
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
      java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 );
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

void calculateBandCounts() {
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

boolean isAHit(float curVal, float lastVal, float nextVal) {
  return curVal > valThreshold && curVal > lastVal && curVal > nextVal;
}

boolean isAHit(float curVal, float otherVal) {
  return curVal > valThreshold && curVal > otherVal;
}

float bonusHitDif = 1.8;

boolean isABonusHit(float curVal, float lastVal, float nextVal) {
  return curVal > valThreshold && curVal > lastVal*bonusHitDif && curVal > nextVal*bonusHitDif;
}
boolean isABonusHit(float curVal, float otherVal) {
  return curVal > valThreshold && curVal > otherVal*bonusHitDif;
}

void makeStandardNodes() {
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

void makeNodes() {  
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

void makeNodeConnections() {
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

void writeTotalNodesMadeToFile() {
  String[] list = new String[totalNodesMadeCounter.length];
  for (int i = 0; i < totalNodesMadeCounter.length; i++) {
    list[i] = (i+ " : " + totalNodesMadeCounter[i]);
  }
  saveStrings("totalNodesMadeCounter.txt", list);
}
