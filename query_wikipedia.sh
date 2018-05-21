#!/bin/bash
set -eu
source urlencode.sh

TMPQUESTION="tmp/"$uuid".question.wikipedia.txt"
TMPANSWER="tmp/"$uuid".answer.wikipedia.txt"
QUERYENC=$(urlencode "$1")
echo "wikiepdia query:" $QUERYENC 1>&2
# Curl wikipedia API with the answer
curl "https://en.wikipedia.org/w/api.php?action=opensearch&search=$QUERYENC&limit=1" -S 2> /dev/null |
#   | Get first http address from wikipedia\
    tr '"' "\n" \
    | grep -P "^http.*" \
    | head -n1 |
#   | Query wikipedia with first url, convert to text\
    xargs -I@ curl -sS @ \
    | html2text |
#   | \Extract words\
    tr " " "\n" |
#   | \Convert non-word characters to breaks\	  
    tr "," "\n" \
    | tr "“" "\n" \
    | tr "." "\n" \
    | tr "[" "\n" \
    | tr "]" "\n" \
    | tr "'" "\n" \
    | tr "_" "\n" |
#   | \Convert all to lowercase\
    tr '[:upper:]' '[:lower:]' |
#   | \Remove urls
    sed 's|http.*||g' |
#   | \Remove rows with bullet points; a lot of them are outlinks to wikipedia\
    egrep -v "[*]" |
#   | \Remove wiki relatated words\
    grep -v "wiki" |
#   | \Minimum word size\
    grep -P ".*.{3,}.*" 
