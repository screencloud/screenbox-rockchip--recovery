TOP_PATH=$(pwd)
IMAGE_OUT_PATH=$(pwd)/Target
TOOLS_PATH=$(pwd)/Tools
CONFIG_PATH=$(pwd)/Config


echo "Package Firmware.img ..."

cp $TOOLS_PATH/px3seddr.bin $IMAGE_OUT_PATH/
cp $TOOLS_PATH/px3seloader.bin $IMAGE_OUT_PATH/
cp $TOOLS_PATH/firmware_merger $IMAGE_OUT_PATH/

cp $CONFIG_PATH/setting_emmc.ini $IMAGE_OUT_PATH/

cd $IMAGE_OUT_PATH && ./firmware_merger -p ./setting_emmc.ini ./
rm Firmware.md5
md5sum Firmware.img >> Firmware.md5

rm $IMAGE_OUT_PATH/px3seddr.bin
rm $IMAGE_OUT_PATH/px3seloader.bin
rm $IMAGE_OUT_PATH/setting_emmc.ini
rm $IMAGE_OUT_PATH/firmware_merger

cd $TOP_PATH

echo 'Updater Image: Firmware.img is ready'
