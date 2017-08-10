#!/bin/sh

#------------------------------
# this script process uevent of gpio-det uevent
# of rockchip linux platform, for example car-reverse,
# when detect car-reverse gpio state change, uevent will
# send from kernel,and process here by udev rules,
# It will launch camera app directly,you may need to change
# the process
#
# para: GPIO_NAME=car-reverse GPIO_STATE=on
#------------------------------

my_program="cvbsView"
log_file="/var/log/gpio_det.log"
program_log_file="/var/log/cvbsView.log"

function f_check_program() {
  ps_out='ps -ef | grep $1 | grep -v 'grep''
  result=$(echo $ps_out | grep "$1")
  if [[ "$result" != "" ]]; then
    echo "Running"
  else
    echo "Not Running"
  fi
}

echo $2 >> $log_file

result=$(echo $2 | grep "on")
if [[ "$result" != "" ]]; then
  camera_running=$(f_check_program ${my_program})

  echo $camera_running
  if [[ "$camera_running" == "Running" ]]; then
    echo "cvbsView already started" >> $log_file
  else
    echo "run cvbsView" >> $log_file
    echo 0 > /sys/class/graphics/fb0/blank
    #(nohup "$@" >& /dev/null &)
    setsid "/usr/local/cvbsView/cvbsView" >& $program_log_file &
  fi
else
  echo "killall cvbsView" >> $log_file
  killall $my_program
fi

exit 0
~
