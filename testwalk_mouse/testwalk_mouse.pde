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
import processing.sound.*;

//Camera camera;
Persons persons = new Persons();
PImage inputImage;

int x1,x2,x3,x4 = 0;
int y1,y2,y3,y4 = 0;
int start = millis();

//DeepVision deepVision = new DeepVision(this);
//YOLONetwork yolo;
//ResultList<ObjectDetectionResult> detections;

Sight[] sights;
boolean calibrated = false;

void setup() {
  size(1920, 1080);
  frameRate(30);

  img = loadImage("ka-dark.png");
  img.resize(1920,1080);
  
  SoundFile[] sounds =  {new SoundFile(this, "1.mp3"), new SoundFile(this, "2.mp3"), new SoundFile(this, "3.mp3"), new SoundFile(this, "4.mp3"), new SoundFile(this, "5.mp3")}; 
  
    for (SoundFile sound : sounds){
      sound.play();
    }
  
  sights = new Sight[]{
    new Sight( (int) (0.31 * img.width) , (int) (0.12 * img.height) , "hka.png" , "HKA" ,sounds),
    new Sight( (int) (0.573 * img.width), (int) (0.137 * img.height), "bahn.png", "bahn" ,sounds),
    new Sight( (int) (0.478 * img.width), (int) (0.124 * img.height), "schlossgarten.png", "schlossgarten" ,sounds),
    //new Sight( (int) (0.524 * img.width), (int) (0.085 * img.height), "schlosssee.png", "schlosssee" ,sounds),
    new Sight( (int) (0.710 * img.width), (int) (0.020 * img.height), "hardtwald.png", "hardtwald" ,sounds),
    new Sight( (int) (0.863 * img.width), (int) (0.081 * img.height), "friedhof.png", "friedhof" ,sounds),
    new Sight( (int) (0.800 * img.width), (int) (0.342 * img.height), "Oststadt.png", "Oststadt" ,sounds),
    new Sight( (int) (0.742 * img.width), (int) (0.361 * img.height), "bernarduskirche.png", "bernarduskirche" ,sounds),
    new Sight( (int) (0.850 * img.width), (int) (0.524 * img.height), "gottesaue.png", "gottesaue" ,sounds),
    new Sight( (int) (0.885 * img.width), (int) (0.478 * img.height), "schlachthof.png", "schlachthof" ,sounds),
    // new Sight( (int) (0.938 * img.width), (int) (0.530 * img.height), "messplatz.png", "messplatz" ,sounds),
    new Sight( (int) (0.727 * img.width), (int) (0.563 * img.height), "Citypark.png", "Citypark" ,sounds),
    new Sight( (int) (0.693 * img.width), (int) (0.295 * img.height), "kit.png", "kit" ,sounds),
    new Sight( (int) (0.607 * img.width), (int) (0.351 * img.height), "Kronenplatz.png", "Kronenplatz" ,sounds),
    // new Sight( (int) (0.459 * img.width), (int) (0.900 * img.height), "hbf.png", "hbf" ,sounds),
    new Sight( (int) (0.470 * img.width), (int) (0.694 * img.height), "zoo.png", "zoo" ,sounds),
    new Sight( (int) (0.548 * img.width), (int) (0.625 * img.height), "Werderplatz.png", "Werderplatz" ,sounds),
    new Sight( (int) (0.567 * img.width), (int) (0.572 * img.height), "Schauburg.png", "Schauburg" ,sounds),
    new Sight( (int) (0.546 * img.width), (int) (0.515 * img.height), "theater.png", "theater" ,sounds),
    new Sight( (int) (0.498 * img.width), (int) (0.470 * img.height), "ettlingertor.png", "ettlingertor" ,sounds),
    new Sight( (int) (0.410 * img.width), (int) (0.458 * img.height), "Gericht.png", "Gericht" ,sounds),
    new Sight( (int) (0.451 * img.width), (int) (0.420 * img.height), "natur.png", "natur" ,sounds),
    new Sight( (int) (0.469 * img.width), (int) (0.396 * img.height), "Friedrichsplatz.png", "Friedrichsplatz" ,sounds),
    new Sight( (int) (0.510 * img.width), (int) (0.377 * img.height), "marktplatz.png", "marktplatz" ,sounds),
    new Sight( (int) (0.493 * img.width), (int) (0.339 * img.height), "rathausturm.png", "rathausturm" ,sounds),
    new Sight( (int) (0.441 * img.width), (int) (0.367 * img.height), "stephan.png", "stephan" ,sounds),
    new Sight( (int) (0.383 * img.width), (int) (0.325 * img.height), "euro.png", "euro" ,sounds),
    new Sight( (int) (0.404 * img.width), (int) (0.302 * img.height), "yangda.png", "yangda" ,sounds),
    new Sight( (int) (0.267 * img.width), (int) (0.277 * img.height), "Christuskirche.png", "Christuskirche" ,sounds),
    new Sight( (int) (0.208 * img.width), (int) (0.403 * img.height), "sophienstraße.png", "sophienstraße" ,sounds),
    new Sight( (int) (0.217 * img.width), (int) (0.648 * img.height), "zkm.png", "zkm" ,sounds),
    new Sight( (int) (0.089 * img.width), (int) (0.743 * img.height), "gka.png", "gka" ,sounds),
    new Sight( (int) (0.519 * img.width), (int) (0.199 * img.height), "schloss.png", "gka" ,sounds),
    
  };
  
  img.loadPixels();
  
  imgC = loadImage("circle_squared.png");
  int sizeC = 300;
  imgC.resize(sizeC,sizeC);
  
  // Only need to load the pixels[] array once, because we're only
  // manipulating pixels[] inside draw(), not drawing shapes.
  loadPixels();
  
  inputImage = new PImage(1920, 1080, RGB);
  
  
  PFont f = createFont("ttf", 18);
  textFont(f);
}


void draw() {
  
  int sizeC = 300;  
  
  int[] personsX = new int[1];
  int[] personsY = new int[1];
  
  personsX[0] = mouseX;
  personsY[0] = mouseY;
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
