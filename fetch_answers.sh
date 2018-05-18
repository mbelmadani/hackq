#!/bin/bash
set -eu
echo "=======================NEW QUESTION==========================="

export SEDMODE='s|SOMETHINGTHATCANTPOSSIBLYBEMATCHED||g'

if [ ! -z ${MODE+x} ] && [ "$MODE" == "q" ]; then
    export SEDMODE='s|\?.*||g'	
fi
    
if [ -z ${UUID+x} ]; then
    echo "USING NEW UUID"
    uuid=$(uuidgen)
    shutter -w Cast -o image.$uuid.raw.png -e
   
else
    echo "USING INPUT UUID"
    uuid=$UUID
fi

convert image.$uuid.raw.png -crop 900x500+200+300 image.$uuid.cropped.png
convert image.$uuid.cropped.png -threshold 75% png:- | tesseract - out/answer -l eng 2> /dev/null

TEXT=$(cat out/answer.txt \
	      | grep -v "^$" \
	      | sed '/^\s*$/d' \
	      | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/|/g' \
	      | sed "s/^|//g" \
              | tr '[:upper:]' '[:lower:]' )

export ANSWERS=$(echo $TEXT | cut --complement -f1 -d"?")
export QUESTION=$(echo $TEXT | sed -e "s|?.*|?|g" | sed 's/|//g' )
echo "QUESTION $QUESTION"
echo "ANSWERS $ANSWERS"

IFS="|"
export QUESTIONFILE="questions.$uuid.txt"
export ANSWERFILE="answers.$uuid.txt"
rm -f $ANSWERFILE
for a in $ANSWERS; do
    # Saving this for analysis
    echo $a >> $ANSWERFILE
done
unset IFS

echo $ANSWERS \
    | tr "|" "\n" \
    | xargs -P3 -I@ ./textfile_to_google.sh @ \
    | sort \
    | uniq -c \
    | sort -k1g \
    | xargs -P3 -I @ python filterhit.py "@" $ANSWERS
