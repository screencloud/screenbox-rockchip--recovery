/*
 *  Copyright (c) 2017 Rockchip Electronics Co. Ltd.
 *  Author: francis <francis.fan@rock-chips.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	 http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <string.h>

#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <pwd.h>
#include <errno.h>
#include <signal.h>
#include <linux/watchdog.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <assert.h>
#include <time.h>
#include <openssl/md5.h>
#include <dirent.h>
#include <string.h>
#include <sys/mount.h>



#include "updater.h"

static STRUCT_PART_INFO g_partition;  //size 2KB

//print fwinfo.
int debug_fwinfo_print(UpdaterInfo* fwinfo, int flag)
{
	if(!flag)
		return 0;

	printf("--->fwinfo->update_version: 0x%08x\n", fwinfo->update_version);
	printf("--->fwinfo->update_mode:%x\n", fwinfo->update_mode);
	printf("--->fwinfo->update_path(len=%d):%s\n\n", strlen(fwinfo->update_path), fwinfo->update_path);

	return 0;
}

static int update_read_file(int fd, void *buffer, int size)
{
    int readcnd = 0;
    int ret = 0;
    unsigned char *p = (unsigned char*)buffer;

	if(NULL == p)
	{
		printf("%s invalid input params \n", __FUNCTION__);
		return -1;
	}
	readcnd = 0;
	ret = 0;

    while (readcnd < size)
    {
        ret = read(fd, p+readcnd, size-readcnd);
        if (ret <= 0)
        {
        	if (ret < 0)
        	{
        		perror("read");
        	}
            return readcnd;
        }
        readcnd += ret;
    }
    return readcnd;
}

static int update_write_file(int fd, void *buffer, int size)
{
    int writecnd = 0;
    int ret = 0;
    unsigned char *p = (unsigned char*)buffer;

	if(NULL == p)
	{
		printf("%s invalid input params \n", __FUNCTION__);
		return -1;
	}

	writecnd = 0;
	ret = 0;

    while (writecnd < size)
    {
        ret = write(fd, p+writecnd,size-writecnd);
        if (ret <= 0)
        {
        	printf("ret = %d\n", ret);
			if (ret < 0)
			{
				perror("write");
			}
            return -1;
        }
        writecnd += ret;
    }
    return writecnd;
}

static int updater_runapp(char* cmd) {
  char buffer[BUFSIZ];
  FILE* read_fp;
  int chars_read;
  int ret;

  memset(buffer, 0, BUFSIZ);
  read_fp = popen(cmd, "r");
  if (read_fp != NULL) {
    chars_read = fread(buffer, sizeof(char), BUFSIZ - 1, read_fp);
    if (chars_read > 0) {
      ret = 1;
    } else {
      ret = -1;
    }
    pclose(read_fp);
  } else {
    ret = -1;
  }

  return ret;
}

/* make sure Thread is exist.
 * parameter:
 * 		tname:thread name.
 * 		retry_cnt: enable retry cnt.
 */
static int is_thread_exist(char* tname, int debug_on)
{
    char buf[512];
    char grep_str[100]; //long enough for thread name.
    char shell_cmd[105];

    sprintf(grep_str, "grep %s", tname);
    sprintf(shell_cmd, "ps | %s", grep_str);

    FILE * fp = popen(shell_cmd, "r");
    if(!fp)
    {
        perror("func::is_thread_exist popen failed!");
        return 0;
    }
    while(fgets(buf, sizeof(buf), fp))
    {
		if(debug_on)
			printf("\n# PS --> %s\n", buf);

        if( !strstr(buf, grep_str) && strstr(buf, tname) &&
			!strstr(buf, " Z ") && !strstr(buf, "sh -c") &&
			!strstr(buf,"updater stop") )
        {
            puts(buf);
            fclose(fp);
            return 1;
        }
    }
    fclose(fp);
    return 0;
}

/*Kill wakeWordAgent thread, in case mode changed during start reboot.*/
static void updater_reboot(int debug_on)
{
	printf("System reboot now....\n");
	updater_runapp("busybox reboot");
}

