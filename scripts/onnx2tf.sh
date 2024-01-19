#!/bin/sh
SRC_DIR=$1
OUT_DIR=${2:-saved_models}

ERR_FILE=$OUT_DIR/onnx2tf_errors.log
echo -n $ERR_FILE

files=`find $SRC_DIR -name *.onnx`
for f in $files; do
	file_name=${f##*/}
	base_name=${file_name%.*}
	cmd="onnx-tf convert -i $f -o $OUT_DIR/$base_name"
	$cmd
	if [ $? -ne 0 ]; then
		echo "Error: $cmd" >> $ERR_FILE
	fi
done
