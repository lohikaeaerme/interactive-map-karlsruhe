public class Persons{
   
  private final int DISTANZE_NO_MOVE =10;
  private final int DISTANZE_SAME_PERSON = 200;
  private final int FRAMES_BEFORE_DELETE = 10;
  
  public class Person{
    public int x;
    public int y;
    public int framesSinceLastSeen;
    public boolean matched = false;
    public int matched_id;
    
    public Person(int x, int y){
      this.x = x;
      this.y = y;
      this.framesSinceLastSeen = 0;
    }
  }
  
  public ArrayList<Person> persons = new ArrayList<Person>();
  
  public Persons(){
  }
  
  public void calculatePersonPositions(int[] personsX, int[] personsY){
    
    boolean matched[] = new boolean[personsX.length];
    for (int j=0;j<personsX.length;j++){
      matched[j] = false;
    }
    
    for (int j=0;j<personsX.length;j++){
      float d_closest_Person = Float.MAX_VALUE;
      Person p = null;
      int matched_id = 0;
      
      for (int i=0;i<personsX.length;i++){
        for (Person person_to_match : persons){
          
          if(!person_to_match.matched){
            float d = dist( person_to_match.x, person_to_match.y, personsX[i], personsY[i]);
            
            if(d < d_closest_Person){
              d_closest_Person = d;
              p = person_to_match;
              matched_id = i;
              println("matched");
            }
          }
        }
      }
      
      println("--------------");
      
      if(d_closest_Person < DISTANZE_SAME_PERSON && p!= null){
        p.matched = true;
        p.matched_id = matched_id;
        matched[matched_id] = true;
      } else {
        //No more Persons to match found
        break;
      }
      
    }
    
    
    //update Coordinates
    ArrayList<Person> personsToRemove = new ArrayList<Person>();
    for (Person p : persons){
      if(p.matched){
          float d = dist( p.x, p.y, personsX[p.matched_id], personsY[p.matched_id]);
          if(d > DISTANZE_NO_MOVE) {
            p.x = personsX[p.matched_id];
            p.y = personsY[p.matched_id];
            p.framesSinceLastSeen = 0;
          }
      }else{
        p.framesSinceLastSeen ++;
        if( p.framesSinceLastSeen > this.FRAMES_BEFORE_DELETE){
          personsToRemove.add(p);
        }
      }
    }
    
    //remove Persons not seen for too long
    for (Person p : personsToRemove){
        persons.remove(p);
    }
    
    //create new Persons for deteced Persons, that were not matched
    for (int i=0;i<personsX.length;i++){
      if(!matched[i]){
        persons.add(new Person(personsX[i], personsY[i]));
      }
    }
    
    //reset matched persons 
    for (Person p : persons){
      p.matched = false;
    }
    
  }
  
  
  
  
  public float mindist(int x,int y){
    float d = Float.MAX_VALUE;
    
    for (Person p : persons){
      float d_new = dist(x,y,p.x,p.y);
      if(d_new < d){
        d = d_new;
      }
    }
    
    return d;
  }
}
