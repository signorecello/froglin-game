#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"

# Loop through all directories at the same level as the script
find . -maxdepth 1 -type d ! -name '.' | while read dir; do
    cd "$dir"
    nargo compile
    cd ..
done
