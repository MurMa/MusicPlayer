



void controlEvent(ControlEvent theControlEvent) {
  if (curTabIndex != 4 || (curTabIndex == 4 && B6 != null && B6.MouseOverButton())) {
    if (theControlEvent != null && theControlEvent.isTab()) {
      curTabIndex = theControlEvent.getTab().getId();
      switch(curTabIndex) {
      case 1: //SongList
        RenderDia = false;
        RenderFFT = false;
        BuQuit.moveTo(TabSonglist);
        menuSwitchMillis = millis();
        break;
      case 2: //Player
        RenderDia = true;
        if (CalcFFT) {
          RenderFFT = true;
        }
        BuQuit.moveTo(TabPlayer);
        menuSwitchMillis = millis();
        break;
      case 3: //Settings
        RenderDia = false;
        RenderFFT = false;
        BuQuit.moveTo(TabSettings);
        menuSwitchMillis = millis();
        break;
      case 4: //Visualizer        
        visualizerAnalyseSong();
        //visualizerCheckLiveMode();
        RenderDia = false;
        RenderFFT = false;
        menuSwitchMillis = millis();
        break;
      }
    }
    if (theControlEvent != null && theControlEvent.isFrom(CheckSettings2)) {
      float[]a = CheckSettings2.getArrayValue();
      if (a[0] == 1) {
        goIdle= true;
      } else {
        goIdle= false;
      }
      if (a[1] == 1) {
        goEco= true;
      } else {
        goEco= false;
      }
      println("Eco: " + goEco);
      println("Idle: " + goIdle);
      println("---");
    }
    if (theControlEvent != null && theControlEvent.isFrom(MyBGColorPicker)) {
      color col = MyBGColorPicker.getRGB();
      BGcolor = col;
      String[] temp = new String[1];
      temp[0] = hex(col);
      saveStrings("MyBackgroundColor.txt", temp);
    }

    if (GroupTheme.isVisible()) {
      if (theControlEvent != null && theControlEvent.isFrom(BackgroundCP) && theControlEvent.arrayValue().length == 4) {
        int r = int(theControlEvent.getArrayValue(0));
        int g = int(theControlEvent.getArrayValue(1));
        int b = int(theControlEvent.getArrayValue(2));
        int a = int(theControlEvent.getArrayValue(3));
        color col = color(r, g, b, a);
        CBackground = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorBackground(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(ForegroundCP) && theControlEvent.arrayValue().length == 4) {
        int r = int(theControlEvent.getArrayValue(0));
        int g = int(theControlEvent.getArrayValue(1));
        int b = int(theControlEvent.getArrayValue(2));
        int a = int(theControlEvent.getArrayValue(3));
        color col = color(r, g, b, a);
        CForeground = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorForeground(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(ActiveCP) && theControlEvent.arrayValue().length == 4) {
        int r = int(theControlEvent.getArrayValue(0));
        int g = int(theControlEvent.getArrayValue(1));
        int b = int(theControlEvent.getArrayValue(2));
        int a = int(theControlEvent.getArrayValue(3));
        color col = color(r, g, b, a);
        CActive = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorActive(col);
        }
      }
      if (theControlEvent != null && theControlEvent.isFrom(LabelCP) && theControlEvent.arrayValue().length == 4) {
        int r = int(theControlEvent.getArrayValue(0));
        int g = int(theControlEvent.getArrayValue(1));
        int b = int(theControlEvent.getArrayValue(2));
        int a = int(theControlEvent.getArrayValue(3));
        color col = color(r, g, b, a);
        CLabel = col;
        if (SlThemeExample != null) {
          SlThemeExample.setColorLabel(col);
        }
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void Yes() {
  YNWindow.setVisible(false);
  if (TxtLQuestion.getStringValue() == "The Files in your directory have changed. Do you want to calculate the Diagrams now?") {
    savefilestatus();
    isCalculating = true;
    calcpos = 0;
    progress = 0;
    renderprogressbar(filenames[calcpos], calcpos + "/" + filenames.length);
    ListSongs.open();
  }
}

void No() {
  YNWindow.setVisible(false);
  if (TxtLQuestion.getStringValue() == "The Files in your directory have changed. Do you want to calculate the Diagrams now?") {
    savefilestatus();
    ListSongs.open();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void RandomSong() {
  filepos = int(random(0, filenames.length));
  if (filenames.length > filepos) {
    nameLoadSong(filenames[filepos]);
  }
}

void ShuffleSongs() {
  ArrayList<String> filenamesList = new ArrayList<String>();
  for (int i = 0; i<filenames.length; i++) {
    filenamesList.add(filenames[i]);
  }
  Collections.shuffle(filenamesList);
  for (int i = 0; i<filenames.length; i++) {
    filenames[i] = filenamesList.get(i);
  }
  NextSong();
}


void PlayPause(boolean value) {
  if (value) {
    Playing = true;
    player.play();
  } else {
    player.pause();
    Playing = false;
  }
}

void NextSong() {
  loadSong(true);
}

void LastSong() {
  loadSong(false);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void ChSettings(float[]a ) {
  if (a[0] == 1) {
    CalcDia= true;
    if (filenames.length > filepos) {
      loadSongDiagram(filenames[filepos]);
    }
  } else {
    CalcDia= false;
    spectra = new byte[0];
  }
  if (a[1] == 1) {
    CalcFFT = true;
  } else {
    CalcFFT = false;
  }
  if (a[2] == 1) {
    goOnlyFFT = true;
  } else {
    goOnlyFFT = false;
  }
}

void ChVisSettings(float[]a ) {
  if (a[0] == 1) {
    liveModeVis= true;
    visualizerCheckLiveMode();
  } else {
    liveModeVis= false;
    visualizerCheckLiveMode();
  }
}



void SaveSettings() {
  cp5.saveProperties("SavedSettings", "default");
}

void DefaultSettings() {
  cp5.loadProperties(("DefaultSettings"));
  cp5.saveProperties("SavedSettings", "default");
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void Idletime(float t) {
  idletime = int(t*1000);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void Search(String searchtext) {
  if (searchtext.length() > 0) {
    searchtext = searchtext.toUpperCase();
    println("SearchText: " + searchtext);
    ListSongs.setCaptionLabel("Results: ");
    SearchResults.clear();
    ListSongs.clear();
    for (int i = 0; i<filenames.length; i++) {
      if (Capsfilenames[i].indexOf(searchtext) > -1) {
        SearchResults.append(filenames[i]);
      }
    }
    listSearchResults();
    printArray("Search Results: " + SearchResults);
  } else {
    SearchResults.clear();
    ListSongs.clear();
    updateFilenames(filenames);
    ListSongs.setCaptionLabel("Your Songs: ");
  }
}

void ClearSearch() {
  TxtFSearch.clear();
  SearchResults.clear();
  ListSongs.clear();
  updateFilenames(filenames);
  ListSongs.setCaptionLabel("Your Songs: ");
}

void SongList(int Res) {
  if (SearchResults.size() > 0) {
    nameLoadSong(SearchResults.get(Res));
  } else {
    nameLoadSong(filenames[Res]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void Quit() {
  println("QUITTING!");
  player.close();
  minim.stop();
  super.stop();
  exit();
}



void ChangeDirectory() {
  selectFolder("Select a folder to process:", "folderSelected");
}



void Volume(float vol) {
  volume = vol;
  println("new Volume: " + volume);
  gain = int(map(volume, 0, 100, lowestGain, highestGain));
  player.shiftGain(player.getGain(), gain, 300);
}



void Position(int pos) {
  if (cp5.getController("Position").isMousePressed()) {
    if (cp5.getController("Position").isMouseOver()) {
      println("new Position: " + pos);
      int newposition = pos*posdivide;
      player.cue(newposition);
    }
  }
}

void CalcAllDia() {
  isCalculating = true;
  calcpos = 0;
  progress = 0;
  renderprogressbar(filenames[calcpos], calcpos + "/" + filenames.length);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

void Resolution(int Res) {

  if (resizeWindow) {

    String NewRes = resolutions[Res];
    String[] parts = NewRes.split("x");
    parts[0] = parts[0].substring(0, parts[0].length()-1);
    parts[1] = parts[1].substring(1, parts[1].length());
    resx = Integer.parseInt(parts[0]);
    resy = Integer.parseInt(parts[1]);
    println("New Resolution: " + resx + " x " + resy);
    if (resx != width && resy != height) {
      surface.setSize(resx, resy);
    }
    halfwidth = width/2;
    halfheight = height/2;

    cp5.getWindow().setPositionOfTabs(halfwidth-225, 20);

    BuPlayPause.setPosition(halfwidth-70, height-120);
    BuNextSong.setPosition(halfwidth-50+150, height-110);
    BuLastSong.setPosition(halfwidth-50-150, height-110);

    BuQuit.setPosition(width-100, 20);

    TxtLSongTitle.setPosition(halfwidth-100, height-320);
    CheckSettings.setPosition(halfwidth-300, 130);
    CheckSettings2.setPosition(halfwidth-110, height-150);

    TxtFSearch.setPosition(width-360, 80);
    ListSongs.setSize(width-100, height-160);
    BuClearSearch.setPosition(width-90, 85);

    GroupBG.setPosition(halfwidth-350, halfheight-250-10);
    GroupTheme.setPosition(halfwidth-350, halfheight-250-10);

    BackgroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40);
    ForegroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40+160);
    ActiveCP.setPosition(halfwidth-350+350, halfheight-250-10+40);
    LabelCP.setPosition(halfwidth-350+350, halfheight-250-10+40+160);

    MyBGColorPicker.setPosition(halfwidth-350+40, halfheight-250-10+40);

    SlIdleTime.setPosition(halfwidth-225, height-80);
    SlVolume.setPosition(width-130, 100);
    SlPosition.setPosition(width/20, height-200);
    SlPosition.setSize(width-width/10, 40); 
    SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
    TxtLSongTime.setPosition(width-220, height-140);  

    BuCalcAllDia.setPosition(halfwidth+50, 130);



    float diagramwidth = width-width/10;
    difx = diagramwidth/spectra.length;
    diagramX = width/20;
    diagramY = height-200;
    FFTX = width/20;
    FFTY = halfheight-100;
    float FFTwidth = width-FFTX*2;
    FFTdifx = FFTwidth/FFTbars;

    //println("Difx: " + difx);
  }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////

void BGWindow() {
  GroupBG.setVisible(true);
  MyBGColorPicker.setVisible(true);
  CheckSettings.setVisible(false);
  CheckSettings2.setVisible(false);
  BuCalcAllDia.setVisible(false);
}

void HideBGWindow() {
  GroupBG.setVisible(false);
  MyBGColorPicker.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
}

void UseWallpaper(boolean state) {
  if (state) {
    PathWallpaper = loadStrings("MyWallpaperPath.txt")[0];
    Wallpaper = loadImage(PathWallpaper);
    drawWallpaper = true;
  } else {
    drawWallpaper = false;
  }
}

void BGWallpaper() {
  selectInput("Select your wallpaper:", "WallpaperSelected");
}

void AnimBGList(int Res) {
  if (Res == 0) {
    animateBackground = false;
  } 
  if (Res == 1) {
    BGAnimation = 1;
    animateBackground = true;
  }
  if (Res == 2) {
    BGAnimation = 2;
    animateBackground = true;
  }
  if (Res == 3) {
    BGAnimation = 3;
    animateBackground = true;
  }
}


void NMode(boolean state) {
  if (state) {
    CForeground = unhex(loadStrings("ThemeRed.txt")[0]);
    CBackground = unhex(loadStrings("ThemeRed.txt")[1]);
    CActive = unhex(loadStrings("ThemeRed.txt")[2]);
    CLabel = unhex(loadStrings("ThemeRed.txt")[3]);
    myTheme = new CColor(CForeground, CBackground, CActive, CLabel, CLabel);
    cp5.setColor(myTheme);
    tint(250, 50, 50);
    DiagramColor = DiagramColorNight;
    FFTColor = FFTColorNight;
    FFTHighlight1 = FFTHighlight1Night;
    FFTHighlight2 = FFTHighlight2Night;
  } else {
    ForegroundCP.setColorValue(CForeground);
    BackgroundCP.setColorValue(CBackground);
    ActiveCP.setColorValue(CActive);
    LabelCP.setColorValue(CLabel);
    if (UseTheme) {
      CForeground = unhex(loadStrings("MyTheme.txt")[0]);
      CBackground = unhex(loadStrings("MyTheme.txt")[1]);
      CActive = unhex(loadStrings("MyTheme.txt")[2]);
      CLabel = unhex(loadStrings("MyTheme.txt")[3]);
      SaveThemeLoopBack();
    } else {
      cp5.setColor(ControlP5.THEME_CP52014);
    }
    noTint();
    DiagramColor = MyDiagramColor;
    FFTColor = MyFFTColor;
    FFTHighlight1 = MyFFTHighlight1;
    FFTHighlight2 = MyFFTHighlight2;
    setConsoleStyle();
  }
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////

void ThemeWindow() {
  GroupTheme.setVisible(true);
  BackgroundCP.setVisible(true);
  ForegroundCP.setVisible(true);
  ActiveCP.setVisible(true);
  LabelCP.setVisible(true);
  CheckSettings.setVisible(false);
  CheckSettings2.setVisible(false);
  BuCalcAllDia.setVisible(false);
}

void HideThemeWindow() {
  GroupTheme.setVisible(false);
  BackgroundCP.setVisible(false);
  ForegroundCP.setVisible(false);
  ActiveCP.setVisible(false);
  LabelCP.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
  if (UseTheme) {
    SaveThemeLoopBack();
  }
}

void ExitThemeWindow() {
  CForeground = unhex(loadStrings("MyTheme.txt")[0]);
  CBackground = unhex(loadStrings("MyTheme.txt")[1]);
  CActive = unhex(loadStrings("MyTheme.txt")[2]);
  CLabel = unhex(loadStrings("MyTheme.txt")[3]);
  ForegroundCP.setColorValue(CForeground);
  BackgroundCP.setColorValue(CBackground);
  ActiveCP.setColorValue(CActive);
  LabelCP.setColorValue(CLabel);
  GroupTheme.setVisible(false);
  BackgroundCP.setVisible(false);
  ForegroundCP.setVisible(false);
  ActiveCP.setVisible(false);
  LabelCP.setVisible(false);
  CheckSettings.setVisible(true);
  CheckSettings2.setVisible(true);
  BuCalcAllDia.setVisible(true);
}

void UseTheme(boolean state) {
  if (state) {
    UseTheme = true;
    SaveThemeLoopBack();
  } else {
    UseTheme = false;
    String[] temp = new String[5];
    temp[0] = hex(CForeground);
    temp[1] = hex(CBackground);
    temp[2] = hex(CActive);
    temp[3] = hex(CLabel);
    temp[4] = hex(BGcolor);
    saveStrings("MyTheme.txt", temp);
    cp5.setColor(ControlP5.THEME_CP52014);
    CForeground = unhex(loadStrings("MyTheme.txt")[0]);
    CBackground = unhex(loadStrings("MyTheme.txt")[1]);
    CActive = unhex(loadStrings("MyTheme.txt")[2]);
    CLabel = unhex(loadStrings("MyTheme.txt")[3]);
    BGcolor = unhex(loadStrings("MyTheme.txt")[4]);
    ForegroundCP.setColorValue(CForeground);
    BackgroundCP.setColorValue(CBackground);
    ActiveCP.setColorValue(CActive);
    LabelCP.setColorValue(CLabel);
  }
}



void toggleconsole(boolean state) {
  /*
  if (state) {
   consoleText.show();
   consoleText.bringToFront();
   } else {
   consoleText.hide();
   }
   */
}
