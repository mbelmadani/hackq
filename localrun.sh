#!/bin/bash
set -eu

ls image.*raw* \
    | cut -d"." -f2 \
    | xargs -I@ bash -c "UUID=@ ./fetch_answers.sh"
