CC=g++
CFLAGS=-O2 -std=c++0x

nps: grs stdgt

grs: src/genetic_score.dosage.cpp
	$(CC) $(CFLAGS) -o grs src/genetic_score.dosage.cpp 

stdgt: src/standardize_gt.dosage.cpp
	$(CC) $(CFLAGS) -o stdgt src/standardize_gt.dosage.cpp

clean:
	rm grs stdgt
