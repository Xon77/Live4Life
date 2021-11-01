/*
  Copyright (c) 2008 Eric Sauser, 
  LASA Lab, EPFL, CH-1015 Lausanne, Switzerland, 
  http://lasa.epfl.ch
*/

#ifndef __MATHLIB_H__
#define __MATHLIB_H__

//#define  USE_T_EXTENSIONS

#include <math.h>
#include "Macros.h"
#include "Vector.h"
#ifdef  USE_T_EXTENSIONS
#include "TVector.h"
#include "Vector3.h"
#endif
#include "Matrix.h"
#ifdef USE_T_EXTENSIONS
#include "TMatrix.h"
#include "Matrix3.h"
#include "Matrix4.h"
#include "Referential.h"
#endif

#endif
