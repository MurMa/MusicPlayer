

void calcAllDiagrams(int pos) {
  println("Analysing file " + pos);

  if (loadBytes(savefilespath + filenames[pos] + ".dat") == null || ignoreExistingData) {
    calcSongDiagram(filenames[pos]);
    saveBytes(savefilespath + filenames[pos] + ".dat", spectra);
  } else {
    println("File already exists!");
  }

  progress = int(map(pos, 0, filenames.length, 0, 680));
}




void loadSongDiagram(final String myfile) {


  println("Loading Diagram for " + myfile);

  Thread t = new Thread(){
    @Override
    public void run(){

      if (loadBytes(savefilespath + myfile + ".dat") == null) {
        calcSongDiagram(myfile);
      } else {
        spectra = loadBytes(savefilespath + myfile + ".dat"); 
        //printArray(spectra);
        float diagramwidth = width-width/10;
        difx = diagramwidth/spectra.length;
        //println("Difx: " + difx);
        Diagramscale = 1.5;
        for (int i = 0; i<spectra.length; i++) {
          while (spectra[i]*Diagramscale>80) {
            Diagramscale = Diagramscale-0.1;
          }
        }
      }

    }
  };
  t.start();

}






void calcSongDiagram(String myfile) {
  println("-----------------------------------------------");
  println("Calculating Song Diagram");
  int oldmillis = millis();

  int chunkStartIndex;
  int chunkSize;


  AudioPlayer tempplayer = minim.loadFile(mypath + myfile);
  if (tempplayer == null) {
    println("Could not load song " + mypath + myfile + " when calculating song diagram");
    return;
  }

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
      java.util.Arrays.fill( fftSamples, chunkSize, fftSamples.length - 1, 0.0 ); // if the chunk was smaller than the fftSize, we need to pad the analysis buffer with zeroes
    }

    fft.forward( fftSamples );

    spectra[chunkIdx] = byte(fft.calcAvg(0, jingle.bufferSize())/5);

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


void renderSongDiagram() {
  if (spectra != null && spectra.length > 0) {
    rectMode(CORNER);

    strokeWeight(1);
    float a;
    float dist;
    float curpos = map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length);
    for (int i = 0; i<spectra.length; i++) {

      dist = curpos-i+0.5;
      a = constrain(dist*210, mina, maxa);
      //float dist = dist(i , 500 , map(cp5.getController("Position").getValue(), 0, possteps, 0, spectra.length) , 500);
      //float a = 255 - constrain( dist*20 , 0 , 255) + mina;

      fill(DiagramColor, a); 
      stroke(0);
      rect(int(i*difx+diagramX), diagramY, 5, -spectra[i]*Diagramscale);
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
    fill(c, 100+constrain((fft.getBand(i)-5)*1.2, 0, 155));

    float change = fft.getBand(i)-FFToldvalues[i];
    FFTvalues[i] = int(FFTvalues[i]+change*0.25);

    //line(int(i*FFTdifx+20), 720, int(i*FFTdifx+20), -fft.getBand(i)+720);
    rect(int(i*FFTdifx+FFTX), FFTY, 14, constrain(FFTvalues[i]*1.5, 0, 250));
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
