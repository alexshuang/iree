#!/bin/sh

SRC_DIR=$1
OUT_DIR=${2:-out}

mkdir -p $OUT_DIR
ERR_FILE=$OUT_DIR/tf2vmvx_errors.log
echo -n $ERR_FILE

models=`find $SRC_DIR -type d -maxdepth 1`
for m in $models; do
	echo "\n\n-------------------------\n"
	MODEL_NAME=${m##*/}
	MLIR_FILE=$OUT_DIR/$MODEL_NAME.mlir
	VMFB=$OUT_DIR/$MODEL_NAME.vmvx

	cmd="iree-import-tf  -o $MLIR_FILE --tf-import-type=savedmodel_v1 --tf-savedmodel-exported-names=serving_default $m"
	echo "### CMD = $cmd"
	$cmd
	if [ $? -ne 0 ]; then
		echo "Error: $cmd" >> $ERR_FILE
	else
		cmd="iree-compile --iree-hal-target-backends=vmvx $MLIR_FILE -o $VMFB"
		echo "### CMD = $cmd"
		$cmd
		if [ $? -ne 0 ]; then
			echo "Error: $cmd" >> $ERR_FILE
		fi
	fi
done
