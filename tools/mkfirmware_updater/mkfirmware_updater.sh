#! /bin/bash

TOP_PATH=$(pwd)
IMAGE_OUT_PATH=$(pwd)/Target
IMAGE_IN_PATH=$(pwd)/Input
RESOURCES_PATH=$(pwd)/Resources
CONFIG_PATH=$(pwd)/Config

rm -rf $IMAGE_OUT_PATH
mkdir -p $IMAGE_OUT_PATH

echo "Package Firmware.img ..."

cp $RESOURCES_PATH/* $IMAGE_OUT_PATH/
cp $CONFIG_PATH/setting_emmc.ini $IMAGE_OUT_PATH/
cp $IMAGE_IN_PATH/* $IMAGE_OUT_PATH/

cd $IMAGE_OUT_PATH && ./firmware_merger -p ./setting_emmc.ini ./
rm Firmware.md5 && md5sum Firmware.img >> Firmware.md5 && cd $TOP_PATH
find $IMAGE_OUT_PATH/* ! -name Firmware* -exec rm -rf {} \;

echo 'Updater Image: Firmware.img is ready'
