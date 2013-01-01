/*---------------------------------------------------------------------------------------------------------------------------

Soundbow_JS - a javascript port of the SoundBow drawing sound interface 
(c) binaura.net 2012
info@binaura.net

---------------------------------------------------------------------------------------------------------------------------*/


  final int MAX_NUMBER_OF_WIRES = 6; 
  final int NUMBER_OF_WALLS = 9;
  
  int counter;
  int scaling = 0;

  Wire wireArray[];  
  Wall wallArray[];
  int xArray[];
  int bar; //  handling bottom bars for interaction
 
  //  minimal GUI to display images
  GUI myGui;
  
  boolean clearWires = false;
  boolean resetWalls = false;
  
  boolean initialized = false; // run setup once
   
  public void setup() 
  {
    counter = 0;
    
    size(screen.width,screen.height-100);
    
    if(!initialized)
    {
      //  create sound engine here
      
      frameRate(30);
      background(0);
      colorMode(HSB, 255);
      bar = height - 80;
        
      //  walls & storing x values for them
      wallArray = new Wall[NUMBER_OF_WALLS];
      xArray = new int[NUMBER_OF_WALLS];
        
      for(int i = 0; i < NUMBER_OF_WALLS; i++) 
      {
          wallArray[i] = new Wall(0, i*width/(NUMBER_OF_WALLS) +  (int)((width/NUMBER_OF_WALLS)/2f) , 55, wallArray);
          xArray[i] = i * width/(NUMBER_OF_WALLS);    
      } 
        
      //  wires
      wireArray = new Wire[MAX_NUMBER_OF_WIRES];
      for (int i = 0; i < MAX_NUMBER_OF_WIRES; i++) 
      {
          wireArray[i] = new Wire(xArray, 55);
      }
      
      //  gui
      myGui = new GUI();
      initialized = true;
    }
  }
  
  public void draw() 
  {
    background(0);
      
    //  update wires
    if(!clearWires && !resetWalls)
    {
      for (int i = 0; i < MAX_NUMBER_OF_WIRES; i++) 
      {
        if(wallArray[i]!=null)  wireArray[i].update();
      }
    }
    
    //  clear wires  
    if(clearWires)
    {
      wireArray = new Wire[MAX_NUMBER_OF_WIRES];
      for (int i = 0; i < MAX_NUMBER_OF_WIRES; i++) 
      {
        wireArray[i] = new Wire( xArray, 55);
      }
      // set counter back to 0
      counter = 0;
      clearWires = false;
    }
    
    if (resetWalls)
    {
      //  reset walls
      wallArray = new Wall[NUMBER_OF_WALLS];
      xArray = new int[NUMBER_OF_WALLS];
        
      for(int i = 0; i < NUMBER_OF_WALLS; i++) 
      {
          wallArray[i] = new Wall(0, i*width/(NUMBER_OF_WALLS) +  (int)((width/NUMBER_OF_WALLS)/2f) , 55, wallArray);
          xArray[i] = i * width/(NUMBER_OF_WALLS); 
      }
      
      //  reset x values for walls
      for ( int i = 0; i < NUMBER_OF_WALLS; i++ ) 
        {
        if(wallArray[i]!=null)wallArray[i].release();
          xArray[i] = wallArray[i].getNewX(i);
        }
      
      //  wires
      for (int i = 0; i < MAX_NUMBER_OF_WIRES; i++) 
      {
         wireArray[i].__xArray = xArray;
      }
      
      resetWalls = false;

    }
    
    myGui.mask();
    
    //  update walls
    for (int i = 0; i < NUMBER_OF_WALLS-1; i++) 
    {
      colorMode(HSB, 255);
        stroke(200,0,150);
        fill(i/parseFloat(NUMBER_OF_WALLS)*255,150,255);
        if(wallArray[i]!=null)
        {  
          wallArray[i].update();
          wallArray[i].display();
        }
    }
  
    myGui.drawintroImage();
    myGui.displayScales();
    myGui.scaleButtons();
    myGui.clearButton();
    myGui.resetButton();


  }
  
  //-------------------------------------------------------------------------------------------------------------------------------------------------
  // DRAWING EVENTS

  public void mouseOut()
  {
    mouseReleased();
  }

  public void mousePressed()
  {
    
    //  custom methods
    if((mouseY> 0) && (mouseY < bar) && (mouseX < width-70)) 
    { 
      counter++;
      if (counter >= MAX_NUMBER_OF_WIRES) 
      {
             counter = 1;
      }
      if(wireArray[counter-1]!=null)wireArray[counter-1].recordIt(); 
    }
  }
  
  public void mouseReleased()
  {
     for (int i = 0; i < counter; i++) 
      {  
        //  check if wire is already present  
        if (counter>0) 
        {
          if(wireArray[counter-1]!=null)wireArray[counter-1].playIt();
        }
      }
      
      for ( int i = 0; i < NUMBER_OF_WALLS-1; i++ ) 
      {
        if(wallArray[i]!=null)wallArray[i].release();
        xArray[i] = wallArray[i].getNewX(i);
      }
      
      if(mouseX>width-60 && mouseY < 85) 
      {
        myGui.scale1Alpha = 255;
        myGui.scale1Pressed = true;
        scaling = 0;
      }
      if(mouseX>width-60 && mouseY < 135 && mouseY > 50) 
      {
        myGui.scale2Alpha = 255;
        myGui.scale2Pressed = true;
        scaling = 1;
      }
      if(mouseX>width-60 && mouseY > height-110 && mouseY < height-80) 
      {
        //  clear wires
        myGui.clearAlpha = 255;
        myGui.clearPressed = true;
        clearWires = true;
      }
      if(mouseX>width-60 && mouseY > height-80)
      {
        myGui.resetAlpha = 255;
        myGui.resetPressed = true;
        resetWalls = true;
      }
  }

