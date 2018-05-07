public class CubicNaturalSpline {
  
  private float[ ][ ] points;
  private float[ ] a;
  private float[ ] b;
  private float[ ] c;
  private float[ ] d;
  
  public CubicNaturalSpline( float[][] points ) {
    this.points = points;
  }

  private void setupMatrices( int coord ) {
    a = new float[ points.length ];
    b = new float[ points.length ];
    c = new float[ points.length ];
    d = new float[ points.length ];
    
    //First row
    b[ 0 ] = 2;
    c[ 0 ] = 1;
    d[ 0 ] = 3 * ( points[ 1 ][ coord ] - points[ 0 ][ coord ] );
    
    //Intermediate rows
    for( int i = 1; i < points.length - 1; i++ ) {
      a[ i ] = 1;
      b[ i ] = 4;
      c[ i ] = 1;
      d[ i ] = 3 * ( points[ i + 1 ][ coord ] - points[ i - 1 ][ coord ] );
    }

    //Last row
    a[ points.length - 1 ] = 1;
    b[ points.length - 1 ] = 2;    
    d[ points.length - 1 ] = 3 * ( points[ points.length - 1 ][ coord ] - points[ points.length - 2 ][ coord ] );
  }
  
  private float[] tridiagonalMatrixSolve( int n, int coord ) {
    /*
      Taken from: https://en.wikibooks.org/wiki/Algorithm_Implementation/Linear_Algebra/Tridiagonal_matrix_algorithm#C++    
      Written by Keivan Moradi, 2014
      
      n is the number of unknowns
  
      |b0 c0 0 ||x0| |d0|
      |a1 b1 c1||x1|=|d1|
      |0  a2 b2||x2| |d2|
    */       
    setupMatrices( coord );
    
    c[ 0 ] /= b[ 0 ];
    d[ 0 ] /= b[ 0 ];
   
    for( int i = 1; i < n; i++ ) {
        c[ i ] /= (b[ i ] - a[ i ] * c[ i - 1 ]);
        d[ i ] = ( d[ i ] - a[ i ] * d[ i - 1 ] ) / ( b[ i ] - a[ i ] * c[ i - 1 ] );
    }
    
    for( int i = n - 2; i >= 0; i--) {
        d[ i ] -= c[ i ] * d [ i + 1 ];
    }      
    return d;
  }
  
  public void paint( int resolution ){
    float[ ][ ] derivate = new float[ 3 ][ ];

    derivate[ X_COORD ] = tridiagonalMatrixSolve( points.length, X_COORD );
    derivate[ Y_COORD ] = tridiagonalMatrixSolve( points.length, Y_COORD );
    derivate[ Z_COORD ] = tridiagonalMatrixSolve( points.length, Z_COORD );
    
    // n-1 spline pieces
    for( int i = 0; i < points.length - 1; i++ ) {
      float[ ] ai = new float[ 3 ];
      float[ ] bi = new float[ 3 ];
      float[ ] ci = new float[ 3 ];
      float[ ] di = new float[ 3 ];

      for( int c = 0; c < 3; c++ ) {
        ai[ c ] = points[ i ][ c ];
        bi[ c ] = derivate[ c ][ i ];
        ci[ c ] = 3 * ( points[ i + 1 ][ c ] - points[ i ][ c ] ) - 2 * derivate[ c ][ i ] - derivate[ c ][ i + 1 ];
        di[ c ] = 2 * ( points[ i ][ c ] - points[ i + 1 ][ c ] ) + derivate[ c ][ i ] + derivate[ c ][ i + 1 ];
      }

      float[ ] segment1 = new float[]{ points[ i ][ X_COORD ], points[ i ][ Y_COORD ], points[ i ][ Z_COORD ] };
      float[ ] segment2 = new float[ 3 ];
      
      for( float r = 0; r <= resolution; r++ ) {        
        float t = r / (float) resolution;
        
        segment2[ X_COORD ] = ( ai[ X_COORD ] + bi[ X_COORD ] * t + ci[ X_COORD ] * pow( t, 2 ) + di[ X_COORD ] * pow( t, 3 ) );
        segment2[ Y_COORD ] = ( ai[ Y_COORD ] + bi[ Y_COORD ] * t + ci[ Y_COORD ] * pow( t, 2 ) + di[ Y_COORD ] * pow( t, 3 ) );
        segment2[ Z_COORD ] = ( ai[ Z_COORD ] + bi[ Z_COORD ] * t + ci[ Z_COORD ] * pow( t, 2 ) + di[ Z_COORD ] * pow( t, 3 ) );
                
        pushStyle( );
        stroke( 0, 0, 255 );
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