#!/bin/bash

make_openssl() {
	local root='/tmp/openssl-'$1
	local bin="${root}/bin/openssl"
	if [[ -f $bin ]]; then
		echo "skipping openssl $1"
	else
		echo "going to build openssl $1"
		cd openssl
		make clean
		./Configure $1 --prefix=$root
		make -j 8
		make install_sw
		cd ..
	fi
}

make_openssl "darwin64-arm64"
make_openssl "darwin64-x86_64"

export OPENSSL_ROOT_DIR="/tmp/openssl-darwin64-arm64"
env | grep SSL

cd libssh2/build
cmake ..
cmake —-build .