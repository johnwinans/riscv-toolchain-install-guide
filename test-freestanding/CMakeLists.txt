cmake_minimum_required(VERSION 3.20)
project(test-freestanding ASM C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Werror -Wcast-align -O2 -g")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-T,${CMAKE_CURRENT_SOURCE_DIR}/vanilla.ld")

add_executable(prog crt0.S)
target_link_libraries(prog gcc)
