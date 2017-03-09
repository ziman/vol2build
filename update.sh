#!/usr/bin/env bash

set -e
set -x

SRC="$PWD/src"
ROOT="$PWD/build"
OPT_INCLUDE="/opt/local/include"
OPT_LIB="/opt/local/lib"

mkdir -p "$SRC"
mkdir -p "$ROOT"


## hlhdf

if ! [ -d "$SRC/hlhdf" ]; then
    cd "$SRC"; git clone git://git.baltrad.eu/hlhdf.git
fi

cd "$SRC/hlhdf"
git pull
./configure \
    --prefix="$ROOT" \
    --with-hdf5="${OPT_INCLUDE},${OPT_LIB}"
make
make install


## rave

if ! [ -d "$SRC/rave" ]; then
    cd "$SRC"; git clone git://git.baltrad.eu/rave.git
fi

cd "$SRC/rave"
./configure \
    --prefix="$ROOT" \
    --with-hlhdf="$ROOT" \

make
make install


## rsl

if ! [ -d "$SRC/rsl" ]; then
    cd "$SRC"; git clone https://github.com/adokter/rsl.git
fi

cd "$SRC/rsl/decode_ar2v"

cd decode_ar2v
./configure --prefix="$ROOT"
make
make install
export PATH="$ROOT/bin:$PATH"

cd "$SRC/rsl"
./configure --prefix="$ROOT"
make AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:
make install AUTOCONF=: AUTOHEADER=: AUTOMAKE=: ACLOCAL=:


## vol2bird

if ! [ -d "$SRC/vol2bird" ]; then
    cd "$SRC"; git clone https://github.com/adokter/vol2bird.git
fi

cd "$SRC/vol2bird"
./configure \
    --prefix="$ROOT" \
    --with-rave="$ROOT" \
    --with-rsl="$ROOT" \
    --with-gsl="${OPT_INCLUDE},${OPT_LIB}" \

make
make install
