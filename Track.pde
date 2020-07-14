class Corner{
  PVector position;
  Track track;
    
  Corner( float x, float y, Track t){
    position = new PVector(x,y); 
    track = t;
  }
  
  void displayCorner(){
    if(track.activeCorner != null && track.activeCorner == track.corners.indexOf(this)){         //Draw body
      stroke(color(255,0,0));
    } else {
      stroke(255);
    }
    strokeWeight(2);
    fill(255);
    ellipse(position.x, position.y, track.radius*2, track.radius*2);
    fill(0);
    text( str(track.corners.indexOf(this)), position.x+track.radius/2+10, position.y+track.radius/2+10 ); 
 
  }

  Rectangle getConnectingRect( Corner other ){
    PVector dir = PVector.sub(position,other.position);
    PVector shoulder = ort( dir );
    shoulder.mult(track.radius);
    PVector point1 = PVector.add(      position,shoulder);
    PVector point2 = PVector.add(other.position,shoulder);
    shoulder.mult(-1);
    PVector point3 = PVector.add(      position,shoulder);
    PVector point4 = PVector.add(other.position,shoulder);
    return new Rectangle( point1, point2, point3, point4 );    
  }
  
  void connectCorner( Corner other ){
    strokeWeight(1);
    stroke(color(200,200,200));
    line( position.x,position.y,other.position.x,other.position.y);
    stroke(255);
    fill(255);
    Rectangle rect = getConnectingRect( other );
    quad( rect.a.x, rect.a.y, 
          rect.b.x, rect.b.y,
          rect.d.x, rect.d.y,
          rect.c.x, rect.c.y);
  }
  
  boolean pointOnPath( Corner other, PVector point ){
    PVector dir = PVector.sub(position,other.position);
    PVector intercept = PVector.sub(point,position);
    float iMag = intercept.mag();
    if( pow(iMag,2) > pow(track.radius,2) + pow(dir.mag(),2) ) //point is not between the two corners
      return false;
    //float angle = angle(dir,intercept); //see definition in etc
    float angle = PVector.angleBetween(dir,intercept);
    if( angle < HALF_PI )  //point is in the other direction
      return false;
    float dist = iMag * sin( angle );
    if( dist < track.radius )
      return true;
     return false;
  }

  PVector directionToPath( Corner other, PVector point ){
    PVector dir = PVector.sub(position,other.position);
    PVector intercept = PVector.sub(point,position);
    float iMag = intercept.mag();
    float angle = PVector.angleBetween(dir,intercept);
    if( angle < HALF_PI ){  //point is in the other direction
      return null;
    }
    float dist = iMag * cos( angle );
    PVector dirNorm = dir.copy();     //keep dir to see if point is outside limits
    dirNorm.normalize();
    dirNorm.mult(dist);
    PVector result =  PVector.sub( intercept, dirNorm );
    if( pow(iMag,2) > pow(result.mag(),2) + pow(dir.mag(),2) ){ //point is not between the two corners
      return null;
    }    
    return result;
  }
}

class Rectangle{
  PVector a;
  PVector b;
  PVector c;
  PVector d;
  Rectangle( PVector _a, PVector _b, PVector _c, PVector _d ){
    a = _a;
    b = _b;
    c = _c;
    d = _d;
  }
}

class Track{
  ArrayList<Corner> corners;
  ArrayList<Corner> toDelete;
  Integer           activeCorner = null;
  float             radius  = 20;
  char              mode = 'c';   //r=run;c=create;t=test

  Track(){
    corners   = new ArrayList<Corner>();
    toDelete = new ArrayList<Corner>();
  }
  
  String getModeText(){
    switch(mode){
      case 'c': return "Create";  
      case 'r': return "Run";  
      case 't': return "Test";  
    }
    return "None";
  }
  
  void display(){
    if(corners.size()==0) return;
    for( int i=0; i < corners.size()-1; i++ )
      corners.get(i).connectCorner(corners.get(i+1));
    corners.get(corners.size()-1).connectCorner(corners.get(0));

    for(Corner c: corners) {
      c.displayCorner();
    }
    //if( mode == 'c' )
    //  displayBorders();
  }
  
  void removeDead(){
    if(toDelete.size()==0) return;
    for(Corner c: toDelete) corners.remove(c);
    toDelete.clear();
    activeCorner = null;
  }
  
