/**
 * Alpha Mask. 
 * 
 * Loads a "mask" for an image to specify the transparency 
 * in different parts of the image. The two images are blended
 * together using the mask() method of PImage. 
 */

PImage img;
PImage imgC;

//import for YOLO
import ch.bildspur.vision.*;
import ch.bildspur.vision.result.*;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PImage;
import processing.video.Capture;

Camera camera;
Persons persons = new Persons();
PImage inputImage;

int x1,x2,x3,x4 = 0;
int y1,y2,y3,y4 = 0;
int start = millis();

DeepVision deepVision = new DeepVision(this);
YOLONetwork yolo;
ResultList<ObjectDetectionResult> detections;

Sight[] sights;
boolean calibrated = false;

void setup() {
  size(1920, 1080);
  frameRate(30);

  img = loadImage("ka-dark.png");
  img.resize(1920,1080);
  
  sights = new Sight[]{
    new Sight( (int) (0.31 * img.width) , (int) (0.12 * img.height) , "hka.png" , "HKA" ),
    new Sight( (int) (0.573 * img.width), (int) (0.137 * img.height), "bahn.png", "bahn"),
    new Sight( (int) (0.478 * img.width), (int) (0.124 * img.height), "schlossgarten.png", "schlossgarten"),
    //new Sight( (int) (0.524 * img.width), (int) (0.085 * img.height), "schlosssee.png", "schlosssee"),
    new Sight( (int) (0.710 * img.width), (int) (0.020 * img.height), "hardtwald.png", "hardtwald"),
    new Sight( (int) (0.863 * img.width), (int) (0.081 * img.height), "friedhof.png", "friedhof"),
    new Sight( (int) (0.800 * img.width), (int) (0.342 * img.height), "Oststadt.png", "Oststadt"),
    new Sight( (int) (0.742 * img.width), (int) (0.361 * img.height), "bernarduskirche.png", "bernarduskirche"),
    new Sight( (int) (0.850 * img.width), (int) (0.524 * img.height), "gottesaue.png", "gottesaue"),
    new Sight( (int) (0.885 * img.width), (int) (0.478 * img.height), "schlachthof.png", "schlachthof"),
    // new Sight( (int) (0.938 * img.width), (int) (0.530 * img.height), "messplatz.png", "messplatz"),
    new Sight( (int) (0.727 * img.width), (int) (0.563 * img.height), "Citypark.png", "Citypark"),
    new Sight( (int) (0.693 * img.width), (int) (0.295 * img.height), "kit.png", "kit"),
    new Sight( (int) (0.607 * img.width), (int) (0.351 * img.height), "Kronenplatz.png", "Kronenplatz"),
    // new Sight( (int) (0.459 * img.width), (int) (0.900 * img.height), "hbf.png", "hbf"),
    new Sight( (int) (0.470 * img.width), (int) (0.694 * img.height), "zoo.png", "zoo"),
    new Sight( (int) (0.548 * img.width), (int) (0.625 * img.height), "Werderplatz.png", "Werderplatz"),
    new Sight( (int) (0.567 * img.width), (int) (0.572 * img.height), "Schauburg.png", "Schauburg"),
    new Sight( (int) (0.546 * img.width), (int) (0.515 * img.height), "theater.png", "theater"),
    new Sight( (int) (0.498 * img.width), (int) (0.470 * img.height), "ettlingertor.png", "ettlingertor"),
    new Sight( (int) (0.410 * img.width), (int) (0.458 * img.height), "Gericht.png", "Gericht"),
    new Sight( (int) (0.451 * img.width), (int) (0.420 * img.height), "natur.png", "natur"),
    new Sight( (int) (0.469 * img.width), (int) (0.396 * img.height), "Friedrichsplatz.png", "Friedrichsplatz"),
    new Sight( (int) (0.510 * img.width), (int) (0.377 * img.height), "marktplatz.png", "marktplatz"),
    new Sight( (int) (0.493 * img.width), (int) (0.339 * img.height), "rathausturm.png", "rathausturm"),
    new Sight( (int) (0.441 * img.width), (int) (0.367 * img.height), "stephan.png", "stephan"),
    new Sight( (int) (0.383 * img.width), (int) (0.325 * img.height), "euro.png", "euro"),
    new Sight( (int) (0.404 * img.width), (int) (0.302 * img.height), "yangda.png", "yangda"),
    new Sight( (int) (0.267 * img.width), (int) (0.277 * img.height), "Christuskirche.png", "Christuskirche"),
    new Sight( (int) (0.208 * img.width), (int) (0.403 * img.height), "sophienstraße.png", "sophienstraße"),
    new Sight( (int) (0.217 * img.width), (int) (0.648 * img.height), "zkm.png", "zkm"),
    new Sight( (int) (0.089 * img.width), (int) (0.743 * img.height), "gka.png", "gka"),
    new Sight( (int) (0.519 * img.width), (int) (0.199 * img.height), "schloss.png", "gka"),
    
  };
  
  img.loadPixels();
  
  imgC = loadImage("circle_squared.png");
  int sizeC = 300;
  imgC.resize(sizeC,sizeC);
  
  // Only need to load the pixels[] array once, because we're only
  // manipulating pixels[] inside draw(), not drawing shapes.
  loadPixels();
  
  //setup for YOLO
  println("creating model...");
  yolo = deepVision.createCrossHandDetector(256);

  println("loading yolo model...");
  yolo.setup();
  
  printArray(Capture.list());
  
  camera = new Camera(this);
  
  inputImage = new PImage(1920, 1080, RGB);
  
  
  PFont f = createFont("ttf", 18);
  textFont(f);
}


