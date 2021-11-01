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

//some modifications for writing out model data by Nick Collins 2011


#include <iostream>
#include <sstream>
#include <fstream>
#include <cstdlib>
#include "MathLib.h"
#include "gmr.h"

#define MAXITER 200

Matrix GaussianMixture::loadDataFile(const char filename [])
{
	// Load the dataset from a file
	Matrix result;
	Vector vecTmp;
	float valTmp;
	char tmp[1024];
	unsigned int l=0, c=0;
	
	std::ifstream f(filename);
	if (f.is_open()){
		// Get number of row
		while(!f.eof()){ 
			f.getline(tmp,1024);
			l++;
			if (l==1){
				// Get number of columns
				std::istringstream strm;
				strm.str(tmp); 
				while (strm >> valTmp)
					c++;
			}
		}
		result.Resize(l-1,c); // then the matrix can be allocated
		f.clear();
		f.seekg(0); // returns to beginning of the file
		for(unsigned int i=0;i<l;i++){ 
			f.getline(tmp,1024);
			std::istringstream strm;
			strm.str(tmp); 
			for(unsigned int j=0;j<c;j++){
				strm >> result(i,j);
			}
		}
		f.close();
	}
	else{
		std::cout  << std::endl << "Error opening file " << filename << std::endl; 
		exit(0);
	}
	return result;
}

bool GaussianMixture::saveDataFile(const char filename [], Matrix data)
{
	// Save the dataset to a file
	std::ofstream f(filename);
	if (f.is_open()) {
		for (unsigned int j = 0; j < data.RowSize(); j++){
			for (unsigned int i = 0; i < data.ColumnSize(); i++)
				f << data(j,i) << " ";
			f << std::endl;
		}
		f.close();
	}
	return 1;
}

bool GaussianMixture::saveRegressionResult(const char fileMu[], const char fileSigma[], Matrix inData, Matrix outData, Matrix outSigma[])
{
	// Save the result of a regression
	std::ofstream Mu_file(fileMu); // regressed data
	std::ofstream Sigma_file(fileSigma); // covariances matrices
	for(unsigned int i=0;i<outData.RowSize();i++) {
		Mu_file << inData(i,0) << " ";
		for(unsigned int j=0;j<outData.ColumnSize();j++) 
			Mu_file << outData(i,j) << " ";
		Mu_file << std::endl;
		for(unsigned int k=0;k<outData.ColumnSize();k++) {
			for(unsigned int j=0;j<outData.ColumnSize();j++)
				Sigma_file << outSigma[i](k,j) << " ";
		}
		Sigma_file << std::endl;
	}
	return 1;
}

bool GaussianMixture::loadParams(const char fileName[])
{
	// Load coefficient of a GMM from a file (stored by saveParams Method
	// or with matlab
	std::ifstream fich(fileName);
	if (!fich.is_open())
		return false;
	fich >> dim >> nState;
	priors = new float[nState];
	for (int s = 0; s < nState; s++)
	{
		fich >> priors[s];
	}
	mu.Resize(nState,dim);
	for (int i = 0; i < nState; i++)
	{
		for (int j = 0;j<dim;j++)
			fich >> mu(i,j);
	}
	sigma = new Matrix[nState];
	for (int s = 0; s < nState; s++)
	{
		sigma[s] = Matrix(dim,dim);
		for (int i = 0; i < dim; i++)
		{
			for (int j = 0;j<dim;j++)
				fich >> sigma[s](i,j);
		}
	}
	return true;
}

void GaussianMixture::debug(void)
{
	/*display on std output info about current parameters */
	Vector v;
	Matrix smat;
	std::cout << "Nb state : "<< this->nState <<std::endl;
	std::cout << "Dimensions : "<< this->dim  <<std::endl;
	std::cout << "Priors : ";
	for(int i = 0;i<nState;i++) {
		std::cout << priors[i] ;
	}
	std::cout << std::endl;
	std::cout << "Means :";
	mu.Print();
	std::cout << "Covariance Matrices :";
	v=Vector(2);
	v(0)=0;
	v(1)=2;
	for(int i =0;i<nState;i++) {
		//float det;
		//Matrix inv;
		//sigma[i].GetMatrixSpace(v,v,inv);
		//inv.Print();
		//std::cout << det << std::endl;
		sigma[i].Print();
	}
}



