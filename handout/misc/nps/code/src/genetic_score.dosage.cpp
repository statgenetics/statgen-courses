#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <cassert>

using namespace std;

/**
 * Calculate genetic risk scores by summing all genetic effects multiplied by 
 * allelic dosages. The allelic dosages are in the dosage format. The 
 * genetic risk scores are written to standard output (screen). 
 *
 * Input parameters:
 * Number of individuals (N)
 * Number of markers (M)
 * allelic effects file
 */

// g++ genetic_score.dosage.cpp -o grs -O2
// g++ genetic_score.dosage.cpp -o grs -O2 -DNDEBUG

int main(int argc, char *argv[]) {

  if (argc != 4) {

    cerr << "NPS v1.1" << endl 
	 << "Usage: " << argv[0] << " <N> <M> <beta file>" 
	 << endl; 

    return 1; 
  }

  int N = atoi(argv[1]);
  int M = atoi(argv[2]);
  char *betafp = argv[3]; 

  assert(N > 0);
  assert(M > 0);

  cerr << "Read beta file: "  << betafp << endl;

  // load beta file 
  int i = 0;
  string line;
  ifstream betafile; 
  double *beta = NULL;

  beta = new double[M];

  betafile.open(betafp); 

  if (!betafile.is_open()) {

    cerr << "Cannot open " << betafp << endl; 

    return 2; 
  }

  while (getline(betafile, line)) {

    beta[i++] = atof(line.c_str()); 
    
  }

  betafile.close();

  cerr << "Done reading beta file" << endl;

  assert(i == M);


  // read genotype file from stdin
  int j;
  double gt_ij;
  double *gliab = NULL;

  gliab = new double[N];

  // initialize
  for (i = 0; i < N; i++) {
    gliab[i] = 0;
  }

  i = 0;

  // header (ignore)
  getline(cin, line);

  while (getline(cin, line)) {

    const char *cstr_pt;
    const char *line_cstr = line.c_str(); 


    // Marker info: first 6 fields 
    // chromosome SNPID rsid position alleleA alleleB
    cstr_pt = strchr(line_cstr, ' ');

    // Skip next 5 columns
    for (int k = 0; k < 5; k++) {
      
      cstr_pt = strchr(cstr_pt + 1, ' '); 

    }

    cstr_pt++; 			// skip whitespace


    // Read genotypes (dosages)
    j = 0; 			// individual index
    char *next_tok = (char *) cstr_pt;

    while (*next_tok != '\0') {

      // allele dosage
      gt_ij = strtod(cstr_pt, &next_tok); 
      gliab[j] += gt_ij * beta[i];
      
      /*
      if (j < 10 || j > (N - 10)) {
	cerr << gt_ij << endl; 
      } 
      */
      
      j++;
      cstr_pt = (const char *) next_tok;
      
    }

    assert(j == N);
    
    /* cerr << "-----" << endl; */
    
    // next marker
    i++;
  }

  assert(i == M);

  
  // print out
  for (j = 0; j < N; j++) {

    cout << gliab[j] << endl;

  }


  // clean up
  delete [] gliab;

  return 0; 
}
