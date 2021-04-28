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
		make -j $CPU_CORES_COUNT
		make install_sw
		cd ..
	fi
}

make_libssh() {
	local ARCH=$1
	

	local ARCH=$ARCH
	local root='/tmp/libssh-'$ARCH
	#rm -rf $root
	local bin="${root}/lib/libssh2.a"
	if [[ -f $bin ]]; then
		echo "skipping libssh2 $ARCH"
	else		
		echo "going to build libssh2 $ARCH"
		
		export OPENSSL_ROOT_DIR="/tmp/openssl-"$ARCH
		env | grep SSL
		
		cd libssh2
		rm -rf ./build
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=$root -DCMAKE_OSX_ARCHITECTURES=$ARCH
		cmake --build . --target install -j $CPU_CORES_COUNT
		cd ..
	fi
}

make_libgit() {
	local ARCH=$1
	
	local OPENSSL_ROOT_DIR="/tmp/openssl-"$ARCH
	local libssh_root='/tmp/libssh-'$ARCH
	export CMAKE_INCLUDE_PATH="${libssh_root}/include;${OPENSSL_ROOT_DIR}/include"
	export CMAKE_LIBRARY_PATH="${libssh_root}/lib;${OPENSSL_ROOT_DIR}/lib"
	
	local root='/tmp/libgit-'$ARCH
	#rm -rf $root
	local bin="${root}/lib/libgit2.a"
	if [[ -f $bin ]]; then
		echo "skipping libgit2 $ARCH"
	else		
		echo "going to build libgit2 $ARCH"
		cd libgit2
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

make_libgit "arm64"
make_libgit "x86_64"
