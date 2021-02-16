#!/bin/bash

export subj=$1
export dim=$2
export coord=$3
export axis=$4
export size=$(echo $(fslval $subj/mask-brain.nii.gz $dim)-1 | bc)

parallel 'slice=$subj/mask-brain-slices/mask-brain-slices-${coord}{}.nii.gz;padded=$subj/mask-brain-slices-padded/mask-brain-slices-${coord}{}-padded.nii.gz;
mrpad $slice $padded -axis $axis {} $(echo $size-{}|bc);
mrconvert $padded $padded -strides -1,2,3 -force' ::: $(seq -w 0 0$size)