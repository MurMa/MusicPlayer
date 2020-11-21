// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/17WoOqgXsRM

Star[] stars = new Star[1000];

float sfSpeed;

void initializeStarfield() {

  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star();
  }
  sfSpeed = 0;
}


void drawStarfield() {
  fxVisCanvas.translate(halfwidth, halfheight);
  for (int i = 0; i < stars.length; i++) {
    stars[i].update();
    stars[i].show();
  }
  fxVisCanvas.translate(-halfwidth, -halfheight);
}
