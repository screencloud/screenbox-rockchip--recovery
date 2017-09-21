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

typedef		unsigned char		        uint8;
typedef		signed char		            int8;
typedef		unsigned short	            uint16;
typedef		signed short	            int16;
typedef		unsigned int			    uint32;
typedef		signed int			        int32;
typedef		unsigned long long	        uint64;
typedef		signed long long	        int64;
typedef 	unsigned char 				BYTE;

//支持firmware.img升级
#define UPDATER_MINI_FW	1

#define MODE_UPDATER	0xF000
#define MODE_GENERATE	0x0000
#define MODE_MASK		0xF000

#define BUFFER_16K 		(4*1024)
#define RK_SECTOR_SIZE	(512)

#if UPDATER_MINI_FW
	#define DEV_KERNEL_NAME		("dev/PartNo/kernel")
	#define RK_PARTITION_TAG 	(0x50464B52)
	#define FW_PART_CNT			3
	#define FW_PERCENT_CNT		5 //统计百分比次数。
	#define UDISK_DEFAULT_PATH	"/mnt/udisk/Firmware.img"
	#define SDCARD_DEFAULT_PATH	"/mnt/sdcard/Firmware.img"

typedef enum {
	PART_VENDOR = 1 << 0,
	PART_IDBLOCK = 1 << 1,
	PART_KERNEL = 1 << 2,
	PART_BOOT = 1 << 3,
	PART_USER = 1 << 31
}ENUM_PARTITION_TYPE;

char *devNamesMini[FW_PART_CNT] = {
	"/dev/PartNo/resource",
	"/dev/PartNo/kernel",
	"/dev/PartNo/boot",
//	"/dev/PartNo/recovery",
};

char *partNamesMini[FW_PART_CNT] = {
	"resource",
	"kernel",
	"rootfs",
//	"recovery",
};

typedef struct {
	uint16	year;
	uint8	month;
	uint8	day;
	uint8	hour;
	uint8	min;
	uint8	sec;
	uint8	reserve;
}STRUCT_DATETIME,*PSTRUCT_DATETIME;

typedef struct {
	uint32	uiFwTag; //"RKFP"
	STRUCT_DATETIME	dtReleaseDataTime;
	uint32	uiFwVer;
	uint32	uiSize;//size of sturct,unit of uint8
	uint32	uiPartEntryOffset;//unit of sector
	uint32	uiBackupPartEntryOffset;
	uint32	uiPartEntrySize;//unit of uint8
	uint32	uiPartEntryCount;
	uint32	uiFwSize;//unit of uint8
	uint8	reserved[464];
	uint32	uiPartEntryCrc;
	uint32	uiHeaderCrc;
}STRUCT_FW_HEADER,*PSTRUCT_FW_HEADER;

typedef struct {
	uint8	szName[32];
	ENUM_PARTITION_TYPE emPartType;
	uint32	uiPartOffset;//unit of sector
	uint32	uiPartSize;//unit of sector
	uint32	uiDataLength;//unit of uint8
	uint32	uiPartProperty;
	uint8	reserved[76];
}STRUCT_PART_ENTRY,*PSTRUCT_PART_ENTRY;

typedef struct {
	STRUCT_FW_HEADER hdr;     //0.5KB
	STRUCT_PART_ENTRY part[12]; //1.5KB
}STRUCT_PART_INFO,*PSTRUCT_PART_INFO;

#endif //#if UPDATER_MINI_FW

typedef enum{
	UPDATER_COMPLEX_LOCAL = 0, 	//固件分离方式本地升级。
	UPDATER_SIMPLE_LOCAL,		//固件打包为一个firmware.img方式本地升级
	UPDATER_STOP
}UPDATER_MODE;

typedef struct{
	//release date
	unsigned int update_version;

	//firmware.img path.
	unsigned char update_path[200];

	/* update mode
	 * 	 0x0000 -> generate mode.
	 *	 0xF000 -> updater mode.
	 */
	unsigned short update_mode;
}UpdaterInfo;

#define VERDOR_DEVICE "/dev/vendor_storage"
#define VENDOR_REQ_TAG	0x56524551
#define VENDOR_READ_IO	_IOW('v', 0x01, unsigned int)
#define VENDOR_WRITE_IO	_IOW('v', 0x02, unsigned int)
#define VENDOR_UPDATER_ID		14
#define VENDOR_DATA_SIZE (3 * 1024)

typedef struct _RK_VERDOR_REQ {
	uint32_t tag;
	uint16_t id;
	uint16_t len;
	uint8_t data[VENDOR_DATA_SIZE];
} RK_VERDOR_REQ;

int vendor_storage_read(int buf_size, uint8_t *buf, uint16_t vendor_id);
int vendor_storage_write(int buf_size, uint8_t *buf, uint16_t vendor_id);

#define MOUNT_RETRY_CNT		5
#define MOUNT_SLEEP_SEC		3
#define MOUNT_PATH_USB		"/mnt/udisk"
#define MOUNT_PATH_SDCARD	"/mnt/sdcard"
#define MAX_FILE_NAME_LEN	(1024)
