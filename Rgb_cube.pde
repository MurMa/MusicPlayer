Serial rgbCubePort;  // Create object from Serial class

String portName; //change the 0 to a 1 or 2 etc. to match your port

void runRgbCube() {
  sendCubeData();
}

void setupRgbCube() {
  try {
    portName = Serial.list()[2];
    println("Trying to connect to cube on port: " + portName);
    rgbCubePort = new Serial(this, portName, 115200);
  }
  catch(Exception e) {
    println(e);
  }
}

void sendCubeData() {
  if(rgbCubePort == null){
    return;
  }

  int startIndex = 1;
  float add = 2.5;
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
