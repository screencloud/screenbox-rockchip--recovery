#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <string.h>
#include <sys/time.h>
#include <stdlib.h>

int main (int argc, char **argv) {
	int ret;
	char cmd[512]={0};

	usleep(2*1000*1000);
	system("echo 1 > /sys/class/rfkill/rfkill0/state");
	usleep(1*1000*1000);
	if(argv[1] != NULL) {
		fprintf(stderr,"rkbt argv %s\n",argv[1]);
		sprintf(cmd,"hciattach_rtk -n -s 115200 %s rtk_h5 &",argv[1]);
		system(cmd);
	} else {
		system("hciattach_rtk -n -s 115200 ttyS0 rtk_h5 &");
	}
	usleep(5*1000*1000);
	system("/usr/libexec/bluetooth/bluetoothd --compat -n &");
	system("sdptool add A2SNK");
	system("hciconfig hci0 up");
}
