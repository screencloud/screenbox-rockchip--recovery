#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
PX3SE_PATH=$(pwd)/../device/rockchip/px3-se
ROOTFS_BASE=$(pwd)/rootfs
ROOTFS_PATH=$(pwd)/rootfs/target
FSOVERLAY_PATH=$(pwd)/rootfs/rockchip/px3se/fs-overlay
RECOVERY_OUT=$(pwd)/recoveryImg
RAMDISK_TOOL_PATH=$(pwd)/tools/ramdisk_tool/

export PATH=$PATH:${RAMDISK_TOOL_PATH}

echo "make recovery start..."

rm -rf $RECOVERY_OUT
mkdir -p $RECOVERY_OUT

echo "make recovery rootfs..."

if [ ! -d $ROOTFS_BASE ]
then
	echo -n "tar xf resource/rootfs.tar..."
	tar xf resource/rootfs.tar
	echo "done."
fi

cp -f $FSOVERLAY_PATH/S50_updater_init $ROOTFS_PATH/etc/init.d/

[ -f "$ROOTFS_PATH/etc/parameter" ] && rm $ROOTFS_PATH/etc/parameter

echo "make recovery kernel..."
cd $KERNEL_PATH
make ARCH=arm px3se_recovery_emmc_defconfig -j8 && make ARCH=arm px3se-recovery-sdk.img -j12

echo "cp kernel.img..."
cp $KERNEL_PATH/kernel.img $RECOVERY_OUT

echo "cp resource.img..."
cp $KERNEL_PATH/resource.img $RECOVERY_OUT

echo "revert kernel defconfig"
make ARCH=arm px3se_linux_defconfig && make ARCH=arm px3se-sdk.img -j12

echo "create recovery.img with kernel..."

mkbootfs $ROOTFS_PATH | minigzip > $RECOVERY_OUT/ramdisk-recovery.img && \
	truncate -s "%4" $RECOVERY_OUT/ramdisk-recovery.img && \
mkbootimg --kernel $RECOVERY_OUT/kernel.img --ramdisk $RECOVERY_OUT/ramdisk-recovery.img --second $RECOVERY_OUT/resource.img --output $RECOVERY_OUT/recovery.img

cp $RECOVERY_OUT/recovery.img $PX3SE_PATH/rockimg/
rm -rf $RECOVERY_OUT/
cd $TOP_PATH

echo "make recovery image ok !"
