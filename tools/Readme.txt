/***********************************************************************
 * Author：范立创
 * Date：  2017/8/10
 * Email:  francis.fan@rock-chips.com
 ***********************************************************************/
 
1、该工具仅用于Pxse大容量EMMC发布升级固件使用（配合updater程序）。
2、目前支持kernel、resource、rootfs、userdata升级。根据需求在Config文件中的
    setting_emmc.ini配置文件中增加对象项。
3、配置文件要求：
	1） 升级程序根据分区名称解析Firmware.img，因此名称只能是步骤2中的那4个项目。类型可任意配置。
	2） 分区只要不造成分区冲突，起始地址没有要求。但分区长度必须与大容量固件parameter.txt中一一对应，不然会导致升级错误。
4、Firmware.md5是通过Linux系统md5sum 命令计算出的字符串，升级开始前需检验Firmware.img的Md5哈希值与Firmware.md5一致，否则固件错误。