void draw() {
  
  // calibration
  if(millis() - start < 10000){
    camera.calibrate();
    //calibrated = true;
    return;
  }
  
  int sizeC = 300;  
  
  PImage cam = camera.read();
  
  if (cam.width == 0) {
    return;
  }
  
  //inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
  yolo.setConfidenceThreshold(0.5f);
  detections = yolo.run(cam);
  
  //float scaleX = inputImage.width / cam.width;
  //float scaleY = inputImage.height / cam.height;
 
  int[] personsX = new int[detections.size() +1];
  int[] personsY = new int[detections.size() +1];
  int i = 0;
  for (ObjectDetectionResult detection : detections) {
    //personsX[i] = (int) (inputImage.width - ((detection.getX() + detection.getWidth() /2) * scaleX));
    //personsY[i] = (int) ((detection.getY() + detection.getHeight() /2) * scaleY);
    int[] pers = camera.CamPosToMap(detection.getX() + detection.getWidth() /2, detection.getY() + detection.getHeight() /2);
    personsX[i] = pers[0];
    personsY[i] = pers[1]; 
    
    i++;
  }
  
  personsX[detections.size()] = mouseX;
  personsY[detections.size()] = mouseY;
  persons.calculatePersonPositions(personsX, personsY);
  
  // colour variations
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++ ) {
      // Calculate the 1D location from a 2D grid
      int loc = x + y*img.width;
      // Get the R,G,B values from image
      float r,g,b;
      r = red (img.pixels[loc]);
      g = green (img.pixels[loc]);
      b = blue (img.pixels[loc]);
      // Calculate an amount to change brightness based on proximity to the mouse
      float maxdist = 50;//dist(0,0,width,height);
      float d = persons.mindist(x, y);
      float adjustbrightness = 0;
      if(d < 102)
        adjustbrightness = 0;
      else
        adjustbrightness = 32*(maxdist-d)/maxdist;
      if(adjustbrightness < -128)
        adjustbrightness = -128;
      
      if(adjustbrightness < 0){
        float gray = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        r = r * (128 + adjustbrightness)/128 + gray * (0-adjustbrightness)/128;
        g = g * (128 + adjustbrightness)/128 + gray * (0-adjustbrightness)/128;
        b = b * (128 + adjustbrightness)/128 + gray * (0-adjustbrightness)/128;
      } 
      
      // Constrain RGB to make sure they are within 0-255 color range
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);
      // Make a new color and set pixel in the window
      color c = color(r, g, b);
      //if (adjustbrightness == -128)
      //  c = color(r);
      pixels[y*width + x] = c;
    }
  }
  updatePixels();

  
  for (Persons.Person p: persons.persons){
  // rotation of circle on user position
    float speedOfRotation = .0002; // higher values go faster, e.g. .02 is double speed
    float amtToRotate = millis()*speedOfRotation;
    pushMatrix();
    translate(p.x, p.y);
    rotate(amtToRotate);
    imageMode(CENTER);
    image(imgC,0, 0);
    popMatrix();
  }
  
  
  imageMode(CENTER);
  for (Sight sight: sights){
    float d = persons.mindist(sight.x,sight.y);
    sight.drawSight(d);
  }
  //fill(0);
  
  //text(mouseX / (float)img.width + " : " + mouseY / (float)img.height ,mouseX,mouseY);
  
  
}
