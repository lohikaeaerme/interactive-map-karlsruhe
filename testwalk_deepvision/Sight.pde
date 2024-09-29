public class Sight{
  
  private int x;
  private int y;
  private String name;
  private PImage img;
  private final int IMG_SIZE = 300;
  private final int CIRCLE_SIZE = 100;
  private final int ANIMATION_DURATION  = 1000;
  private final float CIRCLE_DELAY = ANIMATION_DURATION / 3 * 0.8;
  private int start = 0;
  
  public Sight(int x,int y ,String fileName, String name){
    this.x = x;
    this.y = y;
    this.img = loadImage(fileName);
    this.img.resize(IMG_SIZE,IMG_SIZE);
    this.name = name;
  }
  
 public void drawSight(float minDist){
   
   
   if(minDist < 200 || millis() - start < ANIMATION_DURATION){
     
     if(start == 0){
       start = millis();
     }
     if(millis() - start < ANIMATION_DURATION){
       PImage scaledImg = this.img.copy();
       
       
       if (millis() - start < ANIMATION_DURATION / 3){
         //println(millis() - start);
         scaledImg.resize(IMG_SIZE,max(1,IMG_SIZE * (millis() - start) / (ANIMATION_DURATION /3)));
       }else if(millis() - start > CIRCLE_DELAY && millis() - start < ANIMATION_DURATION){
         color c = color(255,255,255,128);
         fill(c);
         noStroke();
         circle(this.x,this.y,CIRCLE_SIZE * (millis() - start -CIRCLE_DELAY) / (ANIMATION_DURATION - CIRCLE_DELAY) );
       }
       
       image(scaledImg,this.x,this.y);
       
     }else{
       if (millis() - start < ANIMATION_DURATION * 2){
         color c = color(255,255,255,128);
         noFill();
         strokeWeight(5);
         stroke(c);
         circle(this.x,this.y,CIRCLE_SIZE * (millis() - start -CIRCLE_DELAY) / (ANIMATION_DURATION - CIRCLE_DELAY) );
       }
       
       image(this.img,this.x,this.y);
     }
     
   }else{
     start = 0;
     return;
   }
   
 }
}
