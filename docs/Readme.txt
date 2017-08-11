/***********************************************************************
 * Author：范立创
 * Date：  2017/8/10
 * Email:  francis.fan@rock-chips.com
 ***********************************************************************/

1、Recovery中的kernel并非最新版本，版本信息如下
	commit 42f89fca1cf03f0f43e8d3274c010df0e8db657c
	Author: Huang Jiachai <hjc@rock-chips.com>
	Date:   Thu May 25 10:56:20 2017 +0800

		drm/drockchip: set win1 as the default primary layer
		
		Change-Id: Ic7dca21e7e4ba9ee2b24651042faf66e113acd40
		Signed-off-by: Huang Jiachai <hjc@rock-chips.com>
		
2、Kernel编译步骤:
	1） make ARCH=arm px3se_linux_defconfig -j8
	2） make ARCH=arm px3se-sdk.img -j24

3、Buildroot 编译步骤：
	1） make rockchip_px3se_recovery_defconfig
	2） make -j24

4、执行./mkrecovery.sh 在rockimg/recovery/路径下生成recovery.img


/***********************************************************************
 * 小容量recovery.img的制作说明
 * Date：  2017/8/11
 ***********************************************************************/
说明：正常产品的recovery不需要改动，直接使用SDK所带或只要生成一次recovery.img就可以，不需要每次都编译，除非有改动。

1，生成recovery.img
	cd recovery && ./mkrecovery_minifs.sh px3se-emmc-minifs-sdk （px3se-emmc-minifs-sdk 这个参数需要根据具体项目选择，参考编译说明文档）

2，生成recovery.img后回退到正常系统编译kernel时需要重新make xxx_defconfig (xxx_defconfig 为具体kernel的defconfig，参考编译说明文档)


