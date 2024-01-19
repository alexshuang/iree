#!/bin/sh

IREE_BUILD_DIR=/root/iree-build

# predownload amdgpu bitcode
mkdir -p mkdir $IREE_BUILD_DIR/compiler/plugins/target/ROCM/ -p
cp predownload/amdgpu-device-libs-llvm-6086c272a3a59eb0b6b79dcbe00486bf4461856a.tgz $IREE_BUILD_DIR/compiler/plugins/target/ROCM/_fetch_device_libs.tgz -v

export RISCV_COMPILER_FLAGS="${RISCV_COMPILER_FLAGS:--O3}"

cmake -GNinja -B $IREE_BUILD_DIR \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_INSTALL_PREFIX=$IREE_BUILD_DIR/install \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DIREE_BUILD_PYTHON_BINDINGS=ON \
  -DPython3_EXECUTABLE="$(which python3)" \
  .
cmake --build $IREE_BUILD_DIR --target install
