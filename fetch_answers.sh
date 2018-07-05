#!/bin/bash
set -eu
source utils.sh
source colour_codes.sh

function trim()
{
    local trimmed="$1"
    # Strip leading space.
    trimmed="${trimmed## }"
    # Strip trailing space.
    trimmed="${trimmed%% }"

    echo "$trimmed"
}

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
              | tr '[:upper:]' '[:lower:]'  )

echo "TEXT: $TEXT"
export ANSWERS=$(echo $TEXT \
			| cut --complement -f1 -d"?" \
			| cut --complement -f1 -d"|" \
			| tr "|" "\n"  )
export QUESTION=$(echo $TEXT | tr "|" "\n" | sed -e "s|?.*|?|g" | tr "|" " " |  sed 's/|//g' | sed "s/^|//g")

echo -e "QUESTION $QUESTION"
echo -e "ANSWERS $ANSWERS"

export QUESTIONFILE="questions.$uuid.txt"
echo $QUESTION > $QUESTIONFILE
export ANSWERFILE="answers.$uuid.txt"
rm -f $ANSWERFILE
for a in $ANSWERS; do
    # Saving this for analysis
    echo $a >> $ANSWERFILE
done


echo -e "$UWhite=============GOOGLE================$Color_Off"
echo $ANSWERS \
    | tr "|" "\n" \
    | xargs -P3 -I@ ./query_google.sh "$QUESTION @" \
    | sort \
    | xargs -I@ fgrep -i "@" --only-matching $ANSWERFILE \
    | sort \
    | uniq -c \
    | sort -k1g \
    | xargs -I@ echo -e $BCyan@$Color_Off

echo -e "$UWhite=============WIKIPEDIA==============$Color_Off"
echo $QUESTION \
    | tr "\?" "\n" \
    | xargs -P3 -I@ ./query_wikipedia.sh "@" \
    | xargs -0 -I@ fgrep -i "@" --only-matching $PARSEDTEXT".txt" \
    | sort \
    | uniq -c \
    | sort -k1g \
    | xargs -I@ echo -e $BYellow@$Color_Off
echo -e "$UWhite============ Done. =================$Color_Off"
echo -e "$UWhite Enter (q + ENTER) to quit, and (ENTER) to rerun. $Color_Off"
read RETRY
if [ "$RETRY" == "q" ]; then
   exit
fi

./$0 $@

