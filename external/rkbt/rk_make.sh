#! /bin/sh

TOP_DIR=$(pwd)
BUILDROOT_TARGET_PATH=$(pwd)/../../buildroot/output/target/
aarch64_version=$(aarch64-linux-gcc --version 2>/dev/null)
arm_version=$(arm-linux-gcc --version 2>/dev/null)

if [ ! "$aarch64_version" = "" ] ;then
gcc=aarch64-linux-gcc
echo "gcc is aarch64-linux-gcc"
elif [ ! "$arm_version" = "" ] ;then
gcc=arm-linux-gcc
echo "gcc is arm-linux-gcc"
fi

$gcc -rdynamic -g -funwind-tables  -O0 -D_GNU_SOURCE -o  rkrtkbt rkrtkbt.c   -I$(pwd)

cp $TOP_DIR/rkrtkbt $BUILDROOT_TARGET_PATH/usr/bin/

echo "rkrtkbt is ready on buildroot/output/target/usr/bin/"
