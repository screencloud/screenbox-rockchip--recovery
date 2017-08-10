#!/bin/sh

#------------------------------
# this script process uevent of camera uevent
# of rockchip cif platform, for example adv7181,
# when adv7181 detect signal change, uevent will
# send from kernel,and process here by udev rules,
# It will send to pipe to notity camera app
#
# para: CVBS_NAME=ADV7181 NOW_INPUT_MODE=CVBS RESOLUTION=720x576
#------------------------------

pipe_path=/tmp/cvbsView_fifo
log_file="/var/log/camera-uevent.log"

echo $3 >> $log_file
str=$3
result=$(echo $3 | grep "RESOLUTION")
if [[ "$result" != "" ]]; then
  height=${str##*x}
  tmp=${str%x*}
  width=${tmp##*=}

  if [[ ! -p $pipe_path ]]; then
    echo "pipe no ready" >> $log_file
    exit 1
  else
    echo "write pipe" >> $log_file
    echo $3 > $pipe_path
  fi
else
  echo "no RESOLUTION found"
fi

exit 0
