﻿// #################################################################################################
//			Studienprojekt Modellbildung & Simulation - 2015/16
// #################################################################################################
// 					zufallstest.cpp
// ------------------------------------Doxygen-Dokumentation----------------------------------------
///  \file zufallstest.cpp
///  \brief
///  Testet spmv, gpudefect, (spmv2) und vergleicht die ergebnisse mit den Implementationen aus DIA.hpp 
///  
//#################################################################################################

#include"gpumatoperations.hpp"
#include <iostream>
#include <math.h>
#include <cstdlib>
#include <time.h>   

using namespace std;
// testet  spmv, gpudefect, (spmv2) für eine Matrix mit vorgegebener Bandstruktur, vorgegebenem Datentyp und zufälligen Einträgen zwischen -100 und 100 (Einträge sind scheinbar nicht wirklich zufällig) 
template<typename type>
void generatetest(int dim, int ndiags, Vector<int>& offset)
{
    Vector<type> x(dim);
    Vector<type> b(dim) ;
    Vector<type> res(dim) ;
    Vector<type> data (dim*ndiags);
	//setze x Daten
    for (int i=0; i< dim; ++i){
		srand (time(NULL));
        x[i]=(static_cast <type> ((rand()) / static_cast <type> (RAND_MAX))*200 - 100);
    }
    //setze Matrix Daten
    for (int i=0; i< ndiags; ++i){
        if(offset[i]<=0){
            for (int j=-offset[i]; j< dim; ++j){
				srand (time(NULL));
                data[i*dim+j]=((static_cast <type> (rand()) / static_cast <type> (RAND_MAX))*200 - 100);
            }
        }else
        {
            for (int j=0; j< dim-offset[i]; ++i){
				srand (time(NULL));
                data[i*dim+j]=((static_cast <type> (rand()) / static_cast <type> (RAND_MAX))*200 - 100);
            }
        }
    }
    DIA<type> mat (dim, ndiags, data, offset);
    cout<<mat.checkIntact()<<endl;

    spmv(b, mat, x);
    defect(res, mat, b, x);
    cout<<"norm gpu ergebnis: "<<norm(b)<<endl;
    cout<<"norm defekt: "<<norm(res)<<endl;
    gpudefect(res, mat, b, x);
    cout<<"norm gpudefekt: "<<norm(res)<<endl;
	/*	
	spmv2(b, mat, x);
	defect(res, mat, b, x);
	cout<<"norm gpu2 ergebnis: "<<norm(b)<<endl;
	cout<<"norm cpu defekt: "<<norm(res)<<endl;
    */
    matvec(b, mat, x);
	gpudefect(res, mat, b, x);
	cout<<"norm cpu ergebnis: "<<norm(b)<<endl;
    cout<<"norm gpudefekt: "<<norm(res)<<endl;
    defect(res, mat, b, x);
    cout<<"norm defekt: "<<norm(res)<<endl;

}
int main (){
    int dim (90000);
    int ndiags(5);
    Vector<int> offset(ndiags);
    offset[0]=-300;
    offset[1]=-1;
    offset[2]=0;
    offset[3]=1;
    offset[4]=300;
    generatetest<double>(dim, ndiags, offset);
}

