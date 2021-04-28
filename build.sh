#!/bin/bash

CPU_CORES_COUNT=$(sysctl -n hw.ncpu)
COMMON_ROOT="/tmp/git"
OPENSSL_ROOT=$COMMON_ROOT"/openssl-"

echo "cores: "$CPU_CORES_COUNT

make_openssl() {
	local ARCH=$1
	local root=$OPENSSL_ROOT$ARCH
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
	local root=$COMMON_ROOT'/libssh-'$ARCH
	#rm -rf $root
	local bin="${root}/lib/libssh2.a"
	if [[ -f $bin ]]; then
		echo "skipping libssh2 $ARCH"
	else		
		echo "going to build libssh2 $ARCH"
		
		export OPENSSL_ROOT_DIR=$OPENSSL_ROOT$ARCH
		env | grep SSL
		
		cd libssh2
		[[ -d ./build ]] && rm -r ./build
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=$root -DCMAKE_OSX_ARCHITECTURES=$ARCH -DCMAKE_CXX_FLAGS="-g -O0"
		cmake --build . --target install -j $CPU_CORES_COUNT
		cd ../..
	fi
}

make_libgit() {
	local ARCH=$1
	
	local libssl_root=$OPENSSL_ROOT$ARCH
	export OPENSSL_ROOT_DIR=$libssl_root
	export PKG_CONFIG_PATH="${libssl_root}/lib/pkgconfig"
	env | grep PKG_CONFIG_PATH
	
	local root=$COMMON_ROOT'/libgit-'$ARCH
	#rm -rf $root
	local bin="${root}/lib/libgit2.a"
	
	if [[ -f $bin ]]; then
		echo "skipping libgit2 $ARCH"
	else		
		echo "going to build libgit2 $ARCH"
		cd libgit2
		[[ -d ./build ]] && rm -r ./build
		mkdir build
		cd build
		cmake .. -DCMAKE_INSTALL_PREFIX=$root -DCMAKE_OSX_ARCHITECTURES=$ARCH
		cmake --build . --target install -j $CPU_CORES_COUNT
		cd ../..
	fi
}

make_openssl "arm64"
make_openssl "x86_64"

make_libssh "arm64"
make_libssh "x86_64"

make_libgit "arm64"
#make_libgit "x86_64"
