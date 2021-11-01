//This code is part of an extension set for SuperCollider 3 (http://supercollider.sourceforge.net/). We follow the same license terms for SuperCollider 3, releasing under GNU GPL 3 
//all code here by Nick Collins http://www.cogs.susx.ac.uk/users/nc81/index.html


#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//metric can be Manhattan, Euclidean, cosine (Foote)

int similarityMatrix(int metric, int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output);
int similarityMatrixSelf(int metric, int sizea, int numfeatures, float * a, float * output); 

//further distance measures possible here including Mahalanobis and Chebyshev http://en.wikipedia.org/wiki/Euclidean_distance
int similarityMatrixManhattan(int sizea, int sizeb, int numfeatures, float * a, float * b, float * output);
int similarityMatrixEuclidean(int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output);
int similarityMatrixCosine(int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output);

//symmetric matrix only in these cases 
int similarityMatrixSelfManhattan(int sizea, int numfeatures, float * a, float * output);
int similarityMatrixSelfEuclidean(int sizea,  int numfeatures, float * a, float * output);
int similarityMatrixSelfCosine(int sizea, int numfeatures, float * a, float * output);




void reduceFeatureVector(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine, int reductiontype);
void reduceFeatureVectorMean(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine);
void reduceFeatureVectorMax(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine);

void reduceSimilarityMatrix(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit, int reductiontype); 
void reduceSimilarityMatrixMean(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit); 
void reduceSimilarityMatrixMin(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit); 




void reduceSimilarityMatrix(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit, int reductiontype) {
	
	switch(reductiontype) {
		case 0:	
			return reduceSimilarityMatrixMean(source, target, numcolumnsold, numcolumnsnew, numrowsold, numrowsnew, unit); 
			break;
		case 1:
		default:
			return reduceSimilarityMatrixMin(source, target, numcolumnsold, numcolumnsnew, numrowsold, numrowsnew, unit); 
			break;
			//return reduceFeatureVectorMax(source, target, oldframes, newframes, numfeatures, combine); 
	}
	
}


void reduceFeatureVector(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine, int reductiontype) {
	
	switch(reductiontype) {
		case 0:	
			return reduceFeatureVectorMean(source, target, oldframes, newframes, numfeatures, combine); 
			
		case1:
		default:
			return reduceFeatureVectorMax(source, target, oldframes, newframes, numfeatures, combine); 
	}
	
}


int similarityMatrix(int metric, int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output) {
	
	switch(metric) {
		case 0:	
			return similarityMatrixCosine(sizea, sizeb,numfeatures,a,b,output); 
			break;
		case 1:	
			return similarityMatrixManhattan(sizea, sizeb,numfeatures,a,b,output); 
			break;
		case 2:
			return similarityMatrixEuclidean(sizea, sizeb,numfeatures,a,b,output); 
			break;
			
		default:
			//problem, nothing happening
			//output = NULL;
			return 1; 
			//			return reducefeaturevectormax(source, target, oldframes, newframes, numfeatures, combine); 
	}
	
	
}



int similarityMatrixSelf(int metric, int sizea, int numfeatures, float * a, float * output) {
	
	switch(metric) {
		case 0:	
			return similarityMatrixSelfCosine(sizea,numfeatures,a,output); 
			break;
		case 1:	
			return similarityMatrixSelfManhattan(sizea,numfeatures,a,output); 
			break;
		case 2:
			return similarityMatrixSelfEuclidean(sizea,numfeatures,a,output); 
			break;
			
		default:
			//problem, nothing happening
			//output = NULL;
			return 1; 
			//			return reducefeaturevectormax(source, target, oldframes, newframes, numfeatures, combine); 
	}
	
	
}



//usage 
//similaritymatrix metric unit preorpost reductiontype outputfilename inputfile1 [inputfile2]

