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

make_libssh() {
	local ARCH=$1
	local root='/tmp/libssh-'$1
	local bin="${root}/lib/libssh2.a"
	if [[ -f $bin ]]; then
		echo "skipping openssl $1"
	else		
		#export CPPFLAGS="-arch $ARCH -pipe -no-cpp-precomp"
		cd libssh2
		rm -rf ./build
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=$root 
		cmake --build . --target install
	fi
}

make_openssl "darwin64-arm64"
make_openssl "darwin64-x86_64"

export OPENSSL_ROOT_DIR="/tmp/openssl-darwin64-x86_64"
env | grep SSL

make_libssh "arm64"
#make_libssh "x86_64"