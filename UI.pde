void mouseReleased() {
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
        showStarfield = B10.toggle();
      }
      if (B11.MouseOverButton()) {
        showPostFx = B11.toggle();
      }
    }
  }
}

void keyReleased() {
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

void drawMenu() {
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
    B11.run();

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

void showMenu() {
  if (menuY < 0) {
    menuY += 8;
  }
}


void hideMenu() {

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

  color btncolor;

  color colorAct = color(220);
  color colorDea = color(100);

  boolean output;

  String label;
  String secondLabel;

  boolean animations = true;
  float curLerpVal;

  boolean gradients = true;

  boolean disabled;

  PFont Font;

  MyButton(PVector s, PVector t, String l, color a, color d) {
    position = s.copy();
    dimensions = t.copy();
    CheckborderR = int(position.x+dimensions.x);
    CheckborderL = int(position.x);
    CheckborderU = int(position.y);
    CheckborderD = int(position.y+dimensions.y);
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
    CheckborderR = int(position.x+dimensions.x);
    CheckborderL = int(position.x);
    CheckborderU = int(position.y);
    CheckborderD = int(position.y+dimensions.y);
    btncolor = colorDea;
    label = l;
    disabled = false;
    secondLabel = "";
    standardFont();
    autoFontSize();
  }

  void setLabel(String s) {
    label = s;
  }

  void setSecondLabel(String s) {
    secondLabel = s;
  }

  void setDisabled(boolean s) {
    disabled = s;
  }

  void standardFont() {
    Font = createFont("Arial", 36);
  }

  void setFont(String name, int size, boolean autoSize) {
    Font = createFont(name, size);
    if (autoSize) {
      autoFontSize();
    }
  }

  void autoFontSize() {
    while (Font.getSize()*label.length()*0.7 > dimensions.x) {
      Font = createFont(Font.getName(), Font.getSize()-1);
    }
  }

  void run() {
    update();
    display();
  }

  void display() {
    menuVisCanvas.stroke(0);
    menuVisCanvas.strokeWeight(1);

    if (gradients) {
      menuVisCanvas.stroke(lerpColor(colorDea, color(0), 0.5));
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
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/3.4);
      menuVisCanvas.fill(0, 200);
      menuVisCanvas.text(secondLabel, position.x+dimensions.x/2, position.y+dimensions.y/1.6);
    } else {
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/2.4);
    }
  }

  void update() {
    if (!disabled) {
      if (animations) {
        if (MouseOverButton()) {
          if (curLerpVal < 1) {
            curLerpVal += 0.1;
            btncolor = lerpColor(colorDea, colorAct, curLerpVal);
          }
        } else if (curLerpVal > 0) {
          curLerpVal -= 0.1;
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

  boolean MouseOverButton() {
    return(mouseX > CheckborderL && mouseX < CheckborderR && mouseY > CheckborderU && mouseY < CheckborderD);
  }

  boolean clicked() {
    return(!disabled && MouseOverButton());
  }

  boolean pressed() {
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

  color btncolor;

  int alphaAct = 220;
  int alphaDea = 180;
  color colorAct = color(200, 255, 200);
  color colorDea = color(255, 200, 200);

  color fontColor = color(0);

  boolean value;

  boolean disabled;

  String label;
  String secondLabel;
  boolean labelOutside;

  PFont Font;

  MyToggle(PVector s, PVector t, String l, boolean val, color a, color d) {
    position = s.copy();
    dimensions = t.copy();
    CheckborderR = int(position.x+dimensions.x);
    CheckborderL = int(position.x);
    CheckborderU = int(position.y);
    CheckborderD = int(position.y+dimensions.y);
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

  void setLabel(String s) {
    label = s;
  }

  void setSecondLabel(String s) {
    secondLabel = s;
  }

  void setDisabled(boolean s) {
    disabled = s;
  }

  void standardFont() {
    Font = createFont("Arial", 36);
  }

  void setLabelOutside(boolean in) {
    labelOutside = in;
  }

  void setFont(String name, int size, boolean autoSize) {
    Font = createFont(name, size);
    if (autoSize) {
      autoFontSize();
    }
  }

  void setFontColor(color col) {
    fontColor = col;
  }

  void autoFontSize() {
    while (Font.getSize()*label.length()*0.7 > dimensions.x) {
      Font = createFont(Font.getName(), Font.getSize()-1);
    }
  }

  void run() {
    update();
    display();
  }

  void display() {
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
      menuVisCanvas.text(label, position.x+dimensions.x+20, position.y+dimensions.y/2.4);
    } else {
      menuVisCanvas.textAlign(CENTER, CENTER);
      menuVisCanvas.text(label, position.x+dimensions.x/2, position.y+dimensions.y/2.4);
    }
  }

  void update() {
    if (!disabled) {
      if (MouseOverButton()) {
        btnAlpha = alphaAct;
      } else {
        btnAlpha = alphaDea;
      }
    }
  }

  boolean toggle() {
    value = !value;
    return value;
  }

  boolean MouseOverButton() {
    return(mouseX > CheckborderL && mouseX < CheckborderR && mouseY > CheckborderU && mouseY < CheckborderD);
  }

  boolean clicked() {
    return(!disabled && MouseOverButton());
  }

  boolean pressed() {
    return (mousePressed == true && MouseOverButton());
  }
}
