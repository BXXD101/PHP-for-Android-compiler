#!/bin/bash

FILE = ""

if [ $1 -eq "aarch64-linux" ]
then 
  ARCH="aarch64-linux-musl"
elif [ $1 -eq "x86_64" ] then
  ARCH="x86_64-linux-musl"
elif then 
  echo "Not supported. Pass one of these: aarch64-linux or x86_64"
  exit 1
fi

echo "Downloading toolchains"
wget --quiet http://musl.cc/$FILE-cross.tgz
tar -xzf $FILE-cross.tgz

git clone https://github.com/php/php-src
echo "Creating config.."
`pwd`/php-src/buildconf

export TARGET=$FILE
export TOOLCHAIN=`pwd`/$FILE-cross/bin
export AR=$TOOLCHAIN/$FILE-ar 
export CC=$TOOLCHAIN/$FILE-cc
export AS=$CC
export CXX=$TOOLCHAIN/$FILE-c++
export LD=$TOOLCHAIN/$FILE-ld
export RANLIB=$TOOLCHAIN/$FILE-ranlib
export STRIP=$TOOLCHAIN/$FILE-strip

#download and compile sqlite
wget https://www.sqlite.org/2023/sqlite-autoconf-3420000.tar.gz
tar xvf sqlite-autoconf*
./configure --enable-static=yes --host=$TARGET --enable-shared=no --disable-dependency-tracking --enable-static-shell=no 
make -j$(nproc)
make install
cd ..

#download and compile zlib
git clone https://github.com/madler/zlib
cd zlib
./configure --static
make -j$(nproc)
make install
cd ..

#download and compile libxml2
wget --quiet https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.10.1/libxml2-v2.10.1.tar.gz
tar -xzf libxml2-v2.10.1.tar.gz
cd libxml2-v2.10.1
./autogen.sh --enable-static=yes --host=$TARGET --without-lzma --without-iconv --without-python --enable-shared=no --with-zlib
make -j$(nproc)
make install
cd ..

#Add more here if you want additional libs

#compile php
cd php-src
./configure CFLAGS="-static -03 -pipe -ffunction-sections -fdata-sections -funsafe-loop-optimizations -fpredictive-commoning -ftracer -ftree-loop-im -frename-registers -fcx-limited-range" --host=$TARGET \
--with-sqlite3 \
--enable-pocketmine-chunkutils
--enable-ipv6 \
--enable-static \
--with-zlib \
--without-iconv \
--with-libxml \
--disable-opcache \
--disable-shared

make LDFLAGS="-all-static -Wl,--gc-sections" -j$(nproc)
cd ..

mv php-src/sapi/cli/php php
