#!/bin/bash
cd  openssl-OQS-OpenSSL_1_1_1-stable
mkdir oqs
cd ..
cd liboqs-0.9.0
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=../../openssl-OQS-OpenSSL_1_1_1-stable/oqs -DOQS_USE_OPENSSL=OFF ..
ninja
ninja install

cd ..
cd ..
cd openssl-OQS-OpenSSL_1_1_1-stable
chmod +x Configure
./Configure no-shared linux-x86_64 -lm
make -j