static int updater_stop(int debug_on)
{
	int cnt = 0;

	while( is_thread_exist("updater", debug_on) > 0 )
	{
		printf("--->kill updater \n");
		updater_runapp("busybox killall updater");

		if(cnt++ >= 3)
			break;

		sleep(1);
	}

	if(!is_thread_exist("updater", debug_on))
	{
		printf("\nUpdater Stop Sucess!\n");
		return 0;
	}

	if(debug_on)
		printf("Error:Updater Can't be Killed!\n");
	return -1;
}

int vendor_storage_read(int buf_size, uint8_t *buf, uint16_t vendor_id)
{
	int ret = 0;
	int fd;
	RK_VERDOR_REQ req;

	fd = open(VERDOR_DEVICE, O_RDWR, 0);
	if (fd < 0) {
		printf("vendor_storage open fail, errno = %d\n", errno);
		return -1;
	}
	req.tag = VENDOR_REQ_TAG;
	req.id = vendor_id;
	req.len = buf_size > VENDOR_DATA_SIZE ? VENDOR_DATA_SIZE : buf_size;
	ret = ioctl(fd, VENDOR_READ_IO, &req);
	if (ret) {
		printf("vendor read error, ret = %d\n", ret);
		close(fd);
		return -1;
	}
	close(fd);
	memcpy(buf, req.data, req.len);

	return 0;
}

int vendor_storage_write(int buf_size, uint8_t *buf, uint16_t vendor_id)
{
	int ret = 0;
	int fd;
	RK_VERDOR_REQ req;

	fd = open(VERDOR_DEVICE, O_RDWR, 0);
	if (fd < 0) {
		printf("vendor_storage open fail, errno = %d\n", errno);
		return -1;
	}
	req.tag = VENDOR_REQ_TAG;
	req.id = vendor_id;
	req.len = buf_size > VENDOR_DATA_SIZE ? VENDOR_DATA_SIZE : buf_size;
	memcpy(req.data, buf, req.len);
	ret = ioctl(fd, VENDOR_WRITE_IO, &req);
	if(ret){
		printf("vendor write error, ret = %d\n", ret);
		close(fd);
		return -1;
	}
	close(fd);

	return 0;
}

/**从升级信息节点读取数据。
 * fwinfo_buf：读出内容放在此处。
 */
int fwinfo_read(char* fwinfo_buf)
{
	int ret = 0;

	ret = vendor_storage_read(sizeof(UpdaterInfo), fwinfo_buf, VENDOR_UPDATER_ID);
	return ret;
}

/* 写升级节点 */
int fwinfo_write(UpdaterInfo* fwinfo, UPDATER_MODE mode)
{
	int ret = 0;

	fwinfo->update_mode = mode;
	ret = vendor_storage_write(sizeof(UpdaterInfo), (char*)fwinfo, VENDOR_UPDATER_ID);
	return ret;
}

int get_fw_size_info(uint32* total_size, uint32* limit_size)
{
	int i=0, j=0;
	unsigned int sum=0;

	if((NULL == total_size) || (NULL == limit_size))
	{
		printf("%s invalid input parameters \n", __FUNCTION__);
		return -1;
	}

	if (g_partition.hdr.uiFwTag == RK_PARTITION_TAG)
	{
		for(j=0; j<FW_PART_CNT; j++){
			for (i = 0; i < g_partition.hdr.uiPartEntryCount; i++){
				if(strcmp(g_partition.part[i].szName, partNamesMini[j]) == 0){
					sum += (g_partition.part[i].uiPartSize*RK_SECTOR_SIZE);
					break;
				}
			}
		}
	}

	*total_size = sum;
	*limit_size = sum/FW_PERCENT_CNT - 512;

	printf("#Firmware total size:%d, limit size:%d\n", *total_size, *limit_size);
	return 0;
}

