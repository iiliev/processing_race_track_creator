int nextY( boolean reset ){
  if (reset) yMetric = 0;
  yMetric += 20;
  return yMetric;
}


PVector ort( PVector orig ){
  PVector result = new PVector(0,0);
  result.x = -orig.y;
  result.y = orig.x;
  result.normalize();
  return result;
}

float angle(PVector v1, PVector v2) {  //PVector.angleBetween returns results between 0..Pi
  float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
  if (a < 0) a += TWO_PI;
  return a;
}

void resetDebugLine(){
  debugLineBegin = null;
  debugLineEnd   = null;
}

void plotDebugLine(){
  stroke(color(255,0,0));
  if( debugLineBegin != null && debugLineEnd != null )
    line( debugLineBegin.x, debugLineBegin.y, debugLineEnd.x, debugLineEnd.y );
}
