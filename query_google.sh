#!/bin/bash
set -eu

QUERY=$1

# Use googler to get 10 first results for Google for question + 1 answer
googler --np -C -n 10 $QUERY 2> /dev/null |
#   | \Remove urls\
    sed 's|http.*||g' |
#   | \Trim non-word characters\
    tr "\"" '.' \
    | tr " " "\n" \
    | tr "," "\n" \
    | tr "." "\n" \
    | tr "'" "\n" |
#   | \Convert all to lowercase\
    tr '[:upper:]' '[:lower:]' |
#   | \Minimum word size\
    grep -P ".*.{3,}.*" 
