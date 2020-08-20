#!/bin/bash

for d in Event*; do
    (cd $d && xh_shorthead z.xh | awk '{print $8,$9,$3,$4}' > coords.txt)
done