//to calculate spectral decomposition (eigenvalues and eigenvectors, to get 'square root' of matrix)
#include <gsl/gsl_math.h>
#include <gsl/gsl_eigen.h>


void GaussianMixture::saveParams(const char filename [])
{
	
	int i, j, s; 
	
	// save the current GMM parameters, coefficents to a file, to be retrieved 
	// by the loadParams method
	std::ofstream file(filename);
	file << dim << " ";
	file << nState << " " << std::endl; //for consistency of output; always space on end of lines leads to some issues; additional array element
	for(i=0;i<nState;i++) file << priors[i] <<" ";
	file << std::endl;
	for(s=0;s<nState;s++) {
		for(i=0;i<dim;i++) {
			file << mu(s,i) <<" ";
		}
		file << std::endl;
	}
	for(s=0;s<nState;s++) {
		for(j=0;j<dim;j++) {
			for(i=0;i<dim;i++) {
				file << sigma[s](i,j) <<" ";
			}
			file << std::endl;
		}
	}
	
	//also save inverse, for loading into SC. Won't affect model work here (in fact, will be doing all subsequent calculations then in SC itself 	
	
	Matrix inv_sigma;
	float det_sigma;
	
	for(s=0;s<nState;s++) {
		
		sigma[s].Inverse(inv_sigma,&det_sigma); 
		
		if(sigma[s].IsInverseOk())
		{
			
			file << 1 << " " << det_sigma << " " << std::endl; 
			//output flag to show if OK
			
			
			//output matrix if alright
			for(j=0;j<dim;j++) {
				for(i=0;i<dim;i++) {
					
					// row i, column j
					
					file << inv_sigma(i,j) <<" ";
				}
				file << std::endl;
			}
			
		} else {
			file << 0 << " " << std::endl; 	//inversion failure
		}
		
	}
	
	
	//would have to do nState times
	
//	Matrix eigenmatrix;
//	Vector eigenvalues; 
//	
//	int test = sigma[0].TriEigen(eigenvalues,eigenmatrix,30); 
//	
//	std::cout << "eigentest" << test << std::endl;
//	
//	if(test>=1) {
//	for(int j=0;j<dim;j++) {
//		for(int i=0;i<dim;i++) {
//			std::cout << eigenmatrix(i,j) <<" ";
//		}
//		std::cout << std::endl;
//	}
//	}

	
	//Use QR algorithm to get eigenvalues on diagonal of R
	
	//eigen decomposition via gsl

	
	double * matrixdatad = new double[dim*dim]; 
	double * eigenvaluesqrts = new double[dim]; 
	
	for(s=0;s<nState;s++) {
		
		float * matrixdata = sigma[s].Array(); 

			for(i=0;i<dim;i++) {
				int baserow = i*dim; 
				
				for(j=0;j<dim;j++) {
					matrixdatad[baserow+j] = (double) matrixdata[baserow+j]; 
					}
		
			}
				
	gsl_matrix_view m = gsl_matrix_view_array (matrixdatad, dim, dim);
	
	gsl_vector *eval = gsl_vector_alloc (dim);
	gsl_matrix *evec = gsl_matrix_alloc (dim, dim);
	
	gsl_eigen_symmv_workspace * w = gsl_eigen_symmv_alloc (dim);
	
	gsl_eigen_symmv (&m.matrix, eval, evec, w);
	
	gsl_eigen_symmv_free (w);
	
	//by default eigenvalues will have largest first, want it that way
	
		//gsl_eigen_symmv_sort (eval, evec, GSL_EIGEN_SORT_ABS_ASC);

	//need to calculate eigenvectore matrix * diagonal matrix of root of eigenvalues 	
	//which is jth column * jth sqrt of eigenvalue	
	
		
	for (i = 0; i < dim; i++)
		eigenvaluesqrts[i] = sqrt(gsl_vector_get(eval,i)); 	
		
		for(j=0;j<dim;j++) {
			for(i=0;i<dim;i++) {
				
				// row i, column j
				
				file << (gsl_matrix_get(evec,i,j)*eigenvaluesqrts[j]) <<" ";
			}
			file << std::endl;
		}	
		
		
	//double gsl_matrix_get (const gsl_matrix * m, size_t i, size_t j)	
//		
//		for (i = 0; i < dim; i++)
//		{
//			double eval_i 
//			= gsl_vector_get (eval, i);
//			gsl_vector_view evec_i 
//			= gsl_matrix_column (evec, i);
//			
//			std::cout <<"eigenvalue = "<< eval_i << std::endl;
//			std::cout <<"eigenvector" << std::endl;
//			gsl_vector_fprintf (stdout, 
//								&evec_i.vector, "%g");
//		}

	gsl_vector_free (eval);
	gsl_matrix_free (evec);

	
	}
	
	
}

