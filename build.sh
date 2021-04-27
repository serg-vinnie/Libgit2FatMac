#!/bin/bash

CPU_CORES_COUNT=$(sysctl -n hw.ncpu)

echo "cores: "$CPU_CORES_COUNT

make_openssl() {
	local root='/tmp/openssl-'$1
	local bin="${root}/bin/openssl"
	if [[ -f $bin ]]; then
		echo "skipping openssl $1"
	else
		echo "going to build openssl $1"
		cd openssl
		make clean
		./Configure 'darwin64-'$1 --prefix=$root
		make -j 8
		make install_sw
		cd ..
	fi
}

make_libssh() {
	export OPENSSL_ROOT_DIR="/tmp/openssl-"$1
	env | grep SSL

	local ARCH=$1
	local root='/tmp/libssh-'$1
	#rm -rf $root
	local bin="${root}/lib/libssh2.a"
	if [[ -f $bin ]]; then
		echo "skipping libssh2 $1"
	else		
		echo "going to build libssh2 $1"
		cd libssh2
		rm -rf ./build
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=$root -DCMAKE_OSX_ARCHITECTURES=$ARCH
		cmake --build . --target install -j $CPU_CORES_COUNT
		cd ..
	fi
}

make_openssl "arm64"
make_openssl "x86_64"

make_libssh "arm64"
make_libssh "x86_64"