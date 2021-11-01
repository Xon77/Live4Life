#cmake -DCMAKE_OSX_ARCHITECTURES='i386;x86_64' ..

cmake_minimum_required (VERSION 2.6)
project (SCMIRexecutables)

add_executable(noveltycurve noveltycurve/noveltycurve.cpp)

add_executable(similaritymatrix similaritymatrix/similarity.cpp)

#set to locations of your gsl headers and library folders 
set(LIBGSL /Users/nickcollins/Desktop/tosort/gsl_universal_1.14/libs)
include_directories(/Users/nickcollins/Desktop/tosort/gsl_universal_1.14/gsl)

file(GLOB gmmSources gmm/*cpp)
add_executable(gmm ${gmmSources})

file(GLOB hmmSources hmm/*cpp)
add_executable(hmm ${hmmSources})

target_link_libraries(gmm ${LIBGSL}/libgsl.a ${LIBGSL}/libgslcblas.a)
#target_link_libraries(gmm ${LIBGSL}/libgsl.a ${LIBGSL}/libgslcblas.a ${LIBGSL}/libgsleigen.a ${LIBGSL}/libgslmatrix.a)

file(GLOB nnSources NeuralNet/*cpp)
add_executable(NeuralNet ${nnSources})

INSTALL(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/noveltycurve ${CMAKE_CURRENT_BINARY_DIR}/similaritymatrix ${CMAKE_CURRENT_BINARY_DIR}/NeuralNet ${CMAKE_CURRENT_BINARY_DIR}/hmm ${CMAKE_CURRENT_BINARY_DIR}/gmm DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/../SCMIRExtensions/scmirexec/")