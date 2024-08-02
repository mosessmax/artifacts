#!/bin/bash



#destination folder
DEST_FOLDER="all"

# create the destination folder if it doesn't exist
mkdir -p "$DEST_FOLDER"

# find and copy
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.svg" \) -exec cp -v {} "$DEST_FOLDER" \;

FILE_COUNT=$(find "$DEST_FOLDER" -type f | wc -l)

echo "exported $FILE_COUNT image files to the '$DEST_FOLDER' directory."
