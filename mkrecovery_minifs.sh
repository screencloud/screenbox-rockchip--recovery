#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
PRODUCT_PATH=$(pwd)/../device/rockchip/px3-se
TOOLS_PATH=$PRODUCT_PATH/mini_fs
BUILDROOT_PATH=$(pwd)/buildroot
TARGET_PATH=$BUILDROOT_PATH/output/target
PACKAGE_DATA_TOOL_PATH="$(pwd)/buildroot/output/host/usr/bin:$(pwd)/buildroot/output/host/usr/sbin"
PACKAGE_DATA_TOOL=$(pwd)/buildroot/output/host/usr/bin/mke2img
flash_type=$2
IMAGE_PATH=$(pwd)/recoveryimg/

case "$1" in
	[eE][mM][mM][cC])
		echo "make px3se-emmc-minifs-sdk"
		product=px3se-emmc-minifs-sdk	
		kernel_defconfig=px3se_linux_emmc_minifs_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_emmc_defconfig
		;;
	[sS][fF][cC])
		echo "make px3se-sfc-sdk"
		product=px3se-sfc-sdk
                kernel_defconfig=px3se_linux_sfc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_sfc_defconfig
		;;
	[sS][lL][cC])
		echo "make px3se-slc-sdk"
		product=px3se-slc-sdk
                kernel_defconfig=px3se_linux_slc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_slc_defconfig
                ;;
	*)
		echo "parameter need:"
		echo "eMMC or slc  or sfc"
		exit
		;;
esac

rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH

echo "make recovery kernel..."
cd $KERNEL_PATH

make ARCH=arm $recovery_kernel_defconfig -j8 && make ARCH=arm $product.img -j12 &&

cp $TOOLS_PATH/kernelimage $IMAGE_PATH

echo "cp dtb"
cp $KERNEL_PATH/arch/arm/boot/dts/$product.dtb $IMAGE_PATH/

echo "cp zImage"
cp $KERNEL_PATH/arch/arm/boot/zImage $IMAGE_PATH/

echo "revert kernel defconfig"
make ARCH=arm $kernel_defconfig

echo "cat zImage & dtb > zImage-dtb"
cd $IMAGE_PATH && cat zImage $product.dtb > zImage-dtb && cd $TOP_PATH
echo "kernelimage ..."
cd $IMAGE_PATH && ./kernelimage --pack --kernel zImage-dtb recovery.img 0x62000000

cp recovery.img $TOOLS_PATH/
cd $TOP_PATH

rm -rf $IMAGE_PATH

echo "make recovery image ok !"
