#!/bin/sh

export QEMU_BIN=/root/riscv/qemu/linux/RISCV/qemu-riscv64
export RISCV_TOOLCHAIN_ROOT=/root/riscv/toolchain/clang/linux/RISCV
export IREE_RISCV_INSTALL_DIR=/root/iree-riscv
export IREE_INSTALL_DIR=/root/iree-build

MLIR_PATH=$1
INPUT=$2
MODULE_PATH=${MLIR_PATH%.*}.vmfb

$IREE_INSTALL_DIR/install/bin/iree-compile --iree-hal-target-backends=vmvx $MLIR_PATH -o $MODULE_PATH

${QEMU_BIN} \
-cpu rv64 \
-L ${RISCV_TOOLCHAIN_ROOT}/sysroot/ \
${IREE_RISCV_INSTALL_DIR}/tools/iree-benchmark-module \
--device=local-task \
--module=$MODULE_PATH \
--function=forward \
--input=$INPUT \
--output=-

