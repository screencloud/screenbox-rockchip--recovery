#! /bin/bash

TOP_DIR=$(pwd)
BUILDROOT_PATH=$(pwd)/buildroot/
EXTERNAL_PATH=$(pwd)/external
CLEAN_CMD=cleanthen

#define build err exit function
check_err_exit(){
  if [ $1 -ne "0" ]; then
     echo -e $MSG_ERR
     cd $TOP_DIR
     exit 2
  fi
}

#source gstreamer build scrip
source $TOP_DIR/device/rockchip/px3-se/rk_gstreamer_build.sh

echo "build rootfs"
cd $BUILDROOT_PATH
make -j8
check_err_exit $?
cd ..

#source environment variable
source envsetup.sh

FILE='.rkmkdirs_first'
find $TOP_DIR -name rk_make_first.sh | sort -r > $FILE
while read line;do
        #echo "Line # $k: $line"
        mk_path=$(echo $line | sed -r 's@^(/.*/)[^/]+/?@\1@g')
        cd $mk_path
        source $mk_path/rk_make_first.sh $1 $CLEAN_CMD -j8
        check_err_exit $?
        cd -
        #echo $mk_path
        #echo $(pwd)
done < $FILE
[ -d $FILE ] && rm -rf $FILE

FILE='.rkmkdirs'
find $TOP_DIR -name rk_make.sh | sort -r > $FILE
while read line;do
        #echo "Line # $k: $line"
	mk_path=$(echo $line | sed -r 's@^(/.*/)[^/]+/?@\1@g')
        cd $mk_path
        source $mk_path/rk_make.sh $1 $CLEAN_CMD -j8
        check_err_exit $?
        cd -
	#echo $mk_path
	#echo $(pwd)
done < $FILE
[ -d $FILE ] && rm -rf $FILE

echo "build all Done"