int get_part_offset_and_size(char* emPartName, uint32* pOffset, uint32* pPartSize, uint32* pDataSize)
{
	int i=0;

	if((NULL == pOffset) || (NULL == pPartSize) || (NULL == pDataSize))
	{
		printf("%s invalid input parameters \n", __FUNCTION__);
		return -1;
	}

	if (g_partition.hdr.uiFwTag == RK_PARTITION_TAG)
	{
		for (i = 0; i < g_partition.hdr.uiPartEntryCount; i++)
		{
			if(strcmp(g_partition.part[i].szName, emPartName) == 0)
			{
				printf("%s offset=%u PartSize=%u DataSize=%u\n", emPartName, g_partition.part[i].uiPartOffset, g_partition.part[i].uiPartSize, g_partition.part[i].uiDataLength);
				*pOffset = g_partition.part[i].uiPartOffset;
				*pPartSize = g_partition.part[i].uiPartSize;
				*pDataSize = g_partition.part[i].uiDataLength;
				return 0;
			}
		}
	}

	printf("%s FAILED \n", __FUNCTION__);
	return -1;
}

int updater_print_fwhdr()
{
	int i=0;

	printf("#fw_updater Firmware date=%04d-%02d-%02d %02d:%02d:%02d (%d) \n",
		g_partition.hdr.dtReleaseDataTime.year, g_partition.hdr.dtReleaseDataTime.month,
		g_partition.hdr.dtReleaseDataTime.day,  g_partition.hdr.dtReleaseDataTime.hour,
		g_partition.hdr.dtReleaseDataTime.min,  g_partition.hdr.dtReleaseDataTime.sec,
		g_partition.hdr.dtReleaseDataTime.reserve);
	printf("#fw_updater Firmware version=0x%08x \n", g_partition.hdr.uiFwVer);
	if (g_partition.hdr.uiFwTag == RK_PARTITION_TAG)
	{
		printf("#fw_updater Firmware entryCnt=%d\n", g_partition.hdr.uiPartEntryCount);
		for (i = 0; i < g_partition.hdr.uiPartEntryCount; i++)
		{
			printf("\n====PartName:%s====\n",g_partition.part[i].szName);
			printf("\tpartType=%u\n",		g_partition.part[i].emPartType);
			printf("\toffset=%u\n",		g_partition.part[i].uiPartOffset);
			printf("\tPartSize=%u\n",	g_partition.part[i].uiPartSize);
			printf("\tDataSize=%u\n",	g_partition.part[i].uiDataLength);
		}
	}else{
		printf("%s Firmware is invalid!\n", __FUNCTION__);
		return -1;
	}

	return 0;
}

/* 检查并修正path */
int updater_get_fwpath(char* src_path, char* dst_path, int debug)
{
	char* start = NULL;
	char* end = NULL;
	int plen = 0;
	int i;

	start = strstr(src_path, "/mnt");
	if(!start)
		return -1;

	end = strstr(src_path, "Firmware.img");
	if(!end)
		return -1;

	plen = end - start + strlen("Firmware.img");
	memcpy(dst_path, start, plen);

	if(debug)
		printf("\n#Updater Firmware path is %s\n\n", dst_path);

	return 0;
}

