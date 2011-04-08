#!/bin/sh  
  
IMAGES=$@  
  
RADIUS='1'  
SIGMA='0.0'  
FILTER=Catrom  
  
  
for image in $IMAGES  
do  
    convert $image -sharpen ${RADIUS}x${SIGMA} -filter ${FILTER} -resize 50% `basename -s @2x.png $image`.png  
done  
