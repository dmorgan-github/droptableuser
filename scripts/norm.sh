#! /bin/bash

git status
git add .
git commit -m "update patches"
COMMIT_ID=$(git rev-parse --short HEAD)
git diff-tree --no-commit-id --name-only -r $COMMIT_ID

WAV_IN=$1
OPT=$2
WAV_OUT=`echo $WAV_IN | sed "s/.wav/-$COMMIT_ID-6db.wav/i"`

numchan=`soxi -c $WAV_IN`
#numchan=$(echo $numchan | tr -d ' ')

left=()
right=()
for (( i=1; i<=$numchan; i++ ))
do
  if (($i % 2 == 0));
  then
    right+=("${i}")
  else
    left+=("${i}")
  fi
done

# join arrays
left=$(printf ",%s" "${left[@]}")
left=${left:1}

right=$(printf ",%s" "${right[@]}")
right=${right:1}

#if [[ $OPT -eq 1 ]]
#then
#	echo "processing without fade"
	sox $WAV_IN $WAV_OUT remix $left $right norm -6 silence 1 0.1 -50d reverse silence 1 0.1 -50d reverse
#else
# echo "processing with fade"
#	FADE_IN_L="0:8"
#	FADE_OUT_L="0:8"
#	LENGTH=`soxi -d $WAV_IN`

#	sox $WAV_IN "a-$WAV_OUT" \
#	remix $left $right \
#	norm -6 \
#	silence 1 0.1 -50d reverse silence 1 0.1 -50d reverse

	#LENGTH=`soxi -d "a-$WAV_OUT"`
	#sox "a-$WAV_OUT" $WAV_OUT fade $FADE_IN_L $LENGTH $FADE_OUT_L
	#rm "a-$WAV_OUT"
#fi

open -a Music $WAV_OUT

WAV_IN_NEW=`echo $WAV_IN | sed "s/.wav/-$numchan-chan.wav/i"`
mv $WAV_IN $WAV_IN_NEW
