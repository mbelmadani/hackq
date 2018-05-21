#!/bin/bash
set -eu
source urlencode.sh

TMPQUESTION="tmp/"$uuid".question.wikipedia.txt"
TMPANSWER="tmp/"$uuid".answer.wikipedia.txt"
QUERY="wikipedia $1"
# Curl wikipedia API with the answer
#QUERYENC=$(urlencode "$1")
#echo "wikiepdia query:" $QUERY 1>&2
#curl "https://en.wikipedia.org/w/api.php?action=opensearch&search=$QUERYENC&limit=1" -S 2> /dev/null |

# Use googler to get the first wikipedia url
googler --np -C -n 10 $QUERY 2> /dev/null |    
#   | Get first http address from wikipedia\
    tr '"' "\n" \
    | grep -P "^https://en.wikipedia*" \
    | xargs -I@ curl -sS @ \
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



