
int gridSizeX;
int gridSizeY;

float gridDx;
float gridDy;

float rectDim;

float BgSmooth;

BackgroundNode bgNodes[][];

void setBackgroundConsts() {

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

  BgSmooth = 0.01;

  bgNodes = new BackgroundNode[gridSizeX][gridSizeY];

  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j] = new BackgroundNode(gridDx*i, gridDy*j, rectDim);
    }
  }
}


void drawBackground() {
  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j].run();
    }
  }
  filter(blurHor);
  filter(blurVert);
  rectMode(CORNER);
}

void setBackgroundColorsByIndex(int index) {
  backgroundVisCol = backgroundColors[index];
  fittingBackgroundVisCol = fittingBackgroundColors[index];
}

void changeColorSchemeRdm() {
  if (random(1) < 0.05) {
    changeColorScheme();
  }
}


void changeColorScheme() {
  //backgroundVisCol = color(150*rdm1, 150*rdm2, 150*rdm3);
  int rdm = floor(random(0, backgroundColors.length));
  setBackgroundColorsByIndex(rdm);
  for (int j = 0; j<gridSizeY; j++) {
    for (int i = 0; i<gridSizeX; i++) {
      bgNodes[i][j].setColorAndFadeTo(backgroundVisCol, 0.02);
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

  color curCol;
  color lastCol;
  color nextCol;

  BackgroundNode(float posXTmp, float posYTmp, float dimTmp) {
    posX = posXTmp;
    posY = posYTmp;
    dim = dimTmp;
    alpha = 0;
    flashFac = 0;
    oldFlashFac = flashFac;

    fadePos = 10;
    fadeSpeed = 0.05;
    curCol = color(0, 0, 255);
    nextCol = curCol;
  }

  void run() {
    update();
    display();
  }

  void update() {
    flashFac = 0;
    flashFac += constrain(heightToFTTVal(posY), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac += constrain(heightToFTTVal(posY+dim/2), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac += constrain(heightToFTTVal(posY+dim), 0, 255);//*(1-dist(posX, 0, 384, 0)/1536*1);
    flashFac =  constrain(flashFac*0.5, 40, 255);

    float change = flashFac-oldFlashFac;
    flashFac = int(flashFac+change*BgSmooth);
    oldFlashFac = flashFac;

    updateColor();

    //alpha = noise(posX*0.0008, posY*0.0002, t*0.1)*255.0;

    alpha = 100;

    //alpha = 255*(posX/width);

    //alpha = constrain(alpha,20,255);
  }

  void updateColor() {
    if (fadePos<1-fadeSpeed) {
      fadePos += fadeSpeed;
      curCol = lerpColor(lastCol, nextCol, fadePos);
    } else if (fadePos != 10) {
      fadePos = 10;
      curCol = nextCol;
    }
  }

  void display() {
    float r = (curCol >> 16) & 0xFF;  
    float g = (curCol >> 8) & 0xFF;   
    float b = curCol & 0xFF;
    float curBright = (flashFac/255)*(alpha/255);
    r *= curBright;
    g *= curBright;
    b *= curBright;
    fill(r, g, b, 170);
    noStroke();

    //rectMode(CORNER);
    //rect(posX, posY, dim, dim);

    ellipseMode(CORNER);
    ellipse(posX, posY, dim, dim);
  }

  void setColorAndFadeTo(color next, float speed) {
    lastCol = curCol;
    nextCol = next;
    fadeSpeed = speed;
    fadePos = 0;
  }

  void setAlpha(float in) {
    alpha = in;
  }
}