Matrix GaussianMixture::HermitteSplineFit(Matrix& inData, int nbSteps, Matrix& outData)
{
	/* Spline fitting to rescale trajectories. */
	
	if(nbSteps<=0)
		return outData;
    
	const int dataSize  = inData.ColumnSize(); 
	const int inSize    = inData.RowSize();
	const int outSize   = nbSteps;
	
	outData.Resize(outSize,dataSize);
	for(int i=0;i<outSize;i++){
		// Find the nearest data pair
		const float cTime = float(i)/float(outSize-1)*float(inSize-1);
		int   prev, next;
		float prevTime, nextTime;
		
		prev      = int(floor(cTime));
		next      = prev+1;
		prevTime  = float(prev);
		nextTime  = float(next); 
		const float nphase = (cTime-prevTime)/(nextTime-prevTime);
		const float s1 = nphase;
		const float s2 = s1*nphase;
		const float s3 = s2*nphase; 
		const float h1 =  2.0f*s3 - 3.0f*s2 + 1.0f;
		const float h2 = -2.0f*s3 + 3.0f*s2;
		const float h3 =       s3 - 2.0f*s2 + s1;
		const float h4 =       s3 -      s2;
		// The first column is considered as a temporal value 
		outData(i,0) = (float)i;
		for(int j=1;j<dataSize;j++){
			const float p0 = (prev>0?inData(prev-1,j):inData(prev,j));
			const float p1 = inData(prev,j);
			const float p2 = inData(next,j);      
			const float p3 = (next<inSize-1?inData(next+1,j):inData(next,j));
			const float t1 = 0.5f*(p2-p0);
			const float t2 = 0.5f*(p3-p1);
			outData(i,j) = p1*h1+p2*h2+t1*h3+t2*h4;
		}
	}   
	return outData;  
}

void GaussianMixture::initEM_TimeSplit(int nState,Matrix DataSet)
{
	/* init the GaussianMixture by splitting the dataset into 
	 time (first dimension) slices and computing variances 
	 and means for each slices. 
	 once initialisation has been performed, the nb of state is set */
	
	Vector * mean = new Vector[nState];
	int nData = DataSet.RowSize();
	this->nState = nState;
	this->dim = DataSet.ColumnSize();
	float tmax = 0;
	Matrix index(nState,nData);
	int * pop = new int[nState];
	priors = new float[nState];
	mu.Resize(nState,dim);
	sigma = new Matrix[nState];
	
	
	Matrix unity(dim,dim); /* defining unity matrix */
	for(int k = 0;k<dim;k++) unity(k,k)=1.0;
	
	for(int n = 0;n<nData;n++) /* getting the max value for time */
	{
		if(DataSet(n,0) > tmax) tmax = DataSet(n,0); 
	}
	for(int s=0;s<nState;s++) /* clearing values */
	{
		mean[s].Resize(dim,true);
		pop[s]=0;
	}
	
	/* divide the dataset into slices of equal time
     (tmax/nState) and compute the mean for each slice
     the pop table index to wich slice belongs each sample */
	for(int n = 0;n<nData;n++) 
	{
		int s = (int)((DataSet(n,0)/(tmax+1))*nState);
		//std::cout << s << std::endl;
		mean[s] += DataSet.GetRow(n);
		index(s,pop[s]) = (float)n;
		pop[s] +=1;
	}
	
	for(int s =0;s<nState;s++)
	{
		mu.SetRow(mean[s]/(float)pop[s],s); /* initiate the means computed before */
		sigma[s]=Matrix(dim,dim);
		priors[s]=1.0f/nState; /* set equi-probables states */
		for(int ind=0;ind<pop[s];ind++)
		{
			for(int i=0;i<dim;i++) /* Computing covariance matrices */
			{
				for(int j=0;j<dim;j++)
				{
					sigma[s](i,j) += (DataSet((int)index(s,ind),i) - mu(s,i)) \
					*(DataSet((int)index(s,ind),j)-mu(s,j));
				}
			}
		}
		sigma[s] *= 1.0f/pop[s];
		sigma[s] += unity * 1e-5f; /* prevents this matrix from being non-inversible */
	}
}

