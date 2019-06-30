#!/bin/bash
set -e

#==================================#
# Compile jsonnet templates
# 2019
#==================================#

print_usage() {
 echo "usage: $1"
 echo ""
 echo "Compile"
}

FILES=($(find . -type f -name "*.jsonnet" | grep -v "^./lib"))
rm -f compiled/*.json

for f in "${FILES[@]}"; do
    BASE=$(echo $f | awk -F "/" '{print $NF}' | cut -f 1 -d '.')
    DIR=$(echo $f | awk -F "/" '{print $2}')
    jsonnet -J lib "$DIR/$BASE.jsonnet" >> "compiled/$BASE.json"
done