cmake_minimum_required(VERSION 2.6)

project(LuaGE)

option(target "target")
option(ARCH "ARCH")

if(${target} MATCHES OFF)
	if(WIN32)
		set(target win)
		add_definitions(-DPLATFORM_win)
	elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		set(target mac)
		add_definitions(-DPLATFORM_mac)
	elseif(UNIX)
		set(target linux)
		add_definitions(-DPLATFORM_linux)
	endif()
endif()


if("${target}" MATCHES "win*")
	if(${ARCH} MATCHES OFF)
		message(WARNING "Architecture defaulted to Windows 32bits")
		set(ARCH 32)
		set(CMAKE_C_COMPILER i686-pc-mingw32-gcc.exe)
		set(CMAKE_CXX_COMPILER i686-pc-mingw32-g++.exe)
	endif()
elseif("${target}" MATCHES "mac*")
	if(${ARCH} MATCHES OFF)
		execute_process(COMMAND getconf LONG_BIT OUTPUT_VARIABLE ARCH)
	endif()
	set(CMAKE_C_COMPILER gcc)
	set(CMAKE_CXX_COMPILER g++)
elseif("${target}" MATCHES "linux*")
	if(${ARCH} MATCHES OFF)
		execute_process(COMMAND getconf LONG_BIT OUTPUT_VARIABLE ARCH)
	endif()
endif()

if("${ARCH}" MATCHES "64")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -m64")
else()
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -m32")
endif()


add_custom_target(txt2c COMMAND gcc -o ${CMAKE_BINARY_DIR}/txt2c ${CMAKE_SOURCE_DIR}/txt2c/main.c)

add_custom_target(c30log.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_c30log ${CMAKE_BINARY_DIR}/c30log.h ${CMAKE_SOURCE_DIR}/gelua/c30log.lua)
add_custom_target(gelua.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_gelua ${CMAKE_BINARY_DIR}/gelua.h ${CMAKE_SOURCE_DIR}/gelua/ge.lua)
add_custom_target(ui.Button.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_uiButton ${CMAKE_BINARY_DIR}/ui.Button.h ${CMAKE_SOURCE_DIR}/gelua/ui.Button.lua)
add_custom_target(ui.InputText.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_uiInputText ${CMAKE_BINARY_DIR}/ui.InputText.h ${CMAKE_SOURCE_DIR}/gelua/ui.InputText.lua)
add_custom_target(Page.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_Page ${CMAKE_BINARY_DIR}/Page.h ${CMAKE_SOURCE_DIR}/gelua/Page.lua)
add_custom_target(BigMenu.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_BigMenu ${CMAKE_BINARY_DIR}/BigMenu.h ${CMAKE_SOURCE_DIR}/gelua/BigMenu.lua)
add_custom_target(Menu.h COMMAND ${CMAKE_BINARY_DIR}/txt2c h_Menu ${CMAKE_BINARY_DIR}/Menu.h ${CMAKE_SOURCE_DIR}/gelua/Menu.lua)

include_directories(${CMAKE_BINARY_DIR})




set(SOURCES src/main.c)

add_executable(luage ${SOURCES})

add_dependencies(c30log.h txt2c)
add_dependencies(gelua.h txt2c)
add_dependencies(ui.Button.h txt2c)
add_dependencies(ui.InputText.h txt2c)
add_dependencies(Page.h txt2c)
add_dependencies(BigMenu.h txt2c)
add_dependencies(Menu.h txt2c)

add_dependencies(luage c30log.h)
add_dependencies(luage gelua.h)
add_dependencies(luage ui.Button.h)
add_dependencies(luage ui.InputText.h)
add_dependencies(luage Page.h)
add_dependencies(luage BigMenu.h)
add_dependencies(luage Menu.h)

if("${target}" MATCHES "win*")
	target_link_libraries(luage -lge_static -llua -lfreetype -lpng -ljpeg -lz -lm -pthread)
elseif("${target}" MATCHES "mac*")
	target_link_libraries(luage -lge)
elseif("${target}" MATCHES "linux*")
	target_link_libraries(luage -lge_static -llua5.2 -lfreetype -lpng -ljpeg -lGL -lX11 -lz -lm -pthread)
endif()