int GaussianMixture::doEM(Matrix DataSet)
{
	/* perform Expectation/Maximization on the given Dataset :
     Matrix DataSet(nSamples,Dimensions).
     The GaussianMixture Object must be initialised before 
     (see initEM_TimeSplit method ) */
	
	int nData = DataSet.RowSize();
	int iter = 0;
	float log_lik;
	float log_lik_threshold = 1e-8f;
	float log_lik_old = -1e10f;
	
	Matrix unity(dim,dim);
	for(int k = 0;k<dim;k++) unity(k,k)=1.0;
	
    
	//EM loop
	
	while(true)
	{
		float * sum_p = new float[nData];
		Matrix pxi(nData,nState);
		Matrix pix(nData,nState);
		Vector E;
		
		//char strtmp[64];
		//  sprintf(strtmp, "gmms/%03d.gmm",iter);
		//std::cout << strtmp << std::endl;
		//saveParams(strtmp);
		
		iter++;
		if (iter>MAXITER){
			std::cout << "EM stops here. Max number of iterations has been reached." << std::endl;
			return iter;
		}
		
		float sum_log = 0; 
		
		// Expectation Computing 
		for(int i =0;i<nData;i++)
		{
			sum_p[i]=0;
			for(int j=0;j<nState;j++)
			{ 
				float p = pdfState(DataSet.GetRow(i),j);  // P(x|i)
				if(p==0) {
					std::cout << p << std::endl;    
					std::cout << "Error: Null probability. Abort.";
					exit(0);
					return -1;
				}
				pxi(i,j)= p;
				sum_p[i] += p*priors[j];
			} 
			sum_log += log(sum_p[i]);
		}
		for(int j=0;j<nState;j++)
		{
			for(int i=0;i<nData;i++)
			{
				pix(i,j) = pxi(i,j)*priors[j]/sum_p[i]; // then P(i|x) 
			}   
		} 
		
		// here we compute the log likehood 
		log_lik = sum_log/nData; 
		if(fabs((log_lik/log_lik_old)-1) < log_lik_threshold )
		{
			/* if log likehood hasn't move enough, the algorithm has
			 converged, exiting the loop */
			//std::cout << "threshold ok" << std::endl;
			return iter;;
		}
		//std::cout << "likelihood " << log_lik << std::endl;
		log_lik_old = log_lik;
		
		// Update Step
		pix.SumRow(E);
		for(int j=0;j<nState;j++) 
		{
			priors[j]=E(j)/nData; // new priors 
			Vector tmu(dim);
			Matrix tmsigma(dim,dim);
			for(int i=0;i<nData;i++) // Means update loop
			{
				tmu += DataSet.GetRow(i)*pix(i,j); 
			}   
			mu.SetRow(tmu/E(j),j);
			
			for(int i=0;i<nData;i++) // Covariances updates
			{
				Matrix Dif(dim,1);
				Dif.SetColumn((DataSet.GetRow(i)-mu.GetRow(j)),0);
				tmsigma += (Dif*Dif.Transpose())*pix(i,j);
			}
			sigma[j] = tmsigma/E(j) + unity * 1e-5f;
		}
	}
	return iter;
}

