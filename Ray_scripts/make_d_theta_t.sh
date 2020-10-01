#!/bin/bash
taup_time -mod prem -h 0 -ph P < input_D_p_t \
     | grep -E '[+-]?([0-9]*[.])?[0-9]+' | awk '{print $1,$7,$4}' > Table_D_theta_t
