cmake_minimum_required(VERSION 2.6)

project(LuaGE)

option(target "target")
option(ARCH "ARCH")

if(${target} MATCHES OFF)
	if(WIN32)
		set(target win)
	elseif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
		set(target mac)
	elseif(UNIX)
		set(target linux)
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

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")


if("${ARCH}" MATCHES "64")
	set(OBJCPY_OUT elf64-x86-64)
else()
	set(OBJCPY_OUT elf32-i386)
endif()

set(gelua_obj_files
	${CMAKE_CURRENT_BINARY_DIR}/gelua_c30log.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_ge.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_ui_Button.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_ui_InputText.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_Page.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_BigMenu.o
	${CMAKE_CURRENT_BINARY_DIR}/gelua_Menu.o
	)

set_source_files_properties(
			${gelua_obj_files}
			PROPERTIES
			EXTERNAL_OBJECT true
			GENERATED true
			)

add_custom_command(
			OUTPUT ${gelua_obj_files}
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/gelua
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 c30log.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_c30log.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 ge.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_ge.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 ui.Button.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_ui_Button.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 ui.InputText.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_ui_InputText.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 Page.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_Page.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 BigMenu.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_BigMenu.o
			COMMAND objcopy -I binary -O ${OBJCPY_OUT} -B i386 Menu.lua ${CMAKE_CURRENT_BINARY_DIR}/gelua_Menu.o
			)


set(SOURCES
	src/main.c
	${gelua_obj_files}
)

add_executable(luage ${SOURCES})

target_link_libraries(luage -lge)
