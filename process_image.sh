#!/bin/bash
set -eu

THRESHOLD=60
REGION=900x500+200+300
OUTPUT=$PARSEDTEXT
# Crop image
convert image.$uuid.raw.png -crop $REGION image.$uuid.cropped.png

# Binarize
convert image.$uuid.cropped.png -threshold $THRESHOLD% png:- \
    | tesseract - $OUTPUT -l eng 2> /dev/null

##echo "Saved answers at $OUTPUT"
