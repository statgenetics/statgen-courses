#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <cassert>
#include <cmath>
#include <limits>
#include <cstdint>

using namespace std;

/**
 * Convert genotypes in the dosage format to standardized genotypes with
 * mean of 0 and variance of 1. 
 *
 * The standardized genotypes are stored in binary files (.stdgt). These binary
 * files are platform-dependent and not intended for transfer between 
 * little-endian (Intel, AMD CPUs) and big-endian(e.g. ARM) systems, or
 * between 32-bit and 64-bit architectures. IEC 559 floating point arithmetic
 * is required.
 * 
 * Input parameters:
 * Number of individuals (N)
 * Number of markers (M)
 * Prefix to output file
 */

// compile 
// g++ -O2 -std=c++0x -o stdgt standardize_gt.dosage.cpp


int main(int argc, char *argv[]) {

  cout << numeric_limits<double>::is_iec559 << endl; 
  cout << sizeof(double) << endl;

  assert(numeric_limits<double>::is_iec559);

  if (argc != 4) {

    cerr << "NPS v1.1" << endl 
	 << "Usage: " << argv[0] << " <N> <M> <outprefix>" 
	 << endl; 

    return 1; 
  }

  int N = atoi(argv[1]);
  int M = atoi(argv[2]);
  char *outprefix = argv[3];

  assert(N > 0);
  assert(M > 0);


  int i = 0;			// snp index
  string line;			// line buffer


  // Allocate space for standardized genotypes 
  double *stdgt = NULL; 	// length N

  stdgt = new double[N];


  // Allocate output buffer
  char *buffer = NULL; 

  buffer = new char[ N * sizeof(double) ]; 

  // Stack buffer for string tokens
  char chrom[128];
  char snpID[128];
  char rsID[128];
  char pos[128];
  char alleleA[128];
  char alleleB[128];

  // open output files
  ofstream meandosfile; 
  ofstream snpinfofile; 
  ofstream stdgtfile; 

  // meandosage OS in a text write mode 
  meandosfile.open(string(outprefix) + ".meandos", ios::out);

  // snpinfo OS in a text write mode
  snpinfofile.open(string(outprefix) + ".snpinfo", ios::out); 

  if (!meandosfile.is_open()) {

    cerr << "Cannot create " << outprefix << ".meandos" << endl; 

    return 1;
  }

  if (!snpinfofile.is_open()) {

    cerr << "Cannot create " << outprefix << ".snpinfo" << endl; 

    return 1;
  }
  
  // header
  meandosfile << "SNPID" << "\t" << "AAF" << endl; 

  snpinfofile << "chromosome" << "\t" << "SNPID" << "\t" << "rsid" << "\t"
	      << "position" << "\t" << "alleleA" << "\t" << "alleleB" << endl; 


  // stdgt OS in a binary write mode 
  stdgtfile.open(string(outprefix) + ".stdgt", ios::out | ios::binary);

  if (!stdgtfile.is_open()) {

    cerr << "Cannot create " << outprefix << ".stdgt" << endl; 

    return 1; 
  }


  int j = 0; 			// individual index

  // Read genotype file from stdin
  // header (ignore)
  getline(cin, line);

  while (getline(cin, line)) {

    /*
    if (i % 1000 == 0) {
      cerr << "Marker " << i << " out of " << M << endl; 
    }
    */
    
    int len_token;
    const char *cstr_pt;
    const char *next_delim_pt;
    const char *line_cstr = line.c_str(); 

    // Marker info: first 6 fields 
    // chromosome SNPID rsid position alleleA alleleB

    // col #1: chromosome
    cstr_pt = line_cstr;
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(chrom, cstr_pt, len_token); 

    chrom[len_token] = '\0';

    snpinfofile << chrom << "\t";

    cstr_pt = next_delim_pt;
    cstr_pt++; 


    // col #2: SNPID
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(snpID, cstr_pt, len_token); 

    snpID[len_token] = '\0';

    meandosfile << snpID << "\t"; 
    snpinfofile << snpID << "\t";

    cstr_pt = next_delim_pt;
    cstr_pt++; 

    // col #3: rsID (skip)
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(rsID, cstr_pt, len_token); 

    rsID[len_token] = '\0';

    snpinfofile << rsID << "\t";

    cstr_pt = next_delim_pt;
    cstr_pt++; 


    // col #4: position
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(pos, cstr_pt, len_token); 

    pos[len_token] = '\0';

    snpinfofile << pos << "\t";

    cstr_pt = next_delim_pt;
    cstr_pt++; 

    // col #5: alleleA
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(alleleA, cstr_pt, len_token); 

    alleleA[len_token] = '\0';

    snpinfofile << alleleA << "\t";

    cstr_pt = next_delim_pt;
    cstr_pt++; 

    // col #5: alleleB
    next_delim_pt = strchr(cstr_pt, ' ');

    len_token = next_delim_pt - cstr_pt;

    assert(len_token < 128);

    memcpy(alleleB, cstr_pt, len_token); 

    alleleB[len_token] = '\0';

    snpinfofile << alleleB << endl;

    cstr_pt = next_delim_pt;
    cstr_pt++; 


    // Read genotypes (dosages)
    j = 0; 			// individual index
    char *next_tok = (char *) cstr_pt;

    while (*next_tok != '\0') {

      // allele dosage
      stdgt[j] = strtod(cstr_pt, &next_tok); 

      j++;
      cstr_pt = (const char *) next_tok;
      
    }

    assert(j == N);


    // Calculate the mean
    long double mean = 0; 

    for (j = 0; j < N; j++) {
      
      mean += stdgt[j]; 

    }

    mean = mean / N; 		// 2 x AF


    // Center allele dosage
    for (j = 0; j < N; j++) {
      stdgt[j] -= (double) mean;
    }


    // Divide by standard deviation

    long double af_i = mean / 2; 
    long double sd_i = sqrt(2 * af_i * (1 - af_i));

    // only if the SNP is not monomorphic
    if (af_i > 0 && af_i < 1) {

      for (j = 0; j < N; j++) {

	stdgt[j] = (double) ((long double) stdgt[j] / sd_i); 

      }

    } else {

      // stdgt_i[j] = 0 for all j
      
      cerr << "warning: monomorphic site: " << i + 1 << ": AF = " << af_i 
	   << endl;
      
      // do nothing
    }

    // Dump mean dosage
    meandosfile << af_i << endl; 

    // Dump stdgt
    memcpy(buffer, stdgt, N * sizeof(double));

    stdgtfile.write(buffer, N * sizeof(double));


    // Next marker
    i++; 
  }

  assert(i == M);

  // Close files
  meandosfile.close();
  snpinfofile.close();
  stdgtfile.close();

  // Free up memory space
  delete buffer; 
  delete stdgt; 

  return 0; 
}
