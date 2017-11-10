#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/../kernel
RK3399_PATH=$(pwd)/../device/rockchip/rk3399
ROOTFS_BASE=$(pwd)/rootfs
ROOTFS_PATH=$(pwd)/rootfs/target
FSOVERLAY_PATH=$(pwd)/rootfs/rockchip/rk3399/fs-overlay
RECOVERY_OUT=$(pwd)/recoveryImg
RAMDISK_TOOL_PATH=$(pwd)/tools/ramdisk_tool/
LOG_PATH=$(pwd)/../kernel/drivers/video/logo

export PATH=$PATH:${RAMDISK_TOOL_PATH}

echo "make recovery start..."

#初始化操作（清理旧文件）
rm -rf $RECOVERY_OUT
mkdir -p $RECOVERY_OUT
rm -rf $ROOTFS_BASE

echo "make recovery rootfs..."

echo -n "tar xf resource/rootfs.tar.gz..."
tar zxf resource/rootfs.tar.gz
echo "done."

#拷贝升级相关脚本。
cp -f $FSOVERLAY_PATH/busybox $ROOTFS_PATH/bin/
cp -f $FSOVERLAY_PATH/S50_updater_init $ROOTFS_PATH/etc/init.d/
cp -f $FSOVERLAY_PATH/RkUpdater.sh $ROOTFS_PATH/etc/profile.d/
cp -f $FSOVERLAY_PATH/updater $ROOTFS_PATH/usr/bin/
cp -f $FSOVERLAY_PATH/init $ROOTFS_PATH/init

echo "cp kernel.img..."
cp $KERNEL_PATH/arch/arm64/boot/Image $RECOVERY_OUT/kernel

echo "cp resource.img..."
cp $KERNEL_PATH/resource.img $RECOVERY_OUT

echo "create recovery.img with kernel..."

mkbootfs $ROOTFS_PATH | minigzip > $RECOVERY_OUT/ramdisk-recovery.img && \
	truncate -s "%4" $RECOVERY_OUT/ramdisk-recovery.img && \
mkbootimg --kernel $RECOVERY_OUT/kernel --ramdisk $RECOVERY_OUT/ramdisk-recovery.img --second $RECOVERY_OUT/resource.img --output $RECOVERY_OUT/recovery.img

cp $RECOVERY_OUT/recovery.img $RK3399_PATH/rockimg/

echo "make recovery image ok !"
