#! /bin/bash

WAV_IN=$1
OPT=$2
WAV_OUT=`echo $WAV_IN | sed 's/.wav/-6db.wav/i'`

if [[ $OPT -eq 1 ]]
then
	echo "processing without fade"
	sox $WAV_IN $WAV_OUT norm -6 
else
	echo "processing with fade"
	FADE_IN_L="0:8"
	FADE_OUT_L="0:8"
	LENGTH=`soxi -d $WAV_IN`
	sox $WAV_IN $WAV_OUT norm -6 fade $FADE_IN_L $LENGTH $FADE_OUT_L
fi

open -a Music $WAV_OUT

rm $WAV_IN
