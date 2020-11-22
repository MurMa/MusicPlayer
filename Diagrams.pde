import java.util.concurrent.ExecutorService; 
import java.util.concurrent.Executors; 
import java.util.concurrent.ThreadPoolExecutor;

ThreadPoolExecutor calcAllDiagramsExecutor;
Thread songDiagramLoadThread;
volatile boolean calculatingSpectra = false;
volatile boolean spectraNeedsReload = false;

// Maximum number of threads in thread pool 
static final int MAX_T = 16;

volatile int songDiagramsCalculated = 0;
volatile float[] threadProgress = new float[MAX_T];


public void calcAllSongDiagrams() {
  isCalculating = true;
  songDiagramsCalculated = 0;

  for(int i = 0; i<MAX_T; i++){
    threadProgress[i] = -1;
  }

  // creates a thread pool with MAX_T no. of  
  // threads as the fixed pool size
  ExecutorService executor = Executors.newFixedThreadPool(MAX_T);
  calcAllDiagramsExecutor = (ThreadPoolExecutor) executor;

  for (int pos = 0; pos < filenames.length; pos++) {
    executor.submit(new CalcSongDiagrammThread(filenames[pos]));
  }
  executor.shutdown();
}

public class CalcSongDiagrammThread implements Runnable {

  private String filename;
  private float progress;
  private int index;

  public CalcSongDiagrammThread(String filename) {
    this.filename = filename;
    this.progress = 0;
    this.index = -1;
  }

  public void setProgress(float p) {
    this.progress = p;
    if (this.index == -1) {
      String[] nameParts = Thread.currentThread().getName().split("-");
      if (nameParts.length == 4) {
        int index = Integer.parseInt(nameParts[3]);
        if (index > 0 && index < MAX_T) {
          this.index = index;
          threadProgress[this.index] = this.progress;
        }
      }
    } else {
      threadProgress[this.index] = this.progress;
    }
  }

  public float getProgress() {
    return this.progress;
  }

  @Override
    public void run() {
    try {
      println("[" + Thread.currentThread().getName() + "] Starting CalcSongDiagrammThread for file '" + filename + "'");
      if (loadBytes(savefilespath + filename + ".dat") == null || ignoreExistingData) {
        byte[] bytes = calcSongDiagram(filename, this);
        if (bytes != null) {
          saveBytes(savefilespath + filename + ".dat", bytes);
        } else {
          println("[" + Thread.currentThread().getName() + "] songDiagram calculation failed for file '" + filename + "'");
        }
      } else {
        println("[" + Thread.currentThread().getName() + "] File already exists!");
      }
    }
    catch(Exception e) 
    { 
      println("[" + Thread.currentThread().getName() + "] Exception in CalcSongDiagrammThread : ");
      e.printStackTrace();
    } 
    finally {
      println("[" + Thread.currentThread().getName() + "] CalcSongDiagrammThread for file '" + filename + "' is done!");
      songDiagramsCalculated++;
      if (this.index != -1) {
        threadProgress[this.index] = -1;
      }
    }
  }
}

// void calcAllDiagrams(final int pos) {
//   songDiagramLoadThread = new Thread() {
//     @Override
//       public void run() {

//       goalDiagramscale = 0;
//       if (!calculatingSpectra) {
//         calculatingSpectra = true;
//         goalDiagramscale = 0;
//         println("Analysing file " + pos);

//         if (loadBytes(savefilespath + filenames[pos] + ".dat") == null || ignoreExistingData) {
//           byte[] bytes = calcSongDiagram(filenames[pos]);
//           saveBytes(savefilespath + filenames[pos] + ".dat", bytes);
//         } else {
//           println("File already exists!");
//         }
//         calculatingSpectra = false;

//         progress = int(map(pos, 0, filenames.length, 0, 680));
//       } else {
//         println("There is already a calculation in progress, aborting");
//         return;
//       }
//     }
//   };
//   songDiagramLoadThread.start();
// }




void loadSongDiagram(final String myfile) {
  if (isCalculating) {
    println("Currently calculating, cannot load SongDiagram");
    return;
  }
  if (songDiagramLoadThread != null) {
    songDiagramLoadThread.interrupt();
  }
  songDiagramLoadThread = new Thread() {
    @Override
      public void run() {
      println("Loading Diagram for " + myfile);
      goalDiagramscale = 0;
      if (!calculatingSpectra) {
        calculatingSpectra = true;
        spectraNeedsReload = false;
      } else {
        println("There is already a calculation in progress, aborting");
        spectraNeedsReload = true;
        return;
      }
      try {
        if (loadBytes(savefilespath + myfile + ".dat") == null) {
          calcSongDiagramLive(myfile);
        } else {
          Thread.sleep(300);
          spectra = loadBytes(savefilespath + myfile + ".dat");
          //printArray(spectra);
          float diagramwidth = width - width / 10;
          difx = diagramwidth / spectra.length;
          //println("Difx: " + difx);
        }
        calculatingSpectra = false;
        goalDiagramscale = 1.5;
        for (int i = 0; i < spectra.length; i++) {
          while (spectra[i] * goalDiagramscale>80) {
            goalDiagramscale = goalDiagramscale - 0.1;
          }
        }
      }
      catch(InterruptedException e) {
        println("loading songDiagram got interrupted");
      } 
      catch(Exception e) {
        println("Exception when loading songDiagram : ");
        e.printStackTrace();
      }
      finally {
        calculatingSpectra = false;
      }
    }
  };
  songDiagramLoadThread.start();
}



