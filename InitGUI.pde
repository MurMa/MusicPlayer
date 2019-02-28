

Tab TabPlayer;
Tab TabSonglist;
Tab TabSettings;
Tab TabVisualizer;

ScrollableList ListRes;
ScrollableList ListSearchResults;
ScrollableList ListSongs;
Icon BuClearSearch;

CheckBox CheckSettings;
CheckBox CheckVisSettings;
RadioButton CheckSettings2;

Textlabel TxtLSongTime;
Textlabel TxtLSongTitle;
Textfield TxtFSearch;

Button BuChangeDirectory;
Button BuQuit;
Button BuCalcAllDia;
Button BuRandomSong;
Button BuSaveSettings;
Button BuDefaultSettings;

Icon BuPlayPause;
Icon BuNextSong;
Icon BuLastSong;

Group YNWindow;
Icon BuYes;
Icon BuNo;
Textlabel TxtLQuestion;



Group GroupBG;
//MyColorPicker MyBGColorPicker;
ColorWheel MyBGColorPicker;
Button BuBGWindow;
Button BuWallpaper;
Toggle TogUseWallpaper;
Icon BuHideBGWindow;
ScrollableList ListAnimBG;

Group GroupTheme;
Button BuThemeWindow;
Toggle TogUseTheme;
Icon BuHideThemeWindow;
Icon BuExitThemeWindow;
Slider SlThemeExample;
MyColorPicker ForegroundCP;
MyColorPicker BackgroundCP;
MyColorPicker LabelCP;
MyColorPicker ActiveCP;

Toggle TogNightMode;

Toggle TogConsole;

Slider SlIdleTime;
Slider SlVolume;
Slider SlPosition;

Println console;
Textarea consoleText;

