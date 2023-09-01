// Keyboard_______________________________________________________________________

//void keyReleased()
//{
//  if (key == 'm' || key == 'M')
//  {
//    if (player[1].mode == 0) player[1].mode = 1;
//    else if (player[1].mode == 1) player[1].mode = 0;
//  }
//  
//  else if (key == '1')
//  {
//    frame.setLocation(0, 0);
//  }
//  
//  else if (key == '2')
//  {
//    frame.setLocation(1440, 0);
//  }
//}



void keyPressed() {
  
  if (key == '&' // || key == '0'
  ) { selVisual = 0; }
  
  else if (key == 'é' // || key == 'Z'
  ) { selVisual = 1; }
  
  else if (key == '"') 
  { selVisual = 2; }
  
  else if (key == 'a') 
  { selVisual = 3; }
        
  else if (key == 'z') 
  { selVisual = 4; }
        
  else if (key == 'e') 
  { selVisual = 5; }
        
  else if (key == 'r') 
  { selVisual = 6; }
        
  else if (key == 't') 
  { maxSize = 2; }
        
  else if (key == 'y') 
  { maxSize = 4; }
        
  else if (key == 'u') 
  { maxSize = 6; }
        
  else if (key == 'i') 
  { maxSize = 10; }
        
  else if (key == 'o') 
  { maxSize = 20; }
        
  else if (key == 'p') 
  { maxSize = 50; }
        
  else if (key == 'w') 
  { selVisual = 7; }
        
  else if (key == 'x') 
  { selVisual = 8; }
        
  else if (key == 'c') 
  { selVisual = 9; }
        
  else if (key == 'v') 
  { selVisual = 10; }
        
        
        
  // else if (key == 'b'
  // ) {  selBackground = 0; }
  // else if (key == 'n'
  // ) {  selBackground = 1; }
        
  else if (key == 'b')
  { selBackground = (selBackground + 1) % selMaxBackground; 
  println("selBackground =", selBackground); 
  }
  // Quelle est la méthode la plus efficace en CPU 
  // entre une fonction avec un modulo ci-dessus ou avec un if ci dessous ?
  /* { selBackground = selBackground + 1; 
  if (selBackground == selMaxBackground) {selBackground = 0;} 
  println("selBackground =", selBackground); 
  }*/
  
  else if (key == 'n')
  { selSpectreColor = (selSpectreColor + 1) % selMaxSpectreColor; 
  println("selSpectreColor =", selSpectreColor); 
  }
  
  else if (key == ',')
  { selLight = (selLight + 1) % selMaxLight; 
  println("selLight =", selLight); 
  }
  
  else if (key == ';')
  { visualRepartition = (visualRepartition + 1) % 2;
  println("visualRepartition =", visualRepartition); 
  }
  
  else if (key == ':')
  { visualStroke = (visualStroke + 1) % 2;
  println("visualStroke =", visualStroke); 
  }

};
