#!/bin/bash

module load mit/matlab

# List of network values
networks=(
  'events_parcels-original_contrast-both'
  'events_parcels-flipped_contrast-both'
  'events_parcels-original_contrast-pic'
  'events_parcels-flipped_contrast-pic'
  'events_parcels-original_contrast-sent'
  'events_parcels-flipped_contrast-sent'
  'events_parcels-LATL-inferior-pole'
  'events_parcels-RATL-inferior-pole'
  'events_parcels-LATL-inferior-pole-mid'
  'events_parcels-RATL-inferior-pole-mid'
)

# Iterate over each network and main_task_index
for network in "${networks[@]}"; do
  for main_task_index in {1..6}; do
    echo "Running mROI_mega_all('$network', $main_task_index)..."
    matlab -nodisplay -nosplash -r "try, mROI_mega_all('$network', $main_task_index); catch ME, disp(getReport(ME)); end; exit;"
  done
done
