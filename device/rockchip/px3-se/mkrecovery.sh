MAGE_OUT_PATH=$(pwd)/rockimg
KERNEL_PATH=$(pwd)/kernel
ROOTFS_PATH=$(pwd)/buildroot/output/target
RECOVERY_OUT=$(pwd)/rockimg/recovery
PACKAGE_DATA_TOOL_PATH=$(pwd)/ramdisk_tool/
UPDATER_PX3SE_PATH=$(pwd)/device/rockchip/px3-se
UPDATER_BIN_PATH=$(pwd)/device/rockchip/px3-se/bin
UPDATER_TOOL_PATH=$(pwd)/device/rockchip/px3-se/ramdisk_tool/
PARAMETER_PATH=$(pwd)/device/rockchip/px3-se/rockimg/parameter-recovery.txt

export PATH=$PATH:${PACKAGE_DATA_TOOL_PATH}

if [ ! -d "$RECOVERY_OUT" ]; then
  mkdir $RECOVERY_OUT
fi

#删除多余文件
if [ -f "$ROOTFS_PATH/dev/console" ]; then
	rm $ROOTFS_PATH/dev/console
fi

#拷贝打包工具
if [ ! -d "$PACKAGE_DATA_TOOL_PATH" ];then
	cp -rf $UPDATER_TOOL_PATH $(pwd)
fi

#copy 升级程序
cp $UPDATER_BIN_PATH/updater $ROOTFS_PATH/usr/bin/

#U盘自动挂载
mkdir -p $ROOTFS_PATH/etc/udev/rules.d/
mkdir -p $ROOTFS_PATH/mnt/sdcard/
mkdir -p $ROOTFS_PATH/mnt/udisk/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/mount-sdcard.sh $ROOTFS_PATH/etc/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/mount-udisk.sh $ROOTFS_PATH/etc/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/umount-sdcard.sh $ROOTFS_PATH/etc/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/umount-udisk.sh $ROOTFS_PATH/etc/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/rules.d/add-sdcard-udisk.rules $ROOTFS_PATH/etc/udev/rules.d/
cp $UPDATER_PX3SE_PATH/sdcard-udisk-udev/rules.d/remove-sdcard-udisk.rules $ROOTFS_PATH/etc/udev/rules.d/


echo -n "create recovery.img with kernel... " 
[ -d $ROOTFS_PATH ] && \
mkbootfs $ROOTFS_PATH | minigzip > $RECOVERY_OUT/ramdisk-recovery.img && \
	truncate -s "%4" $RECOVERY_OUT/ramdisk-recovery.img && \
mkbootimg --kernel $KERNEL_PATH/kernel.img --ramdisk $RECOVERY_OUT/ramdisk-recovery.img --second $KERNEL_PATH/resource.img --output $RECOVERY_OUT/recovery.img
echo "done."
