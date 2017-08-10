TOOL_PATH=$(pwd)/build
IMAGE_OUT_PATH=$(pwd)/rockimg/
IMAGE_RELEASE_PATH=$(pwd)/rockimg/Image-release
KERNEL_PATH=$(pwd)/kernel
UBOOT_PATH=$(pwd)/u-boot
PRODUCT_PATH=$(pwd)/device/rockchip/px3-se/

#cd buildroot && make && cd -
rm -rf $IMAGE_OUT_PATH
mkdir -p $IMAGE_OUT_PATH
echo "Package rootfs.img now"
source $PRODUCT_PATH/mkrootfs.sh
cp $(pwd)/buildroot/output/images/rootfs.ext4 $IMAGE_OUT_PATH/rootfs.img

cp $KERNEL_PATH/kernel.img $IMAGE_OUT_PATH
cp $KERNEL_PATH/resource.img $IMAGE_OUT_PATH
#cp $UBOOT_PATH/*MiniLoaderAll_*.bin $IMAGE_OUT_PATH/MiniLoaderAll.bin
#cp $UBOOT_PATH/uboot.img $IMAGE_OUT_PATH
cp $PRODUCT_PATH/rockimg/Px3SeMiniLoaderAll_V2.33.bin $IMAGE_OUT_PATH/
cp $PRODUCT_PATH/rockimg/parameter-emmc.txt $IMAGE_OUT_PATH/
cp $PRODUCT_PATH/rockimg/uboot.img $IMAGE_OUT_PATH/
echo 'Image: image in rockimg is ready'
