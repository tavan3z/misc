cropSize="640:ih:480:0" # Adjust area and dimensions of interest

ffplay \
   -i "$1" \
   -vf \
      "
         crop=$cropSize,
         drawbox=x=10:y=(ih-90):w=80:h=80:color=red@0.7:t=fill, \
         drawbox=x=((iw/2)-40):y=((ih/2)-40):w=80:h=80:color=green@0.7:t=fill
      "
