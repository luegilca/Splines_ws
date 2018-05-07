/**
 * Splines.
 *
 * Here we use the interpolator.keyFrames() nodes
 * as control points to render different splines.
 *
 * Press ' ' to change the spline mode.
 * Press 'g' to toggle grid drawing.
 * Press 'c' to toggle the interpolator path drawing.
 * Press 's' to draw the respective spline
 * Press '+' to increase the resolution level
 * Press '-' to decrease the resolution level
 * Press 'd' to change Benzier algorithm between Regular algorithm and De Casteljau's one.
 * Press 'r' to randomly generate a new curve
 */

import frames.input.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

// global variables
// modes: 0 natural cubic spline; 1 Hermite;
// 2 (degree 7) Bezier; 3 Cubic Bezier
int mode;
int resolution = 1;

Scene scene;
Interpolator interpolator;
OrbitNode eye;
boolean drawGrid = true, drawCtrl = true;
boolean drawSpline = true;
boolean print = false;
boolean deCasteljau=false;
// Control points coordinates
float[][] points;

//Choose P3D for a 3D scene, or P2D or JAVA2D for a 2D scene
String renderer = P3D;

final int X_COORD = 0;
final int Y_COORD = 1;
final int Z_COORD = 2;

void setup() {
  size(800, 800, renderer);
  scene = new Scene(this);
  eye = new OrbitNode(scene);
  eye.setDamping(0);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(150);
  scene.fitBallInterpolation();
  interpolator = new Interpolator(scene, new Frame());
  // framesjs next version, simply go:
  //interpolator = new Interpolator(scene);

  // Using OrbitNodes makes path editable
  generate();
}


void generate(){
  int size=9;
  interpolator.clear();
  for (int i = 0; i < size; i++) {
    Node ctrlPoint = new OrbitNode(scene);
    ctrlPoint.randomize();
    interpolator.addKeyFrame(ctrlPoint);
  }
  
  
  Frame sect1p = interpolator.keyFrames( ).get(2);
  Frame sect2p = interpolator.keyFrames( ).get(5);
  Vector coord1p = sect1p.position( );
  Vector coord2p = sect2p.position( );
  float xDistance = coord2p.x() - coord1p.x();
  float yDistance = coord2p.y() - coord1p.y();
  float zDistance = coord2p.z() - coord1p.z();
  
  Vector newV = new Vector((coord1p.x()+(xDistance/2)),
                            (coord1p.y()+(yDistance/2)),
                            (coord1p.z()+(zDistance/2)));
  interpolator.keyFrames( ).get(3).setPosition(newV);
  interpolator.keyFrames( ).get(4).setPosition(newV);
}


void draw() {
  background(175);
  if (drawGrid) {
    stroke(255, 255, 255);
    scene.drawGrid(200, 50);
  }
  if (drawCtrl) {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    for (Frame frame : interpolator.keyFrames())
      scene.drawPickingTarget((Node)frame);
  } else {
    fill(255, 0, 0);
    stroke(255, 0, 255);
    strokeWeight(1);
    scene.drawPath(interpolator);
  }
  scene.beginScreenCoordinates( );
  pushStyle( );
  fill( 0, 0, 0 );
  textSize( 20 );
  String alg = deCasteljau ? "De Casteljau Algorithm":"Regular Algorithm";
  text( "Resolution: " + resolution, 30, 30 );  
  switch( mode ){
    case 0: text( "Mode: Cubic Natural Spline", 30, 60 ); break;
    case 1: text( "Mode: Hermite Spline", 30, 60 ); break;
    case 2: text( "Mode: Degree 7 Bezier Spline", 30, 60 ); break;
    case 3: text( "Mode: Cubic Bezier Spline\n"+alg, 30, 60 ); break;
  }
  popStyle( );
  scene.endScreenCoordinates( );
  // implement me
  // draw curve according to control polygon an mode
  // To retrieve the positions of the control points do:  
  // for(Frame frame : interpolator.keyFrames())
  //   frame.position();
  
  int pointCount = interpolator.keyFrames( ).size( );
  points = new float[ pointCount ][ 3 ];
  for( int i = 0; i < pointCount; i++ ){
    Frame current = interpolator.keyFrames( ).get( i );
    points[ i ][ X_COORD ] = current.position( ).x( );
    points[ i ][ Y_COORD ] = current.position( ).y( );
    points[ i ][ Z_COORD ] = current.position( ).z( );
    if( print )
      text(i, current.position( ).x( ), current.position( ).y( ), current.position( ).z( ));
  }
  
  CubicNaturalSpline cn_spline = new CubicNaturalSpline( points );
  HermiteSpline h_spline = new HermiteSpline( points );
  Degree7Bezier d7b_spline = new Degree7Bezier( points );
  BezierSpline b_spline = new BezierSpline( points );
  
  if(drawSpline){
    switch( mode ) {
      case 0:      
        cn_spline.paint( resolution );
        break;
      case 1:
        h_spline.paint( resolution );
        break;
      case 2:
        d7b_spline.paint( resolution );
        break;
      case 3:
        b_spline.paint( resolution );
        break;
    }
  }
}

void keyPressed() {
  if (key == ' ')
    mode = mode < 3 ? mode+1 : 0;
  if (key == 'g')
    drawGrid = !drawGrid;
  if (key == 'c')
    drawCtrl = !drawCtrl;
  if (key == 's')
    drawSpline = !drawSpline;
  if (key == '+')
    resolution = ( resolution++ > 19 ) ? 1 : resolution++;
  if (key =='p')
    print=true;
  if (key== 'd')
    deCasteljau = !deCasteljau;
  if(key=='r')
    generate();
  if (key == '-')
    resolution = ( resolution-- <= 1 ) ? 20 : resolution--;
}