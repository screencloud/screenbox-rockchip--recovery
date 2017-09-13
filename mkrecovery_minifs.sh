#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
PRODUCT_PATH=$(pwd)/../device/rockchip/px3-se
TOOLS_PATH=$PRODUCT_PATH/mini_fs
ROOTFS_BASE=$(pwd)/rootfs
ROOTFS_PATH=$(pwd)/rootfs/target
FSOVERLAY_PATH=$(pwd)/rootfs/rockchip/px3se/fs-overlay-mini
IMAGE_PATH=$(pwd)/recoveryimg/
LOG_PATH=$(pwd)/../kernel/drivers/video/logo

case "$1" in
	[eE][mM][mM][cC])
		echo "make px3se-emmc-minifs-sdk"
		product=px3se-emmc-minifs-sdk
		kernel_defconfig=px3se_linux_emmc_minifs_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_emmc_defconfig
		img_name=recovery_emmc.img
		;;
	[sS][fF][cC])
		echo "make px3se-sfc-sdk"
		product=px3se-sfc-sdk
    kernel_defconfig=px3se_linux_sfc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_sfc_defconfig
		img_name=recovery_sfc.img
		;;
	[sS][lL][cC])
		echo "make px3se-slc-sdk"
		product=px3se-slc-sdk
    kernel_defconfig=px3se_linux_slc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_slc_defconfig
		img_name=recovery_slc.img
        ;;
	*)
		echo "parameter need:"
		echo "eMMC or slc  or sfc"
		exit
		;;
esac

rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH

echo "make recovery rootfs..."

if [ ! -d $ROOTFS_BASE ]
then
	echo -n "tar xf resource/rootfs_mini.tar.gz..."
	tar zxf resource/rootfs_mini.tar.gz
	echo "done."
fi

cp -f $FSOVERLAY_PATH/S50_updater_init $ROOTFS_PATH/etc/init.d/
cp -f $FSOVERLAY_PATH/parameter $ROOTFS_PATH/etc/
cp -f $FSOVERLAY_PATH/RkUpdater.sh $ROOTFS_PATH/etc/profile.d/
cp -f $FSOVERLAY_PATH/updater $ROOTFS_PATH/usr/bin/
cp -f $FSOVERLAY_PATH/init $ROOTFS_PATH/init


echo "make recovery kernel..."
mv $LOG_PATH/logo_linux_clut224.ppm $LOG_PATH/logo_linux_clut224.ppm-bak
cp -f resource/recovery_logo.ppm $LOG_PATH/logo_linux_clut224.ppm

cd $KERNEL_PATH
make ARCH=arm clean -j4 && make ARCH=arm $recovery_kernel_defconfig -j8 && make ARCH=arm $product.img -j12

cp $TOOLS_PATH/kernelimage $IMAGE_PATH

echo "cp dtb"
cp $KERNEL_PATH/arch/arm/boot/dts/$product.dtb $IMAGE_PATH/

echo "cp zImage"
cp $KERNEL_PATH/arch/arm/boot/zImage $IMAGE_PATH/

echo "revert kernel defconfig"
mv $LOG_PATH/logo_linux_clut224.ppm-bak $LOG_PATH/logo_linux_clut224.ppm
make ARCH=arm clean -j4 && make ARCH=arm $kernel_defconfig && make ARCH=arm $product.img -j12

echo "cat zImage & dtb > zImage-dtb"
cd $IMAGE_PATH && cat zImage $product.dtb > zImage-dtb && cd $TOP_PATH

echo "kernelimage ..."
cd $IMAGE_PATH && ./kernelimage --pack --kernel zImage-dtb recovery.img 0x62000000

cp recovery.img $TOOLS_PATH/$img_name
cd $TOP_PATH

rm -rf $IMAGE_PATH

echo "make recovery image ok !"
