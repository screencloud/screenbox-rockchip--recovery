#! /bin/bash

TOP_DIR=$(pwd)
BUILDROOT_TARGET_PATH=$(pwd)/../../../buildroot/output/target/

cp $(pwd)/lib/libfsmanage.so $BUILDROOT_TARGET_PATH/usr/lib/
cp $(pwd)/bin/px3seBase $BUILDROOT_TARGET_PATH/usr/sbin/
cp $(pwd)/wifi/dnsmasq.conf $BUILDROOT_TARGET_PATH/etc/
cp S12_launcher_init $BUILDROOT_TARGET_PATH/etc/init.d/
cp S50_px3se_init $BUILDROOT_TARGET_PATH/etc/init.d/
cp S90_vehicle_exit $BUILDROOT_TARGET_PATH/etc/init.d/

#Character Font
cp lib/fzytk.ttf $BUILDROOT_TARGET_PATH/usr/lib/fonts/

#copy gt9xx_module.ko
cp lib/gt9xx_module.ko $BUILDROOT_TARGET_PATH/usr/lib/

#get config
source package_config.sh

if [[ $enable_bluetooth =~ "yes" ]];then
        echo "enable bluetooth"
        mkdir -p $BUILDROOT_TARGET_PATH/etc/bluetooth/
	cp $(pwd)/bluetooth/realtek/fw/uart/* $BUILDROOT_TARGET_PATH/etc/bluetooth/
	cp $(pwd)/bluetooth/realtek/hciattach_rtk $BUILDROOT_TARGET_PATH/usr/sbin/
fi

if [[ $enable_sdcard_udisk =~ "yes" ]];then
        echo "enable sdcard udisk auto mount"
	mkdir -p $BUILDROOT_TARGET_PATH/etc/udev/rules.d/
	mkdir -p $BUILDROOT_TARGET_PATH/mnt/sdcard/
	mkdir -p $BUILDROOT_TARGET_PATH/mnt/udisk/
	cp $(pwd)/sdcard-udisk-udev/mount-sdcard.sh $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/sdcard-udisk-udev/mount-udisk.sh $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/sdcard-udisk-udev/umount-sdcard.sh $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/sdcard-udisk-udev/umount-udisk.sh $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/sdcard-udisk-udev/rules.d/add-sdcard-udisk.rules $BUILDROOT_TARGET_PATH/etc/udev/rules.d/
	cp $(pwd)/sdcard-udisk-udev/rules.d/remove-sdcard-udisk.rules $BUILDROOT_TARGET_PATH/etc/udev/rules.d/
fi

if [[ $enable_carplay =~ "yes" ]];then
        echo "enable carplay"
	cp $(pwd)/carplay/siri.png $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/carplay/lib/*.so $BUILDROOT_TARGET_PATH/lib/
	cp $(pwd)/carplay/z-link* $BUILDROOT_TARGET_PATH/bin/
	cp $(pwd)/carplay/unz-link.sh $BUILDROOT_TARGET_PATH/bin/
	cp $(pwd)/carplay/mdnsd $BUILDROOT_TARGET_PATH/bin/
fi

if [[ $enable_EasyConnected =~ "yes" ]];then
        echo "enable EasyConnected"
	cp $(pwd)/EasyConnect/lib/*.so* $BUILDROOT_TARGET_PATH/usr/lib/
	mkdir -p $BUILDROOT_TARGET_PATH/usr/bin/EasyConnect/
	cp $(pwd)/EasyConnect/EasyConnected.RXW01.Linux $BUILDROOT_TARGET_PATH/usr/bin/EasyConnect/
	cp -r $(pwd)/EasyConnect/Resource/ $BUILDROOT_TARGET_PATH/usr/bin/EasyConnect/
	cp -r $(pwd)/EasyConnect/server/ $BUILDROOT_TARGET_PATH/usr/bin/EasyConnect/
	cp -r $(pwd)/EasyConnect/lic/ $BUILDROOT_TARGET_PATH/usr/bin/EasyConnect/
fi

#codec use external chip
if [[ $codec_use_ES8396 =~ "yes" ]];then
        echo "codec use ES8396 chip"
	cp alsa_conf/es8396/alsa.conf $BUILDROOT_TARGET_PATH/usr/share/alsa/alsa.conf
fi

#codec use px3-se(inside chip)
if [[ $codec_use_px3se =~ "yes" ]];then
        echo "codec use px3-se chip"
        cp alsa_conf/px3-se/alsa.conf $BUILDROOT_TARGET_PATH/usr/share/alsa/alsa.conf
fi

if [[ $enable_cvbsView =~ "yes" ]]; then
	echo "enable cvbsView"
	mkdir -p $BUILDROOT_TARGET_PATH/etc/udev/rules.d/
	cp $(pwd)/cif-camera-udev/*.sh $BUILDROOT_TARGET_PATH/etc/
	cp $(pwd)/cif-camera-udev/rules.d/*.rules $BUILDROOT_TARGET_PATH/etc/udev/rules.d/
fi
