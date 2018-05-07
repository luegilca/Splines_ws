public class Degree7Bezier {
  
  private float[ ][ ] points;
  private int degree;
  
  public Degree7Bezier( float[][] points ) {
    this.points = points;
    this.degree = 7;
  }
  
  public Degree7Bezier( float[][] points, int degree ) {
    this.points = points;
    this.degree = degree;
  }
  
  public void paint( int resolution ){
    
    if( points.length < ( degree + 1 ) ){
      println( "No hay suficientes puntos para dibujar una sola curva." );
      return;
    } 
      
    for( int i = 0; ( i + degree ) < points.length; i += degree ) {
      
      float pointChunk[][] = new float[ degree + 1 ][ 3 ];
      for( int j = 0; j < degree + 1; j++ ){
        pointChunk[ j ][ X_COORD ] = points[ j + i ][ X_COORD ];
        pointChunk[ j ][ Y_COORD ] = points[ j + i ][ Y_COORD ];
        pointChunk[ j ][ Z_COORD ] = points[ j + i ][ Z_COORD ];
      }
            
      float[ ] segment1 = new float[]{ pointChunk[ 0 ][ X_COORD ], pointChunk[ 0 ][ Y_COORD ], pointChunk[ 0 ][ Z_COORD ] };
      float[ ] segment2 = new float[ 3 ];
      
      for( float r = 0; r <= resolution; r++ ) {        
        float t = r / (float) resolution;
        
        segment2 = bezier( t, pointChunk );
                
        pushStyle( );
        stroke( 255, 102, 0 );
        strokeWeight(3);
        line( segment1[ X_COORD ], segment1[ Y_COORD ], segment1[ Z_COORD ], segment2[ X_COORD ], segment2[ Y_COORD ], segment2[ Z_COORD ] );
        popStyle( );
        
        segment1[ X_COORD ] = segment2[ X_COORD ];
        segment1[ Y_COORD ] = segment2[ Y_COORD ];
        segment1[ Z_COORD ] = segment2[ Z_COORD ];
      }
    }
  }
  
  private int factorial( int k ) {
    if( k == 0 || k== 1 )
      return 1;
    return k * factorial( k - 1 );
  }
  
  private int binomialCoef( int n, int k ) {
    return ( n >= k && k >= 0) ? factorial( n ) / ( factorial( k ) * ( factorial( n - k ) ) ): 0;  
    //return factorial( n ) / ( factorial( k ) * factorial( n - k ) );
  }
  
  // The details of formulas calculated below are here:
  // https://en.wikipedia.org/wiki/Bézier_curve#Explicit_definition
  
  /**
  *    b_(i,n) (t) = nCi * t^i * (1 - t)^(n-i), i = 0,..., n
  **/
  private float b( int i, int n, float t ) {
    return binomialCoef( n, i ) * pow( t, i ) * pow( ( 1 - t ), ( n - i ) );
  }
  
  /**
  *    B(t) = SUM from i = 0 to n of ( b_(i, n)(t) * P_i),  0 <= t <= 1
  **/
  private float[] bezier( float t, float[][] pointChunk ) {
    float[] b = new float[]{ 0.0, 0.0, 0.0 };
    for( int i = 0; i < pointChunk.length; i++ ) {      
      float coef = b( i, pointChunk.length -1 , t );
      b[ X_COORD ] += pointChunk[ i ][ X_COORD ] * coef;
      b[ Y_COORD ] += pointChunk[ i ][ Y_COORD ] * coef;
      b[ Z_COORD ] += pointChunk[ i ][ Z_COORD ] * coef;
    }
    return b;
  }
}