int main (int argc, const char * argv[]) {
    // insert code here...
	
	//char * inputfilename, * outputfilename;
	float * fvs1, *fvs2; //if fvs2 NULL, 
	int numcols, numrows, numfeatures, total1, total2, total1r, total2r; 
	//int numframes2, numfeatures2; 
	
	printf("Calculating Similarity Matrix \n");
	
	int metric = atoi(argv[1]); 
	
	int unit = atoi(argv[2]); 
	
	int prepost = atoi(argv[3]); 
	
	int reductiontype = atoi(argv[4]); 
	
	int self = atoi(argv[5]); 
	
	
	FILE * fpinput1; //,*fpinput2;
	FILE * fpoutput;
	
	fpinput1 = fopen(argv[7], "rb");
	
	fread(&numcols, sizeof(int), 1, fpinput1); 
	fread(&numrows, sizeof(int), 1, fpinput1);
	fread(&numfeatures, sizeof(int), 1, fpinput1); //"dimensions"= size of feature vectors in data
	
	total1 = numcols * numfeatures; 
	fvs1 = new float[total1]; 
	
	fread(fvs1, sizeof(float),total1, fpinput1); 
	
	if(self==0) {
		
		total2 = numrows * numfeatures; 
		fvs2 = new float[total2]; 
		
		fread(fvs2, sizeof(float),total2, fpinput1); 
		
	} else {
		
		total2 = total1; 
		fvs2 = fvs1; 
		
	}
	
	fclose(fpinput1); 
	
	
	
	int reduced1 = numcols/unit; //will round down to integer result
	int reduced2 = numrows/unit; //will round down to integer result
	
	float * output; 
	int status=0; 
	
	if (unit==1) {
		
		output = new float[numcols*numrows]; 
		
		if(self==1) 
			status = similarityMatrixSelf(metric, numcols, numfeatures, fvs1, output);
		else
			status = similarityMatrix(metric, numcols, numrows, numfeatures, fvs1, fvs2, output);
		
	} else {
		
		//pre collapse
		if(prepost==0) {
			
			//reduce feature vector(s) first
			float * fvs1smaller, * fvs2smaller;
			
			total1r = reduced1 * numfeatures; 
			
			fvs1smaller = new float[total1r]; 
			
			reduceFeatureVector(fvs1, fvs1smaller, numcols, reduced1, numfeatures, unit, reductiontype); 
			
			if(self==0) {
				
				total2r = reduced2 * numfeatures; 
				
				fvs2smaller = new float[total2r]; 
				
				reduceFeatureVector(fvs2, fvs2smaller, numrows, reduced2, numfeatures, unit, reductiontype); 
				
			} else {
				fvs2smaller = fvs1smaller; 
			}
			
			//calculate similarity matrix
			output = new float[reduced1*reduced2]; 
			
			if(self==1) 
				status = similarityMatrixSelf(metric, reduced1, numfeatures, fvs1smaller, output);
			else
				status = similarityMatrix(metric, reduced1, reduced2, numfeatures, fvs1smaller, fvs2smaller, output);
			
			//clean up
			delete [] fvs1smaller; 
			if(self==0) {delete [] fvs2smaller; }
			
		} else {
			//post	
			
			//calculate full matrix
			
			float * matrix = new float[numcols*numrows]; 
			
			if(self==1) 
				status = similarityMatrixSelf(metric, numcols, numfeatures, fvs1, output);
			else
				status = similarityMatrix(metric, numcols, numrows, numfeatures, fvs1, fvs2, output);
			
			//now reduce
			
			//must take account of possibly rectangular matrices
			
			output = new float[reduced1*reduced2]; 
			
			reduceSimilarityMatrix(matrix, output, numcols, reduced1, numrows, reduced2, unit, reductiontype);
			
			
			//clean up
			delete [] matrix; 
		}
		
	}
	
	//const char * checkstring = argv[6]; 
	fpoutput = fopen(argv[6], "wb");
	
	//fwrite(&reduced1, sizeof(int), 1, fpoutput); 
	//fwrite(&reduced2, sizeof(float), 1, fpoutput); 
	
	fwrite(output, sizeof(float), reduced1*reduced2, fpoutput); 
	
	fclose(fpoutput); 
	
	if(self==0) delete [] fvs2; 
	delete [] fvs1; 
	
	delete [] output; 
	
    return status;
}


//takes average
void reduceFeatureVectorMean(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine) {
	
	int i,j,k; 
	int pos=0; 
	int posincrement=numfeatures*combine; 
	int now; 
	float average; 
	
	float mult = 1.0f/numfeatures; 
	
	for (i=0; i<newframes; ++i) {
		
		int newbasepos = i*numfeatures; 
		
		for (j=0; j<numfeatures; ++j) {
			
			now = pos+j; 
			
			
			average = 0.0; 
			
			for (k=0; k<combine; ++k) {
				
				average	+= source[now+(k*numfeatures)]; 
				
			}
			
			target[newbasepos+j] = average * mult; 
			
			
		}
		
		pos += posincrement; 
		
	}
	
	
}