int updater_local_simple( int debug_on, int force)
{
	int ret = 0;
	uint32 partOffset = 0;
	uint32 partSize = 0;
	uint32 dataLength = 0;
	int fd;
	int size = 0;
	int wlen = 0;
	int fdfile;
	int count;
	int start;
	int unlock;
	int regcount;
	char* ubuf = NULL;
	int partId = 0;
	char fwinfo_buf[512];
	UpdaterInfo* fwinfo = NULL;
	unsigned int total_size = 0;
	unsigned int limit_size = 0;
	unsigned int tmp_size = 0;
	unsigned int percent_value = 0;
	char percent_msg[100];
	char fw_path[200];

	/* 初始化指针 */
	fwinfo = (UpdaterInfo*)fwinfo_buf;
	memset(fwinfo_buf, 0, sizeof(fwinfo_buf));

	/* 读取fwinfo信息。若读取失败，考虑vendor分区未初始化。*/
	ret = fwinfo_read(fwinfo_buf);
	if(ret < 0)
	{
		printf("ERROR：fwinfo get failed!\n");
		return ret;
	}
	debug_fwinfo_print(fwinfo, debug_on);

	//检查fwinfo是否合法，不合法则重置。
	if( ((fwinfo->update_mode & MODE_MASK) != MODE_UPDATER) &&
		((fwinfo->update_mode & MODE_MASK) != MODE_GENERATE))
	{
		printf("\n## Reset fwinfo!\n");
		ret = fwinfo_write(fwinfo, MODE_UPDATER);
		if(ret < 0)
		{
			printf("ERROR：Reset fwinfo failed!\n");
			return -1;
		}
	}

	//firmware path check.
	memset(fw_path, 0, sizeof(fw_path));
	ret = updater_get_fwpath(fwinfo->update_path, fw_path, debug_on);
	if(ret < 0){
		printf("ERROR:Firmware.img path is invalid!\n");
		//return -1;
	}

	fdfile = open(fw_path, O_RDONLY);
	if(fdfile < 0)
	{
		if(access(SDCARD_DEFAULT_PATH, R_OK) == 0)
		{
			printf("#New Path:%s\n", SDCARD_DEFAULT_PATH);
			fdfile = open(SDCARD_DEFAULT_PATH, O_RDONLY);
		}
		else if(access(UDISK_DEFAULT_PATH, R_OK) == 0)
		{
			printf("#New Path:%s\n", UDISK_DEFAULT_PATH);
			fdfile = open(UDISK_DEFAULT_PATH, O_RDONLY);
		}

		if(fdfile < 0){
			printf("fw_updater open <%s> failed \n", fwinfo->update_path);
			perror("open");
			return -1;
		}
	}

	printf("fw_updater sizeof(STRUCT_PART_INFO)=%d \n", (int)sizeof(STRUCT_PART_INFO));
	ret = read(fdfile, &g_partition, sizeof(STRUCT_PART_INFO));
	if(ret <= 0)
	{
		close(fdfile);
		printf("fw_updater read %s failed \n", fwinfo->update_path);
		perror("read");
		return -1;
	}

	if(debug_on){
		updater_print_fwhdr();
	}

	if(!force && (g_partition.hdr.uiFwVer <= fwinfo->update_version))
	{
		close(fdfile);
		printf("#Updater firmware is not newer then the Current firmware.\n");
		printf("-->Current firmware version is %0x%08x\n", fwinfo->update_version);
		printf("-->Updater firmware version is %0x%08x\n", g_partition.hdr.uiFwVer);
		return -1;
	}

	ubuf = malloc(BUFFER_16K);
	if(NULL == ubuf)
	{
		printf("fw_updater malloc ubuf failed \n");
		close(fdfile);
		return -1;
	}

	//获取固件总大小和门限大小。
	get_fw_size_info(&total_size, &limit_size);
	tmp_size = 0;

	for(partId=0; partId<FW_PART_CNT; partId++)
	{
		printf("\n====Start updating %s ====\n", partNamesMini[partId]);

MINI_UP_RETRY:
		partOffset = 0;
		partSize = 0;
		dataLength = 0;
		ret = get_part_offset_and_size(partNamesMini[partId], &partOffset, &partSize, &dataLength);
		if( ret != 0)
		{
			printf("+++++++ skip %s ++++++++++++\n", partNamesMini[partId]);
			continue;
		}
		//unlock_mtd(devNamesMini[partId]);
		if ((fd = open(devNamesMini[partId],O_RDWR)) < 0)
		{
			printf("%s open error\n", devNamesMini[partId]);
			close(fdfile);
			free(ubuf);
			return -1;
		}

		lseek(fdfile, partOffset*RK_SECTOR_SIZE, SEEK_SET);
		lseek(fd, 0, SEEK_SET);
		size = partSize*RK_SECTOR_SIZE;

		while(size > 0)
		{
			memset(ubuf, 0, BUFFER_16K);
			ret = update_read_file(fdfile, ubuf, (size > BUFFER_16K)?BUFFER_16K:size);
			if (ret <= 0)
			{
				close(fd);
				printf("%d:%s retry MINI_UP_RETRY\n", __LINE__, __FUNCTION__);
				sync();
				sleep(1);
				goto MINI_UP_RETRY;
			}

			wlen = update_write_file(fd, ubuf, ret);
			if (wlen < ret)
			{
				close(fd);
				printf("%d:%s retry MINI_UP_RETRY\n", __LINE__, __FUNCTION__);
				sync();
				sleep(1);
				goto MINI_UP_RETRY;
			}

			size = size - ret;
			tmp_size += wlen;
			if(tmp_size >= limit_size)
			{
				percent_value += (100/FW_PERCENT_CNT);
				memset(percent_msg, 0, sizeof(percent_msg));
				sprintf(percent_msg, "updater_percent:%d", percent_value);
				if(debug_on)
					printf("\t******** %s ********\n", percent_msg);

				tmp_size = 0;
			}
		}

		fsync(fd);
		close(fd);
		sync();
		updater_runapp("sync");
		sleep(3);
	}

	/* 百分百值判断 */
	if(percent_value < 100)
	{
		memset(percent_msg, 0, sizeof(percent_msg));
		sprintf(percent_msg, "updater_percent:%d", 100);
		if(debug_on)
			printf("\t******** %s ********\n", percent_msg);
	}

	/*记录新版本信息*/
	memset(fwinfo, 0, sizeof(UpdaterInfo));
	fwinfo->update_version = g_partition.hdr.uiFwVer;

	/* 清除升级标志位 */
	ret = fwinfo_write(fwinfo, MODE_GENERATE);
	if(ret < 0)
	{
		printf("%s<%d> Set to generate mode failed!\n", __func__, __LINE__);
		return -1;
	}

	printf("fw_updater Okay! \n");
	close(fdfile);
	free(ubuf);
	return 0;
}

