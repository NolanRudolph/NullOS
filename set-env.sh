#!/bin/bash

# MAKE SURE THE SCRIPT IS RUN FROM /path/to/NullOS

# Sets up the Linux environment to use the GCC-based cross-compiler
if ! [[ -f boot.s ]]; then
  echo "Please run script from /path/to/NullOS"
  exit 1
fi

# Export required variables in user's current environment
export PATH=$PATH:$PWD/opt/cross/bin
export TARGET=i1686-elf
export PREFIX=$PWD/opt/cross

function help
{
  printf "Usage: ./$0 [-b | --build]\n"
  printf "\t-b | --build : Build the source files required for cross-compiler\n"
  exit 1
}

BUILD=0

while [[ $# -gt 0 ]]; do
  key="$1"
  
  case $key in
    -b|--build)
      BUILD=1
      shift
      shift
      ;;
    -h|--help)
      help
      ;;
    *)
    shift  
    ;;
  esac
done
set -- "${POSITIONAL[@]}"

if [ $BUILD == 1 ]; then
  # File structure setup
  mkdir src src/build-binutils src/build-gcc opt opt/cross
  cd src

  # Obtaining cross-compiler sources
  git clone git://sourceware.org/git/binutils-gdb.git
  wget https://ftp.gnu.org/gnu/gcc/gcc-10.1.0/gcc-10.1.0.tar.gz # MAY BE DEPRECATED
  tar -xzf gcc-10.1.0.tar.gz
  rm gcc.10.1.0.tar.gz
   
  # Make source (binutils)
  cd build-binutils
  ../binutils-gdb/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror
  make
  make install

  # Make source (gcc)
  cd ../build-gcc
  ../gcc-10.1.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers
  make all-gcc
  make all-target-libgcc
  make install-gcc
  make install-target-libgcc
fi

# Make the binary kernel
make
