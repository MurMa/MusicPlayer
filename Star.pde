// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/17WoOqgXsRM

// I create a "Star" Class.
class Star {
  float x;
  float y;
  float z;
  float pz;

  Star() {
    x = random(-width/2, width/2);
    y = random(-height/2, height/2);
    z = random(width/2);
    pz = z;
  }

  void update() {
    z = z - sfSpeed;
    if (z < 1) {
      z = width/2;
      x = random(-width/2, width/2);
      y = random(-height/2, height/2);
      pz = z;
    }
    if (z > width/2) {
      z = 1;
      x = random(-width/2, width/2);
      y = random(-height/2, height/2);
      pz = z;
    }
  }

  void show() {
    float alpha = map(z, 0, width/2, 200, 0);
    fxVisCanvas.fill(alpha);
    fxVisCanvas.noStroke();

    float sx = map(x / z, 0, 1, 0, width/2);
    float sy = map(y / z, 0, 1, 0, height/2);

    float r = map(z, 0, width/2, 6, 0);
    fxVisCanvas.ellipse(sx, sy, r, r);

    float px = map(x / pz, 0, 1, 0, width/2);
    float py = map(y / pz, 0, 1, 0, height/2);

    pz = z;
    
    fxVisCanvas.stroke(alpha);
    fxVisCanvas.line(px, py, sx, sy);
  }
}
