// ----------- //
// Cell class //
// ----------- //

// NOT USED CURRENTLY

class Cell
{
  float x, y;        // x, y location
  float value;       // white value : 0. to 1.
  
  // Constructor___________________________________________________
  
  Cell(float _x, float _y, float _v)
  {
    x = _x;
    y = _y;
    value = _v;
  }


  // Display________________________________________________________
  
  void display()
  {
    
//    float greyValue = 0.;
     float value = 0.;
    
    noStroke();
    
    // White
//    if (value > 0.)
//    {
//      greyValue = abs(random(40, 80) - round(value * 255));
//    }
//    
//    // Background
//    else
//    {
//      greyValue = abs(random(40, 80) - round(value * 255)) * gridAlpha;
//      // * noiseAlpha;
//    }
    
    // Render
//    fill(greyValue);

    fill(value, 0, 0, value);
    rect(x, y, cellW, cellH);
  }
}
