/*
 *  Copyright (c) 2017 Rockchip Electronics Co. Ltd.
 *  Author: Jems.Wang <wjh@rock-chips.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "recovery_display.h"

static int disp_fd = 0;

static int set_font_colour(enum print_font_colour print_color)
{
	char cmd[32];
	int ret = -1;

	switch (print_color) {
		case FONT_BLK: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_BLK);
		} break;
		case FONT_RED: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_RED);
		} break;
		case FONT_GRN: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_GRN);
		} break;
		case FONT_YEL: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_YEL);
		} break;
		case FONT_BLU: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_BLU);
		} break;
		case FONT_MAG: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_MAG);
		} break;
		case FONT_CYN: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_CYN);
		} break;
                case FONT_WHI: {
			sprintf(cmd, "sh /usr/bin/setfontcolour.sh %d", FONT_WHI);
		} break;
		default : {
			printf("[%s] print_color is invalid\n", __func__);
			return -1;
		} break;
	}

	ret = system(cmd);

	return ret;
}

int open_disp_dev(void)
{
        disp_fd =  open(DISP_DEV, O_RDWR);
        if(disp_fd < 0) {
                printf("[%s] open display dev fail\n", __func__);
                return -1;
        }
	return 0;
}

void close_disp_dev(void)
{
	if(disp_fd < 0) {
		printf("[%s] display fd is invalid, disp_fd=%d\n", __func__, disp_fd);
		return;
	}
	close(disp_fd);
}

int print_recovery_info(enum print_font_colour print_color, char *print_info)
{
	int ret = -1;

	if(disp_fd < 0) {
		printf("[%s] display fd is invalid, disp_fd=%d\n", __func__, disp_fd);
		return -1;
	}

	set_font_colour(print_color);

	ret = write(disp_fd, print_info, strlen(print_info));
	if (ret <= 0)
		printf("[%s] write Error (%s),ret=%d,fd=%d \n", __func__, strerror(errno), ret, disp_fd);

	return (ret > 0) ? 0 : -1;
}

