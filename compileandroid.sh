#!/bin/bash


mkdir sqlite3
mkdir libxml
mkdir zlib
mkdir musl

echo "Downloading toolchains"
wget --quiet -P `pwd`/musl http://musl.cc/aarch64-linux-musl-cross.tgz
tar -xzf `pwd`/musl/*gz 

sqlite=`pwd`/sqlite3
libxml=`pwd`/libxml
zlib=`pwd`/zlib
TARGET=aarch64-linux-musl

export TOOLCHAIN=`pwd`/musl/aarch64-linux-musl-cross/bin
export AR=$TOOLCHAIN/aarch64-linux-musl-ar 
export CC=$TOOLCHAIN/aarch64-linux-musl-cc
export AS=$CC
export CXX=$TOOLCHAIN/aarch64-linux-musl-c++
export LD=$TOOLCHAIN/aarch64-linux-musl-ld
export RANLIB=$TOOLCHAIN/aarch64-linux-musl-ranlib
export STRIP=$TOOLCHAIN/aarch64-linux-musl-strip

echo "Toolchain setup done"

echo "Downloading latest PHP.."
git clone https://github.com/php/php-src
echo "Creating config.."
`pwd`/php-src/buildconf

echo "Downloading latest sqlite3.."
wget --quiet -P `pwd`/sqlite3 https://www.sqlite.org/2023/sqlite-autoconf-3410200.tar.gz
tar -xzf `pwd`/sqlite3/*gz 
sqlite-autoconf-3410200/configure --enable-static=yes --prefix=$sqlite --host=$TARGET --enable-shared=no --disable-dependency-tracking --enable-static-shell=no 
make
make install


echo "Downloading latest zlib"
git clone https://github.com/madler/zlibtar
zlibtar/configure --prefix=$zlib --static
make
make install



echo "Downloading latest libxml"
wget --quiet -P `pwd`/libxml https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.10.1/libxml2-v2.10.1.tar.gz
tar -xzf `pwd`/libxml/*gz 
libxml2-v2.10.1/autogen.sh --enable-static=yes \
		--prefix=$libxml
		--host=$TARGET \
		--without-lzma \
		--without-iconv \
		--without-python \
		--enable-shared=no 
make
make install

php-src/configure --host=$TARGET \
--with-sqlite3 \
--enable-static \
--with-zlib=$zlib \
--without-iconv \
--with-libxml=$libxml \
--disable-opcache \
--disable-shared

make -C php-src -j 10


