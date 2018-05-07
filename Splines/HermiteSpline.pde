public class HermiteSpline {
  
  private float[ ][ ] points;
  
  public HermiteSpline( float[][] points ) {
    this.points = points;
  }

  
  public float [] tangent(int prev, int next){
    float[] mi=new float[3];
    mi[X_COORD] = (points[next][X_COORD]-points[prev][X_COORD])/2; 
    mi[Y_COORD] = (points[next][Y_COORD]-points[prev][Y_COORD])/2; 
    mi[Z_COORD] = (points[next][Z_COORD]-points[prev][Z_COORD])/2; 
    return mi;
  }
  
  public float hermiteFunction(int coord, float t, float [] p0, float [] m0, float [] p1, float [] m1){
    /*
    * Hermite Function Representation, taken from:
    * https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Representations
    *
    */
    float[][] h = new float[2][2];
    h[0][0]=2*pow(t,3)-3*pow(t,2)+1;
    h[1][0]=pow(t,3)-2*pow(t,2)+t;
    h[0][1]=(-2*pow(t,3))+3*pow(t,2);
    h[1][1]=pow(t,3)-pow(t,2);
    float hermite = h[0][0]*p0[coord] + h[1][0]*m0[coord] + h[0][1]*p1[coord] + h[1][1]*m1[coord];
    return hermite;
  }
  
  public void paint( int resolution ) {
    int n = points.length;
    int nz = n-1;
    
    for (int i=0; i<nz; i++) {
      
      //Set Points
      float[] p0= new float[3]; 
      float[] p1= new float[3]; 
      
      p0[X_COORD]=points[i][X_COORD]; p1[X_COORD]=points[i+1][X_COORD];
      p0[Y_COORD]=points[i][Y_COORD]; p1[Y_COORD]=points[i+1][Y_COORD];
      p0[Z_COORD]=points[i][Z_COORD]; p1[Z_COORD]=points[i+1][Z_COORD];
      
      //Set tagents
      float[] m0 = new float[3];
      float[] m1 = new float[3];
      int next0 = i+1; int next1 = i+2;
      int prev0 = i-1; int prev1 = i;
      /**
      *
      * The Tangent m of the point i is: mi=(p[i+1]+p[i-i])/2
      * If is the first point, we take p[i] as the previous point of i.
      * If is before the last point, we take [i+1] as the next of the next one.
      * https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Interpolation_on_the_unit_interval_with_matched_derivatives_at_endpoints
      **/
      if(i==0)
        prev0=i;
      m0 = tangent(prev0, next0);
      
      if(i==nz-1)
        next1=i+1;
      m1 = tangent(prev1, next1);
      
      
      float[ ] segment1 = new float[]{ points[ i ][ X_COORD ], points[ i ][ Y_COORD ], points[ i ][ Z_COORD ] };
      float[ ] segment2 = new float[ 3 ];
      
      for( float r = 0; r <= resolution; r++ ) {        
        float t = r / (float) resolution;
        
        segment2[X_COORD] = hermiteFunction(X_COORD,t,p0,m0,p1,m1);
        segment2[Y_COORD] = hermiteFunction(Y_COORD,t,p0,m0,p1,m1);
        segment2[Z_COORD] = hermiteFunction(Z_COORD,t,p0,m0,p1,m1);
        
        pushStyle( );
        stroke( 100, 255, 0 );
        strokeWeight(3);
        line( segment1[ 0 ], segment1[ 1 ], segment1[ 2 ], segment2[ 0 ], segment2[ 1 ], segment2[ 2 ] );
        popStyle( );
        
        segment1[ 0 ] = segment2[ 0 ];
        segment1[ 1 ] = segment2[ 1 ];
        segment1[ 2 ] = segment2[ 2 ];
      }
    }
  }
    
    

}