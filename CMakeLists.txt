cmake_minimum_required(VERSION 2.6)

project(LuaGE)

add_executable(txt2c txt2c/main.c)

add_custom_target(
				gelua.h
				COMMAND txt2c
				gelua
				${CMAKE_BINARY_DIR}/gelua.h
				${CMAKE_SOURCE_DIR}/gelua/ge.lua
				${CMAKE_SOURCE_DIR}/gelua/ui.Button.lua
				${CMAKE_SOURCE_DIR}/gelua/ui.InputText.lua
				${CMAKE_SOURCE_DIR}/gelua/Page.lua
				${CMAKE_SOURCE_DIR}/gelua/BigMenu.lua
				${CMAKE_SOURCE_DIR}/gelua/Menu.lua
)

include_directories(${CMAKE_BINARY_DIR})

set(SOURCES
	src/main.c
)

add_executable(luage ${SOURCES})
add_dependencies(luage gelua.h)

target_link_libraries(luage -lge)
