import javax.swing.JOptionPane;

Track track = new Track();
int               yMetric =  0;
PVector debugLineBegin = null;
PVector debugLineEnd   = null;

void setup() {
  size(800,800);
  noLoop();
}

void draw() {
  background(color(200,200,200));
  text(String.format("Mode: %s", track.getModeText())        , 10, nextY(  true));
  track.display();
  //track.displayBorders();
  plotDebugLine();
}

void mousePressed() {
  PVector mouse = new PVector( mouseX, mouseY );
  resetDebugLine();
  if (mouseButton == LEFT) {
    if( track.mode == 'c' ){  //create
      if( track.toggleActiveCorner(mouse) )  //click on a corner
        redraw();
      else
        track.addCorner(mouse);
    } else {       //testing if mouse clicks are inside the track
      //track.isPointOnTrack( mouse );
      PVector d = track.shortestDirectionToTrack( mouse );
      if( d == null ){
        println( "point is outside of track" );
        return;
      }
      debugLineBegin = mouse;
      debugLineEnd   = PVector.sub(mouse,d);
    }
  } else if (mouseButton == RIGHT) {
    track.deleteCornerIfMatch(mouse);
    track.removeDead();
  }
  redraw();
}

void mouseDragged() {
  track.moveCornerIfMatch(new PVector(mouseX,mouseY));
  redraw();
}

void keyPressed() {
 if (key == CODED && keyCode ==   UP) {
    track.radius+=1;
  } else if (key == CODED && keyCode == DOWN) {
    track.radius-=1;
  } else if( key == 'm' ){
    track.mode = track.mode=='c' ? 't' : 'c';
  } else if (key == 's'){                           // 's'    Save config
    String fileName = JOptionPane.showInputDialog(null, "File name to save?"); 
    track.save( fileName );
  } else if (key == 'l'){                           // 'l'    Load track
    selectInput("Select a track to load:", "loadTrack", dataFile(sketchPath()));
  }else if (key == 'r'){                           
    redraw();
  }
  redraw();
}

void loadTrack(File file) {
  track.load(file);
}
