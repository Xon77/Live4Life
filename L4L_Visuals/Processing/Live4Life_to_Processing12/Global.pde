// ------------------------------------ //
// Global variables, enum and constants //
// ------------------------------------ //



// OSC communication
OscP5 oscP5;                     // objet for OSC send and receive
// NetAddress myRemoteLocation;  // objet for service address



// Global variables
// int i = 0;
// int j = 0;
//  int currentX = 0;
//  int currentY = 0;



int selVisual = 0; // Changement du visuel

int selBackground = 0; // Changement du visuel de fond - Valeur initiale
int selMaxBackground = 5; // Changement du visuel de fond - Valeur Max.
int selBackgroundColor = 0;

// Crée une array de taille 512 pour contenir les deux séquences miroir de 0 à 255 puis de 255 à 0
int[] seqBackgroundColorValues = new int[512];
int seqBackgroundColorIndex = 0;

int selSpectreColor = 0; // Changement du visuel de la couleur du spectre - Valeur initiale
int selMaxSpectreColor = 5; // Changement du visuel de la couleur du spectre - Valeur initiale

int selLight = 0; // Changement de light - Valeur initiale
int selMaxLight = 3; // Changement de light - Valeur Max.

int visualRepartition = 0; // Pour changer de représentation visuelle de regroupé à réparti veticalement par pistes
int visualStroke = 0; // Pour voir les traits sur les objets générés

int maxSize = 6; // Taille de l'objet



// Création d'une array pour répartir les objets en fonction de leurs pistes
float[][] widthlists = {
  {1.0},
  {0.5, 1.0},
  {0.33, 0.66, 1.0},
  {0.25, 0.5, 0.75, 1.0},
  {0.2, 0.4, 0.6, 0.8, 1.0},
  {0.166, 0.333, 0.5, 0.666, 0.833, 1.0},
  {0.143, 0.286, 0.429, 0.571, 0.714, 0.857, 1.0},
  {0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0}
};
/*
for (int i = 0; i < widthlists.length; i++) {
    print("Liste avec " + (i + 1) + " éléments : ");
    printArray(widthlists[i]);
}
*/



Float durLifeLeftListA = 0.0;
Float durLifeListA = 0.0;
Float durListA = 0.0;
int trackListA = 0;
int trackListIndexA = 0;
float[] widthlistsA;
Float bufUListA = 0.0;
Float ampListA = 0.0;
Float rateUListA = 0.0;
Float panUListA = 0.0;
String bufTypeListA = "A";

// Déclaration de listes variables pour chaque paramètre des évènements sonores en cours de lecture
FloatList durList = new FloatList(); // durée de quelques centièmes de secondes à 30 secondes
FloatList durLifeList = new FloatList(); // durée ci-dessus * / le frameRate (pour retirer les éléments sonores à leur fin)
FloatList durLifeLeftList = new FloatList(); // durée du reste de vie de l'évènement en frame

IntList trackList = new IntList(); // piste - 8 pistes de 0 à 7
IntList synList = new IntList(); // Type de synthèse - une vingtaine de synthèse - à partir de 0 ...

FloatList ampList = new FloatList(); // Amplitude de 0 à 1 - peut monter jusqu'à 1.5
IntList envList = new IntList(); // Type d'enveloppe de volume (une dizaine) : linéaire, sinus, percussive
// à récupérer aussi les données slider variables selon les pistes et les séquences - à charger au début et lors des modifications
// atk / rel / width1 / width2 / & buffer bufSpec
// Comment transférer et récupérer des données d'enveloppe ???

FloatList rateUList = new FloatList(); // Vitesse de lecture ou fréquence midi selon le type de synthèse choisie : 
// normalisée de 0 à 1
FloatList rateList = new FloatList(); // Vitesse de lecture ou fréquence midi selon le type de synthèse choisie : 
// de 0 à 1280 (plus généralement de 0 à 10)
// à récupérer aussi l'info négative si fichier est lue à l'envers XXX

