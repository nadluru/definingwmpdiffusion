#!/bin/bash

tractfile=$1
subjdir=$2
tractnamesuffix=$3

fa=$subjdir/fa.nii.gz
tractdir=$subjdir/PCTract
filterdir=$subjdir/PCFilterRegions
finaltract=$tractdir/PC_$tractnamesuffix
mkdir -p $tractdir

# filter regions for the posterior commissure
left_thalamus=$filterdir/HarvardOxford-sub_Left-Thalamus_dil3.nii.gz
right_thalamus=$filterdir/HarvardOxford-sub_Right-Thalamus_dil3.nii.gz
brain_stem=$filterdir/HarvardOxford-sub_Brain-Stem_dil1.nii.gz
occipital_pole_ep=$filterdir/HarvardOxford-cort_Occipital-Pole_EP.nii.gz

cat $tractfile | procstreamlines -waypointfile $left_thalamus | procstreamlines -waypointfile $right_thalamus | procstreamlines -waypointfile $brain_stem | procstreamlines -endpointfile $occipital_pole_ep -maxtractlength 250 -discardloops > $finaltract.Bfloat

# converting to other formats for visualization.
camino_to_trackvis -i $finaltract.Bfloat -o $finaltract.trk --nifti $fa --phys-coords

cat $finaltract.Bfloat | vtkstreamlines > $finaltract.vtk
tckconvert $finaltract.vtk $finaltract.tck -force