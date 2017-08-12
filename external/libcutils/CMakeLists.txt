cmake_minimum_required(VERSION 2.8.11)

project(cutils)

enable_language(ASM)

option(BUILD_LIBLOG "Use liblog porting from android or not" ON)

if (${BUILD_LIBLOG})
	add_definitions(-DHAVE_ANDROID_LOG)
endif()

add_definitions(-DANDROID_SMP=1 -DHAVE_PTHREADS -DHAVE_SYS_SOCKET_H)
add_definitions(-DHAVE_SYS_UIO_H)

set(LIBCUTILS_SRC_FILES
    hashmap.c
    atomic.c
    native_handle.c
    socket_inaddr_any_server.c
    socket_local_client.c
    socket_local_server.c
    socket_loopback_client.c
    socket_loopback_server.c
    socket_network_client.c
    sockets.c
    config_utils.c
    cpu_info.c
    load_file.c
    open_memstream.c
    strdup16to8.c
    strdup8to16.c
    record_stream.c
    process_name.c
    threads.c
    sched_policy.c
    iosched_policy.c
    str_parms.c
    ashmem-dev.c
    debugger.c
    klog.c
    partition_utils.c
    properties.c
    qtaguid.c
    trace.c
    uevent.c
    arch-arm/memset32.S
)

#add_library(cutils SHARED ${LIBCUTILS_SRC_FILES})
add_library(cutils STATIC ${LIBCUTILS_SRC_FILES})

if (${BUILD_LIBLOG})
	target_link_libraries(cutils log)
endif()

include_directories(${cutils_SOURCE_DIR}/include ${cutils_SOURCE_DIR})
# include_directories(${cutils_SOURCE_DIR}/include ${cutils_SOURCE_DIR} ${CMAKE_INSTALL_PREFIX}/include)

# If the CMake version supports it, attach header directory information
# to the targets for when we are part of a parent build (ie being pulled
# in via add_subdirectory() rather than being a standalone build).
if (DEFINED CMAKE_VERSION AND NOT "${CMAKE_VERSION}" VERSION_LESS "2.8.11")
	target_include_directories(cutils INTERFACE "${cutils_SOURCE_DIR}/include")
endif()

#install(TARGETS cutils DESTINATION lib)
install(TARGETS cutils ARCHIVE DESTINATION lib)
install(DIRECTORY ${cutils_SOURCE_DIR}/include/cutils DESTINATION include)
install(DIRECTORY ${cutils_SOURCE_DIR}/include/linux DESTINATION include)
