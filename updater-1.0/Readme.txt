/***********************************************************************
 * Author：范立创
 * Date：  2017/9/4
 * Email:  francis.fan@rock-chips.com
 ***********************************************************************/

 1、编译
	首先确保工程目录下buildroot已经成功编译，然后在updater目录下执行如下命令：
	../../buildroot/output/host/usr/bin/arm-rockchip-linux-gnueabihf-gcc -g2 -o updater updater.c recovery_display.c

 2、替换目标
	a) 解压recovery/resource/rootfs.tar.gz。
	b) 将新编译的updater替换解压出的rootfs/rockchip/px3se/fs-overlay/updater。
	c) 重新打包recovery/resource/rootfs.tar.gz，注意名称要一致。
