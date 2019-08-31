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

  float getClosestDist() {
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

  PVector getNewPos() {
    int borderOutside = 200;
    int borderInside = 300;

    float x;
    if (random(1) < 0.5) {
      x  = random(borderOutside, width/2-borderInside);
    } else {
      x  = random(width/2+borderInside, width-borderOutside);
    }
    float bandHeight = height-FFTYVis-band*FFTdify;
    float y = bandHeight+random(-200, 200);
    y = constrain(y, borderOutside, height-borderOutside);

    return new PVector(x, y);
  }

  void run() {
    update();
    display();
  }

  void update() {
    size = val * (band/35+0.6) * 1.2;
    size = constrain(size, 0, 300);
    if (size > 60) {
      if (showParticles) {
        particleSystem.addParticleSystem(int(size/18), size/240, pos, true);
      }
    }
  }

  void display() {

    //stroke(255, 0, 0,20);
    //line(pos.x, pos.y, width/2, height-FFTYVis-band*FFTdify);

    for (int i = 0; i<connections.length; i++) {
      float combVal = ((val/10)*(connections[i].val/10))*0.1;
      fxVisCanvas.stroke(255, combVal*combVal);
      fxVisCanvas.line(pos.x, pos.y, connections[i].pos.x, connections[i].pos.y);
    }

    color c = color(FFTColorVis);
    if (colorNodes) {
      c = fittingBackgroundVisCol;
    }
    if (fillBars) {
      fxVisCanvas.fill(c, 0+constrain((val-5)*1.2, 0, 155));
      if (strokeBars) {
        fxVisCanvas.stroke(c, 0+constrain((val-5)*1.2, 0, 100));
      }
    } else {
      fxVisCanvas.noFill();
      if (strokeBars) {
        fxVisCanvas.stroke(c, 20+constrain((val-5)*1.2, 0, 100));
      }
    }

   fxVisCanvas.ellipse(pos.x, pos.y, size, size);
  }

  void addConnection(int index, Node n) {
    connections[index] = n;
  }

  void setVal(float set) {
    float change = set-val;
    val = val+change*nodeSmooth;
  }

  int getBand() {
    return band;
  }

  boolean isLeftSide() {
    return pos.x < width/2;
  }
}