class GUI
{
  int _trigger;
  PImage introImage;
  PImage btn1, btn2, btn4, btn5;
  
  float fadeOut = 255;
  float clearAlpha = 0;
  float resetAlpha = 0;
  float scale1Alpha = 0;
  float scale2Alpha = 0;
  float scale3Alpha = 0;
  
  boolean clearPressed = false;
  boolean resetPressed = false;
  boolean scale1Pressed = false;
  boolean scale2Pressed = false;
  boolean scale3Pressed = false;
  
  GUI() 
  {
    introImage = loadImage("./assets/pix/introMini.png");
    btn1 = loadImage("./assets/pix/btn_1.png");
    btn2 = loadImage("./assets/pix/btn_2.png");
    btn4 = loadImage("./assets/pix/btn_4.png");
    btn5 = loadImage("./assets/pix/btn_5.png");
  } 
  
  public void drawintroImage()
  {
    fadeOut -= 3.5;
    
    if(fadeOut>0)
    {
      imageMode(CENTER);
      tint(255,fadeOut);
      image(introImage, width/2, height/2);
    }
    else
    {
      //  do not show anymore
    }
  }
  
  public void scaleButtons()
  {
    colorMode(HSB);
    noStroke();
    tint(255);
    
    tint(60,100,180);
    image(btn1, width-40,35,50,50);
    tint(80,100,180);
    image(btn2, width-40,85,50,50);
   
    if(scale1Pressed)
    {
      scale1Alpha -= 15;
      noFill();
      stroke(255, scale1Alpha);
      ellipse(width-40,35,50+(255-scale1Alpha)/2,50+(255-scale1Alpha)/2);
      if(scale1Alpha<1)scale1Pressed = false;
    }
    
    if(scale2Pressed)
    {
      scale2Alpha -= 15;
      noFill();
      stroke(255, scale2Alpha);
      ellipse(width-40,85,50+(255-scale2Alpha)/2,50+(255-scale2Alpha)/2);
      if(scale2Alpha<1)scale2Pressed = false;
    }
  }
  
  public void displayScales()
  {
    noStroke();
    colorMode(HSB);
    if(scaling == 0)
    {
      fill(60,100,80);
      ellipse(width-40,35,50,50);
    }
    
    if(scaling == 1)
    {
      fill(80,100,80);
      ellipse(width-40,85,50,50);
    }
    
    if(scaling == 2)
    {
      fill(100,100,80);
      ellipse(width-40,135,50,50);
    }
  }
  