public byte[] calcSongDiagram(String myfile, CalcSongDiagrammThread thread) {
  // println("-----------------------------------------------");
  // println("Calculating Song Diagram");
  thread.setProgress(0);
  int oldmillis = millis();

  int chunkStartIndex;
  int chunkSize;

  AudioPlayer tempplayer = minim.loadFile(mypath + myfile);
  if (tempplayer == null) {
    println("Could not load song " + mypath + myfile + " when calculating song diagram");
    return null;
  }

  println("Tempplayer loaded after " + (millis() - oldmillis) + " ms");
  if (tempplayer.length()>20000000 || tempplayer.length() < 0) { //tempplayer.length()>2000000
    println("FILE TOO BIG OR ZERO, CLOSING!");
    println("-----------------------------------------------");
    tempplayer.close();
    return null;
  }
  tempplayer.close();

  int s = 1; //stretching samples

  // println("Attempting to load " + myfile);
  AudioSample jingle = minim.loadSample(mypath + myfile);
  // println("File loaded after " + (millis()-oldmillis) + " ms");
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  // println("filelength: " + leftChannel.length);

  int fftSize = 1024;

  int totalChunks = (leftChannel.length / (fftSize * s)) + 1;
  // println("Chunks: " + totalChunks);

  while (totalChunks>190) {
    fftSize = fftSize * 2;
    totalChunks = (leftChannel.length / (fftSize * s)) + 1;
    //println("NEWChunks: " + totalChunks);
    //println("NEWFFTSize: " + fftSize);
  }

  byte[] bytes = new byte[totalChunks];
  goalDiagramscale = 0.1;
  float diagramwidth = width - width / 10;
  difx = diagramwidth / bytes.length;

  float[] fftSamples = new float[fftSize];// then we create an array we'll copy sample data into for the FFT object
  FFT fft = new FFT(fftSize, jingle.sampleRate());

  println("Starting analysis after " + (millis() - oldmillis) + " ms");
  int lastPercent = - 1;
  for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx) {

    chunkStartIndex = chunkIdx * fftSize * s;

    chunkSize = min(leftChannel.length - chunkStartIndex, fftSize);    // the chunk size will always be fftSize, except for the last chunk, which will be however many samples are left in source

    System.arraycopy(leftChannel, chunkStartIndex, fftSamples, 0, chunkSize);// copy first chunk into our analysis array

    if (chunkSize < fftSize) {
      java.util.Arrays.fill(fftSamples, chunkSize, fftSamples.length - 1, 0.0); // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes
    }

    fft.forward(fftSamples);

    bytes[chunkIdx] = byte(constrain(fft.calcAvg(0, jingle.bufferSize()) / 5, 0, 128));

    float percent = chunkIdx * 100.0 / totalChunks;
    thread.setProgress(percent);

    //println("float[" + chunkIdx + "]: " + (fft.calcAvg(0, jingle.bufferSize())/4.5)  );
    //println("byte[" + chunkIdx + "]: " + bytes[chunkIdx]);
  }
  //printArray(bytes);
  jingle.close();
  println("Finished after " + (millis() - oldmillis) + " ms");
  // println("byteslength: " + bytes.length);
  // println("DifX: " + difx);
  // println("Writing File: " + myfile + ".dat");

  // println("-----------------------------------------------");
  return bytes;
}


