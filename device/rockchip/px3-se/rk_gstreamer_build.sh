#! /bin/bash

TOP_DIR=$(pwd)
BUILDROOT_PATH=$(pwd)/buildroot/
EXTERNAL_PATH=$(pwd)/external

#update gstreamer-rockchip common
cd $EXTERNAL_PATH/gstreamer-rockchip

if [ -f *.patch ];then
echo "remove /external/gstreamer-rockchip patchs.."
rm -rf *.patch
fi

if test ! -f common/gst-autogen.sh;
then
        echo "+ Setting up common submodule"
        git submodule init
fi
git submodule update
cd $TOP_DIR

FILE='.gstreamer1-rockchip-patch'
cd $BUILDROOT_PATH/package/rockchip/gstreamer1-rockchip
find . -name "*.patch" | sort -r > $FILE
while read line;do
        #echo "Line # $k: $line"
        patch=$(echo $line | sed -r 's@^(/.*/)[^/]+/?@\1@g')
        external_patch=$EXTERNAL_PATH/gstreamer-rockchip/${patch:2}
        if [ ! -f $external_patch ];then
		echo "jump..."
		cp -f $patch $EXTERNAL_PATH/gstreamer-rockchip/
		cd $EXTERNAL_PATH/gstreamer-rockchip/
		git apply --check $patch 1> /dev/null  2>&1
		if [[ $? -eq "0" ]]; then
			git am $patch
		fi
		cd -
        fi
done < $FILE
[ -d $FILE ] && rm -rf $FILE
cd $TOP_DIR
