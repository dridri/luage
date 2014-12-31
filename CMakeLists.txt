project(LuaGE)

if(WIN32)
	set(CMAKE_C_COMPILER C:/MinGW/mingw64/bin/x86_64-w64-mingw32-gcc.exe) ## TODO
	set(CMAKE_CXX_COMPILER C:/MinGW/mingw64/bin/x86_64-w64-mingw32-g++.exe) ## TODO
endif()

set(SOURCES
	src/main.c
)

add_executable(luage ${SOURCES})

target_link_libraries(luage -lge)
