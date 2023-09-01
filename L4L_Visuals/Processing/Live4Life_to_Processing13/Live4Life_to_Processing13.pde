// Include_________________________________________________________________

import oscP5.*;
import netP5.*;



// Init_____________________________________________________________________

void setup() {

  // size(1024, 729, P3D); // P3D
  // OPENGL permet de réduire le CPU sur un coeur de 10 à 15%, 
  // mais quelle est la différence de rendu visuelle ?
  size(800, 600, P3D); // P3D 
  
  
  
  // keep my java window in front of everything in the OS while it's running    
  surface.setAlwaysOnTop(true);
  // surface.setResizable(true);
  // surface.setTitle("Live 4 Life Processing");
  // surface.setLocation(200,200);
  
  windowResizable(true);
  windowTitle("Live 4 Life Processing");
  
  
  
  // fullScreen(2); // affiche sur le deuxième écran, mais ne fait rien apparaître, 
  // car box et sphere marche seulement avec PD3 ???
  // fullScreen(P3D, 2); // fait rien apparaître le visuel, ->
  // mais ne s'affiche pas sur le second écran s'il est en affichage étendu 
  // Doit être obligatoirement mis en écran principal XXX
 
  
  
  frameRate(60);
  smooth(); 
  
  noCursor(); // Cette ligne masque le curseur de la souris, 
  // mais le fait réapparaitre si on clique sur une autre application,
  // Car on n'est plus en focus sur Processing ???

  
  
  // Initialisation de la séquence seqBackgroundColorValues 
  // pour contenir les deux séquences miroir de 0 à 255 puis de 255 à 0
  // Remplir la première moitié de l'array avec la séquence de 0 à 255
  for (int i = 0; i < 256; i++) {
    seqBackgroundColorValues[i] = i;
  }
  // Remplir la deuxième moitié de l'array avec la séquence de 255 à 0
  for (int i = 256; i < 512; i++) {
    seqBackgroundColorValues[i] = 255 - (i - 256);
  }
  // Afficher les valeurs de l'array (facultatif, à des fins de vérification)
  for (int i = 0; i < seqBackgroundColorValues.length; i++) {
    // println(seqBackgroundColorValues[i]);
  }



  // Initialisation des données FFT
  // noSmooth();
  fftArray = new float[BUFFERSIZE2];
  for (int x= 0; x<BUFFERSIZE2; x++) {
    fftArray[x] = 0.0;
  }
  
  fftArray2 = new float[BUFFERSIZE2];
  for (int x= 0; x<BUFFERSIZE2; x++) {
    fftArray2[x] = 0.0;
  }



  // Matrix initial dimensions
  // NOT USED CURRENTLY
  nbCols = floor(width / cellW) + 1;
  nbRows = floor(height / cellH) + 1;
  centerCellI = floor(nbCols / 2.);
  centerCellJ = floor(nbRows / 2.);

  // Matrix initialisation
  grid = new Cell[nbCols][nbRows];
  for (int i = 0; i < nbCols; i++)
  {
    for (int j = 0; j < nbRows; j++)
    {
      grid[i][j] = new Cell(i * cellW, j * cellH, 0.);
    }
  }



  // for recording the video in Processing
  // http://www.supermanoeuvre.com/blog/?p=1067
  // http://www.learningprocessing.com/examples/chapter-21/example-21-5/

  // way to hide the windows controls of a program that is not running in fullscreen
  // mais impossible de bouger la fenêtre par la suite ???
  // frame.removeNotify();
  // frame.setUndecorated(true);
  // frame.addNotify();



  // ambientLight(102, 102, 102);
  // lightSpecular(204, 204, 204);
  // directionalLight(102, 102, 102, 0, 0, -1);



  //--network
  OscProperties properties= new OscProperties();
  //properties.setRemoteAddress("127.0.0.1", 57120);  //osc send port (to sc)
  properties.setListeningPort(12000);                 //osc receive port (from sc)
  //properties.setSRSP(OscProperties.ON);  //unused

  /* set the datagram byte buffer size. this can be useful when you send/receive
   * huge amounts of data, but keep in mind, that UDP is limited to 64k
   */

  // Pour la FFT ???
  //properties.setDatagramSize(min(BUFFERSIZE*4, 8192));
  // properties.setDatagramSize(5136);  //5136 is the minimum 

  properties.setDatagramSize(8192); 
  // properties.setDatagramSize(1024);
  
  oscP5 = new OscP5(this, properties);



  /* start oscP5, listening for incoming messages at port 12000 */
  // oscP5 = new OscP5(this,12000); XXXXXXXXXX

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  // myRemoteLocation = new NetAddress("127.0.0.1",12000);
  /* for sending the message */
  // oscP5.send(myMessage, myRemoteLocation); 



  /* osc plug service
   * osc messages with a specific address pattern can be automatically
   * forwarded to a specific method of an object. in this example 
   * a message with address pattern /test will be forwarded to a method
   * test(). below the method test takes 2 arguments - 2 ints. therefore each
   * message with address pattern /test and typetag ii will be forwarded to
   * the method test(int theA, int theB)
   */
   
  oscP5.plug(this, "event", "/event"); // XXX
  
  oscP5.plug(this, "fftArray", "/fftArray");
  oscP5.plug(this, "loud", "/loud"); 
  oscP5.plug(this, "pitch", "/pitch"); 
  oscP5.plug(this, "specCentroid", "/specCentroid"); 
  oscP5.plug(this, "specFlatness", "/specFlatness"); 
  
  oscP5.plug(this, "fftArray2", "/fftArray2"); 
  oscP5.plug(this, "loud2", "/loud2"); 
  oscP5.plug(this, "pitch2", "/pitch2"); 
  oscP5.plug(this, "specCentroid2", "/specCentroid2"); 
  oscP5.plug(this, "specFlatness2", "/specFlatness2"); 
  
}





