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
