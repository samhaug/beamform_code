#!/bin/bash
# bash one-liner to make sure z_comp, n_comp, and e_comp have the same number of entries

for d in *; do echo $d; (cd $d && ls z*/ | wc -l); (cd $d && ls e*/ | wc -l); (cd $d && ls e*/ | wc -l); done
