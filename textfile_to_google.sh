#!/bin/bash
set -eu

QUERY="$QUESTION '$1'"
echo "QUERY: >$QUESTION<+>$1<" 1>&2 
googler --np -C -n 10 $QUERY 2> /dev/null  \
    | sed 's|http.*||g' \
    | tr '"' '.' \
    | tr '"' '.' \
    | tr " " "\n" \
    | tr "," "\n" \
    | tr "." "\n" \
    | tr "'" "\n" \
    | tr '[:upper:]' '[:lower:]'
