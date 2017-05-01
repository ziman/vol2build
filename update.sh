#!/usr/bin/env bash

set -e
set -x

SRC="$PWD/src"
ROOT="$PWD/build"
OPT_INCLUDE="/opt/local/include"
OPT_LIB="/opt/local/lib"
platform="$(uname -s)"

mkdir -p "$SRC"
mkdir -p "$ROOT"


## hlhdf

if ! [ -d "$SRC/hlhdf" ]; then
    cd "$SRC"; git clone git://git.baltrad.eu/hlhdf.git
    cd "$SRC/hlhdf"
    if [ "$platform" = "Darwin" ]; then
        ./configure \
            --prefix="$ROOT/hlhdf" \
            --with-hdf5="${OPT_INCLUDE},${OPT_LIB}"
    elif [ "$platform" = "Linux" ]; then
        ./configure \
            --prefix="$ROOT/hlhdf" \
            --with-hdf5="/usr/include/hdf5/serial,/usr/lib/x86_64-linux-gnu/hdf5/serial/"
    fi
fi

cd "$SRC/hlhdf"
git fetch origin
git checkout -f origin/master
if [ "$platform" = "Darwin" ]; then
    sed -i '' -e 's/-bundle/-dynamiclib/g' def.mk
fi
make
make install


## rave

if ! [ -d "$SRC/rave" ]; then
    cd "$SRC"; git clone git://git.baltrad.eu/rave.git
    cd "$SRC/rave"
    ./configure \
        --prefix="$ROOT" \
        --with-hlhdf="$ROOT/hlhdf"
fi

cd "$SRC/rave"
make
make install


## rsl

rsl_needs_configure="no"
if ! [ -d "$SRC/rsl" ]; then
    cd "$SRC"; git clone https://github.com/adokter/rsl.git
    cd "$SRC/rsl/decode_ar2v"
    ./configure --prefix="$ROOT"
    rsl_needs_configure="yes"
fi

cd "$SRC/rsl/decode_ar2v"
make
make install
export PATH="$ROOT/bin:$PATH"

if [ "$rsl_needs_configure" = "yes" ]; then
    cd "$SRC/rsl"
    ./configure --prefix="$ROOT"
fi

cd "$SRC/rsl"
make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
make install AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:


## vol2bird

if ! [ -d "$SRC/vol2bird" ]; then
    cd "$SRC"; git clone https://github.com/adokter/vol2bird.git
else
    cd "$SRC/vol2bird"
    git fetch origin
    git checkout -f origin/master
fi

cd "$SRC/vol2bird"
LDFLAGS="-L/opt/local/lib" CFLAGS="-I/opt/local/include" ./configure \
    --prefix="$ROOT" \
    --with-rave="$ROOT" \
    --with-rsl="$ROOT" \
    --with-confuse="${OPT_LIB}" \
    --with-gsl="${OPT_INCLUDE}/gsl,${OPT_LIB}"

# apply patch
if [ "$platform" = "Darwin" ]; then
    sed -i '' -e 's/-arch i386//g' def.mk
fi

cd "$SRC/vol2bird"
make
make install