void calcSongDiagramLive(String myfile) {
  println("-----------------------------------------------");
  // println("Calculating Song Diagram");
  int oldmillis = millis();

  int chunkStartIndex;
  int chunkSize;


  AudioPlayer tempplayer = minim.loadFile(mypath + myfile);
  if (tempplayer == null) {
    println("Could not load song " + mypath + myfile + " when calculating song diagram");
    return;
  }

  println("Tempplayer loaded after " + (millis() - oldmillis) + " ms");
  if (tempplayer.length()>20000000 || tempplayer.length() < 0) { //tempplayer.length()>2000000
    println("FILE TOO BIG OR ZERO, CLOSING!");
    println("-----------------------------------------------");
    spectra = new byte[0];
    tempplayer.close();
    return;
  }
  tempplayer.close();


  int s = 1; //stretching samples

  // println("Attempting to load " + myfile);
  AudioSample jingle = minim.loadSample(mypath + myfile);
  // println("File loaded after " + (millis()-oldmillis) + " ms");
  float[] leftChannel = jingle.getChannel(AudioSample.LEFT);
  // println("filelength: " + leftChannel.length);

  int fftSize = 1024;

  int totalChunks = (leftChannel.length / (fftSize * s)) + 1;
  // println("Chunks: " + totalChunks);

  while (totalChunks>190) {
    fftSize = fftSize * 2;
    totalChunks = (leftChannel.length / (fftSize * s)) + 1;
    //println("NEWChunks: " + totalChunks);
    //println("NEWFFTSize: " + fftSize);
  }

  spectra = new byte[totalChunks];
  goalDiagramscale = 0.1;
  float diagramwidth = width - width / 10;
  difx = diagramwidth / spectra.length;

  float[] fftSamples = new float[fftSize];// then we create an array we'll copy sample data into for the FFT object
  FFT fft = new FFT(fftSize, jingle.sampleRate());

  println("Starting analysis after " + (millis() - oldmillis) + " ms");
  int lastPercent = - 1;
  for (int chunkIdx = 0; chunkIdx < totalChunks; ++chunkIdx) {

    chunkStartIndex = chunkIdx * fftSize * s;

    chunkSize = min(leftChannel.length - chunkStartIndex, fftSize);    // the chunk size will always be fftSize, except for the last chunk, which will be however many samples are left in source

    System.arraycopy(leftChannel, chunkStartIndex, fftSamples, 0, chunkSize);// copy first chunk into our analysis array

    if (chunkSize < fftSize) {
      java.util.Arrays.fill(fftSamples, chunkSize, fftSamples.length - 1, 0.0); // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes
    }

    fft.forward(fftSamples);

    spectra[chunkIdx] = byte(constrain(fft.calcAvg(0, jingle.bufferSize()) / 5, 0, 128));

    int percentDone = int(chunkIdx * 100.0 / totalChunks);
    if (percentDone != lastPercent && percentDone % 10 == 0) {
      lastPercent = percentDone;
      println("Analysis at " + percentDone + " % ");
    }

    //println("float[" + chunkIdx + "]: " + (fft.calcAvg(0, jingle.bufferSize())/4.5)  );
    //println("byte[" + chunkIdx + "]: " + spectra[chunkIdx]);
  }
  //printArray(spectra);
  jingle.close();
  println("Finished after " + (millis() - oldmillis) + " ms");
  // println("spectralength: " + spectra.length);
  // println("DifX: " + difx);
  // println("Writing File: " + myfile + ".dat");

  saveBytes(savefilespath + myfile + ".dat", spectra);

  println("-----------------------------------------------");
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void renderSongDiagram() {
  if (curDiagramscale < goalDiagramscale) {
    curDiagramscale += 0.1;
    if (curDiagramscale > goalDiagramscale) {
      curDiagramscale = goalDiagramscale;
    }
  } else if (curDiagramscale > goalDiagramscale) {
    curDiagramscale -= 0.1;
    if (curDiagramscale < goalDiagramscale) {
      curDiagramscale = goalDiagramscale;
    }
  }
  if (spectra != null && spectra.length > 0) {
    rectMode(CORNER);

    strokeWeight(1);
    float a;
    float dist;
    float curpos = map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length);
    for (int i = 0; i < spectra.length; i++) {

      dist = curpos - i + 0.5;
      a = constrain(dist * 210, mina, maxa);
      //float dist = dist(i , 500 , map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length) , 500);
      //float a = 255 - constrain( dist*20 , 0 , 255) + mina;

      fill(DiagramColor, a); 
      stroke(0);
      rect(int(i * difx + diagramX), diagramY, 5, - spectra[i] * curDiagramscale);
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




void RenderFFT() {
  rectMode(CENTER);
  FFToldvalues = Arrays.copyOf(FFTvalues, FFTvalues.length);
  fft.forward(player.mix);

  strokeWeight(1);
  color c;

  for (int i = 0; i < FFTbars; i++) {
    c = color(FFTColor);
    if (FFTHighlights) {
      if (fft.getBand(i) - 180 > 0) {
        c = FFTHighlight1;
      } else if (i > 6 && fft.getBand(i) > fft.getBand(i + 1) && fft.getBand(i) > fft.getBand(i - 1) && fft.getBand(i) > 60) {
        c = FFTHighlight2;
      }
    }

    stroke(0);
    fill(c, 100 + constrain((fft.getBand(i) - 5) * 1.2, 0, 155));

    float change = fft.getBand(i) - FFToldvalues[i];
    FFTvalues[i] = int(FFTvalues[i] + change * 0.25);

    //line(int(i*FFTdifx+20), 720, int(i*FFTdifx+20), -fft.getBand(i)+720);
    rect(int(i * FFTdifx + FFTX), FFTY, 14, constrain(FFTvalues[i] * 1.5, 0, 250));
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
