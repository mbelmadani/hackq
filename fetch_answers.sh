#!/bin/bash
set -eu
source colour_codes.sh

echo "=======================NEW QUESTION==========================="

export SEDMODE='s|SOMETHINGTHATCANTPOSSIBLYBEMATCHED||g'

if [ ! -z ${MODE+x} ] && [ "$MODE" == "q" ]; then
    export SEDMODE='s|\?.*||g'	
fi
    
if [ -z ${UUID+x} ]; then
    echo "USING NEW UUID"
    export uuid=$(uuidgen)
    shutter -w Cast -o image.$uuid.raw.png -e
   
else
    echo "USING INPUT UUID"
    export uuid=$UUID
fi

export PARSEDTEXT="parsed.$uuid"
./process_image.sh

TEXT=$(cat $PARSEDTEXT".txt" \
	      | grep -v "^$" \
	      | tr "\n" "|" \
	      | sed '/^\s*$/d' \
	      | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/|/g' \
              | tr '[:upper:]' '[:lower:]' )

export ANSWERS=$(echo $TEXT | cut --complement -f1 -d"?" )
export QUESTION=$(echo $TEXT | sed -e "s|?.*|?|g" | sed 's/|//g' | sed "s/^|//g")
echo "QUESTION $QUESTION"
echo "ANSWERS $ANSWERS"

IFS="|"
export QUESTIONFILE="questions.$uuid.txt"
echo $QUESTION > $QUESTIONFILE

export ANSWERFILE="answers.$uuid.txt"
rm -f $ANSWERFILE
for a in $ANSWERS; do
    # Saving this for analysis
    echo $a >> $ANSWERFILE
done
unset IFS

echo -e "$UWhite=============GOOGLE================$Color_Off"
echo $ANSWERS \
    | tr "|" "\n" \
    | xargs -P3 -I@ ./query_google.sh @ \
    | sort \
    | xargs -I@ grep -i @ --only-matching $ANSWERFILE \
    | sort \
    | uniq -c \
    | sort -k1g \
    | xargs -I@ echo -e $BCyan@$Color_Off

echo -e "$UWhite=============WIKIPEDIA==============$Color_Off"
echo $ANSWERS \
    | tr "|" "\n" \
    | xargs -P3 -I@ ./query_wikipedia.sh @ \
    | xargs -0 -I@ grep -i @ --only-matching $QUESTIONFILE \
    | sort \
    | uniq -c \
    | sort -k1g \
    | xargs -I@ echo -e $BYellow@$Color_Off

echo -e "$UWhite============ Done. =================$Color_Off"
read RETRY
if [ "$RETRY" == "q" ]; then
   exit
fi

./fetch_answers.sh @