// Draw_______________________________________________________________________

void draw() {

  float prop;
  float varTaille;
  float taille;
  float widthAdapt;

  int gridWidth = nbCols * cellW;
  int gridHeight = nbRows * cellH;



  if (selBackground == 0) { background(0); }  // Noir
  
  else if (selBackground == 1) { background(255); } // Blanc
  
  else if (selBackground == 2) // Alternance progressive entre Noir et Blanc à chaque fame
  { 
    seqBackgroundColorIndex = (seqBackgroundColorIndex + 1) % 512;
    background(seqBackgroundColorValues[seqBackgroundColorIndex]); 
    // println(seqBackgroundColorIndex); 
  }
  
  else if (selBackground == 3) { if (selBackgroundColor == 0) { background(0); } else { background(255); } }
  
  else if (selBackground == 4) { background(random(255)); } // Alternance entre différents niveaux de gris
  
  // if (selBackground == 0) { background(0); } else { background(255); };



  // Display cells on vectorial forms (ie pixelize forms)
  // NOT USED CURRENTLY
  for (int i = 0; i < nbCols; i++)
  {
    for (int j = 0; j < nbRows; j++)
    {
      // Compute size and dimension
      grid[i][j].x = i * cellW - round((gridWidth - width) / 2.);
      grid[i][j].y = j * cellH - round((gridHeight - height) / 2.);

      //      currentX = round(grid[i][j].x + cellW / 2.);
      //      currentY = round(grid[i][j].y + cellH / 2.);
      //
      //      color cp = get(currentX, currentY);
      //
      //      // Compute white value
      //      grid[i][j].value = red(cp) / 255.;

      // Compute white value
      // grid[i][j].value = fftArray[min(1023, i*nbCols+j)];
      grid[i][j].value = fftArray[min(BUFFERSIZE2-1, i*nbCols+j)];
      // println(fftArray);
      // println(nbCols * nbRows); // 1064 = 28 * 38
      // println(i*nbCols+j);

      // Display it
      grid[i][j].display();
    }
  }



  // Pour les données FFT
  noFill(); // ??? avec line
  widthAdapt = float(width)/float(BUFFERSIZE2);
  strokeWeight(widthAdapt);
  if (selSpectreColor < 2) { colorMode(RGB); } else { colorMode(HSB, 360, 100, 100, 100); }
  
  boolean containsGreaterThanX = containsValueGreaterThanX(trackList, server2Track);
  
  if (containsGreaterThanX) {
    
    for (int x = 0; x < BUFFERSIZE2; x++) {
    
    if (selSpectreColor == 0)
    { stroke(fftArray[x]*255, 0, 0, fftArray[x]*255); } // Originelle Rouge en RGB   
    else if (selSpectreColor == 1)
    { stroke(fftArray[x]*255, 0, fftArray[x]*255, fftArray[x]*255); } // Violet en RGB
    else if (selSpectreColor == 2)
    { stroke(fftArray[x] * colorFFT, 100, 100, fftArray[x]*100); } // Hue +5 à chaque nouvel événement enn HSV
    else if (selSpectreColor == 3)
    { stroke(fftArray[x]*255.0, 0, 100, fftArray[x]*100); } // Blanc en HSV
    else if (selSpectreColor == 4)
    { stroke(fftArray[x]*255.0, backgroundColorV, backgroundColorB, fftArray[x]*100); } // Muticolore ??? 
    // backgroundColorV & backgroundColorB dépendent du pitch
     
    line((x * widthAdapt)/2, height * 1, (x * widthAdapt)/2, height * fftArray[x] * loudness);
      
    if (selSpectreColor == 0)
    { stroke(fftArray2[x]*255, 0, 0, fftArray2[x]*255);} // Originelle Rouge en RGB   
    else if (selSpectreColor == 1)
    { stroke(fftArray2[x]*255, 0, fftArray2[x]*255, fftArray2[x]*255);} // Violet en RGB
    else if (selSpectreColor == 2)
    { stroke(fftArray2[x] * colorFFT, 100, 100, fftArray2[x]*100);} // Hue +5 à chaque nouvel événement enn HSV
    else if (selSpectreColor == 3)
    { stroke(fftArray2[x]*255.0, 0, 100, fftArray2[x]*100);} // Blanc en HSV
    else if (selSpectreColor == 4)
    { stroke(fftArray2[x]*255.0, backgroundColorV, backgroundColorB, fftArray2[x]*100);} // Muticolore ??? 
    // backgroundColorV & backgroundColorB dépendent du pitch
    
    // line((x * widthAdapt)/2, height * 1, (x * widthAdapt)/2, height * fftArray2[x] * loudness2);
    line(width - (x * widthAdapt / 2), height * 1, width - (x * widthAdapt / 2), height * fftArray2[x] * loudness2);
    // line((x * widthAdapt)/2, height * 1, (x * widthAdapt)/2, height * fftArray2[x] * loudness2);
    
    };
    
  // println("La liste trackList contient un chiffre supérieur à " + server2Track);
  
  } else {
    
    for (int x = 0; x < BUFFERSIZE2; x++) {
    
    // stroke(fftArray[x]*255.0, 0, 0); // Originelle Rouge en RGB
    
    // selSpectreColor de 0 & 1, retirer le fftArray[x]*255 a un impact visuel 
    // parfois potentiellement intéressant 
    // en rajoutant davantage de noir... peut-être rajouter des selSpectreColor supplémentaires ?
    
    if (selSpectreColor == 0)
    { stroke(fftArray[x]*255, 0, 0, fftArray[x]*255); } // Originelle Rouge en RGB   
    else if (selSpectreColor == 1)
    { stroke(fftArray[x]*255, 0, fftArray[x]*255, fftArray[x]*255); } // Violet en RGB
    else if (selSpectreColor == 2)
    { stroke(fftArray[x] * colorFFT, 100, 100, fftArray[x]*100); } // Hue +5 à chaque nouvel événement enn HSV
    else if (selSpectreColor == 3)
    { stroke(fftArray[x]*255.0, 0, 100, fftArray[x]*100); } // Blanc en HSV
    else if (selSpectreColor == 4)
    { stroke(fftArray[x]*255.0, backgroundColorV, backgroundColorB, fftArray[x]*100); } // Muticolore ??? 
    // backgroundColorV & backgroundColorB dépendent du pitch
    
    // Faire une ligne en 3D ???
    // line(x, height * 0.1, x, height * 0.9); // Originelle
    // line(x, height * 1, x, height * loudness);
    line(x * widthAdapt, height * 1, x * widthAdapt, height * fftArray[x] * loudness);
    
    // Ligne ci-dessous plus adaptée si envoi de données FFT de 2 serveurs...
    // line(x * widthAdapt, height * 0.5, x * widthAdapt, height * fftArray2[x] * loudness);
    
  };
  
  // println("La liste trackList ne contient pas de chiffre supérieur à " + server2Track);
  
}

  // println(float(width)/float(BUFFERSIZE2));
  // println(fftArray);


  
  ellipseMode(CENTER);
  rectMode(CENTER);
  
  colorMode(RGB);
  
  
  
  // RuntimeException: can only create 8 lights - donc mis en dehors de la boucle d'objets  
  if (selLight == 0)
  { lights(); directionalLight(128, 128, 128, 0, 0, -1); }
  // directionalLight(128, 128, 128, 0, 0, -1); } // Light in front of the sphere
  
  else if (selLight == 1)
  { directionalLight(128, 128, 128, 0, 1, -1); } // Light in front and above of the sphere
  
  else if (selLight == 2)
  { directionalLight(255, 255, 255, 0, -1, 0); 
  // Moving spotlight that follows the mouse
  spotLight(102, 153, 204, 360, mouseY, 600, 0, 0, -1, PI/2, 600); } // Light in below the sphere
  
  
  
  colorMode(HSB, 360, 100, 100, 100);

  
  
  // The length of an ArrayList is dynamic
  // Notice how we are looping through the ArrayList backwards
  // This is because we are deleting elements from the list
  //for (int a = durLifeLeftList.size() -1; a >= 0; a--) {

  // Mais Pour afficher les derniers élément devant les précédents - nécessité dans l'ordre croissant

  // Mais meilleur effet visuel parfois quand les premières images sont derrière - cf Preset Drum Exile Cut

  // println(durLifeLeftList);

  for (int a = 0; a < durLifeLeftList.size(); a++) {

    durLifeLeftList.set(a, durLifeLeftList.get(a)-1);

    if (durLifeLeftList.get(a) < 0) {
      // Rajout de la protection car parfois génération d'un erreur...
      if (a < durLifeLeftList.size()) {durLifeLeftList.remove(a);}
      if (a < durLifeList.size()) {durLifeList.remove(a);} 
      if (a < durList.size()) {durList.remove(a);} 
      if (a < trackList.size()) {trackList.remove(a);}
      if (a < synList.size()) {synList.remove(a);} 
      if (a < ampList.size()) {ampList.remove(a);}
      if (a < envList.size()) {envList.remove(a);} 
      if (a < rateUList.size()) {rateUList.remove(a);} 
      if (a < rateList.size()) {rateList.remove(a);}
      if (a < bufTypeList.size()) {bufTypeList.remove(a);}
      if (a < bufFolderValueList.size()) {bufFolderValueList.remove(a);}
      if (a < bufUList.size()) {bufUList.remove(a);} 
      if (a < bufList.size()) {bufList.remove(a);}
      if (a < offList.size()) {offList.remove(a);} 
      if (a < strUList.size()) {strUList.remove(a);}
      if (a < strList.size()) {strList.remove(a);}
      if (a < cenUList.size()) {cenUList.remove(a);}
      if (a < cenList.size()) {cenList.remove(a);}
      if (a < spaList.size()) {spaList.remove(a);}
      if (a < panUList.size()) {panUList.remove(a);}
      if (a < outLList.size()) {outLList.remove(a);}
      if (a < outRList.size()) {outRList.remove(a);}
      if (a < fxLList.size()) {fxLList.remove(a);}
      if (a < fxRList.size()) {fxRList.remove(a);}
     
    } 
    
    else {

    if (a < durLifeLeftList.size()) {durLifeLeftListA = durLifeLeftList.get(a);}
    if (a < durLifeList.size()) {durLifeListA = durLifeList.get(a);}
    if (a < durList.size()) {durListA = durList.get(a);}    
    if (a < trackList.size()) {trackListA = trackList.get(a);
      // trackListIndexA = findIndexOfIntInList(trackList, trackListA);
      // uniqueCount = countUniqueElements(trackList);
      // widthlistsA = widthlists[uniqueCount-1];
    }
    if (a < bufUList.size()) {bufUListA = bufUList.get(a);}
    if (a < ampList.size()) {ampListA = ampList.get(a);}
    if (a < rateUList.size()) {rateUListA = rateUList.get(a);}
    if (a < panUList.size()) {panUListA = panUList.get(a);}
    if (a < bufTypeList.size()) {bufTypeListA = bufTypeList.get(a);}
         


      // Dessin à partir de la liste d'évènements en cours

      // % de temps restant pour l'évènement
      prop = durLifeLeftListA / durLifeListA;
      // Taille min & max
      varTaille = max(min((durLifeListA / 6), 2), maxSize) * 50;
      taille = int(prop * varTaille);

      // println(bufUList.size());
      fill(
      bufUListA * 360, 
      (ampListA * 80) + 20, 
      (rateUListA * 80) + 20,
      // durLifeList.get(a) / durLifeLeftList.get(a) * 100 * ampList.get(a) 
      prop * 70 * ampListA + 30
      );

      // println(durLifeList.get(a) / durLifeLeftList.get(a) * 100 * ampList.get(a));
      // println(rateUList.get(a));



      if (keyPressed) {
        
        if (key == 'q' // || key == 'Z'
        ) {  rotateX(TWO_PI * bufUListA); }
        
        else if (key == 's') 
        { rotateY(TWO_PI * bufUListA); }
        
        else if (key == 'd') 
        { rotateZ(TWO_PI * bufUListA); }
        
        else if (key == 'f') 
        { rotateX(TWO_PI * bufUListA); rotateY(TWO_PI * bufUListA); shearY(TWO_PI * bufUListA); }
        
        else if (key == 'g') 
        { rotateX(TWO_PI * bufUListA); rotateY(TWO_PI * bufUListA); rotateZ(TWO_PI * bufUListA); }
 
        else if (key == 'h') 
        { shearX(TWO_PI * bufUListA); }
        
        else if (key == 'j') 
        { shearY(TWO_PI * bufUListA); }
        
        else if (key == 'k') 
        { shearX(TWO_PI * bufUListA); shearY(TWO_PI * bufUListA); }
 
        else if (key == 'l') 
        { shearX(TWO_PI * rateUListA); }
        
        else if (key == 'm') 
        { shearY(TWO_PI * rateUListA); }
        
      };



      // lights();
      lightSpecular(bufUListA * 255, rateUListA * 255, ampListA * 255);
      // lightSpecular(204, 204, 204);

      // RuntimeException: can only create 8 lights
      // ambientLight(102, 102, 102);
      // directionalLight(102, 102, 102, 0, 0, -1); // Light in front of the sphere
      
      // shininess(random(100.0));
      shininess(bufUListA * 255);
      

      
      // rateUList -> prendre en compte la lecture de fichiers sons à l'envers
      // panUList -> renverser l'ordre aussi pour le panning

      pushMatrix();
      


      trackListIndexA = findIndexOfIntInList(trackList, trackListA);
      uniqueCount = countUniqueElements(trackList);
      widthlistsA = widthlists[uniqueCount-1];
      // println("widthlistsA", widthlistsA);
      // println("index", trackListIndexA);
      // println("length", widthlistsA.length);
      
      if (trackListIndexA < widthlistsA.length && visualRepartition == 1)
      // protection car sinon message d'erreur dans certains cas
      // Cependant problème de représentation
      {
      
        colorMode(RGB);
        stroke(255);
      
        line ( 
        widthlistsA[trackListIndexA] * width, // X
        0, // Y
        0, // Z
        widthlistsA[trackListIndexA] * width, // X
        height, // Y
        0 // Z
        );
      
      // Les objets sont tous regroupés au centre peu importe la piste
      // translate((1 - panUListA) * width, (1 - rateUListA) * height );
      translate((widthlistsA[trackListIndexA] - (panUListA * widthlistsA[0])) * width, (1 - rateUListA) * height );
    
      } else { 
        
        // translate((widthlistsA[widthlistsA.length-1] - (panUListA * widthlistsA[0])) * width, (1 - rateUListA) * height ); }
        translate((1 - panUListA) * width, (1 - rateUListA) * height ); 
    
      }
      
      
      
      if (selVisual == 0) { rotateX(TWO_PI * bufUListA); }
      else if (selVisual == 1) { rotateY(TWO_PI * bufUListA); }
      else if (selVisual == 2) { rotateZ(TWO_PI * bufUListA); }
      else if (selVisual == 3) { rotateX(TWO_PI * bufUListA); rotateY(TWO_PI * bufUListA); }
      else if (selVisual == 4) { rotateX(TWO_PI * bufUListA); rotateZ(TWO_PI * bufUListA); }
      else if (selVisual == 5) { rotateY(TWO_PI * bufUListA); rotateZ(TWO_PI * bufUListA); } 
      else if (selVisual == 6) { rotateX(TWO_PI * bufUListA); rotateY(TWO_PI * bufUListA); 
        rotateZ(TWO_PI * bufUListA); } 
      else if (selVisual == 7) { rotateX(TWO_PI * bufUListA); shearX(TWO_PI * bufUListA); }
      else if (selVisual == 8) { rotateX(TWO_PI * bufUListA); shearY(TWO_PI * bufUListA); }
      else if (selVisual == 9) { shearX(TWO_PI * bufUListA); shearY(TWO_PI * bufUListA); }
      else if (selVisual == 10) { shearX(TWO_PI * bufUListA); shearY(TWO_PI * bufUListA); 
        rotateX(TWO_PI * bufUListA); rotateY(TWO_PI * bufUListA); rotateZ(TWO_PI * bufUListA);} 



      if (visualStroke == 0) { noStroke(); } else { stroke(255); }
      colorMode(HSB, 360, 100, 100, 100);



      if (bufTypeListA.equals("D")) {
       
      box(
        // /*panUList.get(a)*/ map(panUList.get(a), 0, 1, 1, 0) * width, // horizontal -> Panning 
        // /*rateUList.get(a)*/ map(rateUList.get(a), 0, 1, 1, 0) * height, // vertical -> N° de buffer
        // taille, 
        taille 
        );
             
      } else {
      
      sphereDetail(int(3+ (30*bufUListA)));
      // println(int(3+ (30*bufUList.get(a))));
      
      sphere(
        // map(panUList.get(a), 0, 1, 1, 0) * width, // horizontal -> Panning 
        // map(rateUList.get(a), 0, 1, 1, 0) * height, // vertical -> N° de buffer
        // taille, 
        taille 
          // durLifeLeftList.get(a) / durList.get(a) * 15
        // max(10,durLifeList.get(a))
        ); 
        
      }
      
      popMatrix();
    
    
      
      }
      
    }
    
  // saveFrame("live-######.png"); // Décommenter pour sauvegarder des images
  
}











// Quand P2D n'est pas activé : Processing peut aller au delà de 100% au lieu de 25%

// Erreur quand trop de données sont lancées au 1/100 de seconde ou en dessous ???
// ArrayIndexOutOfBoundsException : Array index out of Range : 145
// par exemple dans : 
// rateUList.remove(i); rateList.remove(i); ou bufUList.remove(i); bufList.remove(i); ou autres
// durLifeLeftList.remove(i); durLifeList.remove(i); durList.remove(i); 
// ou bufUList.get(a) * 360, 
// if (bufTypeList.get(a).equals("D")) {



// et parfois la circonférence des cercles augmente en cours sans raison ???