float GaussianMixture::pdfState(Vector Vin,int state)
{
	/* get the probability density for a given state and a given vector */
	Matrix inv_sigma;
	float det_sigma;
	double p;
	Vector dif;
	sigma[state].Inverse(inv_sigma,&det_sigma); 
	if(sigma[state].IsInverseOk())
	{
		dif = Vin - mu.GetRow(state);
		p=(double)(dif*(inv_sigma*dif));
		p=exp(-0.5*p)/sqrt(pow(2*3.14159,dim)*fabs(det_sigma));
		if(p < 1e-40) return 1e-40f;
		else return (float)p;
	}
	else 
	{
		// sigma[state].Print();
		std::cout << "fail invert sigma matrix" << state << std::endl;
		return 0;
	}
}


float GaussianMixture::pdfState(Vector Vin,Vector Components,int state) 
{
	/* Compute the probability density function at vector Vin, 
     (given along the dimensions Components), for a given state */ 
	Vector mu_s;
	Matrix sig_s;
	Matrix inv_sig_s;
	float det_sig;
	float p;
	int dim_s;
	dim_s = Components.Size();
	mu.GetRow(state).GetSubVector(Components,mu_s);
	sigma[state].GetMatrixSpace(Components,Components,sig_s);
	sig_s.Inverse(inv_sig_s,&det_sig);
	if(sig_s.IsInverseOk())
	{
		p = (Vin-mu_s) * ( inv_sig_s*(Vin-mu_s));
		p = exp(-0.5f*p)/sqrt(pow(2.0f*3.14159f,dim_s)*fabs(det_sig));
		return p;
	}
	else
	{
		std::cout << "Error in the inversion of sigma" << std::endl;
		exit(0);
		return 0;
	}
}



Matrix GaussianMixture::doRegression(Matrix in,Matrix * SigmaOut,Vector inComponents,Vector outComponents)
{
	int nData = in.RowSize();
	int outDim = outComponents.Size();
	Matrix Pxi(nData,nState);
	Matrix out(nData,outDim);
	Matrix * subSigma;
	Matrix * subSigmaVar;
	Matrix subMu;
	Matrix subMuIn;
	Matrix subMuOut;
	
	for(int i=0;i<nData;i++)
	{
		float norm_f = 0.0f;
		for(int s=0;s<nState;s++){
			float p_i = priors[s]*pdfState(in.GetRow(i),inComponents,s);
			Pxi(i,s) = p_i;
			norm_f += p_i;
		}
		Pxi.SetRow(Pxi.GetRow(i)/norm_f,i);
	}
	
	subSigma = new Matrix[nState];
	subSigmaVar = new Matrix[nState];
	mu.GetColumnSpace(outComponents,subMuOut);
	mu.GetColumnSpace(inComponents,subMuIn);
	
	for(int s=0;s<nState;s++)
	{
		Matrix isubSigmaIn;
		Matrix subSigmaOut;
		sigma[s].GetMatrixSpace(inComponents,inComponents,subSigmaOut);
		subSigmaOut.Inverse(isubSigmaIn);
		sigma[s].GetMatrixSpace(outComponents,inComponents,subSigmaOut);
		subSigma[s] = subSigmaOut*isubSigmaIn;
		sigma[s].GetMatrixSpace(outComponents,outComponents,subSigmaOut);
		sigma[s].GetMatrixSpace(inComponents,outComponents,isubSigmaIn);
		subSigmaVar[s] = subSigmaOut - subSigma[s]*isubSigmaIn;
		
	}
	
	for(int i=0;i<nData;i++)
	{
		Vector sv(outDim,true);
		Vector sp(outDim,true);
		SigmaOut[i] = Matrix(outDim,outDim);
		for(int s=0;s<nState;s++)
		{
			sp = subMuOut.GetRow(s); 
			sp = sp + subSigma[s]*(in.GetRow(i)-subMuIn.GetRow(s));
			sv += sp*Pxi(i,s);
			
			// CoVariance Computation
			SigmaOut[i]=SigmaOut[i] + subSigmaVar[s]*(Pxi(i,s)*Pxi(i,s));
		}
		out.SetRow(sv,i);
	}
	return out;
}