void InitializeGUI() {

  println("Start to initialize GUI");




  CtrRaleway.setSize(20);
  Textlabel FrameRate = cp5.addFrameRate()
    .setInterval(20)
    .setPosition(10, height-30)
    ;

  CtrRaleway.setSize(16);
  TabSonglist = cp5.addTab("Songs")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(1)
    ;
  TabSonglist.getCaptionLabel().setFont(CtrRaleway);

  TabPlayer = cp5.getTab("default")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setLabel("Player")
    .setId(2)
    ;
  TabPlayer.getCaptionLabel().setFont(CtrRaleway);
  curTabIndex = 2;


  TabSettings = cp5.addTab("Settings")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(3)
    ;
  TabSettings.getCaptionLabel().setFont(CtrRaleway);
  
  TabVisualizer = cp5.addTab("Visualizer")
    .setHeight(40)
    .setWidth(150)
    .setColorLabel(color(255))
    //.setColorActive(color(0, 128, 255))
    .activateEvent(true)
    .setId(4)
    ;
  TabVisualizer.getCaptionLabel().setFont(CtrRaleway);


  cp5.getWindow().setPositionOfTabs(halfwidth-225, 20);

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  Iconfont = loadFont("musicplayer-50.vlw");
  BuPlayPause = cp5.addIcon("PlayPause", 10)
    .setPosition(halfwidth-70, height-120)
    .setSize(140, 90)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcons(0xe811, 0xe818)
    .setScale(0.9, 1)
    .setSwitch(true)
    .showBackground()
    ;


  Iconfont = loadFont("musicplayer-40.vlw");
  BuNextSong = cp5.addIcon("NextSong", 10)
    .setPosition(halfwidth-50+150, height-110)
    .setSize(100, 70)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe815)
    .setScale(0.9, 1)
    .showBackground()
    ;

  BuLastSong = cp5.addIcon("LastSong", 10)
    .setPosition(halfwidth-50-150, height-110)
    .setSize(100, 70)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe816)
    .setScale(0.9, 1)
    .showBackground()
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  YNWindow = cp5.addGroup("YNWindow")
    .setPosition(halfwidth-250, halfheight-150)
    .setSize(500, 300)
    .setBackgroundColor(color(0, 150, 250))
    .hideBar()
    ;

  BuYes = cp5.addIcon("Yes", 10)
    .setPosition(50, 200)
    .setSize(150, 80)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9, 1)
    .showBackground()
    .setGroup(YNWindow)
    ;

  BuNo = cp5.addIcon("No", 10)
    .setPosition(300, 200)
    .setSize(150, 80)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9, 1)
    .showBackground()
    .setGroup(YNWindow)
    ;

  CtrRaleway.setSize(26);
  TxtLQuestion = cp5.addTextlabel("Question")
    .setPosition(20, 20)
    .setSize(460, 150)
    .setMultiline(true)
    .setFont(CtrRaleway)
    .setText("Are you sure?")
    .setGroup(YNWindow)
    ;

  YNWindow.setVisible(false);

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  BuRandomSong = cp5.addButton("RandomSong")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Random Song")
    ;


  CtrRaleway.setSize(16);
  BuChangeDirectory = cp5.addButton("ChangeDirectory")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Directory")
    ;

  CtrRaleway.setSize(18);
  BuCalcAllDia = cp5.addButton("CalcAllDia")
    .setPosition(halfwidth+50, 130)
    .setSize(250, 50)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Calculate Diagrams")
    ;

  CtrRaleway.setSize(12);
  BuQuit = cp5.addButton("Quit")
    .setPosition(width-100, 20)
    .setSize(80, 30)
    .setColorCaptionLabel(color(255))
    ;

  CtrRaleway.setSize(16);
  BuSaveSettings = cp5.addButton("SaveSettings")
    .setPosition(30, 30)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Save settings")
    ;

  CtrRaleway.setSize(16);
  BuDefaultSettings = cp5.addButton("DefaultSettings")
    .setPosition(30, 80)
    .setSize(140, 40)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Reset settings")
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(32);
  TxtLSongTime = cp5.addTextlabel("SongTime")
    .setPosition(width-220, height-140)
    ;

  CtrRaleway.setSize(32);
  TxtLSongTitle = cp5.addTextlabel("SongTitle")
    .setPosition(halfwidth-100, height-320)
    ;
  TxtLSongTitle.get().align(ControlP5.CENTER, ControlP5.CENTER);
  TxtLSongTitle.setSize(800, 200);

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  CheckSettings = cp5.addCheckBox("ChSettings")
    .setPosition(halfwidth-300, 130)
    .setSize(50, 50)
    .setItemsPerRow(1)
    .setSpacingColumn(100)
    .setSpacingRow(20)
    .addItem("Draw Graphs", 0)
    .addItem("Draw Spectrum", 0)
    .addItem("Go Only Spectrum", 0)
    ;
  if (RenderFFT) {
    CheckSettings.activate("Draw Frequency Spectrum");
  }
  if (CalcDia) {
    CheckSettings.activate("Draw Graphs");
  }
  if (goOnlyFFT) {
    CheckSettings.activate("Go Only Spectrum");
  }
  CheckSettings.getItem(0).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);
  CheckSettings.getItem(1).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);
  CheckSettings.getItem(2).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);
  
  CtrRaleway.setSize(16);
  CheckVisSettings = cp5.addCheckBox("ChVisSettings")
    .setPosition(halfwidth-300, 370)
    .setSize(50, 50)
    .setItemsPerRow(1)
    .setSpacingColumn(100)
    .setSpacingRow(20)
    .addItem("Live Mode", 0)
    ;
  CheckVisSettings.getItem(0).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(15);


  CtrRaleway.setSize(16);
  CheckSettings2 = cp5.addRadioButton("ChSettings2")
    .setPosition(halfwidth-110, height-150)
    .setSize(60, 40)
    .setItemsPerRow(2)
    .setSpacingColumn(100)
    .setSpacingRow(10)
    .addItem("Go Idle", 0)
    .addItem("Go Eco", 0)
    ;
  if (goIdle) {
    CheckSettings2.activate("Go Idle");
  }
  if (goEco) {
    CheckSettings2.activate("Go Eco");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(20);
  TxtFSearch = cp5.addTextfield("Search")
    .setPosition(width-360, 80)
    .setSize(250, 40)
    .setAutoClear(false)
    ;
  TxtFSearch.setCaptionLabel("Search:");
  TxtFSearch.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(10);
  TxtFSearch.getValueLabel().setSize(22);


  CtrRaleway.setSize(16);
  ListSongs = cp5.addScrollableList("SongList")
    .setPosition(50, 140)
    .setSize(width-100, height-160)
    .setBarHeight(35)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    ;
  ListSongs.getCaptionLabel().setSize(18);
  ListSongs.addItems(filenames);
  ListSongs.setCaptionLabel("Your Songs: ");
  ListSongs.getCaptionLabel().setLineHeight(10);

  Iconfont = loadFont("musicplayer-40.vlw");
  BuClearSearch = cp5.addIcon("ClearSearch", 10)
    .setPosition(width-90, 85)
    .setSize(30, 30)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9, 1)
    .showBackground()
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  BuBGWindow = cp5.addButton("BGWindow")
    .setPosition(30, 150)
    .setSize(140, 40)
    .setCaptionLabel("Background")
    ;

  GroupBG = cp5.addGroup("BGGroup")
    .setPosition(halfwidth-350, halfheight-250-10)
    .setSize(700, 520)
    .setBackgroundColor(color(40))
    .hideBar()
    .setVisible(false)
    ;

  TogUseWallpaper = cp5.addToggle("UseWallpaper")
    .setPosition(40, 300)
    .setSize(60, 60)
    .setMode(ControlP5.DEFAULT)
    .setGroup(GroupBG)
    .setCaptionLabel("")
    ;

  CtrRaleway.setSize(18);
  BuWallpaper = cp5.addButton("BGWallpaper")
    .setPosition(140, 300)
    .setSize(180, 60)
    .setColorCaptionLabel(color(255))
    .setCaptionLabel("Wallpaper")
    .setGroup(GroupBG)
    ;

  /*
  
   MyBGColorPicker = new MyColorPicker(cp5, "BGCP");
   MyBGColorPicker.setPosition(halfwidth-350+40, halfheight-250-10+40);
   MyBGColorPicker.setColorValue(BGcolor);
   MyBGColorPicker.setItemSize(400, 30);
   MyBGColorPicker.setVisible(false);
   */
  CtrRaleway.setSize(16);
  MyBGColorPicker = cp5.addColorWheel(cp5, "BGCP")
    .setRGB(BGcolor)
    .setPosition(halfwidth-350+40, halfheight-250-10+40)
    .setVisible(false);
  ;

  CtrRaleway.setSize(16);
  ListAnimBG = cp5.addScrollableList("AnimBGList")
    .setPosition(360, 40)
    .setSize(300, 200)
    .setBarHeight(60)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    .addItem("Off", 0)
    .addItem("Circles", 0)
    .addItem("-2-", 0)
    .addItem("-3-", 0)
    .setGroup(GroupBG)
    .close()
    ;
  ListAnimBG.getCaptionLabel().setSize(18);
  ListAnimBG.setCaptionLabel("Animated Background");

  BuHideBGWindow = cp5.addIcon("HideBGWindow", 10)
    .setPosition(560, 420)
    .setSize(100, 60)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9, 1)
    .showBackground()
    .setGroup(GroupBG)
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  CtrRaleway.setSize(16);
  BuThemeWindow = cp5.addButton("ThemeWindow")
    .setPosition(30, 200)
    .setSize(140, 40)
    .setCaptionLabel("Theme")
    ;

  GroupTheme = cp5.addGroup("ThemeGroup")
    .setPosition(halfwidth-350, halfheight-250-10)
    .setSize(700, 520)
    .setBackgroundColor(color(40))
    .hideBar()
    .setVisible(false)
    ; 

  TogUseTheme = cp5.addToggle("UseTheme")
    .setPosition(40, 400)
    .setSize(60, 60)
    .setMode(ControlP5.DEFAULT)
    .setGroup(GroupTheme)
    .setCaptionLabel("Use Theme")
    ;  

  CtrRaleway.setSize(16);
  BackgroundCP = new MyColorPicker(cp5, "ThemeBGCP");
  BackgroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40);
  BackgroundCP.setColorValue(CBackground);
  BackgroundCP.setItemSize(260, 30);
  BackgroundCP.setVisible(false);

  ForegroundCP = new MyColorPicker(cp5, "ThemeFGCP");
  ForegroundCP.setPosition(halfwidth-350+40, halfheight-250-10+40+160);
  ForegroundCP.setColorValue(CForeground);
  ForegroundCP.setItemSize(260, 30);
  ForegroundCP.setVisible(false);

  ActiveCP = new MyColorPicker(cp5, "ThemeActiveCP");
  ActiveCP.setPosition(halfwidth-350+350, halfheight-250-10+40);
  ActiveCP.setColorValue(CActive);
  ActiveCP.setItemSize(260, 30);
  ActiveCP.setVisible(false);

  LabelCP = new MyColorPicker(cp5, "ThemeLabelCP");
  LabelCP.setPosition(halfwidth-350+350, halfheight-250-10+40+160);
  LabelCP.setColorValue(CLabel);
  LabelCP.setItemSize(260, 30);
  LabelCP.setVisible(false);

  SlThemeExample = cp5.addSlider("ThemeExample")
    .setPosition(200, 380)
    .setSize(260, 40)
    .setCaptionLabel("Example")
    .setValue(50)
    .setGroup(GroupTheme)
    ;
  SlThemeExample.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);

  BuHideThemeWindow = cp5.addIcon("HideThemeWindow", 10)
    .setPosition(560, 420)
    .setSize(100, 60)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe802)
    .setScale(0.9, 1)
    .showBackground()
    .setGroup(GroupTheme)
    ;

  Iconfont = loadFont("musicplayer-40.vlw");
  BuExitThemeWindow = cp5.addIcon("ExitThemeWindow", 10)
    .setPosition(660, 10)
    .setSize(30, 30)
    .setRoundedCorners(5)
    .setFont(Iconfont)
    .setFontIcon(0xe803)
    .setScale(0.9, 1)
    .showBackground()
    .setGroup(GroupTheme)
    ;

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  TogNightMode = cp5.addToggle("NMode")
    .setPosition(30, 260)
    .setSize(140, 40)
    .setCaptionLabel("Night Mode")
    ;
  TogNightMode.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /*
  CtrRaleway.setSize(16);
  TogConsole = cp5.addToggle("toggleconsole")
    .setPosition(30, 320)
    .setSize(140, 40)
    .setCaptionLabel("console")
    ;
  TogConsole.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  CtrRaleway.setSize(16);
  consoleText = cp5.addTextarea("console")
    .setPosition(200, 100)
    .setSize(850, 400)
    .setLineHeight(15)
    .setFont(CtrRaleway)
    .setMoveable(true) 
    .setTab(TabSettings)
    ;
  consoleText.hide();
  consoleText.clear();
  console = cp5.addConsole(consoleText);
  console.pause();
*/
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  CtrRaleway.setSize(16);
  ListRes = cp5.addScrollableList("Resolution")
    .setPosition(30, 380)
    .setSize(200, 130)
    .setBarHeight(35)
    .setItemHeight(30)
    .setType(ScrollableList.LIST)
    .addItems(resolutions)
    .close()
    ;
  ListRes.setCaptionLabel("Select resolution: ");

  ////////////////////////////////////////////////////////////////////////////////////////////////////

  int idletimeSec = idletime/1000;

  CtrRaleway.setSize(16);
  SlIdleTime = cp5.addSlider("Idletime")
    .setPosition(halfwidth-225, height-80)
    .setSize(450, 40)
    .setRange(0, 300)
    .setNumberOfTickMarks(21)
    .setValue(idletimeSec)
    .setCaptionLabel("Idle Time")
    .setColorCaptionLabel(color(255))
    ;

  CtrRaleway.setSize(12);
  SlPosition = cp5.addSlider("Position")
    .setPosition(width/20, height-200)
    .setSize(width-width/10, 40)
    .setRange(0, possteps)
    .setColorCaptionLabel(color(255))
    ;
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
  SlPosition.getValueLabel().setSize(10);



  CtrRaleway.setSize(12);
  SlVolume = cp5.addSlider("Volume")
    .setPosition(width-130, 100)
    .setSize(60, 250)
    .setRange(0, 100)
    .setValue(50)
    .setNumberOfTickMarks(51)
    .setColorCaptionLabel(color(255))
    ;
  SlVolume.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  ////////////////////////////////////////////////////////////////////////////////////////////////////


  TxtLSongTitle.moveTo(TabPlayer);
  BuPlayPause.moveTo(TabPlayer);
  BuNextSong.moveTo(TabPlayer);
  BuLastSong.moveTo(TabPlayer);
  BuRandomSong.moveTo(TabPlayer);

  TxtFSearch.moveTo(TabSonglist);
  ListSongs.moveTo(TabSonglist);
  BuChangeDirectory.moveTo(TabSonglist);
  BuClearSearch.moveTo(TabSonglist);

  SlVolume.moveTo(TabSettings);
  SlIdleTime.moveTo(TabSettings);
  CheckSettings.moveTo(TabSettings);
  CheckVisSettings.moveTo(TabSettings);
  CheckSettings2.moveTo(TabSettings);
  BuCalcAllDia.moveTo(TabSettings);
  BuSaveSettings.moveTo(TabSettings);
  BuDefaultSettings.moveTo(TabSettings);

  GroupBG.moveTo(TabSettings);
  BuBGWindow.moveTo(TabSettings);
  MyBGColorPicker.moveTo(TabSettings);

  GroupTheme.moveTo(TabSettings);
  BuThemeWindow.moveTo(TabSettings);
  ForegroundCP.moveTo(TabSettings);
  BackgroundCP.moveTo(TabSettings);
  LabelCP.moveTo(TabSettings);
  ActiveCP.moveTo(TabSettings);
  TogNightMode.moveTo(TabSettings);
  //TogConsole.moveTo(TabSettings);
  ListRes.moveTo(TabSettings);

  ////////////////////////////////////////////////////////////////////////////////////////////////////



  cp5.getProperties().setFormat(ControlP5.SERIALIZED);

  cp5.getProperties().remove(cp5.getController("SongList"));
  cp5.getProperties().remove(cp5.getController("SongTitle"));
  cp5.getProperties().remove(cp5.getController("Position")); 
  cp5.getProperties().remove(cp5.getController("PlayPause")); 
  cp5.getProperties().remove(cp5.getController("SongTime")); 
  //cp5.getProperties().remove(cp5.getController("Volume")); 
  cp5.getProperties().remove(cp5.getController("Search")); 
  cp5.getProperties().remove(cp5.getController("NextSong")); 
  cp5.getProperties().remove(cp5.getController("LastSong")); 
  cp5.getProperties().remove(cp5.getController("Question")); 
  cp5.getProperties().remove(cp5.getController("console")); 
  cp5.getProperties().remove(cp5.getController("ThemeExample")); 

  //cp5.getProperties().print();


  println("Loading Settings");

  if (createInput("DefaultSettings.ser") == null) {
    cp5.saveProperties("DefaultSettings", "default");
  } 

  if (createInput("SavedSettings.ser") != null) {
    cp5.loadProperties(("SavedSettings.ser"));
  } else {
    cp5.loadProperties(("DefaultSettings.ser"));
  }

  /*
  ChSettings(CheckSettings.getArrayValue());
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
   
   if (TogUseWallpaper.getState() == true) {
   drawWallpaper = true;
   }
   if (drawWallpaper) {
   PathWallpaper = loadStrings("MyWallpaperPath.txt")[0];
   Wallpaper = loadImage(PathWallpaper);
   }
   
   if (TogUseTheme.getState() == true) {
   UseTheme = true;
   }
   if (UseTheme) {
   myTheme = new CColor(CForeground, CBackground, CActive, CLabel, CLabel);
   CForeground = unhex(loadStrings("MyTheme.txt")[0]);
   CBackground = unhex(loadStrings("MyTheme.txt")[1]);
   CActive = unhex(loadStrings("MyTheme.txt")[2]);
   CLabel = unhex(loadStrings("MyTheme.txt")[3]);
   BGcolor = unhex(loadStrings("MyTheme.txt")[4]);
   ForegroundCP.setColorValue(CForeground);
   BackgroundCP.setColorValue(CBackground);
   ActiveCP.setColorValue(CActive);
   LabelCP.setColorValue(CLabel);
   cp5.setColor(myTheme);
   } else {
   cp5.setColor(ControlP5.THEME_CP52014);
   }
   
   ForegroundCP.setColorValue(CForeground);
   BackgroundCP.setColorValue(CBackground);
   ActiveCP.setColorValue(CActive);
   LabelCP.setColorValue(CLabel);
   
   */

  setConsoleStyle();




  if (TogNightMode.getState() == true) {
    NMode(true);
  } 


  if (CalcDia) {
    loadSongDiagram(filenames[filepos]);
    renderSongDiagram();
  }

  updateMetaInfo();
  playerlengthsec = int((player.length() / 1000) % 60);
  playerlengthmin = int((player.length() / 60000) % 60);
  possteps = player.length()/posdivide;
  SlPosition.setRange(0, possteps);
  SlPosition.getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE);
}





////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////



void setConsoleStyle() {
  /*
  consoleText.setColor(color(0));
  consoleText.setColorBackground(color(255, 240));
  consoleText.setColorForeground(color(100));
  consoleText.setColorActive(color(200));
  consoleText.setScrollBackground(color(80)); 
  consoleText.setScrollForeground(color(150)); 
  consoleText.setScrollActive(color(30));
  */
}
