#! /bin/bash

TOP_PATH=$(pwd)
KERNEL_PATH=$(pwd)/kernel
PRODUCT_PATH=$(pwd)/device/rockchip/px3-se
TOOLS_PATH=$PRODUCT_PATH/mini_fs
BUILDROOT_PATH=$(pwd)/buildroot
TARGET_PATH=$BUILDROOT_PATH/output/target
PACKAGE_DATA_TOOL_PATH="$(pwd)/buildroot/output/host/usr/bin:$(pwd)/buildroot/output/host/usr/sbin"
PACKAGE_DATA_TOOL=$(pwd)/buildroot/output/host/usr/bin/mke2img
product=$1
flash_type=$2
IMAGE_PATH=$(pwd)/rockimg/Image-$flash_type

if [ "$product"x = ""x ]||[ "$flash_type"x = ""x ];then
        echo "Package firmware [parameter error], such as:"
		echo "mkfirmware_minifs.sh px3se-sfc-sdk sfc - for spi nor flash"
		echo "mkfirmware_minifs.sh px3se-slc-sdk slc - for slc nand flash and spi nand flash"
		echo "mkfirmware_minifs.sh px3se-emmc-minifs-sdk emmc - for mini emmc flash"
        exit
fi

rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH
mkdir -p $TARGET_PATH/data

cp $TOOLS_PATH/firmware_merger $IMAGE_PATH
cp $TOOLS_PATH/kernelimage $IMAGE_PATH
if [ -f $TOOLS_PATH/setting_$flash_type.ini ];then
	cp $TOOLS_PATH/setting_$flash_type.ini $IMAGE_PATH/
	cp $TOOLS_PATH/S50_px3se_init_$flash_type $TARGET_PATH/etc/init.d/S50_px3se_init
else
	echo "Package firmware fail [parameter error], such as:"
	echo "mkfirmware_minifs.sh px3se-sfc-sdk sfc - for spi nor flash"
	echo "mkfirmware_minifs.sh px3se-slc-sdk slc - for slc nand flash and spi nand flash"
	echo "mkfirmware_minifs.sh px3se-emmc-minifs-sdk emmc - for mini emmc flash"
	exit 
fi

echo "create userdata.img..."
if [ "$flash_type"x = "sfc"x ]; then
	echo "The flash type is sfc nor"
	cp $TOOLS_PATH/mkfs.jffs2 $IMAGE_PATH
	$IMAGE_PATH/mkfs.jffs2 --root=$TARGET_PATH/data --eraseblock=0x3000  --pad=0x600000 -o $IMAGE_PATH/userdata.img
else
	export PATH=$PATH:${PACKAGE_DATA_TOOL_PATH}
	${PACKAGE_DATA_TOOL} -d $TARGET_PATH/data -G 4 -r 1 -b 10240 -i 0 -o $IMAGE_PATH/userdata.img
fi
echo "userdata.img done."

FSTYPE=squashfs
echo rootfs filesysystem is $FSTYPE
cp $TOOLS_PATH/mksquashfs $TOP_PATH

#package rootfs.img
echo "Package rootfs.img now"

FSTYPE=squashfs
echo rootfs filesysystem is $FSTYPE

source $PRODUCT_PATH/mkrootfs.sh
cp $BUILDROOT_PATH/output/images/rootfs.squashfs $IMAGE_PATH/rootfs.img

echo "cp dtb"
cp $KERNEL_PATH/arch/arm/boot/dts/$product.dtb $IMAGE_PATH/

echo "cp zImage"
cp $TOP_PATH/kernel/arch/arm/boot/zImage $IMAGE_PATH/

echo "cat zImage & dtb > zImage-dtb"
cd $IMAGE_PATH && cat zImage $product.dtb > zImage-dtb && cd $TOP_PATH
echo "kernelimage ..."
cd $IMAGE_PATH && ./kernelimage --pack --kernel zImage-dtb kernel.img 0x62000000 > /dev/null  && cd $TOP_PATH

echo "cp loader ddr root"
cp $TOOLS_PATH/px3seloader.bin $IMAGE_PATH
cp $TOOLS_PATH/px3seddr.bin $IMAGE_PATH

echo "firmware_merger ..."
cd $IMAGE_PATH && ./firmware_merger -p ./setting_$flash_type.ini ./ && cd $TOP_PATH
find $IMAGE_PATH/* ! -name Firmware* -exec rm -rf {} \;
cp $TOOLS_PATH/px3se_usb_boot_*.bin $IMAGE_PATH/
echo "ok ..."

chmod a+r -R $IMAGE_PATH/
