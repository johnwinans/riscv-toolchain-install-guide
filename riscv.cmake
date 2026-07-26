# CMake toolchain file for bare-metal RISC-V (rv32i) cross-compilation.
#
# Usage:
#   cmake -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/cmake/riscv.cmake ..
#
# To override the toolchain location set RISCV_TOOLCHAIN_ROOT before
# configuring, e.g.:
#   cmake -DRISCV_TOOLCHAIN_ROOT=/opt/riscv/bin \
#         -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/cmake/riscv.cmake ..

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

# --- Toolchain location ------------------------------------------------
# Default to /usr/bin (Ubuntu packages).  Override with
# -DRISCV_TOOLCHAIN_ROOT=<path> for a source-built toolchain.
if(NOT DEFINED RISCV_TOOLCHAIN_ROOT)
    if(DEFINED ENV{RISCV_TOOLCHAIN_ROOT})
        set(RISCV_TOOLCHAIN_ROOT $ENV{RISCV_TOOLCHAIN_ROOT})
    else()
        set(RISCV_TOOLCHAIN_ROOT /usr/bin)
    endif()
endif()

set(CROSS_PREFIX ${RISCV_TOOLCHAIN_ROOT}/riscv64-unknown-elf-)

# --- Compilers ----------------------------------------------------------
set(CMAKE_C_COMPILER   ${CROSS_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_PREFIX}g++)
set(CMAKE_ASM_COMPILER ${CROSS_PREFIX}gcc)

# --- Architecture flags -------------------------------------------------
set(ARCH_FLAGS "-march=rv32i_zicsr -mabi=ilp32")

set(CMAKE_C_FLAGS_INIT   "${ARCH_FLAGS} -ffreestanding -fno-pic")
set(CMAKE_CXX_FLAGS_INIT "${ARCH_FLAGS} -ffreestanding -fno-pic")
set(CMAKE_ASM_FLAGS_INIT "${ARCH_FLAGS} -ffreestanding -fno-pic")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-nostdlib" ${ARCH_FLAGS})

# --- Bare-metal: skip the linker during compiler detection --------------
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# --- Search paths -------------------------------------------------------
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
