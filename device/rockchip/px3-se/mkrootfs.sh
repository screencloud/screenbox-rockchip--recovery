#! /bin/bash

top_dir=$(pwd)
BUILDROOT_PATH=$(pwd)/buildroot/
BUILDROOT_TARGET_PATH=$(pwd)/buildroot/output/target/

#define build err exit function
check_err_exit(){
  if [ $1 -ne "0" ]; then
     echo -e $MSG_ERR
     cd $TOP_DIR
     exit 2
  fi
}

#get config
source $top_dir/device/rockchip/px3-se/package_config.sh

if [[ $enable_io_tool =~ "no" ]];then
	echo "remove io tool"
	FILE=$BUILDROOT_TARGET_PATH/usr/bin/io
	[ -d $FILE ] && rm -rf $FILE
fi

if [[ $enable_adb =~ "no" ]];then
	echo "remove adbd tool"
	FILE=$BUILDROOT_TARGET_PATH/usr/sbin/adbd
	[ -d $FILE ] && rm -rf $FILE
fi

echo "build and package rootfs"
cd $BUILDROOT_PATH
make -j8
check_err_exit $?
cd $top_dir

echo "build rootfs Done..."
