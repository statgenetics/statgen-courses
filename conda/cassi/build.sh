#!/bin/bash

# Unzip the source code
unzip $SRC_DIR/cassi-v2.51-code.zip -d $SRC_DIR

# Change directory to the source code
cd $SRC_DIR/cassi-v2.51-code

# Compile the code
g++ -m64 -O3 *.cpp -o cassi

# Move the compiled binary to the bin directory of the environment
mv cassi $PREFIX/bin/