StringList bufTypeList = new StringList(); // Type de dossier (2 premières lettres du dossier)
IntList bufFolderValueList = new IntList(); // N° de dossier son
FloatList bufUList = new FloatList(); // N° de fichier son dans un dossier son spécifique : normalisée de 0 à 1
IntList bufList = new IntList(); // N° de fichier son dans un dossier son spécifique : variable de quelques-uns à des centaines
FloatList offList = new FloatList(); // Position dans le fichier son : de 0 à 1

FloatList strUList = new FloatList(); // Paramètre pour certaines synthèses
// exemple Time Stretching pour synthèse 4 : normalisée de 0 à 1
FloatList cenUList = new FloatList(); // Paramètre pour certaines synthèses
//exemple Décalage fréquentiel pour synthèse 4 : normalisée de 0 à 1

IntList spaList = new IntList(); // Type de spatialisation - une trentaine pouvant aller à une centaine : 
// pointilliste / linéaire / circulaire / variables selon données spectrales / ambisonique
// à récupérer les données de sorties et les buffers de trajectoires ambisoniques XXX
FloatList panUList = new FloatList(); // Panning stéréo fichier son : de 0 à 1
IntList outLList = new IntList(); // N° d'enceinte Links utilisée pour certains types de spatialisation stéréo vers mulitiphonie
IntList outRList = new IntList(); // N° d'enceinte Right utilisée pour certains types de spatialisation stéréo vers mulitiphonie

IntList fxLList = new IntList(); // Type d'effet Gauche variable : 5 au max en série ou parallèle
IntList fxRList = new IntList(); // Type d'effet Droit variable : 5 au max en série ou parallèle
// à récupérer les données les sliders des effets et du type d'effet dans les popUp menus XXX



// int listSize = 0; // Pas utilisé
int colorFFT = 0; // pour changement de couleur progressif du spectre quand nouvel évènement
float backgroundColorR = 0;
float backgroundColorV = 0;
float backgroundColorB = 0;

float backgroundColorR2 = 0;
float backgroundColorV2 = 0;
float backgroundColorB2 = 0;



// Pour savoir combien de pistes jouent
int uniqueCount = 0; 
/* int countUniqueElements(IntList list) {
  IntList uniqueList = new IntList();
  for (int i = 0; i < list.size(); i++) {
    int item = list.get(i);
    if (!uniqueList.hasValue(item)) {
      uniqueList.append(item);
    }
  }
  return uniqueList.size();
}
*/
int countUniqueElements(IntList list) {
  int maxElement = list.max();
  boolean[] encountered = new boolean[maxElement + 1];
  int uniqueCount = 0;
  for (int i = 0; i < list.size(); i++) {
    int item = list.get(i);
    if (!encountered[item]) {
      encountered[item] = true;
      uniqueCount++;
    }
  }
  return uniqueCount;
}

int findIndexOfIntInList(IntList list, int valueToFind) {
  for (int i = 0; i < list.size(); i++) {
    if (list.get(i) == valueToFind) {
      return i;
    }
  }
  return 0; // Retourne 0 si la valeur n'est pas trouvée
}



// Déclaration d'une array pour le signal FFT
final int BUFFERSIZE = 2048;  // should correspond with fft size in supercollider
final int BUFFERSIZE2 = BUFFERSIZE/2;
float[] fftArray;
float[] fftArray2;

// Déclaration de données high-level des server : Loudness, Pitch
float loudness;
float pitch1;
int pitch2;
float specCentroid;
float specFlatness;

float loudness2;
float pitch12;
int pitch22;
float specCentroid2;
float specFlatness2;

// Fonction pour vérifier si l'IntList contient un chiffre supérieur à X
boolean containsValueGreaterThanX(IntList list, int value) {
  for (int i = 0; i < list.size(); i++) {
    int currentValue = list.get(i);
    if (currentValue > value) {
      return true;
    }
  }
  return false;
}

int server2Track = 2;  // Valeur de référence




// Déclaration de variables pour la matrice de fond
Cell[][] grid;
int nbCols;
int nbRows;
int cellW = 27; 
int cellH = 27;
int centerCellI = 0;
int centerCellJ = 0;
float gridAlpha = 0.3;
