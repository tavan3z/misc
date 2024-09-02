cropSize="640:ih:480:0" # Adjust area and dimensions of interest

ffplay \
   -flags2 +export_mvs \
   -i "$1" \
   -vf \
      "
         codecview=mv=pf+bf+bb,
         crop=$cropSize
      "
