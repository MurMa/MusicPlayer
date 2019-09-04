

void checkfilestatus() {
  if (loadStrings("Songlist.txt") == null) {
    savefilestatus();
    return;
  }
  if (Arrays.equals(loadStrings("Songlist.txt"), filenames)==false) {
    println("NEW FILES DETECTED!");
    TabPlayer.setActive(false);
    TabSonglist.setActive(true);
    RenderDia = false;
    RenderFFT = false;
    YNWindow.moveTo(TabSonglist);
    TxtLQuestion.setText("The Files in your directory have changed. Do you want to calculate the Diagrams now?");
    YNWindow.setVisible(true);
    YNWindow.bringToFront();
    ListSongs.close();
  }
}

void savefilestatus() {
  saveStrings("Songlist.txt", filenames);
}




void readFilesInDirectory() {
  println("Files found in path: ");
  filenames = listFileNames(mypath);
  printArray(filenames);
}



void filterfilenames() {
  if (filenames != null) {
    StringList filterednames = new StringList();
    for (int i = 0; i<filenames.length; i++) {
      String ss1 = filenames[i].substring(filenames[i].length()-3);
      if (ss1.equals("mp3") || ss1.equals("wav")) {
        filterednames.append(filenames[i]);
      }
    }
    filenames = filterednames.array();
    println("Filtered files: ");
    printArray(filenames);

    Capsfilenames = new String[filenames.length];
    for (int i = 0; i<filenames.length; i++) {
      Capsfilenames[i] = filenames[i].toUpperCase();
    }
  }
}



String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    mypath = selection.getAbsolutePath();
    String newpath = (mypath + "/");
    println("New Path is: " + newpath);
    mypath = newpath;
    String[] temp = new String[1];
    temp[0] = mypath;
    saveStrings("MyDirectory.txt", temp);
    readFilesInDirectory();
    filterfilenames();
    ListSongs.clear();
    updateFilenames(filenames);
    filepos = -1;
    loadSong(true);
    checkfilestatus();
  }
}
