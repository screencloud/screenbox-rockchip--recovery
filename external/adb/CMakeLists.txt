cmake_minimum_required(VERSION 2.8.11)
project(adbd)

set(ADB_SRC_FILES
    adb.c
    backup_service.c
    fdevent.c
    transport.c
    transport_local.c
    transport_usb.c
    adb_auth_client.c
    sockets.c services.c
    file_sync_service.c
    jdwp_service.c
    remount_service.c
    usb_linux_client.c
    mincrypt/rsa.c
    mincrypt/sha256.c
    mincrypt/sha.c
)

add_definitions(-DADB_HOST=0 -D_XOPEN_SOURCE -D_GNU_SOURCE)

add_executable(adbd ${ADB_SRC_FILES})
install(TARGETS adbd DESTINATION sbin)

target_include_directories(adbd
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(adbd cutils pthread)
