project(LuaGE)

set(SOURCES
	src/main.c
)

add_executable(luage ${SOURCES})

target_link_libraries(luage -lge)