//max
void reduceFeatureVectorMax(float * source, float * target, int oldframes, int newframes, int numfeatures, int combine) {
	
	int i,j,k; 
	int pos=0, posincrement=numfeatures*combine; 
	int now; 
	float max, test; 
	
	//	float mult = 1.0f/numfeatures; 
	
	for (i=0; i<newframes; ++i) {
		
		int newbasepos = i*numfeatures; 
		
		for (j=0; j<numfeatures; ++j) {
			
			now = pos+j; 
			
			
			max = 0.0; 
			
			for (k=0; k<combine; ++k) {
				
				test = source[now+(k*numfeatures)]; 
				
				if(test>max) {max= test; }
				
			}
			
			target[newbasepos+j] = max; 
			
			
		}
		
		pos += posincrement; 
		
	}
	
	
}



//just Manhattan for now, increase number of these later; probably have to separate into different functions
int similarityMatrixManhattan(int sizea, int sizeb, int numfeatures, float * a, float * b, float * output) {
	
	int i, j, k; 
	
	float mult= 1.0f/numfeatures; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizeb; 
		
		for (j=0; j<sizeb; ++j) {
			
			int pos2= j*numfeatures; 
			
			float sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				
				sum += fabs(a[pos+k]-b[pos2+k]); 	
				
			}
			
			sum *= mult; 
			
			output[framepos+j]= sum; 
			
			//no shortcuts here, not a symmetric matrix
			//output[(j*numframes)+i]= sum; 
			
		}
		
		//won't print as it goes unless Pipe from SC? 
		//		if(i%40==0) {
		//			printf("similaritymatrix: finished up to column %d \n",i); 
		//		}
		
	}
	
	
	return 0; 
}

//just Manhattan for now, increase number of these later; probably have to separate into different functions
int similarityMatrixSelfManhattan(int sizea, int numfeatures, float * a, float * output) {
	
	int i, j, k; 
	
	float mult= 1.0f/numfeatures; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizea; 
		
		for (j=i; j<sizea; ++j) {
			
			int pos2= j*numfeatures; 
			
			float sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				
				sum += fabs(a[pos+k]-a[pos2+k]); 	
				
			}
			
			sum *= mult; 
			
			output[framepos+j]= sum; 
			output[(j*sizea)+i]= sum; 
			
		}
		
	}
	
	
	return 0; 
}




int similarityMatrixEuclidean(int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output) {
	
	int i, j, k; 
	
	float mult= 1.0f/sqrt(numfeatures); //maximal separation adjustment 
	float temp; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizeb; 
		
		for (j=0; j<sizeb; ++j) {
			
			int pos2= j*numfeatures; 
			
			float sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				temp = (a[pos+k]-b[pos2+k]);
				sum += temp*temp; 	
				
			}
			
			sum = sqrt(sum)*mult; 
			
			output[framepos+j]= sum; 
			//output[(j*numframes)+i]= sum; 
			
		}
		
	}
	
	
	return 0; 
}


int similarityMatrixSelfEuclidean(int sizea, int numfeatures, float * a, float * output) {
	
	int i, j, k; 
	
	float mult= 1.0f/sqrt(numfeatures); //maximal separation adjustment 
	float temp; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizea; 
		
		for (j=i; j<sizea; ++j) {
			
			int pos2= j*numfeatures; 
			
			float sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				temp = (a[pos+k]-a[pos2+k]);
				sum += temp*temp; 	
				
			}
			
			sum = sqrt(sum)*mult; 
			
			output[framepos+j]= sum; 
			output[(j*sizea)+i]= sum; 
			
		}
		
	}
	
	
	return 0; 
}




int similarityMatrixCosine(int sizea, int sizeb,  int numfeatures, float * a, float * b, float * output) {
	
	int i, j, k; 
	
	//float mult= 1.0f/numfeatures; 
	float temp; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizeb; 
		
		float norm1; 
		float sum=0.0; 
		
		for (k=0; k<numfeatures; ++k) {
			temp = a[pos+k];
			sum += temp*temp; 	
			
		}
		
		if(sum>0.000001f)
			norm1 = sqrt(sum); 
		else 
			norm1 = 1.0; 
		
		for (j=0; j<sizeb; ++j) {
			
			int pos2= j*numfeatures; 
			
			float norm2 = 0.0; 
			float innerproduct = 0.0; 
			sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				
				innerproduct += b[pos2+k]*a[pos+k]; 
				
				temp = b[pos2+k];
				sum += temp*temp; 	
				
			}
			
			if(sum>0.000001f)
				norm2 = sqrt(sum); 
			else 
				norm2 = 1.0; 
			
			sum = 1.0- (innerproduct/(norm1*norm2)); //1.0- sum is dissimilarity
			
			output[framepos+j]= sum; 
			//output[(j*numframes)+i]= sum; 
			
		}
		
	}
	
	
	return 0; 
}




