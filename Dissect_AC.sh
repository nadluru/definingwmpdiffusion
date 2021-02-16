#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/ACTract
filterdir=$subjdir/ACFilterRegions
finaltract=$tractdir/AC_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the anterior commissure (AC)
leftamyg=$filterdir/HarvardOxford-sub_Left-Amygdala_dil3.nii.gz
rightamyg=$filterdir/HarvardOxford-sub_Right-Amygdala_dil3.nii.gz
occipital_ep=$filterdir/MNI_Occipital-Lobe_EP.nii.gz
axialfilter=$filterdir/AxialSlabFilter_dil2.nii.gz

cat $tractfile | procstreamlines -waypointfile $leftamyg | procstreamlines -waypointfile $rightamyg | procstreamlines -endpointfile $occipital_ep | procstreamlines -exclusionfile $axialfilter -maxtractlength 200 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force