void updater_print_usage()
{
printf("\nUsage: updater [stop] [OPTION]..\n");
	printf("[OPTION]\n");
	printf("\t-f, --force  force updater when version is equal.\n");
	printf("\t-d, --debug  open debug info.\n");
	printf("eg.\n");
	printf("\tupdater -f -d\n");
	printf("\tupdater stop\n");
}

int get_file_count(char *root)
{
	DIR *dir = NULL;
	struct dirent * ptr = NULL;
	int total = 0;
	char path[MAX_FILE_NAME_LEN]={0};

	if(NULL == root)
	{
		return -1;
	}

	dir = opendir(root);
	if(dir == NULL)
	{
		return -1;
	}

	while((ptr = readdir(dir)) != NULL)
	{
		if(strcmp(ptr->d_name,".") == 0 || strcmp(ptr->d_name,"..") == 0)
		{
			continue;
		}

		if(ptr->d_type == DT_DIR)
		{
			memset(path, 0x0, sizeof(path));
			sprintf(path,"%s%s/",root,ptr->d_name);
			total += get_file_count(path);
		}

		if(ptr->d_type == DT_REG)
		{
			total++;
		}
	}

	closedir(dir);
	return total;
}

int mount_usb_device()
{
	char usbDevice[64] = {0};
	int result;
	DIR* d=NULL;
	struct dirent* de = NULL;
	int fd_count = 0;

	fd_count = get_file_count(MOUNT_PATH_USB);
	if(fd_count > 0)
	{
		printf("mount_usb_device usb is mounted! fd_count=%d \n", fd_count);
		return 0;
	}

	printf("mount_usb_device try to mount udisk! fd_count=%d \n", fd_count);

	d = opendir("/dev");
	if(d != NULL) {
		while(de = readdir(d)) {
			//printf("mount_usb_device /dev/%s\n", de->d_name);
			if((strncmp(de->d_name, "sd", 2) == 0) &&(isdigit(de->d_name[strlen(de->d_name)-1])!=0)){
				memset(usbDevice, 0, sizeof(usbDevice));
				sprintf(usbDevice, "/dev/%s", de->d_name);
				printf("mount_usb_device try to mount usb device %s by vfat", usbDevice);
				result = mount(usbDevice, MOUNT_PATH_USB, "vfat",
						MS_NOATIME | MS_NODEV | MS_NODIRATIME, "shortname=mixed,utf8");
				if(result != 0) {
					printf("mount_usb_device try to mount usb device %s by ntfs\n", usbDevice);
					result = mount(usbDevice, MOUNT_PATH_USB, "ntfs",
							MS_NOATIME | MS_NODEV | MS_NODIRATIME, "");
				}

				if(result == 0) {
					closedir(d);
					return 0;
				}
			}
		}
		closedir(d);
	}

	return -1;
}

