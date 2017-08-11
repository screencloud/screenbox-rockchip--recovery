#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
PRODUCT_PATH=$(pwd)/../device/rockchip/px3-se
TOOLS_PATH=$PRODUCT_PATH/mini_fs
BUILDROOT_PATH=$(pwd)/buildroot
TARGET_PATH=$BUILDROOT_PATH/output/target
PACKAGE_DATA_TOOL_PATH="$(pwd)/buildroot/output/host/usr/bin:$(pwd)/buildroot/output/host/usr/sbin"
PACKAGE_DATA_TOOL=$(pwd)/buildroot/output/host/usr/bin/mke2img
product=$1
flash_type=$2
IMAGE_PATH=$(pwd)/recoveryimg/

rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH

echo "make recovery kernel..."
cd $KERNEL_PATH

make ARCH=arm px3se_recovery_minifs_defconfig -j8 && make ARCH=arm $product.img -j12 &&

cp $TOOLS_PATH/kernelimage $IMAGE_PATH

echo "cp dtb"
cp $KERNEL_PATH/arch/arm/boot/dts/$product.dtb $IMAGE_PATH/

echo "cp zImage"
cp $KERNEL_PATH/arch/arm/boot/zImage $IMAGE_PATH/

echo "cat zImage & dtb > zImage-dtb"
cd $IMAGE_PATH && cat zImage $product.dtb > zImage-dtb && cd $TOP_PATH
echo "kernelimage ..."
cd $IMAGE_PATH && ./kernelimage --pack --kernel zImage-dtb recovery.img 0x62000000

cp recovery.img $TOOLS_PATH/
cd $TOP_PATH

rm -rf $IMAGE_PATH

echo "ok ..."
echo "YOUR KERNEL NEED make xxx_defconfig (choice your project defconfig)"
