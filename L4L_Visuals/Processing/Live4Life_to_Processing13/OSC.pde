// -------------- //
// OSC Management //
// -------------- //

public void event(
float dur, 
int track, 
int syn, 
float amp, 
int env, 
float rateU, 
float rate, 
String bufType, 
int bufFolderValue, 
float bufU, 
int buf, 
float off, 
float strU,
float str,
float cenU, 
float cen,
int spa, 
float panU, 
int outL, 
int outR, 
int fxL, 
int fxR

) {

  // Assignation des variables locales à des listes globales pour chaque paramètre 

  durList.append(dur);
  durLifeList.append(dur * frameRate);
  durLifeLeftList.append(dur * frameRate);

  trackList.append(track); // println(trackList);
  uniqueCount = countUniqueElements(trackList); // println(uniqueCount);
  synList.append(syn);

  ampList.append(amp);
  envList.append(env);

  rateUList.append(rateU);
  rateList.append(rate); // println(rate);

  bufTypeList.append(bufType);
  bufFolderValueList.append(bufFolderValue);
  bufUList.append(bufU);
  bufList.append(buf);
  offList.append(off);

  strUList.append(strU);
  strList.append(str);
  cenUList.append(cenU);
  cenList.append(cen);

  spaList.append(spa);
  panUList.append(panU);

  outLList.append(outL);
  outRList.append(outR);

  fxLList.append(fxL);
  fxRList.append(fxR);
  
  if (selSpectreColor == 2)
  {
    // colorFFT = colorFFT+255; // pour changement de couleur progressif quand nouvel évènement
    colorFFT = colorFFT+5; // pour changement de couleur progressif quand nouvel évènement
    // println(colorFFT);
    if (colorFFT > 255) {
      colorFFT = 0;
    };
  }
  
  if (selBackground == 3)
  { selBackgroundColor = (selBackgroundColor+1) % 2; }
  // println(selBackgroundColor);
  
}





public void fftArray(float[] fftArrayR)
{ // Pas possible de faire une attribution directe sans faire une boucle ???????????????? 
  // - Le TypeTag recu est un float et non une array ???
  for (int i= 0; i<BUFFERSIZE2; i++) {
    fftArray[i] = fftArrayR[i];
  }
  // println(fftArray);
}

public void fftArray2(float[] fftArrayR2)
{
  for (int i= 0; i<BUFFERSIZE2; i++) {
    fftArray2[i] = fftArrayR2[i];
  }
  // println(fftArray);
}

/*
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/fftArray")) {
    for (int i= 0; i<BUFFERSIZE2; i++) {
      fftArray[i]= msg.get(i).floatValue();
    }
  }
}
*/



public void loud(float loudnessR)
{ 
  loudness = loudnessR;
  // println(loudnessR);
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  loudness = map(loudness, 0.0, 100.0, 1.0, 0.0); 
  // println(loudness);
}

public void loud2(float loudnessR2)
{ 
  loudness2 = loudnessR2;
  // println(loudnessR);
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  loudness2 = map(loudness2, 0.0, 100.0, 1.0, 0.0); 
  // println(loudness);
}



public void pitch(float pitchR1, int pitchR2)
{ 
  pitch1 = pitchR1;
  pitch2 = pitchR2;
  
  if (pitch2 == 0) {
      pitch1 = 0.0;
    }
   
    // backgroundColorR = map(pitch1, 0, 8000, 255, 0);
    backgroundColorB = map(pitch1, 0, 1000, 0, 255);
    backgroundColorV = map(pitch1, 0, 2000, 0, 255);  
    // println(backgroundColorB);
}

public void pitch2(float pitchR12, int pitchR22)
{ 
  pitch12 = pitchR12;
  pitch22 = pitchR22;
  
  if (pitch22 == 0) {
      pitch12 = 0.0;
    }
   
    // backgroundColorR = map(pitch1, 0, 8000, 255, 0);
    backgroundColorB2 = map(pitch12, 0, 1000, 0, 255);
    backgroundColorV2 = map(pitch12, 0, 2000, 0, 255);  
    // println(backgroundColorB);
}



public void specCentroid(float specCentroidR)
{ 
  specCentroid = specCentroidR;
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  specCentroid = map(specCentroid, 0, 8000, 1, 0); 
  // println(specCentroid);
}

public void specCentroid2(float specCentroidR2)
{ 
  specCentroid2 = specCentroidR2;
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  specCentroid2 = map(specCentroid2, 0, 8000, 1, 0); 
  // println(specCentroid);
}



public void specFlatness(float specFlatnessR)
{ 
  specFlatness = specFlatnessR;
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  specFlatness = map(specFlatness, 0, 1, 1, 0); 
  // println(specFlatness);
}

public void specFlatness2(float specFlatnessR2)
{ 
  specFlatness2 = specFlatnessR2;
  // préférable de mettre le calcul ici pour éviter de la calculer à chaque frame
  specFlatness2 = map(specFlatness2, 0, 1, 1, 0); 
  // println(specFlatness);
}






/* incoming osc message are forwarded to the oscEvent method. */

// void oscEvent(OscMessage msg) { // retiré CL

  
  // void oscEvent(OscMessage msg) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
   */


  // Pourquoi se déclenche alors que déjà pluggé ????????????????
  /*
     if (msg.isPlugged()==false) {
   // print the address pattern and the typetag of the received OscMessage 
   println("### received an osc message. with address pattern "+
   msg.addrPattern()+" typetag "+ msg.typetag());
   }
   */


  // inséré dans Plug
  /*
  if (msg.checkAddrPattern("/fftArray")) {
   for (int i= 0; i<BUFFERSIZE2; i++) {
   fftArray[i]= msg.get(i).floatValue();
   }
   }
   */


  /*
  if (msg.checkAddrPattern("/event")) {
   println(msg);
   println(msg.get(0).floatValue());
   }
   */
   
// } // retiré CL
