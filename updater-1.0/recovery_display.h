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


#ifndef _RECOVERY_DISPLAY_H__
#define _RECOVERY_DISPLAY_H__

#define DISP_DEV	"/dev/tty0"

#define PRINT_FONT_BLK	"\e[1;30m"
#define PRINT_FONT_RED	"\e[1;31m"
#define PRINT_FONT_GRN	"\e[1;32m"
#define PRINT_FONT_YEL	"\e[1;33m"
#define PRINT_FONT_BLU	"\e[1;34m"
#define PRINT_FONT_MAG	"\e[1;35m"
#define PRINT_FONT_CYN	"\e[1;36m"
#define PRINT_FONT_WHI	"\e[1;37m"

enum print_font_colour {
        FONT_BLK = 0,
        FONT_RED,
        FONT_GRN,
        FONT_YEL,
        FONT_BLU,
	FONT_MAG,
	FONT_CYN,
	FONT_WHI
};

int open_disp_dev(void);
void close_disp_dev(void);
int print_recovery_info(enum print_font_colour print_color, char *print_info);

#endif
