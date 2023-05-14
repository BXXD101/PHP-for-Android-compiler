#!/bin/bash

echo "Downloading toolchains"
wget --quiet http://musl.cc/aarch64-linux-musl-cross.tgz
tar -xzf aarch64-linux-musl-cross.tgz

sqlite=`pwd`/sqlite3
libxml=`pwd`/libxml
zlib=`pwd`/zlib
zip=`pwd`/zip

git clone https://github.com/php/php-src
echo "Creating config.."
`pwd`/php-src/buildconf

export TARGET=aarch64-linux-musl
export TOOLCHAIN=`pwd`/aarch64-linux-musl-cross/bin
export AR=$TOOLCHAIN/aarch64-linux-musl-ar 
export CC=$TOOLCHAIN/aarch64-linux-musl-cc
export AS=$CC
export CXX=$TOOLCHAIN/aarch64-linux-musl-c++
export LD=$TOOLCHAIN/aarch64-linux-musl-ld
export RANLIB=$TOOLCHAIN/aarch64-linux-musl-ranlib
export STRIP=$TOOLCHAIN/aarch64-linux-musl-strip

wget --quiet https://libzip.org/download/libzip-1.9.2.tar.gz
tar -xzf libzip-1.9.2.tar.gz
cd libzip-1.9.2
cmake . \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_PREFIX_PATH=$zip \
	-DCMAKE_INSTALL_PREFIX=$zip \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DBUILD_TOOLS=OFF \
	-DBUILD_REGRESS=OFF \			
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_DOC=OFF \
	-DENABLE_BZIP2=OFF \
	-DENABLE_COMMONCRYPTO=OFF \
	-DENABLE_GNUTLS=OFF \
	-DENABLE_MBEDTLS=OFF \
	-DENABLE_LZMA=OFF
make -j$(nproc)
make install
cd ..

git clone https://github.com/sqlite/sqlite
cd sqlite
./configure --enable-static=yes --prefix=$sqlite --host=$TARGET --enable-shared=no --disable-dependency-tracking --enable-static-shell=no 
make -j$(nproc)
make install
cd ..

git clone https://github.com/madler/zlib
cd zlib
./configure --prefix=$zlib --static
make -j$(nproc)
make install
cd ..

wget --quiet https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.10.1/libxml2-v2.10.1.tar.gz
tar -xzf libxml2-v2.10.1.tar.gz
cd libxml2-v2.10.1
./autogen.sh --enable-static=yes \
		--prefix=$libxml
		--host=$TARGET \
		--without-lzma \
		--without-iconv \
		--without-python \
		--enable-shared=no 
make -j$(nproc)
make install
cd ..

cd php-src
./configure CFLAGS="-static" --host=$TARGET \
--with-sqlite3 \
--enable-ipv6 \
--enable-static \
--with-zlib=$zlib \
--with-zip=$zip \
--without-iconv \
--with-libxml=$libxml \
--disable-opcache \
--disable-shared

make LDFLAGS="-all-static" -j$(nproc)
cd ..

mv php-src/sapi/cli/php php


