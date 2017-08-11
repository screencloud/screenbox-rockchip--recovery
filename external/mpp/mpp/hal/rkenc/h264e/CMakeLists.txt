# vim: syntax=cmake
include_directories(.)
include_directories(../../common/h264/)

# hal h264 header
set(HAL_H264E_HDR
    hal_h264e_rkv.h
    )

# hal h264 encoder sourse
set(HAL_H264E_SRC
    hal_h264e_rkv.c
    )

add_library(hal_h264e_rkv STATIC
            ${HAL_H264E_HDR}
            ${HAL_H264E_SRC}
            )

target_link_libraries(hal_h264e_rkv hal_h264e)
set_target_properties(hal_h264e_rkv PROPERTIES FOLDER "mpp/hal")
