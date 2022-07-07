wget https://www.openssl.org/source/openssl-1.1.1o.tar.gz
tar xf openssl-1.1.1o.tar.gz
cd openssl-1.1.1o
./config
make
make test
make install
