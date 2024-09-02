cropSize="640:ih:480:0" # Adjust area and dimensions of interest

ffplay \
   -i "$1" \
   -vf \
      "
         crop=$cropSize,
         split [original1][original2];
         [original1] drawgrid=w=16:h=16:t=2:c=red [output1];
         [original2] drawgrid=w=16:h=16:t=10:c=red [output2];
         [output1][output2] hstack=inputs=2
      "