#!/bin/bash

trim()
{
    local trimmed="$1"
    # Strip leading space.
    trimmed="${trimmed## }"
    # Strip trailing space.
    trimmed="${trimmed%% }"

    echo "$trimmed"
}

export -f trim
