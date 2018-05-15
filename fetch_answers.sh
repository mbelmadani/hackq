#!/bin/bash
set -eu

if [ $# -gt 1 ]; then
    MODE="s|DONTCHANGEATHINGYOUBEATIFULPERSON||g"
    if [ "$1" == "q" ]; then
	MODE='s|\?.*||g'
	echo "MODE SET: $MODE"
    fi
fi
    
if [ $# -lt 2 ]; then
    echo "USING NEW UUID"
    uuid=$(uuidgen)
    shutter -w Cast -o image.$uuid.raw.png -e
    convert image.$uuid.raw.png -crop 900x500+200+210 image.$uuid.cropped.png
else
    echo "USING INPUT UUID"
    uuid=$2
fi

convert image.$uuid.cropped.png -threshold 75% png:- | tesseract - out/answer -l eng 2> /dev/null
ANSWERS=$(cat out/answer.txt \
		 | grep -v "^$" \
		 | sed '/^\s*$/d' \
		 | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/_/g' \
		 | sed -e "s|.*?||g" \
		 | tr " " "|" \
		 | tr "_" "|" \
		 | sed "s/^|//g" )
echo $ANSWERS

IFS="|"
QUESTIONFILE="questions.$uuid.txt"
ANSWERFILE="answers.$uuid.txt"
rm -f $ANSWERFILE
for a in $ANSWERS; do
    echo $a >> $ANSWERFILE
done
unset IFS
#exit

cat out/answer.txt \
    | grep -v "^$" \
    | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' \
    | sed $MODE  \
    | googler -C 2> /dev/null  \
    | tr " " "\n" \
    | tr "," "\n" \
    | tr "." "\n" \
    | tr "'" "\n" \
    | tr '[:upper:]' '[:lower:]' \
    | grep -P ".*.{3,}.*" \
    | sort \
    | uniq -c \
    | sort -k1gr > $QUESTIONFILE

grep -i -f $ANSWERFILE $QUESTIONFILE
