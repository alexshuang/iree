#!/bin/sh

IREE_BUILD_DIR=/root/iree-build
IREE_RISCV_BUILD_DIR=/root/iree-riscv

#echo -e "/opt/riscv\ny\ny\n" | ./build_tools/riscv/riscv_bootstrap.sh
export RISCV_TOOLCHAIN_ROOT=/opt/riscv/toolchain/clang/linux/RISCV
export RISCV_COMPILER_FLAGS="${RISCV_COMPILER_FLAGS:--O3}"

cmake -GNinja -B $IREE_RISCV_BUILD_DIR \
  -DCMAKE_TOOLCHAIN_FILE="./build_tools/cmake/riscv.toolchain.cmake" \
  -DIREE_HOST_BIN_DIR=$(realpath $IREE_BUILD_DIR/install/bin) \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DRISCV_CPU=linux-riscv_64 \
  -DIREE_BUILD_COMPILER=OFF \
  -DRISCV_TOOLCHAIN_ROOT=${RISCV_TOOLCHAIN_ROOT} \
  -DIREE_ENABLE_CPUINFO=OFF \
  .
cmake --build $IREE_RISCV_BUILD_DIR
