#!/bin/bash

if [ ! -e dirty_list.txt ]; then
    echo "cannot find dirty_list.txt"
    exit
fi

if [ ! -d dirty ]; then
    mkdir dirty
fi

while read name; do mv data/*${name}* dirty; done < dirty_list.txt