int mount_sdcard_device()
{
	char sdcardDevice[64] = {0};
	int result;
	DIR* d=NULL;
	struct dirent* de = NULL;
	int fd_count = 0;

	fd_count = get_file_count(MOUNT_PATH_SDCARD);
	if(fd_count > 0)
	{
		printf("mount_sdcard_device sdcard is mounted! fd_count=%d \n", fd_count);
		return 0;
	}

	printf("mount_sdcard_device try to mount sdcard! fd_count=%d \n", fd_count);

	d = opendir("/dev");
	if(d != NULL) {
		while(de = readdir(d)) {
			//printf("mount_sdcard_device /dev/%s\n", de->d_name);
			if((strncmp(de->d_name, "mmcblk", 6) == 0) && (strncmp(de->d_name, "mmcblk0", 7) != 0) &&(isdigit(de->d_name[strlen(de->d_name)-1])!=0)){
				memset(sdcardDevice, 0, sizeof(sdcardDevice));
				sprintf(sdcardDevice, "/dev/%s", de->d_name);
				printf("mount_sdcard_device try to mount sdcard device %s by vfat", sdcardDevice);
				result = mount(sdcardDevice, MOUNT_PATH_SDCARD, "vfat",
						MS_NOATIME | MS_NODEV | MS_NODIRATIME, "shortname=mixed,utf8");
				if(result != 0) {
					printf("mount_sdcard_device try to mount sdcard device %s by ntfs\n", sdcardDevice);
					result = mount(sdcardDevice, MOUNT_PATH_SDCARD, "ntfs",
							MS_NOATIME | MS_NODEV | MS_NODIRATIME, "");
				}

				if(result == 0) {
					closedir(d);
					return 0;
				}
			}
		}
		closedir(d);
	}

	return -1;
}


int try_mount_media(void)
{
	mount_usb_device();
	mount_sdcard_device();
	return 0;
}


int main(int argc, char* argv[])
{
	int ret = 0;
	int debug = 0;
	int force = 0;
	UPDATER_MODE umode;

	if(argc > 3){
		updater_print_usage();
		return -1;
	}

	try_mount_media();

	//对比执行模式。
	if(!strcmp(argv[1], "stop"))
		umode = UPDATER_STOP;
	else
		umode = UPDATER_SIMPLE_LOCAL;

	//判断是否开启debug
	if(argc >= 2)
	{
		if(!strcmp(argv[1], "-d"))
			debug = 1;
		else if(!strcmp(argv[1], "-f"))
			force = 1;
		else
		{
			updater_print_usage();
			return -1;
		}
	}
	if(argc == 3)
	{
		if(!strcmp(argv[2], "-d"))
			debug = 1;
		else if(!strcmp(argv[2], "-f"))
			force = 1;
		else
		{
			updater_print_usage();
			return -1;
		}
	}

	if(umode == UPDATER_STOP)
	{
		updater_stop(debug);
		return 0;
	}
	else
	{
		ret = updater_local_simple(debug, force);
		if(ret != 0)
		{
			printf("ERROR:updater failed(s)! \n");
			return -1;
		}
	}

	updater_runapp("busybox reboot");

	return 0;
}
