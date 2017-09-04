#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
PX3SE_PATH=$(pwd)/../device/rockchip/px3-se
ROOTFS_PATH=$(pwd)/rootfs/target
FSOVERLAY_PATH=$(pwd)/rootfs/rockchip/px3se/fs-overlay
RECOVERY_OUT=$(pwd)/recoveryImg
RAMDISK_TOOL_PATH=$(pwd)/tools/ramdisk_tool/

export PATH=$PATH:${RAMDISK_TOOL_PATH}

case "$1" in
	[eE][mM][mM][cC])
		echo "make px3se-emmc-minifs-sdk"
		product=px3se-sdk
		recovery_product=px3se-recovery-sdk
		kernel_defconfig=px3se_linux_defconfig
		recovery_kernel_defconfig=px3se_recovery_emmc_defconfig
		recovery_rootfs_defconfig=px3se_recovery_defconfig
		;;
	[sS][fF][cC])
		echo "make px3se-sfc-sdk"
		product=px3se-sfc-sdk
		recovery_product=px3se-recovery-sfc-sdk
        kernel_defconfig=px3se_linux_sfc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_sfc_defconfig
		recovery_rootfs_defconfig=px3se_recovery_defconfig
		;;
	[sS][lL][cC])
		echo "make px3se-slc-sdk"
		product=px3se-slc-sdk
		recovery_product=px3se-recovery-slc-sdk
        kernel_defconfig=px3se_linux_slc_defconfig
		recovery_kernel_defconfig=px3se_recovery_minifs_slc_defconfig
		recovery_rootfs_defconfig=px3se_recovery_defconfig
        ;;
	*)
		echo "parameter need:"
		echo "eMMC or slc  or sfc"
		exit
		;;
esac

rm -rf $RECOVERY_OUT
mkdir -p $RECOVERY_OUT

echo "make recovery rootfs..."
cp -f $FSOVERLAY_PATH/S50_updater_init $ROOTFS_PATH/etc/init.d/

#删除多余文件
[ -f "$ROOTFS_PATH/dev/console" ] && rm $ROOTFS_PATH/dev/console
[ -f "$ROOTFS_PATH/etc/parameter" ] && rm $ROOTFS_PATH/etc/parameter

echo "make recovery kernel..."
cd $KERNEL_PATH
#make ARCH=arm $recovery_kernel_defconfig -j8 && make ARCH=arm $recovery_product.img -j12

echo "cp kernel.img..."
cp $KERNEL_PATH/kernel.img $RECOVERY_OUT

echo "cp resource.img..."
cp $KERNEL_PATH/resource.img $RECOVERY_OUT

echo "revert kernel defconfig"
#make ARCH=arm $kernel_defconfig && make ARCH=arm $product.img -j12 &&


echo "create recovery.img with kernel..." 

mkbootfs $ROOTFS_PATH | minigzip > $RECOVERY_OUT/ramdisk-recovery.img && \
	truncate -s "%4" $RECOVERY_OUT/ramdisk-recovery.img && \
mkbootimg --kernel $RECOVERY_OUT/kernel.img --ramdisk $RECOVERY_OUT/ramdisk-recovery.img --second $RECOVERY_OUT/resource.img --output $RECOVERY_OUT/recovery.img

cp $RECOVERY_OUT/recovery.img $PX3SE_PATH/rockimg/
rm -rf $RECOVERY_OUT/
cd $TOP_PATH

echo "make recovery image ok !"
