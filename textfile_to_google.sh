#!/bin/bash
set -eu
source urlencode.sh

QUERY="$QUESTION '$1'"
echo "QUERY: >$QUESTION<+>$1<" &1>2 
googler --np -C -n 10 $QUERY 2> /dev/null  \
    | sed 's|http.*||g' \
    | tr '"' '.' \
    | tr '"' '.' \
    | tr " " "\n" \
    | tr "," "\n" \
    | tr "." "\n" \
    | tr "'" "\n" \
    | tr '[:upper:]' '[:lower:]' \
    | grep -P ".*.{3,}.*"

#$HOME/gopath/bin/wiki $1 -n \
QUERYENC=$(urlencode $1)
echo "https://en.wikipedia.org/w/api.php?action=opensearch&search=$QUERYENC&limit=10" >&2
curl "https://en.wikipedia.org/w/api.php?action=opensearch&search=$QUERYENC&limit=10" -S 2> /dev/null \
    | tr " " "\n" \
    | tr "," "\n" \
    | tr "." "\n" \
    | tr "'" "\n" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's|http.*||g' \
    | tr "\n" "|" \
    | tr -cd '[A-Za-z:blank:|]'   \
    | tr "|" "\n" \
    | grep -P ".*.{3,}.*" 


# googler --np -C -n 10 $QUERY --json 2> /dev/null  \
#     | grep https \
#     | head -n1 \
#     | grep wiki \
#     | cut -f4 -d '"' \
#     | xargs -I@ curl -vs @ 2>&1 | html2text \
#     | sed 's|http.*||g' \
#     | tr " " "\n" \
#     | tr "," "\n" \
#     | tr "." "\n" \
#     | tr "'" "\n" \
#     | tr '"' '.' \
#     | tr '"' '.' \
#     | tr '[:upper:]' '[:lower:]' \
#     | grep -P ".*.{3,}.*" \
#     | sort \
#     | uniq