int similarityMatrixSelfCosine(int sizea, int numfeatures, float * a, float * output) {
	
	int i, j, k; 
	
	//float mult= 1.0f/numfeatures; 
	float temp; 
	
	for (i=0; i<sizea; ++i) {
		
		int pos = i*numfeatures; 
		int framepos = i*sizea; 
		
		float norm1; 
		float sum=0.0; 
		
		for (k=0; k<numfeatures; ++k) {
			temp = a[pos+k];
			sum += temp*temp; 	
			
		}
		
		if(sum>0.000001f)
			norm1 = sqrt(sum); 
		else 
			norm1 = 1.0; 
		
		for (j=i; j<sizea; ++j) {
			
			int pos2= j*numfeatures; 
			
			float norm2 = 0.0; 
			float innerproduct = 0.0; 
			sum = 0.0; 
			
			for (k=0; k<numfeatures; ++k) {
				
				innerproduct += a[pos2+k]*a[pos+k]; 
				
				temp = a[pos2+k];
				sum += temp*temp; 	
				
			}
			
			if(sum>0.000001f)
				norm2 = sqrt(sum); 
			else 
				norm2 = 1.0; 
			
			sum = 1.0-(innerproduct/(norm1*norm2)); 
			
			output[framepos+j]= sum; 
			output[(j*sizea)+i]= sum; 
			
		}
		
	}
	
	
	return 0; 
}












void reduceSimilarityMatrixMean(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit) {
	
	int i,j,k, l; 
	
	float average; 
	
	float mult = 1.0f/(unit*unit); 
	
	for (i=0; i<numcolumnsnew; ++i) {
		
		int newbaseindex = i*numrowsnew; 
		int oldbaseindex = i*unit*numrowsold; 
		
		//can't go from j=i, not symmetric in general
		for (j=0; j<numrowsnew; ++j) {
			
			//int columnposold = j*unit; 
			
			int basepos = oldbaseindex + (j*unit);
			
			//calculate for this unit by unit square block
			
			average = 0.0; 
			
			
			//columns
			for (l=0; l<unit; ++l) {
				
				int reallybase = basepos+(l*numrowsold); 
				
				//rows
				for (k=0; k<unit; ++k) {
					
					average += source[reallybase+k]; 
				}
				
				
			}
			
			float temp = average * mult; 
			//symmetric
			target[newbaseindex+j] = temp; 
			//target[j*numcolumnsnew+i] = temp; 
			
		}
		
	}
	
	
}




void reduceSimilarityMatrixMin(float * source, float * target, int numcolumnsold, int numcolumnsnew, int numrowsold, int numrowsnew, int unit) {
	
	int i,j,k, l; 
	
	float min, temp; 
	
	//float mult = 1.0f/(unit*unit); 
	
	for (i=0; i<numcolumnsnew; ++i) {
		
		int newbaseindex = i*numrowsnew; 
		int oldbaseindex = i*unit*numrowsold; 
		
		//can't go from j=i, not symmetric in general
		for (j=0; j<numrowsnew; ++j) {
			
			//int columnposold = j*unit; 
			
			int basepos = oldbaseindex + (j*unit);
			
			//calculate for this unit by unit square block
			
			min = 999999.9f; 
			
			//columns
			for (l=0; l<unit; ++l) {
				
				int reallybase = basepos+(l*numrowsold); 
				
				//rows
				for (k=0; k<unit; ++k) {
					
					temp = source[reallybase+k]; 
					
					if (temp<min) min = temp;
				}
				
				
			}
			
			
			target[newbaseindex+j] = min; 
			
		}
		
	}
	
	
}



//
//void reduceSimilarityMatrixMax(float * source, float * target, int numcolumnsold, int numcolumnsnew, int unit) {
//	
//	int i,j,k, l; 
//	
//	float max, temp; 
//
//	for (i=0; i<numcolumnsnew; ++i) {
//		
//		int newbaseindex = i*numcolumnsnew; 
//		int oldbaseindex = i*unit*numcolumnsold; 
//		
//		for (j=i; j<numcolumnsnew; ++j) {
//			
//			//int columnposold = j*unit; 
//			
//			int basepos = oldbaseindex + (j*unit);
//			
//			//calculate for this unit by unit square block
//			
//			max = 0.0; 
//			
//			//rows
//			for (k=0; k<unit; ++k) {
//				
//				//columns
//				for (l=0; l<unit; ++l) {
//					
//					temp =  source[basepos+(l*numcolumnsold)+k]; 
//					
//					if (temp>max) max = temp; 
//				}
//				
//				
//			}
//			
//			target[newbaseindex+j] = max; 
//			target[j*numcolumnsnew+i] = max; 
//			
//		}
//		
//	}
//	
//	
//}

