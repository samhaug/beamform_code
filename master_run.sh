#!/bin/bash

~/src/beamform_code/normalize_beam_on_P_filter.sh
wait
~/src/beamform_code/measure_P_energy_filter.sh
wait
~/src/beamform_code/find_beammax_filter.sh
wait
~/src/beamform_code/remove_maxima_along_baz_filter.sh 10 60
wait
#~/src/beamform_code/measure_scatter_energy_filter.sh
