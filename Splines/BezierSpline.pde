public class BezierSpline {
  
  private float[ ][ ] points;
  private int one = 1;
  private int two = 2;
  private int three = 3;
  
  public BezierSpline( float[][] points) {
    this.points = points;
  }
  
  public float bezierFunction(int coords, float t, int i){
    float P1 = points[i][coords];
    float P2 = points[i+one][coords];//+(float)((points[i+1][coords]-points[i][coords])*1/3);
    float P3 = points[i+two][coords];//+(float)((points[i+1][coords]-points[i][coords])*2/3);
    float P4 = points[i+three][coords];
    float k1 = (1 - t) * (1 - t) * (1 - t); 
    float k2 = 3 * (1 - t) * (1 - t) * t; 
    float k3 = 3 * (1 - t) * t * t; 
    float k4 = t * t * t;
    float Pt = P1 * k1 + P2 * k2 + P3 * k3 + P4 * k4; 
    
    return Pt;
  }
  
  public float deCasteljauFunction(int coords, float t, int i){
    float P1 = points[i][coords];
    float P2 = points[i+one][coords];//+(float)((points[i+1][coords]-points[i][coords])*1/3);
    float P3 = points[i+two][coords];//+(float)((points[i+1][coords]-points[i][coords])*2/3);
    float P4 = points[i+three][coords];
    
    // compute first tree points along main segments P1-P2, P2-P3 and P3-P4
    float P12 = (1 - t) * P1 + t * P2; 
    float P23 = (1 - t) * P2 + t * P3; 
    float P34 = (1 - t) * P3 + t * P4; 
    // compute two points along segments P1P2-P2P3 and P2P3-P3P4
    float P1223 = (1 - t) * P12 + t * P23; 
    float P2334 = (1 - t) * P23 + t * P34; 
 
    // finally compute P
    float Pt= (1 - t) * P1223 + t * P2334; // P 
    return Pt;
  }
  
  public void paint( int resolution ) {
    one = 1;
    two = 2;
    three = 3;
    int i = 0;
    while (i < points.length-1){
      float[ ] segment1 = new float[]{ points[ i ][ X_COORD ], points[ i ][ Y_COORD ], points[ i ][ Z_COORD ] };
      float[ ] segment2 = new float[ 3 ];
      /*
      *
      * Bezier and De Casteljau algorithm taken from reference used in class
      * https://www.scratchapixel.com/lessons/advanced-rendering/bezier-curve-rendering-utah-teapot
      *
      */
      for( float r = 0; r <= resolution; r++ ) {        
        float t = r / (float) resolution;
        segment2[X_COORD] = deCasteljau ? deCasteljauFunction(X_COORD, t, i) : bezierFunction(X_COORD, t, i);
        segment2[Y_COORD] = deCasteljau ? deCasteljauFunction(Y_COORD, t, i) : bezierFunction(Y_COORD, t, i);
        segment2[Z_COORD] = deCasteljau ? deCasteljauFunction(Z_COORD, t, i) : bezierFunction(Z_COORD, t, i);
        
        pushStyle();
        color c = deCasteljau ? color(255, 255, 0) : color(0, 255, 255);
        stroke(c);
        strokeWeight(3); 
        line( segment1[ 0 ], segment1[ 1 ], segment1[ 2 ], segment2[ 0 ], segment2[ 1 ], segment2[ 2 ] );
        popStyle();
        
        segment1[ 0 ] = segment2[ 0 ];
        segment1[ 1 ] = segment2[ 1 ];
        segment1[ 2 ] = segment2[ 2 ];
        
      }
      i+=4;
    }
    print=false;
  }
}