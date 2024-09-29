import processing.video.Capture;
import processing.core.PImage;

public class Camera{
  
  private final String CAM_NAME = "USB Camera VID:1133 PID:2085";
  private Capture cam;
  private int x1,x2,x3,x4 = 0;
  private int y1,y2,y3,y4 = 0;
  
  public Camera(testwalk_mouse window){
    
    for (String camName : Capture.list()){
      if(camName.equals(CAM_NAME)){
          this.cam = new Capture(window,CAM_NAME, 20);
      }
    }
    
    if (this.cam == null){
      println("external Camera not found");
      this.cam = new Capture(window, "pipeline:autovideosrc");
    }
    
    this.cam.start();
  }
  
  
  public PImage read(){
    if (cam.available()) {
      cam.read();
    }
    
    return cam;
  }
  
  /**
  *  Transforms Pixel coordinates from a position on the camera Image to a position on the MapImage.
  *  Works under the assumption, the map is a rectangle on the camera Image which is parallel to the camera Image (not rotated).
  *
  *  @param x X coordinate on the camera image
  *  @param y Y coordinate on the camera image
  *  @return    Int Array with coordinates on the MapImage. X coordinate at first position, Y coordinate at second position
  **/
  public int[] CamPosToMap(int x, int y){
    int[] newPos = new int[2];
    
    // 
    newPos[0] =(int) ((x -x1) / (float)(x1 - x2) * img.width) *-1;
    newPos[1] =(int) ((y -y1) / (float)(y1 - y3) * img.height) * -1;
    return newPos;
  }
  
  
  public void calibrate(){
    
    //draw Colored Rectangles, to find on the Camera Stream
    fill(color(255,0,0));
    rect(0,0,img.width / 2, img.height / 2);
    
    fill(color(0,255,0));
    rect(img.width / 2,0, img.width , img.height / 2);
    
    fill(color(0,0,255));
    rect(0,img.height / 2,img.width / 2, img.height);
    
    
    if (cam.available()) {
      cam.read();
    } else {
      return;
    }
    
    //Find the colored Rectangles on the Video by searcheing the colors and calculate the center.
    //Discovered Colors are set to black, to verify they have bin found 
    //and to aviode impact on calibration, wehn camera image is drawwn.
    int delta = 50;
    
    int[] sumX = new int[]{0,0,0,0};
    int[] sumY = new int[]{0,0,0,0};
    int[] count = new int[]{0,0,0,0};
    
    for (int x = 0; x < cam.width; x++) {
      for (int y = 0; y < cam.height; y++ ) {
        int loc = x + y*cam.width;
        // Get the R,G,B values from image
        float r,g,b;
        r = red (cam.pixels[loc]);
        g = green (cam.pixels[loc]);
        b = blue (cam.pixels[loc]);
        
        if(r -g > delta && r -b > delta){
          count[0] ++;
          sumX[0] += x;
          sumY[0] += y;
          r = 0;
          g = 0;
          b = 0;
        }
        else if(g -r > delta && g -b > delta){
          count[1] ++;
          sumX[1] += x;
          sumY[1] += y;
          r = 0;
          g = 0;
          b = 0;
        }
        else if(b -r > delta && b -g > delta){
          count[2] ++;
          sumX[2] += x;
          sumY[2] += y;
          r = 0;
          g = 0;
          b = 0;
        }
        else {
          count[3] ++;
          sumX[3] += x;
          sumY[3] += y;
        }
        
        color c = color(r, g, b);
        //if (adjustbrightness == -128)
        //  c = color(r);
        cam.pixels[loc] = c;
      }
    }
    
    image(cam,img.width/2,img.height/2);
    
    stroke(color(255,255,0));
    noFill();
    
    //calculate centers of the colored Rectangles
    // x1,y1 = top left
    // x2,y2 = top right
    // x3,y3 = bottom left
    // x4,y4 = bottom right
    
    int x1_mid = sumX[0] / max(1,count[0]);
    int x2_mid = sumX[1] / max(1,count[1]);
    int x3_mid = sumX[2] / max(1,count[2]);
    
    int y1_mid = sumY[0] / max(1,count[0]);
    int y2_mid = sumY[1] / max(1,count[1]);
    int y3_mid = sumY[2] / max(1,count[2]);
    
    int x4_mid = x3_mid + (x2_mid - x1_mid);
    int y4_mid = y2_mid + (y3_mid - y1_mid);
    
    //calculate edge coordinates
    x1 = x1_mid - (x2_mid - x1_mid)/2;
    y1 = y1_mid - (y3_mid - y1_mid)/2;
    
    x2 = x2_mid + (x2_mid - x1_mid)/2;
    y2 = y2_mid - (y3_mid - y1_mid)/2;
    
    x3 = x3_mid - (x4_mid - x3_mid)/2;
    y3 = y3_mid + (y3_mid - y1_mid)/2;
    
    x4 = x4_mid + (x4_mid - x3_mid)/2;
    y4 = y4_mid + (y4_mid - y2_mid)/2;
    
    //draw center points on camera image on the bottom right of the window
    line(x1_mid + img.width/2, y1_mid + img.height/2, x2_mid + img.width/2, y2_mid + img.height/2);
    line(x1_mid + img.width/2, y1_mid + img.height/2, x3_mid + img.width/2, y3_mid + img.height/2);
    line(x2_mid + img.width/2, y2_mid + img.height/2, x4_mid + img.width/2, y4_mid + img.height/2);
    line(x3_mid + img.width/2, y3_mid + img.height/2, x4_mid + img.width/2, y4_mid + img.height/2);
    
    //draw edge points
    line(x1 + img.width/2, y1 + img.height/2, x2 + img.width/2, y2 + img.height/2);
    line(x1 + img.width/2, y1 + img.height/2, x3 + img.width/2, y3 + img.height/2);
    line(x2 + img.width/2, y2 + img.height/2, x4 + img.width/2, y4 + img.height/2);
    line(x3 + img.width/2, y3 + img.height/2, x4 + img.width/2, y4 + img.height/2);
    
    /*
    x1 -= img.width/2;
    x2 -= img.width/2;
    x3 -= img.width/2;
    x4 -= img.width/2;
    
    y1 -= img.height/2;
    y2 -= img.height/2;
    y3 -= img.height/2;
    y4 -= img.height/2;
    */
    /*rect(
      sumX[0] / max(1,count[0]) + img.width/2, 
      sumY[0] / max(1,count[0]) + img.height/2,
      -(sumX[0] / max(1,count[0]) + img.width/2) + (sumX[1] / max(1,count[1]) + img.width/2),
      -(sumY[0] / max(1,count[0]) + img.height/2)+ (sumY[2] / max(1,count[2]) + img.height/2));
      */
      
     /*
    fill(0);
    
    println("cam : " + cam.width + " " + cam.height);
    text("box : " + sumX[0] / max(1,count[0]) + ":" + sumY[0] / max(1,count[0]) + " --> " 
      + sumX[1] / max(1,count[1]) + ":" + sumY[2] / max(1,count[2]), img.width/2,img.height/4*3);
    
    int loc = cam.width/4 + cam.height /4 * cam.width;
    text("red : " + red(cam.pixels[loc]) + " : " + green(cam.pixels[loc]) + " : " + blue(cam.pixels[loc]), img.width/4, img.height/4);
    
    loc = cam.width/4*3 + cam.height /4 * cam.width;
    text("green : " + red(cam.pixels[loc]) + " : " + green(cam.pixels[loc]) + " : " + blue(cam.pixels[loc]), img.width/4*3,img.height/4);
    
    loc = cam.width/4 + cam.height /4 * cam.width * 3;
    text("blue : " + red(cam.pixels[loc]) + " : " + green(cam.pixels[loc]) + " : " + blue(cam.pixels[loc]), img.width/4,img.height/4*3);
    
    println("counts : " + count[0] + ":" + count[1] + ":" + count[2] + ":" + count[3]);
    */
  }
  

}
