
void drawPerlinLine(float time, float phaseDif, int innerRad, int outerRad, color col, float jitter, int offset) {
  float p1 = map(noise(lineTime*10+offset), 0.2, 0.7, -1, 1);
  fxVisCanvas.strokeWeight(1);
  drawLine(time, phaseDif+p1*jitter, innerRad, outerRad, col);
}

void changePhaseDif() {
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

void fadePhaseDif() {
  float bonusSpeed = lastSecVol*0.000000004;
  float fadeSpeed = 0.0010+bonusSpeed;
  if (linePhaseFadePos > 1 && linePhaseFadePos != 10) {
    linePhaseFadePos = 10;
    linePhaseDif = targetPhaseDif;
  } else if (linePhaseFadePos<1-fadeSpeed) {
    linePhaseFadePos += fadeSpeed;
    linePhaseDif = lerp(lastPhaseDif, targetPhaseDif, linePhaseFadePos);
  }
}

void fadeLineSpeed() {
  float bonusSpeed = lastSecVol*0.000000001;
  float fadeSpeed = 0.0000005+bonusSpeed;
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
void drawLine(float time, float phaseDif, int innerRad, int outerRad, color col) {
  float x1 = cos(time)*innerRad;
  float y1 = sin(time)*innerRad;
  float x2 = cos(time-phaseDif)*outerRad;
  float y2 = sin(time-phaseDif)*outerRad;
  fxVisCanvas.stroke(col);
  fxVisCanvas.line(width/2+x2, height/2+y2, width/2+x1, height/2+y1);
}

//Bunch of laser lines
void drawLines() {
  fadePhaseDif();
  fadeLineSpeed();

  float bonusSpeed = lastSecVol*0.00000002;
  targetLineSpeed = 0.001+bonusSpeed;
  lineTime += lineSpeed;
  int innerRad = 80;
  int outerRad = height+200;

  float bonusFac = lastSecVol*0.000002;
  //println(bonusFac);
  float stren = FFTvaluesVis[1];
  float flashFac = constrain((stren/100)+bonusFac, 0.25, 2);
  float r1 = 20+flashFac*30;
  float g1 = 80+flashFac*20;
  float b1 = 200+flashFac*25;
  float r2 = 20+flashFac*60;
  float g2 = 80+flashFac*40;
  float b2 = 200+flashFac*25;
  float a1 = constrain(flashFac*130, 0, 255);
  float a2 = a1*a1*0.0035;

  color col = color(r1, g1, b1, a1);
  color col2 = color(r2, g2, b2, a2);

  float jitter = flashFac*0.01;
  float p1 = map(noise(lineTime*30), 0.2, 0.7, -1, 1);
  float p2 =  map(noise(lineTime*30+5), 0.2, 0.7, -1, 1);
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
  drawEllipseFade(new PVector(width/2, height/2), 1200, 40, color(0, 20));
}

void drawEllipseFade(PVector o, float size, int steps, color col) {
  fxVisCanvas.ellipseMode(CENTER);
  PVector origin = o.copy();
  fxVisCanvas.fill(col);
  fxVisCanvas.noStroke();
  float dif = size / steps;
  for (int i = 0; i<steps; i++) {
    fxVisCanvas.ellipse(origin.x, origin.y, i*dif, i*dif);
  }
}

void drawLight(PVector o, int amount) {
  fxVisCanvas.ellipseMode(CENTER);
  PVector origin = o.copy();
  amount = int(constrain(amount*1.4, 0, 60));
  fxVisCanvas.fill(50+amount*amount/18, 200-amount*amount/18, amount+50, 120-constrain(amount*2, 0, 119));
  fxVisCanvas.noStroke();
  for (int i = 0; i< amount; i++) {
    fxVisCanvas.ellipse(origin.x, origin.y, i*i/6, i*i/65);
    fxVisCanvas.ellipse(origin.x, origin.y, i*i/5, i/9);
  }
}

void drawLightning(PVector o, int amount) {
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

void RenderLights() {
  for (int i = 0; i<FFTbarsVis; i++) {
    int amount = constrain(int(FFTvaluesVis[i]/2)-10, 0, 400);
    if (amount > 0) {
      PVector pos = new PVector(width-FFTXVis, height-FFTYVis-i*FFTdify);
      drawLight(pos, amount);
    }
  }
}

void RenderLightning() {
  for (int i = 0; i<FFTbarsVis; i++) {
    drawLightning(new PVector(FFTXVis, height-FFTYVis-i*FFTdify), constrain(int(FFTvaluesVis[i]/2)-20, 0, 100));
  }
}