  public void mask()
  {
    noStroke();
    fill(0);
    rect(0,bar,width,height);
  }
    
  public void resetButton()
  {
    noStroke();
    colorMode(HSB);
    tint(140,100,180);
    image(btn4, width-40,height-60,50,50);
  
    if(resetPressed)
    {
      resetAlpha -= 15;
      noFill();
      stroke(255, resetAlpha);
      ellipse(width-40,height-60,50+(255-resetAlpha)/2,50+(255-resetAlpha)/2);
      if(resetAlpha<1)  resetPressed = false;
    }
  }
  
  public void clearButton()
  {
    noStroke();
    colorMode(HSB);
    tint(160,100,180);
    image(btn5, width-40,height-110,50,50);
    if(clearPressed)
    {
      clearAlpha -= 15;
      noFill();
      stroke(255, clearAlpha);
      ellipse(width-40,height-110,50+(255-clearAlpha)/2,50+(255-clearAlpha)/2);
      if(clearAlpha<1)clearPressed = false;
    }
  }
}
class Sound
{

int _trigger;
  
  Sound() 
  {
  } 
  
  void trigger(int t) 
  {
    _trigger = t;
    
    if (scaling == 0)
    {
      PlayPentaSound(_trigger);
    }
    
    if (scaling == 1)
    {
      PlayHarmonicSound(_trigger);
    }
  }
}

class Wall
{
  int _x;
  int boxX, boxY;
  int length;
  int size;
  float flash;
  
  boolean over;
  boolean press;
  boolean locked= false;
  boolean otherslocked = false;
  boolean dragged = false;
  
  Wall[] others;
  
  Wall(int x, int l, int s, Wall[] o) 
  {
    _x = x;
    length = l;
    size = s;
    boxX = length - size/2;
    boxY = (int)(height - size*1.5f);
    others = o;
  } 
    
  void update() 
  {
    boxX = _x+length;
    boxY = (int)(height-size*1.5f);
    
    if(others!=null)
  {  
    for( int i=0; i < others.length; i++ ) 
    {
      if( others[i].locked == true ) 
      {
        otherslocked = true;
        break;
      } 
      else 
      {
        otherslocked = false;
      } 
    }
  }
      
    if ( otherslocked == false ) 
    {
        isOver();
        isPressed();
    }
      
    if ( press ) 
    {
        length = lock( mouseX-size/2, 0, width-size-1 );
    }
  }
    
  void isOver() 
  {
    if ( overRect( boxX, boxY, size, size ) ) 
    {
      over = true;
    } 
    else 
    {
      over = false;
    }
  }
    
  void isPressed() 
  {
    if ( over && mousePressed || locked )
    {
        press = true;
        locked = true;
    } 
    else 
    {
        press = false;
    }
  }
    
  void release()
  {
    locked = false;
    press = false;
    //  pass back actual x value of the wall
    getNewX(boxX);
  }
    
  void display() 
  {
      strokeWeight(1);
      stroke(120);
      line(boxX+ size/2, 0, boxX+size/2, boxY);
      
      noStroke();
      ellipse( boxX+size/2,boxY+size/2,size/3,size/3 );
      
      noFill();
      strokeWeight(1);
      stroke(0,0,120);
      ellipse( boxX+size/2,boxY+size/2,size,size );
      
      if( over && press ) 
      {
        colorMode(RGB);
        noStroke();
        fill(14,190,206,50);
        ellipse(boxX+size/2, boxY+size/2,size+20,size+20);
        ellipse(boxX+size/2, boxY+size/2,size+30,size+30);
      }
      
      flash -= 10;
      strokeWeight(3);
      stroke(255,0,255,flash);
      line(boxX+ size/2-1, 0, boxX+size/2, height);
  }
    
  boolean overRect( int x, int y, int width, int height ) 
  {
    if ( mouseX >= boxX && mouseX <= boxX+width && mouseY >= boxY && mouseY <= boxY+height ) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }
    
