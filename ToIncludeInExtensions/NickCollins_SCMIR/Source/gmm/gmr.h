/*
  Copyright (c) 2008 Florent D'halluin , Sylvain Calinon, 
  LASA Lab, EPFL, CH-1015 Lausanne, Switzerland, 
  http://www.calinon.ch, http://lasa.epfl.ch

  The program is free for non-commercial academic use. 
  Please acknowledge the authors in any academic publications that have 
  made use of this code or part of it. Please use this BibTex reference: 
 
  @article{Calinon07SMC,
  title="On Learning, Representing and Generalizing a Task in a Humanoid 
  Robot",
  author="S. Calinon and F. Guenter and A. Billard",
  journal="IEEE Transactions on Systems, Man and Cybernetics, Part B. 
  Special issue on robot learning by observation, demonstration and 
  imitation",
  year="2007",
  volume="37",
  number="2",
  pages="286--298"
  }
*/

#include "Matrix.h"

class GaussianMixture {
  /* GMM class, see main.cpp to see some sample code */
 public :		//was private, but otherwise no way to get back model params when loading from a file!
  int nState,dim;
  Matrix mu;
  Matrix *sigma;
  float *priors;

 public :
  GaussianMixture(){}; 

  // Load the dataset from a file
  Matrix loadDataFile(const char filename []);

  // Save the dataset to a file
  bool saveDataFile(const char filename [], Matrix data);

  // Save the result of a regression
  bool saveRegressionResult(const char fileMu[], const char fileSigma[], Matrix inData, Matrix outData, Matrix outSigma[]);   

  bool loadParams(const char filename[]);
  /* Load the means, priors probabilies and covariances matrices 
     stored in a file .. (see saveParams )*/

  void saveParams(const char filename []);
  /* save current parameters in a file */
 
  void debug(void);
  /* display on screen current parameters */
	

  Matrix doRegression( Matrix in,
		       Matrix * SigmaOut,
		       Vector inComponents,
		       Vector outComponents);
  /* do a regression with current parameters : 
     - output a matrix of size nb row of in * nb components in outComponents
     - the SigmaOut pointer will point to an array of nb row of in or out
     covariances matrices
     - inComponents and outComponents are the index of the dimensions 
     represented in the in and out matrices */

  float pdfState(Vector v,Vector Components,int state);
  /* Compute probabilty of vector v ( corresponding to dimension given 
     in the Components vector) for the given state. */

  float pdfState(Vector v,int state);
  // same as above but v is of same dimension as the GMM 

  /* Spline fitting to rescale trajectories. */
  Matrix HermitteSplineFit(Matrix& inData, int nbSteps, Matrix& outData);

  void initEM_TimeSplit(int nState,Matrix Dataset);
  /* init the GaussianMixture by splitting the dataset into 
     time (first dimension) slices and computing variances 
     and means for each slices. 
     once initialisation has been performed, the nb of state is set */
  
  int doEM(Matrix DataSet);
  /* performs Expectation Maximization on the Dataset, 
     in order to obtain a nState GMM 
     Dataset is a Matrix(nSamples,nDimensions) */
       
};