  boolean toggleActiveCorner( PVector location ){
    for(Corner c: corners) {
      if( PVector.sub(c.position, location).mag() < radius ){
        if( activeCorner != null && corners.indexOf(c) == activeCorner )
          activeCorner = null;
        else
          activeCorner = new Integer(corners.indexOf(c));
        return true;
      }
    }
    return false;
  }

  void addCorner( PVector location ){
    Corner corner = new Corner( location.x, location.y, this ); 
    if( activeCorner != null )
      corners.add(activeCorner, corner); //goes before the active
    else
      corners.add(corner);              //goes last
  }

  void moveCornerIfMatch( PVector location ){ //if mouse drags corner move it
    for(Corner c: corners)
      if( PVector.sub(c.position, location).mag() < radius ){
        c.position.x = location.x;
        c.position.y = location.y;
        return;
      }
  }

  void deleteCornerIfMatch( PVector location ){
    for(Corner c: corners)
      if( PVector.sub(c.position, location).mag() < radius ){
         toDelete.add( c );
         return;
      }
  }
  
  boolean isPointOnTrack( PVector point ){
    if(corners.size()==0) return false;
    for( int i=0; i < corners.size()-1; i++ )
      if( corners.get(i).pointOnPath(corners.get(i+1),point))
        return true;
    if( corners.get(corners.size()-1).pointOnPath(corners.get(0),point) ) //<>//
      return true;
    for(Corner c: corners) {
      if( PVector.sub(c.position, point).mag() < radius )
        return true;
    } 
    return false;
  }  
  
  PVector shortestDirectionToTrack( PVector point ){
    ArrayList<PVector> directions = new ArrayList<PVector>();
    for( int i=0; i < corners.size()-1; i++ )                  //check the segments
      directions.add( corners.get(i).directionToPath(corners.get(i+1),point));
    directions.add( corners.get(corners.size()-1).directionToPath(corners.get(0),point) );
    for( Corner c: corners )
      directions.add( PVector.sub( point, c.position ) );
    float minDistance = Float.MAX_VALUE;
    PVector currentBest = null; //<>//
    for( PVector d : directions )
      if( d != null && d.mag() < minDistance ){
        minDistance = d.mag();
        currentBest = d;
      }
    if( currentBest != null )
      println( String.format("Segment: %d; Dist: %.2f", directions.indexOf(currentBest), currentBest.mag()) );
    return currentBest;    
  }
    
  void displayBorders(){
    strokeWeight(1);
    for(int i = 0; i <= width; i+=20)
      for(int j = 0; j <= height; j+=20){
        PVector point = new PVector( i, j );
        if( isPointOnTrack( point ))
          fill( color(255,0,0) ); //red
        else
          fill( color(0,0,255) ); //blue
        ellipse(i, j, 6, 6);
      }
  }  
  
  JSONObject getJSONRect( int i, int j ){
    Rectangle currentRect = corners.get(i).getConnectingRect(corners.get(j));
    JSONObject rect = new JSONObject();
    rect.setFloat( "a_x", currentRect.a.x);
    rect.setFloat( "a_y", currentRect.a.y);
    rect.setFloat( "b_x", currentRect.b.x);
    rect.setFloat( "b_y", currentRect.b.y);
    rect.setFloat( "c_x", currentRect.c.x);
    rect.setFloat( "c_y", currentRect.c.y);
    rect.setFloat( "d_x", currentRect.d.x);
    rect.setFloat( "d_y", currentRect.d.y);
    return rect; 
  }
  
  void save(String fileName) {
    if( fileName == null ) return;
    JSONArray jsonCorners = new JSONArray();
    for(Corner c: corners) {
      JSONObject corner = new JSONObject();
      corner.setFloat( "pos_x", c.position.x);
      corner.setFloat( "pos_y", c.position.y);
      jsonCorners.setJSONObject(corners.indexOf(c), corner);
    }
    JSONObject json = new JSONObject();
    json.setFloat( "radius", radius);
    json.setJSONArray("corners", jsonCorners);
  
    saveJSONObject(json, "data/"+fileName+".json");  
  }  
  
  void load(File file) {
    if (file == null) return;
    corners.clear();
    JSONObject json = loadJSONObject(file.getAbsolutePath());
    radius = json.getFloat("radius");
    JSONArray jsonCorners = json.getJSONArray("corners");
    for (int i = 0; i < jsonCorners.size(); i++) {
      JSONObject jsonCorner = jsonCorners.getJSONObject(i); 
      Corner corner = new Corner( jsonCorner.getFloat("pos_x"), jsonCorner.getFloat("pos_y"), this );
      corners.add(corner);
    }
    redraw();
  }  
}