  int lock( int val, int minv, int maxv ) 
  {
    return min(max(val, minv), maxv);
  }
    
  int getNewX(int x) 
  {
    return boxX;
  }
}
class Wire
{
  boolean recording = false;
  boolean playing = false;
  
  int index = 0;
    
  int _x;
  int _y;
  int _xNext;
  int[] __xArray;
  int _coll;
  int size; // size of wall (offset for collision)
    
  ArrayList<Integer> touchPosX;
  ArrayList<Integer> touchPosY;
    
  Sound sound;
  
  Wire(int[] _xArray, int _s) 
  { 
    _xNext = 0; 
    __xArray = _xArray;
    size = _s;
    sound = new Sound();    
  } 
    
  void update() 
  {
    if (recording) 
    {  
      if(counter>1)
      {
      
        //  check collision while drawing
        for (_coll=0; _coll < __xArray.length; _coll++) 
        {
          if(mouseY<bar)
          {
            if(touchPosX.size() > 1)
            {
              if(pmouseX -size/2<= __xArray[_coll] && mouseX-size/2 >= __xArray[_coll]) 
              {
                getCollision(_coll);       
              }
          
              if(pmouseX-size/2 >= __xArray[_coll] && mouseX-size/2 <= __xArray[_coll]) 
              {
                getCollision(_coll);       
              }
            }
          }
        }  
      }
      touchPosX.add(mouseX);
      touchPosY.add(mouseY);
      index++;
    
      stroke(255,100,255);  
      for(int i=0; i<touchPosX.size()-1; i++) 
      {
        line((Integer)touchPosX.get(i), (Integer)touchPosY.get(i), (Integer)touchPosX.get(i+1), (Integer)touchPosY.get(i+1));
      }
    } 
    
    else if (playing) 
    {
      if(index<=touchPosX.size())  
      {
        _x = (Integer)touchPosX.get(index); // parse out integers from Vector data
      }
      if(index<=touchPosY.size())
      {
        _y = (Integer)touchPosY.get(index);
      }
      
      if ( index < touchPosX.size()-1) 
      {
        _xNext = (Integer)touchPosX.get( index + 1 );
      }
      
      if(_y<bar)
      {
      
        noStroke();
        fill(255);     
        ellipse(_x, _y, 10, 10);
        stroke(100);
      
        for(int i=0; i<touchPosX.size()-1; i++) 
        {
          line((Integer)touchPosX.get(i), (Integer)touchPosY.get(i), (Integer)touchPosX.get(i+1), (Integer)touchPosY.get(i+1));
        }
        
        index++;
      
        if (index == touchPosX.size()) 
        {
          playIt();
        }
      }
      
      // checking if this wire crosses a specific wall (compare the two arrays) - pseudo:
      // wire is made of discrete values: p1-p2-p3-p4-p5-...-pn
      // if (pn < wall.x && p(n+1) > wall.x) { trigger wall.x }  
      // and vice-versa, if the wire's value is descending
        
      for (_coll=0; _coll < __xArray.length; _coll++) 
      {
        if(_x - size/2 <= __xArray[_coll] && _xNext - size/2 >= __xArray[_coll]) 
        {
          getCollision(_coll);       
        }
        if(_x - size/2 >= __xArray[_coll] && _xNext - size / 2 <= __xArray[_coll]) 
        {
          getCollision(_coll);       
        }  
      }
    }
  }
    
  float getpositionX(float posX) 
  {
    return _x; 
  }
      
  float getpositionY(float posY) 
  {
    return _y; 
  }
    
  void getCollision(float coll) 
  {  
    int noteOn = 0;
    wallArray[_coll].flash = 255;
    noteOn = (_coll + 1); 
    sound.trigger(noteOn);
  }
    
  void recordIt() 
  {  
    playing = false;
    recording = true;
    index = 0;
      
    touchPosX = new ArrayList<Integer>();
    touchPosY = new ArrayList<Integer>(); 
  }
    
  void playIt() 
  {
    recording = false;
    playing = true;
    index = 0;
  }
}

